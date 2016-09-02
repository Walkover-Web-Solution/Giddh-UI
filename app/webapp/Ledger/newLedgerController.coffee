
newLedgerController = ($scope, $rootScope, $window,localStorageService, toastr, modalService, ledgerService,FileSaver , $filter, DAServices, $stateParams, $timeout, $location, $document, permissionService, accountService, Upload, groupService, $uibModal, companyServices, $state) ->
  if _.isUndefined($rootScope.selectedCompany)
    $rootScope.selectedCompany = localStorageService.get('_selectedCompany')
  $scope.pageLoader = false
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
  $scope.mergeTransaction = false
  $scope.showEledger = true
  $scope.pageAccount = {}
  $scope.showLoader = true
  $scope.showExportOption = false
  $scope.showLedgerPopover = false
  $scope.adjustHeight = 0
  $scope.dLedgerLimit = 10
  $scope.cLedgerLimit = 10
  $scope.popover = {
    templateUrl: 'panel'
    draggable: false
  }
  $scope.newAccountModel = {
    group : ''
    account: ''
    accUnqName: ''
  }


  $scope.hideEledger = () ->
    $scope.showEledger = !$scope.showEledger 

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
      isBlankLedger : true
      description:null
      entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
#      hasCredit:false
#      hasDebit:false
      invoiceGenerated:false
      isCompoundEntry:false
      applyApplicableTaxes:false
      tag:null
      transactions:[
        $scope.newDebitTxn
        $scope.newCreditTxn
      ]
      unconfirmedEntry:false
      isInclusiveTax: false
      uniqueName:""
      voucher:{
        name:"Sales"
        shortCode:"sal"
      }
      tax:[]
      voucherNo:null
    }

  blankLedgerModel = () ->
    @blankLedger = {
      isBlankLedger : true
      description:''
      entryDate:''
      invoiceGenerated:false
      isCompoundEntry:false
      applyApplicableTaxes: false
      tag:''
      transactions:[]
      unconfirmedEntry:false
      uniqueName:""
      isInclusiveTax: false
      voucher:{
        name:"Sales"
        shortCode:"sal"
      }
      tax: []
      voucherNo:''
    }

  txnModel = (str) ->
    @ledger = {
      date: $filter('date')(new Date(), "dd-MM-yyyy")
      particular: {
        name:""
        uniqueName:""
      }
      amount : 0
      type: str
    } 

  $scope.addBlankTxn= (str, ledger) ->
    txn = new txnModel(str)
