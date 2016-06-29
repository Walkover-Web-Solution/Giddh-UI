
newLedgerController = ($scope, $rootScope, localStorageService, toastr, modalService, ledgerService, $filter, DAServices, $stateParams, $timeout, $location, $document, permissionService, accountService, Upload, groupService, $uibModal, companyServices) ->

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
  $scope.closePanel = () ->
    $scope.showPanel = false
    console.log $scope.showPanel
  $scope.accountToShow = {}

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
    accUname = $location.path()
    accUname = $scope.accountUnq #accUname.split('/')
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
    data = angular.copy(emailData)
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

  $scope.getLedgerData = () ->
    if _.isUndefined($rootScope.selectedCompany.uniqueName)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.accountUnq
      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    }
    ledgerService.getLedger(unqNamesObj).then($scope.getLedgerDataSuccess, $scope.getLedgerDataFailure)

  $scope.getLedgerDataSuccess = (res) ->
#    $scope.filterLedgers(res.body.ledgers)
    $scope.ledgerData = res.body

  $scope.getLedgerDataFailure = (res) ->
    console.log res

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
    console.log ledger, txn, index
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
    ledgerService.deleteEntry(unqNamesObj).then((res) ->
      $scope.deleteEntrySuccess(ledger, res)
    , $scope.deleteEntryFailure)

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


giddh.webApp.controller 'newLedgerController', newLedgerController