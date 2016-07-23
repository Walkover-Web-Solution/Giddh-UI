
newLedgerController = ($scope, $rootScope, localStorageService, toastr, modalService, ledgerService, $filter, DAServices, $stateParams, $timeout, $location, $document, permissionService, accountService, Upload, groupService, $uibModal, companyServices, $state) ->

  #date time picker code starts here
  $scope.today = new Date()
  d = moment(new Date()).subtract(1, 'month')
  $scope.fromDate = {date: d._d}
  $scope.toDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.format = "dd-MM-yyyy"
  $scope.showPanel = false
  $scope.accountUnq = $stateParams.unqName  
  $scope.accountToShow = {}
  $scope.combineTransaction = true

  $scope.closePanel = () ->
    $scope.showPanel = false

  $scope.ledgerData = {} 
  $scope.newDebitTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: {
      name:''
      uniqueName:''
    }
    amount : 0
    type: 'DEBIT'
  }
  $scope.newCreditTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: {
      name:''
      uniqueName:''
    }
    amount : 0
    type: 'CREDIT'
  }

  $scope.blankLedger = {
      description:null
      entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
#      hasCredit:false
#      hasDebit:false
      invoiceGenerated:false
      isCompoundEntry:false
      tag:null
      transactions:[
        $scope.newDebitTxn
        $scope.newCreditTxn
      ]
      unconfirmedEntry:false
      uniqueName:""
      voucher:{
        name:""
        shortCode:""
      }
      voucherNo:null
    }

  txnModel = (str) ->
    @ledger = {
      date: $filter('date')(new Date(), "dd-MM-yyyy")
      particular: ''
      amount : 0
      type: str
    } 

  $scope.addBlankTxn= (str) ->
    txn = new txnModel(str)
    $scope.blankLedger.transactions.push(txn)

  $scope.saveEntry = (newEntry) ->
    console.log newEntry


  $scope.taxList = []
  $scope.voucherTypeList = [
    {
      name: "Sales"
      shortCode: "sal"
    }
    {
      name: "Purchases"
      shortCode: "pur"
    }
    {
      name: "Receipt"
      shortCode: "rcpt"
    }
    {
      name: "Payment"
      shortCode: "pay"
    }
    {
      name: "Journal"
      shortCode: "jr"
    }
    {
      name: "Contra"
      shortCode: "cntr"
    }
    {
      name: "Debit Note"
      shortCode: "debit note"
    }
    {
      name: "Credit Note"
      shortCode: "credit note"
    }
  ]

  $scope.selectedLedger = {
    description:null
    entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
#    hasCredit:false
#    hasDebit:false
    invoiceGenerated:false
    isCompoundEntry:false
    tag:null
    transactions:[{
      amount:0
      particular:{
        name:""
        uniqueName:""
      }
      type:""
    }]
    unconfirmedEntry:false
    uniqueName:""
    voucher:{
      name:""
      shortCode:""
    }
    voucherNo:null
  }

  $scope.isSelectedAccount = () ->
    if _.isUndefined($rootScope.selectedAccount.name)
      $rootScope.selectedAccount = localStorageService.get('_selectedAccount')
      $scope.accountToShow = $rootScope.selectedAccount
    else
      $scope.accountToShow = $rootScope.selectedAccount

  $scope.isCurrentAccount =(acnt) ->
    acnt.uniqueName is $scope.accountUnq

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  # upper icon functions starts here
  # generate magic link
  $scope.getMagicLink = () ->
    accUname = $scope.accountUnq
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      accountUniqueName: accUname
      from: $filter('date')($scope.fromDate.date, 'dd-MM-yyyy')
      to: $filter('date')($scope.toDate.date, 'dd-MM-yyyy')
    }
    companyServices.getMagicLink(reqParam).then($scope.getMagicLinkSuccess, $scope.getMagicLinkFailure)

  $scope.getMagicLinkSuccess = (res) ->
    $scope.magicLink = res.body.magicLink
    modalInstance = $uibModal.open(
      template: '<div>
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" ng-click="$dismiss()" aria-label="Close"><span
        aria-hidden="true">&times;</span></button>
          <h3 class="modal-title">Magic Link</h3>
          </div>
          <div class="modal-body">
            <input id="magicLink" class="form-control" type="text" ng-model="magicLink">
          </div>
          <div class="modal-footer">
            <button class="btn btn-default" ngclipboard data-clipboard-target="#magicLink">Copy</button>
          </div>
      </div>'
      size: "md"
      backdrop: 'static'
      scope: $scope
    )

  $scope.getMagicLinkFailure = (res) ->
    toastr.error(res.data.message)

  # ledger send email
  $scope.sendLedgEmail = (emailData) ->
    data = emailData
    if _.isNull($scope.toDate.date) || _.isNull($scope.fromDate.date)
      toastr.error("Date should be in proper format", "Error")
      return false
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.accountUnq
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
    }
    sendData = {
      recipients: []
    }
    data = data.replace(RegExp(' ', 'g'), '')
    cdata = data.split(',')
    _.each(cdata, (str) ->
      if $rootScope.validateEmail(str)
        sendData.recipients.push(str)
      else
        toastr.warning("Enter valid Email ID", "Warning")
        data = ''
        sendData.recipients = []
        return false
    )
    if sendData.recipients < 1
      if $rootScope.validateEmail(data)
        sendData.recipients.push(data)
      else
        toastr.warning("Enter valid Email ID", "Warning")
        return false

    accountService.emailLedger(unqNamesObj, sendData).then($scope.emailLedgerSuccess, $scope.emailLedgerFailure)

  $scope.emailLedgerSuccess = (res) ->
    toastr.success(res.body, res.status)
    $scope.ledgerEmailData = {}

  $scope.emailLedgerFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  # upper icon functions ends here

  $scope.getAccountDetail = (accountUniqueName) ->
    unqObj = {
      compUname : $rootScope.selectedCompany.uniqueName
      acntUname : accountUniqueName
    }
    accountService.get(unqObj)
    .then(
      (res)->
        $scope.getAccountDetailSuccess(res)
    ,(error)->
      $scope.getAccountDetailFailure(error)
    )

  $scope.getAccountDetailFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getAccountDetailSuccess = (res) ->
    if res.body.yodleeAdded == true
      #get bank transaction here
      $scope.getBankTransactions(res.body.uniqueName)

  $scope.getBankTransactions = (accountUniqueName) ->
    unqObj = {
      compUname : $rootScope.selectedCompany.uniqueName
      acntUname : accountUniqueName
    }
    # get other ledger transactions
    ledgerService.getOtherTransactions(unqObj)
    .then(
      (res)->
        $scope.getBankTransactionsSuccess(res)
    ,(error)->
      $scope.getBankTransactionsFailure(error)
    )

  $scope.getBankTransactionsFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getBankTransactionsSuccess = (res) ->
    angular.copy([], $scope.eLedgerDrData)
    angular.copy([], $scope.eLedgerCrData)

    if res.body.length > 0
      $scope.eLedgerDataFound = true
    else
      $scope.eLedgerDataFound = false


  $scope.calculateELedger = () ->
    $scope.eLedgType = undefined
    $scope.eCrBalAmnt = 0
    $scope.eDrBalAmnt = 0
    $scope.eDrTotal = 0
    $scope.eCrTotal = 0
    crt = 0
    drt = 0
    _.each($scope.eLedgerDrData, (entry) ->
      drt += Number(entry.transactions[0].amount)
    )
    _.each($scope.eLedgerCrData, (entry) ->
      crt += Number(entry.transactions[0].amount)
    )
    crt = parseFloat(crt)
    drt = parseFloat(drt)

    if drt > crt
      $scope.eLedgType = 'DEBIT'
      $scope.eCrBalAmnt = drt - crt
      $scope.eDrTotal = drt
      $scope.eCrTotal = crt + (drt - crt)
    else if crt > drt
      $scope.eLedgType = 'CREDIT'
      $scope.eDrBalAmnt = crt - drt
      $scope.eDrTotal = drt + (crt - drt)
      $scope.eCrTotal = crt
    else
      $scope.eCrTotal = crt
      $scope.eDrTotal = drt

  $scope.getLedgerData = () ->
    if _.isUndefined($rootScope.selectedCompany.uniqueName)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    $scope.getAccountDetail($scope.accountUnq)
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.accountUnq
      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    }
    if not _.isEmpty($scope.accountUnq)
      ledgerService.getLedger(unqNamesObj).then($scope.getLedgerDataSuccess, $scope.getLedgerDataFailure)

  $scope.getLedgerDataSuccess = (res) ->
    #$scope.filterLedgers(res.body.ledgers)
    $scope.ledgerData = res.body

  $scope.getLedgerDataFailure = (res) ->
    toastr.error(res.data.message)

  $scope.filterLedgers = (ledgers) ->
    _.each ledgers, (lgr) ->
      lgr.hasDebit = false
      lgr.hasCredit = false
      if lgr.transactions.length > 0
        _.each lgr.transactions, (txn) ->
          if txn.type == 'DEBIT'
            lgr.hasDebit = true
          else if txn.type == 'CREDIT'
            lgr.hasCredit = true

  # get tax list

  $scope.getTaxList = () ->
    $scope.taxList = []
    if $rootScope.canUpdate and $rootScope.canDelete
      companyServices.getTax($rootScope.selectedCompany.uniqueName).then($scope.getTaxListSuccess, $scope.getTaxListFailure)

  $scope.getTaxListSuccess = (res) ->
    _.each res.body, (tax) ->
      tax.isSelected = false
      if tax.account == null
        tax.account = {}
        tax.account.uniqueName = 0
      $scope.taxList.push(tax)


  $scope.getTaxListFailure = (res) ->
    toastr.error(res.data.message, res.status)

  $scope.addTaxEntry = (tax, item) ->
    if tax.isSelected
      $scope.selectedTaxes.push(tax)
    else
      $scope.selectedTaxes = _.without($scope.selectedTaxes, tax)