#    if ledger.uniqueName != ""
    $scope.hasBlankTxn = false
    $scope.checkForExistingblankTransaction(ledger, str)
    if !$scope.hasBlankTxn
      ledger.transactions.push(txn)
    $scope.setFocusToBlankTxn(ledger, txn, str)
    $scope.blankCheckCompEntry(ledger)
  
  $scope.setFocusToBlankTxn = (ledger, transaction, str) ->
    _.each ledger.transactions, (txn) ->
      if txn.amount == 0 && txn.particular.name == "" && txn.particular.uniqueName == "" && txn.type == str
        txn.isblankOpen = true
        $scope.openClosePopOver(txn, ledger)

  $scope.getFocus = (txn, ledger) ->
    if txn.particular.name == "" && txn.particular.uniqueName == "" && txn.amount == 0
      txn.isOpen = true
      $scope.openClosePopOver(txn,ledger)

  $scope.checkForExistingblankTransaction = (ledger, str) ->
    _.each ledger.transactions, (txn) ->
      if txn.particular.uniqueName == '' && txn.amount == 0 && txn.type == str
        $scope.hasBlankTxn = true

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
    isInclusiveTax: false
    uniqueName:""
    voucher:{
      name:"Sales"
      shortCode:"sal"
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
  $scope.sendLedgEmail = (emailData, emailType) ->
    data = emailData
    if _.isNull($scope.toDate.date) || _.isNull($scope.fromDate.date)
      toastr.error("Date should be in proper format", "Error")
      return false
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.accountUnq
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
      format: emailType
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
    #$scope.ledgerEmailData.email = ''
    $scope.ledgerEmailData = {}

  $scope.emailLedgerFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #export ledger
  $scope.exportLedger = (type)->
    $scope.showExportOption = false
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.accountUnq
      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
      lType:type
    }
    accountService.exportLedger(unqNamesObj).then($scope.exportLedgerSuccess, $scope.exportLedgerFailure)

  $scope.exportLedgerSuccess = (res)->
    $scope.isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0
    console.log $scope.isSafari
    if $scope.msieBrowser()
      $scope.openWindow(res.body.filePath)
    else if $scope.isSafari       
      modalInstance = $uibModal.open(
        template: '<div>
            <div class="modal-header">
              <h3 class="modal-title">Download File</h3>
            </div>
            <div class="modal-body">
              <p class="mrB">To download your file Click on button</p>
              <button onClick="window.open(\''+res.body.filePath+'\')" class="btn btn-primary">Download</button>
            </div>
            <div class="modal-footer">
              <button class="btn btn-default" ng-click="$dismiss()">Cancel</button>
            </div>
        </div>'
        size: "sm"
        backdrop: 'static'
        scope: $scope
      )
    else
      window.open(res.body.filePath)

  $scope.exportLedgerFailure = (res)->
    toastr.error(res.data.message, res.data.status)


  # upper icon functions ends here

  $scope.getAccountDetail = (accountUniqueName) ->
    if not _.isUndefined(accountUniqueName) && not _.isEmpty(accountUniqueName) && not _.isNull(accountUniqueName)
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
    if res.body.yodleeAdded == true && $rootScope.canUpdate
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
    $scope.eLedgerData = $scope.formatBankLedgers(res.body)
    $scope.calculateELedger()
    #$scope.removeUpdatedBankLedger()

  $scope.calculateELedger = () ->
    $scope.eLedgType = undefined
    $scope.eCrBalAmnt = 0
    $scope.eDrBalAmnt = 0
    $scope.eDrTotal = 0
    $scope.eCrTotal = 0
    crt = 0
    drt = 0
    _.each($scope.eLedgerData, (ledger) ->
      _.each(ledger.transactions, (transaction) ->
        if transaction.type == 'DEBIT'
          drt += Number(transaction.amount)
        else if transaction.type == 'CREDIT'
          crt += Number(transaction.amount)
      )
    )
    crt = parseFloat(crt)
    drt = parseFloat(drt)
    $scope.eCrTotal = crt
    $scope.eDrTotal = drt


  $scope.formatBankLedgers = (bankArray) ->
    formattedBankLedgers = []
    if bankArray.length > 0
      _.each bankArray, (bank) ->
        ledger = new blankLedgerModel()
        ledger.entryDate = bank.date
        ledger.isBankTransaction = true
        ledger.transactionId = bank.transactionId
        ledger.transactions = $scope.formatBankTransactions(bank.transactions, bank, ledger)
        ledger.description = bank.description
        formattedBankLedgers.push(ledger)
    formattedBankLedgers

  $scope.formatBankTransactions = (transactions, bank, ledger, type) ->
    formattedBanktxns = []
    if transactions.length > 0
      _.each transactions, (txn) ->
        bank.description = txn.remarks.description
        newTxn = new txnModel()
        newTxn.particular = {}
        newTxn.particular.name = ''
        newTxn.particular.uniqueName = ''
        newTxn.amount = txn.amount
        newTxn.type = txn.type
        if txn.type == 'DEBIT'
          ledger.voucher.name = "Receipt"
          ledger.voucher.shortCode = "rcpt"
        else 
          ledger.voucher.name = "Payment"
          ledger.voucher.shortCode = "pay"
        formattedBanktxns.push(newTxn)
    formattedBanktxns

  $scope.mergeBankTransactions = (toMerge) ->
    if toMerge
      $scope.mergeTransaction = true
      $scope.ledgerData.ledgers.push($scope.eLedgerData)
      $scope.ledgerData.ledgers = $scope.sortTransactions(_.flatten($scope.ledgerData.ledgers), 'entryDate')
      $scope.showEledger = false
    else
    #   $scope.AddBankTransactions()
    #   $scope.showEledger = false
    # else
      $scope.mergeTransaction = false
      $scope.removeBankTransactions()
    #   $scope.showEledger = true

  # $scope.AddBankTransactions = () ->
  #   bankTxnDuplicate = $scope.eLedgerData
  #   bankTxntoMerge = $scope.fromBanktoLedgerObject(bankTxnDuplicate)
  #   $scope.ledgerData.ledgers.push(bankTxntoMerge)
  #   $scope.ledgerData.ledgers = _.flatten($scope.ledgerData.ledgers)

  $scope.sortTransactions = (ledger, sortType) ->
    ledger = _.sortBy(ledger, sortType)
    ledger

  $scope.removeBankTransactions = () ->
    withoutBankTxn = []
    _.each $scope.ledgerData.ledgers, (ledger) ->
      if ledger.isBankTransaction == undefined
        withoutBankTxn.push(ledger)
    $scope.ledgerData.ledgers = withoutBankTxn
    $scope.showEledger = true

  # $scope.fromBanktoLedgerObject = (bankArray) ->
  #   bank2LedgerArray = []
  #   _.each bankArray, (txn) ->
  #     led = {}
  #     led.entryDate = txn.date
  #     led.transactions = txn.transactions
  #     led.isBankTransaction = true
  #     $scope.renameBankTxnKeys(led.transactions)
  #     bank2LedgerArray.push(led)
  #   bank2LedgerArray

  # $scope.renameBankTxnKeys = (txnArray) ->
  #   _.each txnArray, (txn) ->
  #     txn.particular = txn.remarks

  $scope.getLedgerData = (showLoaderCondition) ->
    $scope.showLoader = showLoaderCondition || true
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
    $scope.paginateledgerData(res.body.ledgers)
    $scope.ledgerData = res.body
    $scope.countTotalTransactions()
    $scope.sortTransactions($scope.ledgerData, 'entryDate')
    $scope.showLoader = false
    $scope.pageLoader = false

  $scope.getLedgerDataFailure = (res) ->
    toastr.error(res.data.message)
    $scope.showLoader = false
    $scope.pageLoader = false

  $scope.updateLedgerData = (condition, ledger) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.accountUnq
      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    }
    if not _.isEmpty($scope.accountUnq)
      ledgerService.getLedger(unqNamesObj).then(
        (res) -> $scope.updateLedgerDataSuccess(res, condition, ledger)
        (res) -> $scope.updateLedgerDataFailure
      )

  $scope.updateLedgerDataSuccess = (res,condition, ledger) ->
    $scope.setEntryTotal(ledger, res.body, condition)
    $scope.ledgerData.balance.amount = res.body.balance.amount
    $scope.ledgerData.balance.type = res.body.balance.type
    $scope.ledgerData.creditTotal = res.body.creditTotal
    $scope.ledgerData.debitTotal = res.body.debitTotal
    $scope.ledgerData.forwardedBalance.amount = res.body.forwardedBalance.amount
    $scope.ledgerData.forwardedBalance.type = res.body.forwardedBalance.type
    $scope.updateTotalTransactions()
    #$scope.paginateledgerData(res.body.ledgers)

  $scope.updateLedgerDataFailure = (res) ->
    toastr.error(res.data.message)

  $scope.paginateledgerData = (ledgers) ->
    $scope.ledgerCount = 20
    # $scope.dLedgerLimit = $scope.setCounter(ledgers, 'DEBIT')
    # $scope.cLedgerLimit = $scope.setCounter(ledgers, 'CREDIT')
    $scope.dLedgerLimit = 50
    $scope.cLedgerLimit = 50


  $scope.setCounter = (ledgers, type) ->
    txns = 0
    ledgerCount = 0  
    _.each ledgers, (led) ->
      l = 0
      #count transactions in ledger
      _.each led.transactions, (txn) ->
        if txn.type == type
          l += 1 
      if txns <= $scope.ledgerCount
        txns += l
        ledgerCount += 1
    # if ledgerCount < txns
    #   ledgerCount = txns
    if ledgerCount < 20
      ledgerCount = $scope.ledgerCount
    ledgerCount

  $scope.countTotalTransactionsAfterSomeTime = () ->
    $timeout ( ->
      $scope.countTotalTransactions()
    ), 500

  $scope.onScrollDebit = (sTop, sHeight, e) ->
    if sTop >= sHeight-100
      $scope.dLedgerLimit += 15
      # $scope.dSpliceIdx += 2
      # $scope.spliceLedger('DEBIT')
    # else if sTop == 0 && $scope.dLedgerLimit > 20
    #   $scope.dLedgerLimit -= 20

  $scope.onScrollCredit = (sTop, sHeight, e) ->
    if sTop >= sHeight-100
      $scope.cLedgerLimit += 15
      # $scope.cSpliceIdx += 2
      # $scope.spliceLedger('DEBIT')
    # else if sTop == 0 && $scope.dLedgerLimit > 20
    #   $scope.cLedgerLimit -= 20


  $scope.creditTotal = 0
  $scope.debitTotal = 0
  $scope.countTotalTransactions = () ->
    $scope.creditTotal = 0
    $scope.debitTotal = 0
    $scope.dTxnCount = 0
    $scope.cTxnCount = 0
    if $scope.ledgerData.ledgers.length > 0
      _.each $scope.ledgerData.ledgers, (ledger) ->
        if ledger.transactions.length > 0
          _.each ledger.transactions, (txn) ->
            txn.isOpen = false
            if txn.type == 'DEBIT'
              $scope.dTxnCount += 1
              $scope.debitTotal += Number(txn.amount)
            else
              $scope.cTxnCount += 1
              $scope.creditTotal += Number(txn.amount)

  $scope.updateTotalTransactions = () ->
    $timeout ( ->
      $scope.countTotalTransactions()
    ), 500

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
    $scope.showLoader = true
    $scope.pageLoader = true
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
    $scope.matchTaxAccounts($scope.taxList)
    $scope.pageLoader = false
    $scope.showLoader = false

  $scope.getTaxListFailure = (res) ->
    toastr.error(res.data.message, res.status)
    $scope.pageLoader = false
    $scope.showLoader = false

  $scope.matchTaxAccounts = (taxlist) ->
    _.each taxlist, (tax) ->
      

  $scope.addTaxEntry = (tax, item) ->
    if tax.isSelected
      $scope.selectedTaxes.push(tax)
    else
      $scope.selectedTaxes = _.without($scope.selectedTaxes, tax)
#    item.sharedData.taxes = $scope.selectedTaxes

  $scope.isSelectedAccount()
  $scope.getLedgerData(true)

  $timeout ( ->
    $scope.getTaxList()
  ), 2000

  $scope.flatAccListC5 = {
      page: 1
      count: 5
      totalPages: 0
      currentPage : 1
    }

  $scope.exportOptions = () ->
    $scope.showExportOption = !$scope.showExportOption

  $scope.calculateEntryTotal = (ledger) ->
    ledger.entryTotal = {}
    ledger.entryTotal.amount = 0
    if ledger.transactions.length > 1
      _.each ledger.transactions, (txn) ->
        if txn.type == 'DEBIT'
          ledger.entryTotal.amount += Number(txn.amount)
        else
          ledger.entryTotal.amount -= Number(txn.amount)
    else
      ledger.entryTotal.amount = Number(ledger.transactions[0]['amount'])
    if ledger.entryTotal.amount > 0
      ledger.entryTotal.type = 'Dr'
    else
      ledger.entryTotal.amount = Number(ledger.entryTotal.amount) * -1
      ledger.entryTotal.type = 'Cr'


  $scope.selectTxn = (ledger, txn, index ,e) ->
    $scope.selectedTxn = txn
    $scope.calculateEntryTotal(ledger)
    $scope.showLedgerPopover = true
    $scope.ledgerBeforeEdit = {}
    angular.copy(ledger,$scope.ledgerBeforeEdit)
    if $scope.popover.draggable
      $scope.showPanel = true
    else
      $scope.openClosePopOver(txn, ledger)
    if ledger.isBankTransaction != undefined
      _.each(ledger.transactions,(transaction) ->
        if transaction.type == 'DEBIT'
          ledger.voucher.shortCode = "rcpt"
        else if transaction.type == 'CREDIT'
          ledger.voucher.shortCode = "pay"
      )
    $scope.selectedLedger = ledger
    $scope.selectedLedger.index = index
    #if ledger.uniqueName != '' || ledger.uniqueName != undefined || ledger.uniqueName != null
    $scope.checkCompEntry(ledger)
    $scope.blankCheckCompEntry(ledger)
    $scope.isTransactionContainsTax(ledger)
    e.stopPropagation() 

  $scope.$watch('selectedTxn.amount', (newVal, oldVal) ->
    if newVal != oldVal
      $scope.calculateEntryTotal($scope.selectedLedger)
  )

  $scope.setEntryTotal = (pre,post, condition) ->
    if condition != 'delete'
      _.each post.ledgers, (led) ->
        if pre.uniqueName == led.uniqueName
          pre.total = led.total
          if condition == 'update'
            $scope.updatedLedgerTotal = led.total

  $scope.openClosePopoverForLedger = (txn, ledger) ->
    _.each $scope.ledgerData.ledgers, (iledger) ->
      _.each iledger.transactions, (itxn) ->
        itxn.isOpen = false
    txn.isOpen = true

  $scope.openClosePopoverForeLedger = (txn, ledger) ->
    _.each $scope.eLedgerData, (iledger) ->
      _.each iledger.transactions, (itxn) ->
        itxn.isOpen = false
    txn.isOpen = true

  $scope.openClosePopoverForBlankLedger = (txn, ledger) ->
    _.each $scope.blankLedger.transactions, (itxn) ->
      itxn.isOpen = false
    txn.isOpen = true

  $scope.openClosePopOver = (txn, ledger) ->
    $scope.openClosePopoverForLedger(txn, ledger)
    $scope.openClosePopoverForBlankLedger(txn, ledger)
    $scope.openClosePopoverForeLedger(txn, ledger)

  $scope.checkCompEntry = (ledger) ->
    unq = ledger.uniqueName
    ledger.isCompoundEntry = true
    _.each $scope.ledgerData.ledgers, (lgr) ->
      if unq == lgr.uniqueName
        lgr.isCompoundEntry = true
      else
        lgr.isCompoundEntry = false
    if unq == $scope.blankLedger.uniqueName
      $scope.blankLedger.isCompoundEntry = true
    else
      $scope.blankLedger.isCompoundEntry = false

  $scope.blankCheckCompEntry = (ledger) ->
    if ledger.isBlankLedger
      _.each ledger.transactions, (txn) ->
        if txn.particular.uniqueName.length > 0
          ledger.isBlankCompEntry = true
    else
      ledger.isBlankCompEntry = false 
      $scope.blankLedger.isBlankCompEntry = false

  $scope.doingEntry = false
  $scope.lastSelectedLedger = {}
  $scope.saveUpdateLedger = (ledger) ->
    $scope.pageLoader = true
    $scope.showLoader = true
    $scope.lastSelectedLedger = ledger
    $scope.dLedgerLimitBeforeUpdate = $scope.dLedgerLimit
    $scope.cLedgerLimitBeforeUpdate = $scope.cLedgerLimit
    if $scope.doingEntry == true
      return

    $scope.doingEntry = true
    $scope.ledgerTxnChanged = false
    if ledger.isBankTransaction
      $scope.btIndex = ledger.index
    delete ledger.isCompoundEntry
    if !_.isEmpty(ledger.voucher.shortCode) 
      if _.isEmpty(ledger.uniqueName)
        #add new entry
        unqNamesObj = {
          compUname: $rootScope.selectedCompany.uniqueName
          acntUname: $scope.accountUnq
        }
        delete ledger.uniqueName
        delete ledger.voucherNo
        transactionsArray = []
        # _.every(ledgerToSend.transactions,(led) ->
        #   delete led.date
        #   delete led.parentGroups
        #   delete led.particular.parentGroups
        #   delete led.particular.mergedAccounts
        #   delete led.particular.applicableTaxes
        # )
        rejectedTransactions = []
        transactionsArray = _.reject(ledger.transactions, (led) ->
         if led.particular == "" || led.particular.uniqueName == ""
           rejectedTransactions.push(led)
           return led
        )
        ledger.transactions = transactionsArray
        ledger.voucherType = ledger.voucher.shortCode
        $scope.addTaxesToLedger(ledger)
        if ledger.transactions.length > 0
          if ledger.transactions.length > 1
            $scope.matchTaxTransactions(ledger.transactions, $scope.taxList)
            $scope.checkManualTaxTransaction(ledger.transactions, $scope.ledgerBeforeEdit.transactions)
            $scope.checkTaxCondition(ledger)
          ledgerService.createEntry(unqNamesObj, ledger).then(
            (res) -> $scope.addEntrySuccess(res, ledger)
            (res) -> $scope.addEntryFailure(res,rejectedTransactions, ledger))
        else
          $scope.doingEntry = false
          ledger.transactions = rejectedTransactions
          response = {}
          response.data = {}
          response.data.message = "There must be at least a transaction to make an entry."
          response.data.status = "Error"
          $scope.addEntryFailure(response,[])