#    item.sharedData.taxes = $scope.selectedTaxes

  $scope.isSelectedAccount()
  $scope.getLedgerData()

  $timeout ( ->
    $scope.getTaxList()
  ), 3000

  $scope.flatAccListC5 = {
      page: 1
      count: 5
      totalPages: 0
      currentPage : 1
    }

  $scope.selectTxn = (ledger, txn, index) ->
    $scope.showPanel = true
    $scope.selectedLedger = ledger
    if ledger.uniqueName != '' || ledger.uniqueName != undefined || ledger.uniqueName != null
      $scope.checkCompEntry(ledger)

  $scope.checkCompEntry = (ledger) ->
    unq = ledger.uniqueName
    ledger.isCompoundEntry = true
    _.each $scope.ledgerData.ledgers, (lgr) ->
      if unq == lgr.uniqueName
        lgr.isCompoundEntry = true
      else
        lgr.isCompoundEntry = false

  $scope.saveUpdateLedger = (ledger) ->
    delete ledger.isCompoundEntry
    if _.isEmpty(ledger.uniqueName)
      console.log("creating new entry")
      unqNamesObj = {
        compUname: $rootScope.selectedCompany.uniqueName
        acntUname: $scope.accountUnq
      }
      delete ledger.uniqueName
      delete ledger.voucherNo
      transactionsArray = []
      _.every(ledger.transactions,(led) ->
        delete led.date
        delete led.parentGroups
      )
      transactionsArray = _.reject(ledger.transactions, (led) ->
           led.particular.uniqueName == ""
      )
      ledger.transactions = transactionsArray
      ledger.voucherType = ledger.voucher.shortCode

      ledgerService.createEntry(unqNamesObj, ledger).then($scope.addEntrySuccess, $scope.addEntryFailure)
    else
      console.log("updating entry")
      unqNamesObj = {
        compUname: $rootScope.selectedCompany.uniqueName
        acntUname: $scope.accountUnq
        entUname: ledger.uniqueName
      }
      transactionsArray = []
      _.every($scope.blankLedger.transactions,(led) ->
        delete led.date
        delete led.parentGroups
      )
      transactionsArray = _.reject($scope.blankLedger.transactions, (led) ->
        led.particular.uniqueName == ""
      )
      ledger.transactions.push(transactionsArray)
      ledgerService.updateEntry(unqNamesObj, ledger).then($scope.updateEntrySuccess, $scope.updateEntryFailure)


  $scope.resetBlankLedger = () ->
    $scope.blankLedger = {
      description:null
      entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
      invoiceGenerated:false
      isCompoundEntry:false
      tag:null
      transactions:[
        $scope.newDebitTxn = {
          date: $filter('date')(new Date(), "dd-MM-yyyy")
          particular: {
            name:""
            uniqueName:""
          }
          amount : 0
          type: 'DEBIT'
        }
        $scope.newCreditTxn = {
          date: $filter('date')(new Date(), "dd-MM-yyyy")
          particular: {
            name:""
            uniqueName:""
          }
          amount : 0
          type: 'CREDIT'
        }
      ]
      unconfirmedEntry:false
      uniqueName:""
      voucher:{
        name:""
        shortCode:""
      }
      voucherNo:null
    }

  $scope.addEntrySuccess = (res) ->
    toastr.success("Entry created successfully", "Success")
    addThisLedger = {}
    _.extend(addThisLedger,$scope.selectedLedger)
    $scope.ledgerData.ledgers.push(addThisLedger)
    $scope.getLedgerData()
    $scope.resetBlankLedger()
    $scope.selectedLedger = $scope.blankLedger

  $scope.addEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
    $scope.resetBlankLedger()
    $scope.selectedLedger = $scope.blankLedger

  $scope.updateEntrySuccess = (res) ->
    toastr.success("Entry updated successfully", "Success")
    addThisLedger = {}
    _.extend(addThisLedger,$scope.blankLedger)
    $scope.ledgerData.ledgers.push(addThisLedger)
    $scope.getLedgerData()
    $scope.resetBlankLedger()

  $scope.updateEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.deleteEntry = (ledger) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.accountUnq
      entUname: ledger.uniqueName
    }
    if unqNamesObj.acntUname != '' || unqNamesObj.acntUname != undefined
      ledgerService.deleteEntry(unqNamesObj).then((res) ->
        $scope.deleteEntrySuccess(ledger, res)
        $scope.deleteEntryFailure
      )

  $scope.deleteEntrySuccess = (item, res) ->
    toastr.success("Entry deleted successfully","Success")
    withoutLedger  = _.without($scope.ledgerData,item)
    $scope.ledgerData = withoutLedger
    $scope.resetBlankLedger()
    $scope.selectedLedger = $scope.blankLedger
    $scope.getLedgerData()
#    $scope.calculateLedger($scope.ledgerData, "deleted")

  $scope.deleteEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  # select multiple transactions, from same or different entries
  $scope.allSelected = []  
  $scope.selectMultiple = (ledger, txn, index) ->
    cTxn = {}
    if txn.isSelected == true
      cTxn.unq = ledger.uniqueName
      cTxn.index = index
      cTxn.txn = txn 
      $scope.allSelected.push(cTxn)

  $scope.deleteMultipleTransactions = () ->
    if $scope.allSelected.length > 0
      _.each $scope.ledgerData.ledgers, (ledger) ->
        _.each $scope.allSelected, (t) ->
          if ledger.uniqueName = t.unq
            ledger.transactions.splice(t.index, 1)
    $scope.allSelected = []

  $scope.redirectToState = (state) ->
    $state.go(state)

  $rootScope.$on 'company-changed', (event,changeData) ->
    # when company is changed, redirect to manage company page
    if changeData.type == 'CHANGE'
      $scope.redirectToState('company.content.manage')

giddh.webApp.controller 'newLedgerController', newLedgerController