#          toastr.error("There must be at least a transaction to make an entry.")
      else
        #update entry
        #$scope.removeEmptyTransactions(ledger.transactions)
        _.each ledger.transactions, (txn) ->
          if !_.isEmpty(txn.particular.uniqueName)
            particular = {}
            particular.name = txn.particular.name
            particular.uniqueName = txn.particular.uniqueName
            txn.particular = particular
  #      ledger.isInclusiveTax = false
        unqNamesObj = {
          compUname: $rootScope.selectedCompany.uniqueName
          acntUname: $scope.accountUnq
          entUname: ledger.uniqueName
        }
        # transactionsArray = []
        # _.every($scope.blankLedger.transactions,(led) ->
        #   delete led.date
        #   delete led.parentGroups
        # )
        # _.each(ledger.)
        # transactionsArray = _.reject($scope.blankLedger.transactions, (led) ->
        #   led.particular.uniqueName == ""
        # )
        $scope.addTaxesToLedger(ledger)
#        console.log ledger
        #ledger.transactions.push(transactionsArray)
        ledger.voucher = _.findWhere($scope.voucherTypeList,{'shortCode':ledger.voucher.shortCode})
        ledger.voucherType = ledger.voucher.shortCode
        if ledger.transactions.length > 0
          $scope.matchTaxTransactions(ledger.transactions, $scope.taxList)
          $scope.matchTaxTransactions($scope.ledgerBeforeEdit.transactions, $scope.taxList)
          $scope.checkManualTaxTransaction(ledger.transactions, $scope.ledgerBeforeEdit.transactions)
          updatedTxns = $scope.updateEntryTaxes(ledger.transactions)
          ledger.transactions = updatedTxns
          $scope.checkTaxCondition(ledger)
          isModified = false
          if ledger.taxes.length > 0
            isModified = $scope.checkPrincipleModifications(ledger, $scope.ledgerBeforeEdit.transactions)
          if isModified
            $scope.selectedTxn.isOpen = false
            modalService.openConfirmModal(
              title: 'Update'
              body: 'Principle transaction updated, Would you also like to update tax transactions?',
              ok: 'Yes',
              cancel: 'No'
            ).then(
                (res) -> $scope.UpdateEntry(ledger, unqNamesObj, true),
                (res) -> $scope.UpdateEntry(ledger, unqNamesObj, false)
            )
          else
           ledgerService.updateEntry(unqNamesObj, ledger).then(
             (res) -> $scope.updateEntrySuccess(res, ledger)
             (res) -> $scope.updateEntryFailure(res, ledger)
           )
        else
          $scope.doingEntry = false
          response = {}
          response.data = {}
          response.data.message = "There must be at least a transaction to make an entry."
          response.data.status = "Error"
          $scope.addEntryFailure(response,[])
    else
      toastr.error("Select voucher type.")

  $scope.checkTaxCondition = (ledger) ->
    transactions = []
    _.each ledger.transactions, (txn) ->
      if ledger.isInclusiveTax && !txn.isTax
        transactions.push(txn)
    if ledger.isInclusiveTax
      ledger.transactions = transactions

  $scope.checkPrincipleModifications = (ledger, uTxnList) ->
    withoutTaxesLedgerTxn = $scope.getPrincipleTxnOnly(ledger.transactions)
    withoutTaxesUtxnList = $scope.getPrincipleTxnOnly(uTxnList)
    isModified = false
    if withoutTaxesLedgerTxn.length == withoutTaxesUtxnList.length
      _.each withoutTaxesLedgerTxn, (txn, idx) ->
        _.each withoutTaxesUtxnList, (uTxn, dx) ->
          if idx == dx 
            if txn.particular.uniqueName != uTxn.particular.uniqueName || txn.amount != uTxn.amount
              isModified = true
    else
      isModified = true
    isModified

  $scope.checkManualTaxTransaction = (txnList, uTxnList) ->
    #console.log txnList.length, uTxnList.length
    _.each txnList, (txn) ->
      txn.isManualTax = true
      _.each uTxnList, (uTxn) ->
        if txn.particular.uniqueName == uTxn.particular.uniqueName && txn.isTax
          txn.isManualTax = false
    return 

  $scope.getPrincipleTxnOnly = (txnList) ->
    transactions = []
    _.each txnList, (txn) ->
      if txn.isTax == undefined || !txn.isTax
        transactions.push(txn)
    transactions

  $scope.addTaxesToLedger = (ledger) ->
    ledger.taxes = []
    _.each($scope.taxList, (tax) ->
      if tax.isChecked == true
        ledger.taxes.push(tax.uniqueName)
    )

  $scope.updateEntryTaxes = (txnList) ->
    transactions = []
    if txnList.length > 1
      _.each txnList, (txn, idx) ->
        _.each $scope.taxList, (tax) ->
          if txn.particular.uniqueName == tax.account.uniqueName && !tax.isChecked
            if !txn.isManualTax
              txn.toRemove = true 
              #transactions.push(txn)
              #txnList.splice(idx, 1)
    txnList = _.filter(txnList, (txn)->
      return txn.toRemove == undefined || txn.toRemove == false
    )
    txnList

  $scope.isTransactionContainsTax = (ledger) ->
    if ledger.taxes != undefined && ledger.taxes.length > 0
      _.each($scope.taxList, (tax) ->
        tax.isChecked = false
        _.each(ledger.taxes, (taxe) ->
          if taxe == tax.uniqueName
            tax.isChecked = true
        )
      )
    else
      _.each($scope.taxList, (tax) ->
        tax.isChecked = false
        _.each(ledger.transactions, (txn) ->
          if txn.particular.uniqueName == tax.account.uniqueName
            tax.isChecked = true
        )
      )

  $scope.UpdateEntry = (ledger, unqNamesObj,removeTax) ->
    if removeTax == true
      $scope.txnAfterRmovingTax = []
      $scope.removeTaxTxnOnPrincipleTxnModified(ledger.transactions)
      ledger.transactions = $scope.txnAfterRmovingTax
    if ledger.transactions.length > 0
      ledgerService.updateEntry(unqNamesObj, ledger).then(
        (res) -> $scope.updateEntrySuccess(res, ledger)
        (res) -> $scope.updateEntryFailure(res, ledger)
      )

  $scope.matchTaxTransactions = (txnList, taxList) ->
    _.each txnList, (txn) ->
      _.each taxList, (tax) ->
        if txn.particular.uniqueName == tax.account.uniqueName
          txn.isTax = true

  # $scope.checkIfPrincipleTxnIsModified = (ledger, uTxnList, unqNamesObj) ->
  #   $scope.ledgerTxnChanged = false
  #   txnList = ledger.transactions
  #   if txnList.length <= 1
  #     $scope.UpdateEntry(ledger, unqNamesObj, false)
  #     return
  #   if ledger.transactions.length != uTxnList.length
  #     modalService.openConfirmModal(
  #       title: 'Update'
  #       body: 'Transactions updated, Would you also like to update tax transactions?',
  #       ok: 'Yes',
  #       cancel: 'No'
  #     ).then(
  #       (res) -> $scope.UpdateEntry(ledger, unqNamesObj, true),
  #       (res) -> $scope.UpdateEntry(ledger, unqNamesObj, false)
  #     )
  #   else
  #     openModal = false
  #     _.each txnList, (txn, i) ->
  #       _.each uTxnList, (uTxn, j) ->
  #         if txn.isTax == undefined && i == j && txn.particular.uniqueName == uTxn.particular.uniqueName && txn.amount != uTxn.amount
  #           openModal = true
  #     if openModal == true
  #       modalService.openConfirmModal(
  #         title: 'Update'
  #         body: 'Principle transaction updated, Would you also like to update tax transactions?',
  #         ok: 'Yes',
  #         cancel: 'No'
  #       ).then(
  #           (res) -> $scope.UpdateEntry(ledger, unqNamesObj, true),
  #           (res) -> $scope.UpdateEntry(ledger, unqNamesObj, false)
  #       )
  #     else
  #       $scope.UpdateEntry(ledger, unqNamesObj, false)


  $scope.removeTaxTxnOnPrincipleTxnModified = (txnList) ->
    _.each txnList, (txn) ->
      if !txn.isTax
        $scope.txnAfterRmovingTax.push(txn)


  $scope.removeUpdatedBankLedger = () ->
    if $scope.btIndex != undefined
      $scope.eLedgerData.splice($scope.btIndex, 1)

  $scope.resetBlankLedger = () ->
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
      isBlankLedger : true
      description:null
      entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
#      hasCredit:false
#      hasDebit:false
      invoiceGenerated:false
      isCompoundEntry:false
      applyApplicableTaxes:false
      tag:null
      transactions:[
        $scope.newDebitTxn
        $scope.newCreditTxn
      ]
      unconfirmedEntry:false
      isInclusiveTax: false
      uniqueName:""
      voucher:{
        name:"Sales"
        shortCode:"sal"
      }
      tax:[]
      voucherNo:null
    }

  $scope.addEntrySuccess = (res, ledger) ->
    $scope.doingEntry = false
    ledger.failed = false
    toastr.success("Entry created successfully", "Success")
    #addThisLedger = {}
    #_.extend(addThisLedger,$scope.selectedLedger)
    #$scope.ledgerData.ledgers.push(res.body)
    #$scope.getLedgerData(false)
    $scope.resetBlankLedger()
    $scope.selectedLedger = $scope.blankLedger
    _.each($scope.taxList, (tax) ->
      tax.isChecked = false
    )
    $scope.selectedTxn.isOpen = false
    if $scope.mergeTransaction
      $timeout ( ->
        $scope.mergeBankTransactions($scope.mergeTransaction)
      ), 2000
    $scope.updateLedgerData('new',res.body[0])
    $scope.pushNewEntryToLedger(res.body)
    if ledger.isBankTransaction
      $scope.updateBankLedger(ledger)
    $timeout ( ->
      $scope.pageLoader = false
      $scope.showLoader = false
    ), 1000

  $scope.addEntryFailure = (res, rejectedTransactions, ledger) ->
    $scope.doingEntry = false
    ledger.failed = true
    toastr.error(res.data.message, res.data.status)
    if rejectedTransactions.length > 0
      _.each(rejectedTransactions, (rTransaction) ->
        $scope.selectedLedger.transactions.push(rTransaction)
      )
    $timeout ( ->
      $scope.pageLoader = false
      $scope.showLoader = false
    ), 1000

  $scope.updateBankLedger = (ledger) ->
    _.each $scope.eLedgerData, (eledger, idx) ->
      if ledger.transactionId == eledger.transactionId
        $scope.eLedgerData.splice(idx, 1)
    $scope.getLedgerData()

  $scope.pushNewEntryToLedger = (newLedgers) ->
    _.each newLedgers, (ledger) ->
      $scope.calculateEntryTotal(ledger)
      $scope.ledgerData.ledgers.push(ledger)

  $scope.resetLedger = () ->
    $scope.resetBlankLedger()
    $scope.selectedLedger = $scope.blankLedger
    _.each($scope.taxList, (tx) ->
      tx.isChecked = false
    )

  $scope.updateEntrySuccess = (res, ledger) ->
    $scope.doingEntry = false
    ledger.failed = false
    toastr.success("Entry updated successfully.", "Success")
    #addThisLedger = {}
    #_.extend(addThisLedger,$scope.blankLedger)
#    $scope.ledgerData.ledgers.push(addThisLedger)
    #$scope.getLedgerData(false)
    _.extend(ledger, res.body)
    $scope.resetBlankLedger()
    $scope.selectedLedger = $scope.blankLedger
    $scope.selectedTxn.isOpen = false
    if $scope.mergeTransaction
      $scope.mergeBankTransactions($scope.mergeTransaction)
    $scope.dLedgerLimit = $scope.dLedgerLimitBeforeUpdate
    #$scope.openClosePopOver(res.body.transactions[0], res.body)
    $scope.updateLedgerData('update',res.body)
    $timeout ( ->
      ledger.total = $scope.updatedLedgerTotal
      $scope.pageLoader = false
      $scope.showLoader = false
    ), 2000
    
  $scope.updateEntryFailure = (res, ledger) ->
    $scope.doingEntry = false
    ledger.failed = true
    toastr.error(res.data.message, res.data.status)
    $timeout ( ->
      $scope.pageLoader = false
      $scope.showLoader = false
    ), 1000
    
  $scope.closePopOverSingleLedger = (ledger) ->
    _.each ledger.transactions, (txn) ->
      txn.isOpen = false

  $scope.deleteEntry = (ledger) ->
    $scope.pageLoader = true
    $scope.showLoader = true
    $scope.lastSelectedLedger = ledger
    if (ledger.uniqueName == undefined || _.isEmpty(ledger.uniqueName)) && (ledger.isBankTransaction)
      return
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.accountUnq
      entUname: ledger.uniqueName
    }
    if unqNamesObj.acntUname != '' || unqNamesObj.acntUname != undefined
      ledgerService.deleteEntry(unqNamesObj).then((res) ->
        $scope.deleteEntrySuccess(ledger, res)
      , $scope.deleteEntryFailure)

  $scope.deleteEntrySuccess = (item, res) ->
    toastr.success("Entry deleted successfully","Success")
    # withoutLedger  = _.without($scope.ledgerData.ledgers,item)
    # $scope.ledgerData.ledgers = withoutLedger
    $scope.removeDeletedLedger(item)
    $scope.resetBlankLedger()
    $scope.selectedLedger = $scope.blankLedger
    #$scope.getLedgerData(false)
    if $scope.mergeTransaction
      $timeout ( ->
        $scope.mergeBankTransactions($scope.mergeTransaction)
      ), 2000
#    $scope.calculateLedger($scope.ledgerData, "deleted")
    $scope.updateLedgerData('delete')
    $timeout ( ->
      $scope.pageLoader = false
      $scope.showLoader = false
    ), 1000
    
  
  $scope.deleteEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
    $timeout ( ->
      $scope.pageLoader = false
      $scope.showLoader = false
    ), 1000

  $scope.removeDeletedLedger = (item) ->
    index = 0
    _.each $scope.ledgerData.ledgers, (led, idx ) ->
      if led.uniqueName == item.uniqueName
        index = idx
    $scope.ledgerData.ledgers.splice(index, 1)

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


  $scope.b64toBlob = (b64Data, contentType, sliceSize) ->
    contentType = contentType or ''
    sliceSize = sliceSize or 512
    byteCharacters = atob(b64Data)
    byteArrays = []
    offset = 0
    while offset < byteCharacters.length
      slice = byteCharacters.slice(offset, offset + sliceSize)
      byteNumbers = new Array(slice.length)
      i = 0
      while i < slice.length
        byteNumbers[i] = slice.charCodeAt(i)
        i++
      byteArray = new Uint8Array(byteNumbers)
      byteArrays.push byteArray
      offset += sliceSize
    blob = new Blob(byteArrays, type: contentType)
    blob


  $scope.downloadInvoice = (invoiceNumber, e) ->
    e.stopPropagation()
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.accountUnq
    data=
      invoiceNumber: [invoiceNumber]
      template: ''
    accountService.downloadInvoice(obj, data).then((res) ->
      $scope.downloadInvSuccess(res, invoiceNumber)
    , $scope.multiActionWithInvFailure)

  $scope.downloadInvSuccess = (res, invoiceNumber)->
    data = $scope.b64toBlob(res.body, "application/pdf", 512)
    blobUrl = URL.createObjectURL(data)
    $scope.dlinv = blobUrl
    $scope.dlname = "abc.pdf"
    #$window.open(blobUrl)
    FileSaver.saveAs(data, $scope.accountToShow.name+invoiceNumber+".pdf")

  # common failure message
  $scope.multiActionWithInvFailure=(res)->
    toastr.error(res.data.message, res.data.status)

  #export ledger
#  $scope.exportLedger = ()->
#    unqNamesObj = {
#      compUname: $rootScope.selectedCompany.uniqueName
#      selGrpUname: $scope.selectedGroupUname
#      acntUname: $rootScope.selectedAccount.uniqueName
#      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
#      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
#    }
#    accountService.exportLedger(unqNamesObj).then($scope.exportLedgerSuccess, $scope.exportLedgerFailure)
#
#  $scope.exportLedgerSuccess = (res)->
#    $scope.isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0
#    if $scope.msieBrowser()
#      $scope.openWindow(res.body.filePath)
#    else if $scope.isSafari
#      modalInstance = $uibModal.open(
#        template: '<div>
#            <div class="modal-header">
#              <h3 class="modal-title">Download File</h3>
#            </div>
#            <div class="modal-body">
#              <p class="mrB">To download your file Click on button</p>
#              <button onClick="window.open(\''+res.body.filePath+'\')" class="btn btn-primary">Download</button>
#            </div>
#            <div class="modal-footer">
#              <button class="btn btn-default" ng-click="$dismiss()">Cancel</button>
#            </div>
#        </div>'
#        size: "sm"
#        backdrop: 'static'
#        scope: $scope
#      )
#    else
#      window.open(res.body.filePath)
#
#  $scope.exportLedgerFailure = (res)->
#    toastr.error(res.data.message, res.data.status)

  $scope.isScrolledIntoView = (elem,top,height) ->
    docViewTop = top
    docViewBottom = docViewTop + height
    elemTop = $(elem).offset().top
    elemBottom = elemTop + $(elem).height()
    ((elemBottom <= docViewBottom) && (elemTop >= docViewTop))

  $scope.stopProp = (e) ->
    e.stopPropagation()

  $scope.onledgerScroll = (top,height,e) ->
    if top >= height-100
      $scope.cLedgerLimit += 10
      $scope.dLedgerLimit += 10

  $scope.triggerPanelFocus = (e) ->
    if e.keyCode == 13
      $('#saveUpdate').focus()
      e.stopPropagation()
      return false

  $scope.gwaList = {
    page: 1
    count: 5000
    totalPages: 0
    currentPage : 1
    limit: 5
  }

  $scope.getFlattenGrpWithAccList = (compUname) ->
#    console.log("working  : ",$scope.working)
    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: $scope.gwaList.page
      count: $scope.gwaList.count
    }
    if $scope.working == false
      $scope.working = true
      groupService.getFlattenGroupAccList(reqParam).then($scope.getFlattenGrpWithAccListSuccess, $scope.getFlattenGrpWithAccListFailure)

  $scope.getGroupsWithDetail = () ->
    groupService.getGroupsWithoutAccountsInDetail($rootScope.selectedCompany.uniqueName).then(
      (success)->
        $scope.detGrpList = success.body
      (failure) ->
        toastr.error('Failed to get Detailed Groups List')
    )
  $scope.getGroupsWithDetail()

  $scope.markFixedGrps = (flatGrpList) ->
    temp = []
    _.each $scope.detGrpList, (detGrp) ->
      _.each flatGrpList, (fGrp) ->
        if detGrp.uniqueName == fGrp.groupUniqueName && detGrp.isFixed
          fGrp.isFixed = true
    _.each flatGrpList, (grp) ->
      if !grp.isFixed
        temp.push(grp)
    temp

  $scope.getFlattenGrpWithAccListSuccess = (res) ->
    $scope.gwaList.totalPages = res.body.totalPages
    $scope.flatGrpList = $scope.markFixedGrps(res.body.results)
    #$scope.removeEmptyGroups(res.body.results)
    #$scope.flatAccntWGroupsList = $scope.grpWithoutEmptyAccounts
    #console.log($scope.flatAccntWGroupsList)
    #$scope.showAccountList = true
    $scope.gwaList.limit = 5
    #$rootScope.companyLoaded = true
    #$scope.working = false

  $scope.getFlattenGrpWithAccListFailure = (res) ->
    toastr.error(res.data.message)
    #$scope.working = false

  $scope.addNewAccount = () ->
    $scope.newAccountModel.group = ''
    $scope.newAccountModel.account = ''
    $scope.newAccountModel.accUnqName = ''
    $scope.selectedTxn.isOpen = false
    $scope.getFlattenGrpWithAccList($rootScope.selectedCompany.uniqueName)
    $scope.AccmodalInstance = $uibModal.open(
      templateUrl: '/public/webapp/Ledger/createAccountQuick.html'
      size: "sm"
      backdrop: 'static'
      scope: $scope
    )
    #modalInstance.result.then($scope.addNewAccountCloseSuccess, $scope.addNewAccountCloseFailure)

  $scope.addNewAccountConfirm = () ->
    newAccount = {
      email:""
      mobileNo:""
      name:$scope.newAccountModel.account
      openingBalanceDate: $filter('date')($scope.today, "dd-MM-yyyy")
      uniqueName:$scope.newAccountModel.accUnqName
    }
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.newAccountModel.group.groupUniqueName
      acntUname: $scope.newAccountModel.accUnqName
    }
    if $scope.newAccountModel.group.groupUniqueName == '' || $scope.newAccountModel.group.groupUniqueName == undefined
      toastr.error('Please select a group.')
    else
      accountService.createAc(unqNamesObj, newAccount).then($scope.addNewAccountConfirmSuccess, $scope.addNewAccountConfirmFailure) 

  $scope.addNewAccountConfirmSuccess = (res) ->
    toastr.success('Account created successfully')
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    $scope.AccmodalInstance.close()

  $scope.addNewAccountConfirmFailure = (res) ->
    toastr.error(res.data.message)

  $scope.genearateUniqueName = (unqName) ->
    unqName = unqName.replace(/ /g,'')
    unqName = unqName.toLowerCase()
    if unqName.length >= 1
      unq = ''
      text = ''
      chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
      i = 0
      while i < 3
        text += chars.charAt(Math.floor(Math.random() * chars.length))
        i++ 
      unq = unqName + text
      $scope.newAccountModel.accUnqName = unq
    else
      $scope.newAccountModel.accUnqName = ''

  $scope.genUnq = (unqName) ->
    $timeout ( ->
      $scope.genearateUniqueName(unqName)
    ), 800

  $scope.$on 'company-changed', (event,changeData) ->
    # when company is changed, redirect to manage company page
    if changeData.type == 'CHANGE'
      $scope.redirectToState('company.content.manage')

  $scope.$watch 'popover.draggable', (newVal, oldVal) ->
    if newVal != oldVal
      $('.popover').remove()


  $rootScope.$emit('catchBreadcumbs', $scope.accountToShow)

giddh.webApp.controller 'newLedgerController', newLedgerController