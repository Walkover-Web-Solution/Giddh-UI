ledgerController = ($scope, $rootScope, $window,localStorageService, toastr, modalService, ledgerService,FileSaver , $filter, DAServices, $stateParams, $timeout, $location, $document, permissionService, accountService, groupService, $uibModal, companyServices, $state,idbService, $http, nzTour, $q ) ->
  ledgerCtrl = this
  ledgerCtrl.LedgerExport = false
  ledgerCtrl.toggleShare = false
  ledgerCtrl.getLink = true

  ledgerCtrl.today = new Date()
  d = moment(new Date()).subtract(8, 'month')
  ledgerCtrl.fromDate = {date: d._d}
  ledgerCtrl.toDate = {date: new Date()}
  ledgerCtrl.fromDatePickerIsOpen = false
  ledgerCtrl.toDatePickerIsOpen = false
  ledgerCtrl.format = "dd-MM-yyyy"
  ledgerCtrl.accountUnq = $stateParams.unqName
  ledgerCtrl.showExportOption = false
  ledgerCtrl.showLedgerPopover = false
  ledgerCtrl.showExportOption = false
  ledgerCtrl.showLedgers = false
  ledgerCtrl.showEledger = true
  ledgerCtrl.popover = {

    templateUrl: 'panel'
    draggable: false
    position: "bottom"
  }
# mustafa
  
  ledgerCtrl.exportOptions = () ->
    ledgerCtrl.showExportOption = !ledgerCtrl.showExportOption

  ledgerCtrl.toggleShareFucntion = () ->
    ledgerCtrl.LedgerExport = false
    ledgerCtrl.toggleShare = false
    ledgerCtrl.toggleShare = !ledgerCtrl.toggleShare

  ledgerCtrl.toggleExportFucntion = () ->
    ledgerCtrl.toggleShare = false
    ledgerCtrl.LedgerExport = false
    ledgerCtrl.LedgerExport = !ledgerCtrl.LedgerExport

  ledgerCtrl.voucherTypeList = [
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

  ledgerCtrl.toggleDropdown = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    $scope.status.isopen = !$scope.status.isopen

  ledgerCtrl.shareLedger =() ->
    ledgerCtrl.shareModalInstance = $uibModal.open(
      templateUrl: '/public/webapp/Ledger/shareLedger.html',
      size: "md",
      backdrop: 'true',
      animation: true,
      scope: $scope
    )

  if _.isUndefined($rootScope.selectedCompany)
    $rootScope.selectedCompany = localStorageService.get('_selectedCompany')

  ledgerCtrl.accountUnq = $stateParams.unqName

  ledgerCtrl.isCurrentAccount =(acnt) ->
    acnt.uniqueName is ledgerCtrl.accountUnq

  ledgerCtrl.loadDefaultAccount = (acc) ->
    
    @success = (res) ->
      ledgerCtrl.accountUnq = 'cash'
      ledgerCtrl.getAccountDetail(ledgerCtrl.accountUnq)

    @failure = (res) ->
      ledgerCtrl.accountUnq = 'sales'
      ledgerCtrl.getAccountDetail(ledgerCtrl.accountUnq)

    unqObj = {
      compUname : $rootScope.selectedCompany.uniqueName
      acntUname : 'cash'
    }
    accountService.get(unqObj).then(@success, @failure)

  ledgerCtrl.sortFlatAccListAlphabetically = (list, property) ->
    sortedList = []
    _.each list, (item) ->
      sortedList.push(item[property])
    sortedList = sortedList.sort()
    return sortedList

  ledgerCtrl.getAccountDetail = (accountUniqueName) ->
    if not _.isUndefined(accountUniqueName) && not _.isEmpty(accountUniqueName) && not _.isNull(accountUniqueName)
      unqObj = {
        compUname : $rootScope.selectedCompany.uniqueName
        acntUname : accountUniqueName
      }
      accountService.get(unqObj)
      .then(
        (res)->
          ledgerCtrl.getAccountDetailSuccess(res)
      ,(error)->
        ledgerCtrl.getAccountDetailFailure(error)
      )

  ledgerCtrl.getAccountDetailFailure = (res) ->
    if ledgerCtrl.accountUnq != 'sales'
      toastr.error(res.data.message, res.data.status)
    else
      sortedAccList = ledgerCtrl.sortFlatAccListAlphabetically($rootScope.fltAccntListPaginated, 'uniqueName')
      ledgerCtrl.getAccountDetail(sortedAccList[0])

  ledgerCtrl.getAccountDetailSuccess = (res) ->
    localStorageService.set('_selectedAccount', res.body)
    $rootScope.selectedAccount = res.body
    ledgerCtrl.accountToShow = $rootScope.selectedAccount
    ledgerCtrl.accountUnq = res.body.uniqueName
    ledgerCtrl.getTransactions(0)
    ledgerCtrl.getBankTransactions($rootScope.selectedAccount.uniqueName)
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    $state.go($state.current, {unqName: res.body.uniqueName}, {notify: false})
    if res.body.uniqueName == 'cash'
      $rootScope.ledgerState = true
    # ledgerCtrl.getPaginatedLedger(1)
    if res.body.yodleeAdded == true && $rootScope.canUpdate
      #get bank transaction here
      $timeout ( ->
        ledgerCtrl.getBankTransactions(res.body.uniqueName)
      ), 2000

  ledgerCtrl.hideEledger = () ->
    ledgerCtrl.showEledger = !ledgerCtrl.showEledger

  ledgerCtrl.getBankTransactions = (accountUniqueName) ->
    unqObj = {
      compUname : $rootScope.selectedCompany.uniqueName
      acntUname : accountUniqueName
    }
    # get other ledger transactions
    ledgerService.getOtherTransactions(unqObj)
    .then(
      (res)->
        ledgerCtrl.getBankTransactionsSuccess(res)
    ,(error)->
      ledgerCtrl.getBankTransactionsFailure(error)
    )

  ledgerCtrl.getBankTransactionsFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  ledgerCtrl.getBankTransactionsSuccess = (res) ->
    ledgerCtrl.eLedgerData = ledgerCtrl.formatBankLedgers(res.body)
    ledgerCtrl.calculateELedger()
    ledgerCtrl.getReconciledEntries()
    #ledgerCtrl.removeUpdatedBankLedger()

  ledgerCtrl.calculateELedger = () ->
    ledgerCtrl.eLedgType = undefined
    ledgerCtrl.eCrBalAmnt = 0
    ledgerCtrl.eDrBalAmnt = 0
    ledgerCtrl.eDrTotal = 0
    ledgerCtrl.eCrTotal = 0
    crt = 0
    drt = 0
    _.each(ledgerCtrl.eLedgerData, (ledger) ->
      _.each(ledger.transactions, (transaction) ->
        if transaction.type == 'DEBIT'
          drt += Number(transaction.amount)
        else if transaction.type == 'CREDIT'
          crt += Number(transaction.amount)
      )
    )
    crt = parseFloat(crt)
    drt = parseFloat(drt)
    ledgerCtrl.eCrTotal = crt
    ledgerCtrl.eDrTotal = drt

  ledgerCtrl.getReconciledEntries = (cheque, toMap, matchingEntries) ->
    @success = (res) ->
      ledgerCtrl.reconciledEntries = res.body
      if toMap
        _.each ledgerCtrl.reconciledEntries, (entry) ->
          _.each entry.transactions, (txn) ->
            if txn.amount == ledgerCtrl.selectedLedger.transactions[0].amount
              matchingEntries.push(entry)
        if matchingEntries.length == 1
          ledgerCtrl.confirmBankTransactionMap(matchingEntries[0], ledgerCtrl.selectedLedger)
        else if matchingEntries.length >1
          ledgerCtrl.showBankEntriesToMap(matchingEntries)
        else
          toastr.error('no entry with matching amount found, please create a new entry with same amount as this transaction.')

    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      accountUniqueName: $rootScope.selectedAccount.uniqueName
      from: $filter('date')($scope.cDate.startDate, 'dd-MM-yyyy')
      to: $filter('date')($scope.cDate.endDate, 'dd-MM-yyyy')
      chequeNumber: cheque

    }

    ledgerService.getReconcileEntries(reqParam).then(@success, @failure)
  
  # $rootScope.$on('account-selected', ()->
  #   ledgerCtrl.getAccountDetail(ledgerCtrl.accountUnq)
  #   #ledgerCtrl.isSelectedAccount()
  #   #$rootScope.$emit('catchBreadcumbs', ledgerCtrl.accountToShow.name)
  # )

  ledgerCtrl.matchBankTransaction = () ->
    matchingEntries = []
    ledgerCtrl.getReconciledEntries('', true, matchingEntries)


  ledgerCtrl.confirmBankTransactionMap = (mappedEntry, bankEntry) ->
    modalService.openConfirmModal(
        title: 'Map Bank Entry'
        body: 'Selected bank transaction will be mapped with cheque number ' +mappedEntry.chequeNumber+ '. Click yes to accept.',
        ok: 'Yes',
        cancel: 'No'
      ).then(
          (res) -> ledgerCtrl.mapBankTransaction(mappedEntry.uniqueName, bankEntry.transactionId),
          (res) -> 
      )
  ledgerCtrl.mapBankTransaction = (entryUnq, transactionId) ->
    ledgerCtrl.selectedTxn.isOpen = false
    @success = (res) ->
      toastr.success(res.body)
      # ledgerCtrl.getPaginatedLedger(ledgerCtrl.currentPage)
      ledgerCtrl.getBankTransactions($rootScope.selectedAccount.uniqueName)
      ledgerCtrl.getTransactions(ledgerCtrl.currentPage)

    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      accountUniqueName: $rootScope.selectedAccount.uniqueName
      transactionId: transactionId
    }
    data = {
      uniqueName: entryUnq
    }
    ledgerService.mapBankEntry(reqParam, data).then(@success, @failure)

  ledgerCtrl.showBankEntriesToMap = (matchingEntries) ->
    ledgerCtrl.showMatchingEntries = true
    ledgerCtrl.matchingEntries = matchingEntries

  ledgerCtrl.formatBankLedgers = (bankArray) ->
    formattedBankLedgers = []
    if bankArray.length > 0
      _.each bankArray, (bank) ->
        ledger = new blankLedgerObjectModel()
        ledger.entryDate = bank.date
        ledger.isBankTransaction = true
        ledger.transactionId = bank.transactionId
        ledger.transactions = ledgerCtrl.formatBankTransactions(bank.transactions, bank, ledger)
        ledger.description = bank.description
        formattedBankLedgers.push(ledger)
    formattedBankLedgers

  ledgerCtrl.formatBankTransactions = (transactions, bank, ledger, type) ->
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

  ledgerCtrl.mergeBankTransactions = (toMerge) ->
    if toMerge
      ledgerCtrl.mergeTransaction = true
      _.each ledgerCtrl.eLedgerData, (ld) ->
        if ld.uniqueName.length < 1 then ld.uniqueName = ld.transactionId else ld.uniqueName
        if ld.transactions[0].type == 'DEBIT'
          ledgerCtrl.dLedgerContainer.addAtTop(ld)
        else if ld.transactions[0].type == 'CREDIT'
          ledgerCtrl.cLedgerContainer.addAtTop(ld)
      # ledgerCtrl.ledgerData.ledgers.push(ledgerCtrl.eLedgerData)
      # ledgerCtrl.ledgerData.ledgers = ledgerCtrl.sortTransactions(_.flatten(ledgerCtrl.ledgerData.ledgers), 'entryDate')
      ledgerCtrl.showEledger = false
    else
    #   ledgerCtrl.AddBankTransactions()
    #   ledgerCtrl.showEledger = false
    # else
      ledgerCtrl.mergeTransaction = false
      ledgerCtrl.removeBankTransactions()
    #   ledgerCtrl.showEledger = true

  # ledgerCtrl.AddBankTransactions = () ->
  #   bankTxnDuplicate = ledgerCtrl.eLedgerData
  #   bankTxntoMerge = ledgerCtrl.fromBanktoLedgerObject(bankTxnDuplicate)
  #   ledgerCtrl.ledgerData.ledgers.push(bankTxntoMerge)
  #   ledgerCtrl.ledgerData.ledgers = _.flatten(ledgerCtrl.ledgerData.ledgers)

  ledgerCtrl.sortTransactions = (ledger, sortType) ->
    ledger = _.sortBy(ledger, sortType)
    ledger = ledger.reverse()
    ledger

  ledgerCtrl.removeBankTransactions = () ->
    withoutBankTxn = []
    _.each ledgerCtrl.cLedgerContainer.ledgerData, (ledger) ->
      if ledger.isBankTransaction 
        ledgerCtrl.cLedgerContainer.remove(ledger)
    _.each ledgerCtrl.dLedgerContainer.ledgerData, (ledger) ->
      if ledger.isBankTransaction 
        ledgerCtrl.dLedgerContainer.remove(ledger)
    ledgerCtrl.showEledger = true
  if ledgerCtrl.accountUnq
    ledgerCtrl.getAccountDetail(ledgerCtrl.accountUnq)
  else
    ledgerCtrl.loadDefaultAccount() 

  ###date range picker ###
  $scope.cDate = {
    startDate: moment().subtract(30, 'days')._d,
    endDate: moment()._d
  };


  $scope.singleDate = moment()
  $scope.opts = {
      locale:
        applyClass: 'btn-green'
        applyLabel: 'Go'
        fromLabel: 'From'
        format: 'D-MMM-YY'
        toLabel: 'To'
        cancelLabel: 'Cancel'
        customRangeLabel: 'Custom range'
      ranges:
        'Last 1 Day': [
          moment().subtract(1, 'days')
          moment()
        ]
        'Last 7 Days': [
          moment().subtract(6, 'days')
          moment()
        ]
        'Last 30 Days': [
          moment().subtract(29, 'days')
          moment()
        ]
        'Last 6 Months': [
          moment().subtract(6, 'months')
          moment()
        ]
        'Last 1 Year': [
          moment().subtract(12, 'months')
          moment()
        ]
      eventHandlers : {
        'apply.daterangepicker' : (e, picker) ->
          $scope.cDate.startDate = e.model.startDate._d || e.model.startDate
          $scope.cDate.endDate = e.model.endDate._d || e.model.endDate
          ledgerCtrl.getTransactions(0)
      }
  }
  $scope.setStartDate = ->
    $scope.cDate.startDate = moment().subtract(4, 'days').toDate()

  $scope.setRange = ->
    $scope.cDate =
        startDate: moment().subtract(5, 'days')
        endDate: moment()
  ###date range picker end###

  ledgerCtrl.selectedLedger = {
    description:null
    entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
    invoiceGenerated:false
    isCompoundEntry:false
    tag:null
    transactions:[{
      amount:0
      rate:0
      particular:{
        name:""
        uniqueName:""
      }
      type:""
    }]
    unconfirmedEntry:false
    isInclusiveTax: true
    uniqueName:""
    voucher:{
      name:"Sales"
      shortCode:"sal"
    }
    voucherNo:null
    panel:{
      amount: 0
      tax: 0
      discount: 0
      quantity:0
      price:0
    }
  }

  blankLedgerObjectModel = () ->
    @blankLedger = {
      isBlankLedger : true
      attachedFileName: ''
      attachedFile: ''
      description:''
      entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
      invoiceGenerated:false
      isCompoundEntry:false
      applyApplicableTaxes: false
      tag:''
      transactions:[]
      unconfirmedEntry:false
      uniqueName:""
      isInclusiveTax: true
      voucher:{
        name:"Sales"
        shortCode:"sal"
      }
      tax: []
      taxList : []
      taxes: []
      voucherNo:''
    }


  blankLedgerModel = () ->
    @blankLedger = {
      isBlankLedger : true
      attachedFileName: ''
      attachedFile: ''
      description:''
      entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
      invoiceGenerated:false
      isCompoundEntry:false
      applyApplicableTaxes: false
      tag:''
      transactions:[]
      unconfirmedEntry:false
      uniqueName:""
      isInclusiveTax: true
      voucher:{
        name:"Sales"
        shortCode:"sal"
      }
      tax: []
      taxList : []
      taxes: []
      voucherNo:''
    }

  ledgerCtrl.dBlankTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: {
      name:''
      uniqueName:''
    }
    amount : ''
    type: 'DEBIT'
  }

  ledgerCtrl.cBlankTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: {
      name:''
      uniqueName:''
    }
    amount : ''
    type: 'CREDIT'
  }


  ledgerCtrl.blankLedger = new blankLedgerModel()
  ledgerCtrl.blankLedger.transactions.push(ledgerCtrl.dBlankTxn)
  ledgerCtrl.blankLedger.transactions.push(ledgerCtrl.cBlankTxn)

  txnModel = (type) ->
    @ledger = {
      date: $filter('date')(new Date(), "dd-MM-yyyy")
      particular: {
        name:""
        uniqueName:""
      }
      amount : 0
      type: type
    }



  # ledgerCtrl.resetBlankLedger = () ->
  #   ledgerCtrl.newDebitTxn = {
  #     date: $filter('date')(new Date(), "dd-MM-yyyy")
  #     particular: {
  #       name:''
  #       uniqueName:''
  #     }
  #     amount : 0
  #     type: 'DEBIT'
  #   }
  #   ledgerCtrl.newCreditTxn = {
  #     date: $filter('date')(new Date(), "dd-MM-yyyy")
  #     particular: {
  #       name:''
  #       uniqueName:''
  #     }
  #     amount : 0
  #     type: 'CREDIT'
  #   }
#     ledgerCtrl.blankLedger = {
#       isBlankLedger : true
#       description:null
#       entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
# #      hasCredit:false
# #      hasDebit:false
#       invoiceGenerated:false
#       isCompoundEntry:false
#       applyApplicableTaxes:false
#       tag:null
#       transactions:[
#         ledgerCtrl.newDebitTxn
#         ledgerCtrl.newCreditTxn
#       ]
#       unconfirmedEntry:false
#       isInclusiveTax: false
#       uniqueName:""
#       voucher:{
#         name:"Sales"
#         shortCode:"sal"
#       }
#       tax:[]
#       taxList: []
#       voucherNo:null
#     }


  # ledgerCtrl.ledgerPerPageCount = 10
  # ledgerCtrl.pages = []
  # ledgerCtrl.getPaginatedLedger = (page) ->
  #   @success = (res) ->
  #     ledgerCtrl.ledgerData = res.body
  #     ledgerCtrl.pages = []
  #     ledgerCtrl.paginatedLedgers = res.body.ledgers
  #     ledgerCtrl.totalLedgerPages = res.body.totalPages
  #     ledgerCtrl.currentPage = res.body.page
  #     ledgerCtrl.totalCreditTxn = res.body.totalCreditTransactions
  #     ledgerCtrl.totalDebitTxn = res.body.totalDebitTransactions
  #     ledgerCtrl.addLedgerPages()
  #     ledgerCtrl.calculateClosingBal(res.body.ledgers)

  #   @failure = (res) ->
  #     toastr.error(res.data.message)

  #   if _.isUndefined($rootScope.selectedCompany.uniqueName)
  #     $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  #   unqNamesObj = {
  #     compUname: $rootScope.selectedCompany.uniqueName
  #     acntUname: ledgerCtrl.accountUnq
  #     fromDate: $filter('date')($scope.cDate.startDate, "dd-MM-yyyy")
  #     toDate: $filter('date')($scope.cDate.endDate, "dd-MM-yyyy")
  #     count: ledgerCtrl.ledgerPerPageCount
  #     page: page || 1
  #     sort: 'desc'
  #   }
    # if not _.isEmpty(ledgerCtrl.accountUnq)
    #   ledgerService.getLedger(unqNamesObj).then(@success, @failure)

  #ledgerCtrl.getPaginatedLedger(1)

  ledgerCtrl.calculateClosingBal = (ledgers) ->
    totalDebit = 0
    totalCredit = 0
    _.each ledgers, (ledger) ->
      _.each ledger.transactions, (txn) ->
        if txn.type == 'DEBIT'
          totalDebit += ledgerCtrl.cutToTwoDecimal(txn.amount)
        else if txn.type == 'CREDIT'
          totalCredit += ledgerCtrl.cutToTwoDecimal(txn.amount)
    ledgerCtrl.totalCredit = totalCredit
    ledgerCtrl.totalDebit = totalDebit


  ledgerCtrl.addLedgerPages = () ->
    ledgerCtrl.pages = []
    i = 0
    while i <= ledgerCtrl.totalLedgerPages
      if i > 0
        ledgerCtrl.pages.push(i)
      i++

  ##--shared list--##
  ledgerCtrl.getSharedUserList = (uniqueName) ->
    companyServices.shredList(uniqueName).then($scope.getSharedUserListSuccess, $scope.getSharedUserListFailure)

  ledgerCtrl.getSharedUserListSuccess = (res) ->
    $scope.sharedUsersList = res.body

  ledgerCtrl.getSharedUserListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  ledgerCtrl.getSharedList = () ->
    $scope.setShareableRoles($rootScope.selectedCompany)
    $scope.getSharedUserList($rootScope.selectedCompany.uniqueName)
  ledgerCtrl.getSharedList()
  # generate magic link
  ledgerCtrl.getMagicLink = () ->
    accUname = ledgerCtrl.accountUnq
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      accountUniqueName: accUname
      from: $filter('date')($scope.cDate.startDate, 'dd-MM-yyyy')
      to: $filter('date')($scope.cDate.endDate, 'dd-MM-yyyy')
    }
    companyServices.getMagicLink(reqParam).then(ledgerCtrl.getMagicLinkSuccess, ledgerCtrl.getMagicLinkFailure)

  ledgerCtrl.getMagicLinkSuccess = (res) ->
    ledgerCtrl.magicLink = res.body.magicLink
    # modalInstance = $uibModal.open(
    #   template: '<div>
    #       <div class="modal-header">
    #         <button type="button" class="close" data-dismiss="modal" ng-click="$dismiss()" aria-label="Close"><span
    #     aria-hidden="true">&times;</span></button>
    #       <h3 class="modal-title">Magic Link</h3>
    #       </div>
    #       <div class="modal-body">
    #         <input id="magicLink" class="form-control" type="text" ng-model="ledgerCtrl.magicLink">
    #       </div>
    #       <div class="modal-footer">
    #         <button class="btn btn-default" ngclipboard data-clipboard-target="#magicLink">Copy</button>
    #       </div>
    #   </div>'
    #   size: "md"
    #   backdrop: 'static'
    #   scope: $scope
    # )
    # ledgerCtrl.getLink = false

  ledgerCtrl.getMagicLinkFailure = (res) ->
    toastr.error(res.data.message)
# mustafa end


  ledgerCtrl.ledgerEmailData = {
    viewDetailed: "view-detailed"
    viewCondensed:"view-condensed"
    adminDetailed:"admin-detailed"
    adminCondensed:"admin-condensed"
  }
  ledgerCtrl.ledgerEmailData.emailType = ledgerCtrl.ledgerEmailData.viewDetailed
  
# ledger send email
  ledgerCtrl.sendLedgEmail = (emailData, emailType) ->
    data = emailData
    if _.isNull(ledgerCtrl.toDate.date) || _.isNull($scope.cDate.startDate)
      toastr.error("Date should be in proper format", "Error")
      return false
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: ledgerCtrl.accountUnq
      toDate: $filter('date')($scope.cDate.endDate, "dd-MM-yyyy")
      fromDate: $filter('date')($scope.cDate.startDate, "dd-MM-yyyy")
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

    accountService.emailLedger(unqNamesObj, sendData).then(ledgerCtrl.emailLedgerSuccess, ledgerCtrl.emailLedgerFailure)

  ledgerCtrl.emailLedgerSuccess = (res) ->
    toastr.success(res.body, res.status)
    #ledgerCtrl.ledgerEmailData.email = ''
    ledgerCtrl.ledgerEmailData = {}

  ledgerCtrl.emailLedgerFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  # #export ledger
  # ledgerCtrl.exportLedger = (type)->
  #   ledgerCtrl.showExportOption = false
  #   unqNamesObj = {
  #     compUname: $rootScope.selectedCompany.uniqueName
  #     acntUname: ledgerCtrl.accountUnq
  #     fromDate: $filter('date')($scope.cDate.startDate, "dd-MM-yyyy")
  #     toDate: $filter('date')($scope.cDate.endDate, "dd-MM-yyyy")
  #     lType:type
  #   }
  #   accountService.exportLedger(unqNamesObj).then(ledgerCtrl.exportLedgerSuccess, ledgerCtrl.exportLedgerFailure)

  # ledgerCtrl.exportLedgerSuccess = (res)->
  #   # blob = new Blob([res.body.filePath], {type:'file'})
  #   # fileName = res.body.filePath.split('/')
  #   # fileName = fileName[fileName.length-1]
  #   # FileSaver.saveAs(blob, fileName)
  #   ledgerCtrl.isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0
  #   if $rootScope.msieBrowser()
  #     $rootScope.openWindow(res.body.filePath)
  #   else if ledgerCtrl.isSafari       
  #     modalInstance = $uibModal.open(
  #       template: '<div>
  #           <div class="modal-header">
  #             <h3 class="modal-title">Download File</h3>
  #           </div>
  #           <div class="modal-body">
  #             <p class="mrB">To download your file Click on button</p>
  #             <button onClick="window.open(\''+res.body.filePath+'\')" class="btn btn-primary">Download</button>
  #           </div>
  #           <div class="modal-footer">
  #             <button class="btn btn-default" ng-click="$dismiss()">Cancel</button>
  #           </div>
  #       </div>'
  #       size: "sm"
  #       backdrop: 'static'
  #       scope: $scope
  #     )
  #   else
  #     window.open(res.body.filePath)

  # ledgerCtrl.exportLedgerFailure = (res)->
  #   toastr.error(res.data.message, res.data.status)
  #   modalInstance = $uibModal.open(
  #     template: '<div>
  #         <div class="modal-header">
  #           <button type="button" class="close" data-dismiss="modal" ng-click="$dismiss()" aria-label="Close"><span
  #       aria-hidden="true">&times;</span></button>
  #         <h3 class="modal-title">Magic Link</h3>
  #         </div>
  #         <div class="modal-body">
  #           <input id="magicLink" class="form-control" type="text" ng-model="ledgerCtrl.magicLink">
  #         </div>
  #         <div class="modal-footer">
  #           <button class="btn btn-default" ngclipboard data-clipboard-target="#magicLink">Copy</button>
  #         </div>
  #     </div>'
  #     size: "md"
  #     backdrop: 'static'
  #     scope: $scope
  #   )

  ledgerCtrl.getMagicLinkFailure = (res) ->
    toastr.error(res.data.message)

  ledgerCtrl.prevTxn = null
  ledgerCtrl.selectBlankTxn = (ledger, txn, index ,e) ->
    ledgerCtrl.selectedTxn = txn
    if ledgerCtrl.prevTxn != null
      ledgerCtrl.prevTxn.isOpen = false
    ledgerCtrl.selectedTxn.isOpen = true
    ledgerCtrl.selectedLedger = ledger
    # ledgerCtrl.clearTaxSelection(txn, ledger)
    # ledgerCtrl.clearDiscounts(ledger)
    ledgerCtrl.isTransactionContainsTax(ledgerCtrl.selectedLedger)
    ledgerCtrl.createNewPanel(ledgerCtrl.selectedTxn, ledgerCtrl.selectedLedger)
    # ledgerCtrl.matchInventory(ledgerCtrl.selectedLedger)
    ledgerCtrl.prevTxn = txn
    e.stopPropagation()


  ledgerCtrl.getNewPanelDiscount = (ledger) ->
    discount = 0
    if ledgerCtrl.discountAccount != undefined
      _.each ledgerCtrl.discountAccount.accountDetails, (account) ->
        _.each ledger.transactions, (txn) ->
          if txn.particular.uniqueName == account.uniqueName
            account.amount = txn.amount
        if account.amount
          discount += Number(account.amount)
    return discount

  ledgerCtrl.getNewPanelTax = (txn, ledger) ->
    totalTax = 0
    if ledgerCtrl.taxList.length > 0
      _.each ledgerCtrl.taxList, (tax) ->
        if ledgerCtrl.isTaxApplicable(tax) && tax.isChecked
          taxAmount = txn.panel.amount * ledgerCtrl.getApplicableTaxRate(tax) /100
          totalTax += taxAmount
    taxPercentage = ledgerCtrl.cutToTwoDecimal((totalTax/txn.panel.amount)*100)
    txn.panel.total = ledgerCtrl.cutToTwoDecimal(txn.panel.amount - txn.panel.discount + (taxPercentage*(txn.panel.amount-txn.panel.discount)/100))
    ledgerCtrl.cutToTwoDecimal(taxPercentage) || 0

  ledgerCtrl.createNewPanel = (txn, ledger) ->
    if typeof(txn.particular) == 'object' && txn.particular.uniqueName.length < 1 && _.isEmpty(txn.amount)
      txn.panel = {
        tax : 0
        total: 0
        discount: 0
        amount: 0
        price: 0
        unit: null
        quantity: 0
        units: []
      }

    panel = @
    panel.getQuantity = () ->
      if txn.panel.quantity != undefined
        return ledgerCtrl.cutToTwoDecimal(panel.getAmount()/panel.getPrice())

    panel.getPrice = () ->
      if txn.particular.stock
        units = panel.getUnits()
        if txn.panel.unit
          return txn.panel.unit.rate
        else if units.length > 0
          return units[0].rate
      else
        return 0

    panel.getUnits = () ->
      if txn.particular.stock && txn.particular.stock.accountStockDetails.unitRates.length > 0
        return txn.particular.stock.accountStockDetails.unitRates
      else
        return txn.panel.units

    panel.getAmount = () ->
      if txn.panel.quantity > 0
        return txn.panel.quantity * txn.panel.price
      else
        return Number(txn.amount) 

    panel.getDiscount = () ->
      discount = ledgerCtrl.getNewPanelDiscount(ledger)

    panel.getTax = () ->
      tax = ledgerCtrl.getNewPanelTax(txn, ledger)
      return tax

    panel.getTotal = () ->
      amount = txn.panel.amount - txn.panel.discount
      txn.panel.total = ledgerCtrl.cutToTwoDecimal(amount + (amount*txn.panel.tax/100))


    txn.panel.quantity = panel.getQuantity()
    txn.panel.price = panel.getPrice()
    txn.panel.units = panel.getUnits()
    txn.panel.unit = txn.panel.units[0]
    txn.panel.amount = panel.getAmount()
    txn.panel.disocunt = panel.getDiscount()
    txn.panel.tax = panel.getTax()
    txn.panel.total = panel.getTotal()


  ledgerCtrl.onNewPanelChange = () ->
    change = @

    change.quantity = (txn, ledger) ->
      txn.panel.amount = ledgerCtrl.cutToTwoDecimal(txn.panel.quantity * txn.panel.price)
      change.getTotal(txn, ledger)

    change.unit = (txn, ledger) ->
      txn.panel.price = ledgerCtrl.cutToTwoDecimal(txn.panel.unit.rate)
      txn.panel.quantity = ledgerCtrl.cutToTwoDecimal(txn.panel.amount / txn.panel.price)
      #change.price(txn, ledger)

    change.price = (txn, ledger) ->
      txn.panel.amount = ledgerCtrl.cutToTwoDecimal(txn.panel.quantity * txn.panel.price)
      change.getTotal(txn, ledger)

    change.amount = (txn, ledger) ->
      txn.panel.price = ledgerCtrl.cutToTwoDecimal(txn.panel.amount / txn.panel.quantity)
      txn.amount = txn.panel.amount
      change.getTotal(txn, ledger)

    change.discount = (txn, ledger) ->
      txn.panel.discount = ledgerCtrl.getNewPanelDiscount(ledger)
      change.getTotal(txn, ledger)

    change.tax = (txn, ledger) ->
      txn.panel.tax = ledgerCtrl.getNewPanelTax(txn, ledger)
      change.getTotal(txn, ledger)

    change.txnAmount = (txn, ledger) ->
      txn.panel.amount = Number(txn.amount)
      change.tax(txn, ledger)
      # if txn.panel.quantity == undefined || txn.panel.quantity == 0
      txn.panel.quantity = ledgerCtrl.cutToTwoDecimal(txn.panel.amount/txn.panel.price)

    change.getTotal = (txn, ledger) ->
      amount = txn.panel.amount - txn.panel.discount
      txn.panel.total = amount + (amount*txn.panel.tax/100)
      txn.amount = txn.panel.amount

    change.total = (txn, ledger) ->
      if !txn.panel.discount 
        amount = (100*txn.panel.total)/(100+(txn.panel.tax||0))
      else
        amount = (100*txn.panel.total)/(100+(txn.panel.tax||0)) + txn.panel.discount
      txn.panel.amount = Number(amount.toFixed(2))
    return change


  ledgerCtrl.selectTxn = (ledger, txn, index ,e) ->
    ledgerCtrl.selectedTxn = txn
    if ledgerCtrl.prevTxn != null
      ledgerCtrl.prevTxn.isOpen = false
    ledgerCtrl.selectedTxn.isOpen = true
    ledgerCtrl.prevTxn = txn
    # ledgerCtrl.clearTaxSelection(ledger)
    # ledgerCtrl.clearDiscounts(ledger)
    if !ledger.isBlankLedger
      ledgerCtrl.addBlankRow(ledger, txn)
    # ledgerCtrl.removeBlankRowFromPrevLedger(ledgerCtrl.prevLedger, ledger)
    # ledger.isCompoundEntry = true
    # if ledgerCtrl.prevLedger && ledgerCtrl.prevLedger.uniqueName != ledger.uniqueName
    #   ledgerCtrl.prevLedger.isCompoundEntry = false
    # # ledgerCtrl.calculateEntryTotal(ledger)
    # ledgerCtrl.showLedgerPopover = true
    # ledgerCtrl.matchInventory(ledgerCtrl.selectedLedger)
    # ledgerCtrl.ledgerBeforeEdit = {}
    # angular.copy(ledger,ledgerCtrl.ledgerBeforeEdit)
    # # ledgerCtrl.isTransactionContainsTax(ledger)
    ledgerCtrl.selectedLedger = ledger
    # ledgerCtrl.selectedLedger.index = index
    #ledgerCtrl.createPanel(ledgerCtrl.selectedLedger)

    #ledgerCtrl.selectedLedger.panel.total = ledgerCtrl.getEntryTotal(ledgerCtrl.selectedLedger)
    #if ledger.uniqueName != '' || ledger.uniqueName != undefined || ledger.uniqueName != null
    # ledgerCtrl.checkCompEntry(txn)
    #ledgerCtrl.blankCheckCompEntry(ledger)
    # ledgerCtrl.prevLedger = ledger
    e.stopPropagation()

  ledgerCtrl.createPanel = (ledger) ->
    ledgerCtrl.selectedLedger.panel = {
      tax : 0
      total: 0
      discount: 0
      amount: 0
      price: 0
      unit: ''
      units: []
    }
    if ledgerCtrl.accountToShow.stocks != null
      ledgerCtrl.selectedLedger.panel.price = ledgerCtrl.accountToShow.stocks[0].rate
    ledgerCtrl.selectedLedger.panel.amount = ledgerCtrl.getPanelAmount(ledgerCtrl.selectedLedger)
    ledgerCtrl.selectedLedger.panel.total = ledgerCtrl.selectedLedger.panel.amount
    ledgerCtrl.selectedLedger.panel.discount = ledgerCtrl.getTotalDiscount(ledgerCtrl.selectedLedger)
    ledgerCtrl.selectedLedger.panel.tax = ledgerCtrl.getTotalTax(ledgerCtrl.selectedLedger)
    stockTxn = ledgerCtrl.getStockTxn(ledger)
    if !_.isEmpty(stockTxn)
      stockAccount = ledgerCtrl.getStockAccountfromFlattenAccountList(stockTxn)
      if stockAccount
        linkedStock = _.findWhere(stockAccount.stocks, {uniqueName:stockTxn.inventory.stock.uniqueName})
        ledgerCtrl.selectedLedger.panel.units = linkedStock.accountStockDetails.unitRates
        ledgerCtrl.selectedLedger.panel.unit = _.findWhere(ledgerCtrl.selectedLedger.panel.units, {stockUnitCode:stockTxn.inventory.unit.code})

  ledgerCtrl.getStockAccountfromFlattenAccountList = (txn) ->
    account = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:txn.particular.uniqueName})
    account


  ledgerCtrl.addBlankRow = (ledger, txn) ->
    dBlankRow = _.findWhere(ledger.transactions, {blankRow:'DEBIT'})
    cBlankRow = _.findWhere(ledger.transactions, {blankRow:'CREDIT'})
    if !dBlankRow && txn.type == 'DEBIT'
      txn = new txnModel('DEBIT')
      txn.blankRow = 'DEBIT'
      ledger.transactions.push(txn)
    else if dBlankRow && dBlankRow.particular != "" && dBlankRow.particular.uniqueName.length
      txn = new txnModel('DEBIT')
      txn.blankRow = 'DEBIT'
      ledger.transactions.push(txn)
      delete dBlankRow.blankRow

    if !cBlankRow && txn.type == 'CREDIT'
      txn = new txnModel('CREDIT')
      txn.blankRow = 'CREDIT'
      ledger.transactions.push(txn)
    else if cBlankRow && cBlankRow.particular != "" && cBlankRow.particular.uniqueName.length
      txn = new txnModel('CREDIT')
      txn.blankRow = 'CREDIT'
      ledger.transactions.push(txn)
      delete cBlankRow.blankRow


  ledgerCtrl.removeBlankRowFromPrevLedger = (prevLedger, ledger) ->
    if prevLedger && prevLedger.uniqueName != ledger.uniqueName
      _.each prevLedger.transactions, (txn, i) ->
        if txn.blankRow && txn.particular.uniqueName == ''
          prevLedger.transactions.splice(i, 1)

  ledgerCtrl.addBlankTxn = (type, ledger) ->
    txn = new txnModel(type)
    hasBlank = ledgerCtrl.checkForExistingblankTransaction(ledger, type)
    if !hasBlank
      ledgerCtrl.createNewPanel(txn, ledger)
      ledger.transactions.push(txn)
    ledgerCtrl.setFocusToBlankTxn(ledger, txn, type)

  ledgerCtrl.checkForExistingblankTransaction = (ledger, type) ->
    hasBlank = false
    _.each ledger.transactions, (txn) ->
      if txn.particular.uniqueName == "" && type == txn.type
        hasBlank = true
    return hasBlank

  ledgerCtrl.setFocusToBlankTxn = (ledger, txn, type) ->
    ledgerCtrl.prevTxn.isOpen = false
    _.each ledger.transactions, (trn) ->
      if trn.particular.uniqueName == "" && trn.type == type
        ledgerCtrl.createNewPanel(trn, ledger)
        trn.isOpen = true
        ledgerCtrl.prevTxn = trn

  ledgerCtrl.clearDiscounts = (ledger) ->
    if ledgerCtrl.discountAccount
      _.each ledgerCtrl.discountAccount.accountDetails, (account) ->
        account.amount = 0

  ledgerCtrl.matchInventory = (ledger) ->
    stockTxn = ledgerCtrl.getStockTxn(ledger)
    if stockTxn && stockTxn.inventory
      ledger.panel.quantity = stockTxn.inventory.quantity
      ledger.panel.price = ledger.panel.amount / ledger.panel.quantity
      # add stock name to transaction.particular to show on view
      stockTxn.particular.name += ' (' + stockTxn.inventory.stock.name + ')'
      ledger.showStock = true
    if stockTxn.particular && stockTxn.particular.stock
      ledger.panel.units = stockTxn.particular.stock.accountStockDetails.unitRates
      ledger.panel.unit =  ledger.panel.units[0]
      if ledger.panel.unit
        ledger.panel.price = ledger.panel.unit.rate
      else
        ledger.panel.price = 0
      ledger.showStock = true
    
    # match = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:txn.particular.uniqueName})
    # if match && match.stocks != null
    #   txn.inventory = angular.copy(match.stock, txn.inventory)

  ledgerCtrl.isDiscountTxn = (txn) ->
    isDiscount = false
    dTxn = _.findWhere(ledgerCtrl.discountAccount.accountDetails, {uniqueName: txn.particular.uniqueName})
    if dTxn
      isDiscount = true
    return isDiscount


  ledgerCtrl.isTransactionContainsTax = (ledger) ->
    if ledger.taxes and ledger.taxes.length > 0
      ledger.taxList = []
      _.each ledgerCtrl.taxList, (tax) ->
        if ledger.taxes.indexOf(tax.uniqueName) != -1 
          tax.isChecked = true
          ledger.taxList.push(tax)

  ledgerCtrl.getPanelAmount = (ledger) ->
    amount = 0
    if ledger.transactions.length > 1 && !ledger.isBlankLedger
      _.each ledger.transactions, (txn) ->
        acc = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:txn.particular.uniqueName})
        if acc
          parent = acc.parentGroups[0].uniqueName
          discount = _.findWhere(acc.parentGroups, {uniqueName:"discount"})
          parentGroup = _.findWhere($rootScope.groupWithAccountsList, {uniqueName:parent}) 
          if parentGroup.category == "income" || parentGroup.category == "expenses" && !txn.isTax && txn.particular.uniqueName != 'roundoff' && !discount
            amount += Number(txn.amount)
            ledger.panel.show = true
    else if !ledger.isBlankLedger
      amount = Number(ledger.transactions[0].amount)
      ledger.panel.show = true
    else if ledger.isBlankLedger
      _.each ledger.transactions, (txn) ->
        amount += Number(txn.amount)
    return amount

  ledgerCtrl.getTotalDiscount = (ledger) ->
    discount = 0
    amounts = []
    if ledgerCtrl.discountAccount != undefined
      _.each ledgerCtrl.discountAccount.accountDetails, (account) ->
        _.each ledger.transactions, (txn) ->
          if txn.particular.uniqueName == account.uniqueName
            amounts.push(txn.amount)
        if account.amount
          discount += Number(account.amount)
      _.each amounts, (amount) ->
        discount += amount
      ledger.panel.total = ledgerCtrl.cutToTwoDecimal(ledger.panel.amount - discount + (ledger.panel.tax*(ledger.panel.amount-discount)/100))
      ledger.panel.discount = ledgerCtrl.cutToTwoDecimal(discount)
    discount

  ledgerCtrl.getTotalTax = (ledger) ->
    totalTax = 0
    if ledgerCtrl.taxList.length > 0
      _.each ledgerCtrl.taxList, (tax) ->
        if ledgerCtrl.isTaxApplicable(tax) && tax.isChecked
          taxAmount = ledger.panel.amount * ledgerCtrl.getApplicableTaxRate(tax) /100
          totalTax += taxAmount
    taxPercentage = ledgerCtrl.cutToTwoDecimal((totalTax/ledger.panel.amount)*100)
    ledger.panel.total = ledgerCtrl.cutToTwoDecimal(ledger.panel.amount - ledger.panel.discount + (taxPercentage*(ledger.panel.amount-ledger.panel.discount)/100))
    ledger.panel.tax = ledgerCtrl.cutToTwoDecimal(taxPercentage)
    taxPercentage || 0

  ledgerCtrl.isTaxApplicable = (tax) ->
    today = new Date()
    today = today.getTime()
    isApplicable = false
    _.each tax.taxDetail, (det) ->
      if today > ledgerCtrl.parseLedgerDate(det.date) 
        isApplicable = true
    isApplicable

  ledgerCtrl.getApplicableTaxRate = (tax) ->
    rate = 0
    today = new Date()
    today = today.getTime()
    _.each tax.taxDetail, (det) ->
      if today > ledgerCtrl.parseLedgerDate(det.date) 
        rate = det.taxValue
    rate

  ledgerCtrl.parseLedgerDate = (date) ->
    date = date.split('-')
    date = date[2] + '-' + date[1] + '-' + date[0]
    date = new Date(date).getTime()
    date

  ledgerCtrl.onAmountChange = (ledger) ->
    ledgerCtrl.getTotalTax(ledger)
    ledgerCtrl.getTotalDiscount(ledger)
    if ledgerCtrl.selectedLedger.panel.quantity > 0
      ledgerCtrl.selectedLedger.panel.price = ledgerCtrl.cutToTwoDecimal(ledgerCtrl.selectedLedger.panel.amount / ledgerCtrl.selectedLedger.panel.quantity)

    
  ledgerCtrl.onQuantityChange = (ledger) ->
    ledgerCtrl.selectedLedger.panel.amount = ledgerCtrl.cutToTwoDecimal(ledgerCtrl.selectedLedger.panel.quantity * ledgerCtrl.selectedLedger.panel.price)
    ledgerCtrl.getTotalTax(ledger)
    ledgerCtrl.getTotalDiscount(ledger)
    ledgerCtrl.updateTxnAmount()

  ledgerCtrl.onPriceChange = (ledger) ->
    ledgerCtrl.selectedLedger.panel.amount = ledgerCtrl.cutToTwoDecimal(ledgerCtrl.selectedLedger.panel.quantity * ledgerCtrl.selectedLedger.panel.price)
    ledgerCtrl.getTotalTax(ledger)
    ledgerCtrl.getTotalDiscount(ledger)
    ledgerCtrl.updateTxnAmount()

  # ledgerCtrl.onstockUnitChange = (ledger) ->
  #   ledger.panel.unit.code = ledger.panel.unit.stockUnitCode
  #   ledger.panel.price = ledgerCtrl.selectedLedger.panel.unit.rate
  #   ledger.panel.amount = ledgerCtrl.selectedLedger.panel.unit.rate * ledgerCtrl.selectedLedger.panel.quantity
  #   ledgerCtrl.getTotalTax(ledger)
  #   ledgerCtrl.getTotalDiscount(ledger)
  #   ledgerCtrl.updateTxnAmount()

  ledgerCtrl.getTxnCategory = (txn) ->
    category = ''
    account = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:txn.particular.uniqueName})
    if account
      parent = account.parentGroups[0].uniqueName
      parentGroup = _.findWhere($rootScope.groupWithAccountsList, {uniqueName:parent})
      category = parentGroup.category
    return category

  ledgerCtrl.onTxnAmountChange = (txn)->
    if !ledgerCtrl.isDiscountTxn(txn) && (ledgerCtrl.getTxnCategory(txn) == 'income' || ledgerCtrl.getTxnCategory(txn) == 'expenses')
      ledgerCtrl.selectedLedger.panel.amount = Number(txn.amount)
      ledgerCtrl.getTotalTax(ledgerCtrl.selectedLedger)
      ledgerCtrl.getTotalDiscount(ledgerCtrl.selectedLedger)
      # ledgerCtrl.updateTxnAmount()

  ledgerCtrl.onTxnTotalChange = (txn)->
    ledgerCtrl.selectedLedger.panel.amount = ledgerCtrl.calculateAmountAfterInclusiveTax()
    stockTxn = ledgerCtrl.getStockTxn(ledgerCtrl.selectedLedger)
    stockTxn.amount = ledgerCtrl.selectedLedger.panel.amount
    if ledgerCtrl.selectedLedger.panel.quantity > 0
      ledgerCtrl.selectedLedger.panel.price = ledgerCtrl.cutToTwoDecimal(ledgerCtrl.selectedLedger.panel.amount / ledgerCtrl.selectedLedger.panel.quantity)
    ledgerCtrl.updateTxnAmount()

  ledgerCtrl.onstockUnitChange = (ledger) ->
    ledger.panel.price = ledger.panel.unit.rate
    ledger.panel.quantity = ledgerCtrl.cutToTwoDecimal(ledger.panel.amount / ledger.panel.price)
    # ledgerCtrl.onPriceChange(ledgerCtrl.selectedLedger)

  ledgerCtrl.updateTxnAmount = () ->
    _.each ledgerCtrl.selectedLedger.transactions, (txn) ->
      if ledgerCtrl.getTxnCategory(txn) == 'income' || ledgerCtrl.getTxnCategory(txn) == 'expenses' && !txn.isTax && txn.particular.uniqueName != 'roundoff' && !ledgerCtrl.isDiscountTxn(txn)
        txn.amount = ledgerCtrl.selectedLedger.panel.amount

    # ledgerCtrl.selectedLedger.isInclusiveTax = true
    # ledgerCtrl.getTotalTax(ledgerCtrl.selectedLedger)
    # ledgerCtrl.getTotalDiscount(ledgerCtrl.selectedLedger)


  ledgerCtrl.calculateAmountAfterInclusiveTax = (tax) ->
    if !ledgerCtrl.selectedLedger.panel.discount 
      amount = (100*ledgerCtrl.selectedLedger.panel.total)/(100+(ledgerCtrl.selectedLedger.panel.tax||0))
    else
      amount = (100*ledgerCtrl.selectedLedger.panel.total)/(100+(ledgerCtrl.selectedLedger.panel.tax||0)) + ledgerCtrl.selectedLedger.panel.discount
    amount = Number(amount.toFixed(2))
    amount    

  ledgerCtrl.cutToTwoDecimal = (num) ->
    num = Number(num)
    num = Number(num.toFixed(2))
    return num
    # num = num%1
    # if(num)
    #   num = num.toString()
    #   num = num.split('.')
    #   if num[1].length > 1
    #     num = num[0] + '.' + num[1][0] + num[1][1] + num[1][2]
    #   else
    #     num = num[0] + '.' + num[1][0]
    # num = Number(num)
    # return Math.ceil(num)


  ledgerCtrl.createEntry = () ->

  ledgerCtrl.showExportOption = false
  ledgerCtrl.exportOptions = () ->
    ledgerCtrl.showExportOption = !ledgerCtrl.showExportOption

  ledgerCtrl.exportLedger = (type)->
    ledgerCtrl.showExportOption = false
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: ledgerCtrl.accountUnq
      fromDate: $filter('date')($scope.cDate.startDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.cDate.endDate, "dd-MM-yyyy")
      lType:type
    }
    accountService.exportLedger(unqNamesObj).then(ledgerCtrl.exportLedgerSuccess, ledgerCtrl.exportLedgerFailure)

  ledgerCtrl.exportLedgerSuccess = (res)->
    data = ledgerCtrl.b64toBlob(res.body, "application/vnd.ms-excel", 512)
    FileSaver.saveAs(data, $rootScope.selectedAccount.name + '.xls')
    # ledgerCtrl.isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0
    # if $rootScope.msieBrowser()
    #   $rootScope.openWindow(res.body.filePath)
    # else if ledgerCtrl.isSafari       
    #   modalInstance = $uibModal.open(
    #     template: '<div>
    #         <div class="modal-header">
    #           <h3 class="modal-title">Download File</h3>
    #         </div>
    #         <div class="modal-body">
    #           <p class="mrB">To download your file Click on button</p>
    #           <button onClick="window.open(\''+res.body.filePath+'\')" class="btn btn-primary">Download</button>
    #         </div>
    #         <div class="modal-footer">
    #           <button class="btn btn-default" ng-click="$dismiss()">Cancel</button>
    #         </div>
    #     </div>'
    #     size: "sm"
    #     backdrop: 'static'
    #     scope: $scope
    #   )
    # else
    #   window.open(res.body.filePath)

  ledgerCtrl.exportLedgerFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  ledgerCtrl.getTaxList = () ->
    ledgerCtrl.taxList = []
    if $rootScope.canUpdate and $rootScope.canDelete
      companyServices.getTax($rootScope.selectedCompany.uniqueName).then(ledgerCtrl.getTaxListSuccess, ledgerCtrl.getTaxListFailure)

  ledgerCtrl.getTaxList()

  ledgerCtrl.getTaxListSuccess = (res) ->
    _.each res.body, (tax) ->
      tax.isSelected = false
      if tax.account == null
        tax.account = {}
        tax.account.uniqueName = 0
      #check if selected account is a tax account
      if tax.account.uniqueName == ledgerCtrl.accountToShow.uniqueName
        ledgerCtrl.accountToShow.isTax = true
      ledgerCtrl.taxList.push(tax)

    #ledgerCtrl.matchTaxAccounts(ledgerCtrl.taxList)

  ledgerCtrl.getTaxListFailure = (res) ->
    toastr.error(res.data.message, res.status)

  ledgerCtrl.getDiscountGroupDetail = () ->
    @success = (res) ->
      ledgerCtrl.discountAccount = _.findWhere(res.body.results, {groupUniqueName:'discount'})
    @failure = (res) ->
    
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    reqParam.q = 'discount'
    reqParam.page = 1
    reqParam.count = 0
    groupService.getFlattenGroupAccList(reqParam).then(@success, @failure) 

  # ledgerCtrl.getGroupsList = () ->
  #   @success = (res) ->
  #     ledgerCtrl.groupList = res.body
  #   @failure = (res) ->

  #   groupService.getGroupsWithoutAccountsCropped($rootScope.selectedCompany.uniqueName).then(@success, @failure)
  # ledgerCtrl.getGroupsList()

  ledgerCtrl.checkTransactionByUniqueName = (transactions, uniqueName) ->
    hasTransaction = false
    _.each transactions, (txn) ->
      if txn.particular.uniqueName == uniqueName
        hasTransaction = true
    return hasTransaction


  ledgerCtrl.addDiscountTxns = (ledger) ->
    if ledgerCtrl.discountAccount != undefined
      _.each ledgerCtrl.discountAccount.accountDetails, (account) ->
        if account.amount > 0
          txn = {}
          txn.amount = account.amount
          txn.particular = {}
          txn.particular.uniqueName = account.uniqueName
          txn.particular.name = account.name
          txn.type = ledgerCtrl.selectedTxn.type
          hasDiscount = ledgerCtrl.checkTransactionByUniqueName(ledger.transactions,account.uniqueName)
          if !hasDiscount
            ledger.transactions.push(txn)

  ledgerCtrl.removeBlankTransactions = (ledger) ->
    transactions = []
    _.each ledger.transactions, (txn, i) ->
      if txn && !txn.blankRow && txn.particular.uniqueName != ''
        transactions.push(txn)
    return transactions

  ledgerCtrl.getStockTxn = (ledger) ->
    stockTxn = {}
    _.each ledger.transactions, (txn) ->
      if txn.particular.uniqueName.length > 0 && txn.particular.stocks 
        stockTxn = txn
      if txn.inventory
        stockTxn = txn
    return stockTxn

  ledgerCtrl.addStockDetails = (ledger) ->
    if ledger.transactions[0].particular.stocks
      stockTxn = ledger.transactions[0]
    else
      stockTxn = ledgerCtrl.getStockTxn(ledger)
    if !_.isEmpty(stockTxn) && !stockTxn.inventory
      stockTxn.inventory = {}
      stockTxn.inventory.stock = stockTxn.particular.stocks[0]
      stockTxn.inventory.quantity = ledger.panel.quantity
      stockTxn.inventory.unit = stockTxn.particular.stocks[0].stockUnit
      stockTxn.amount = ledger.panel.total
    else if !_.isEmpty(stockTxn)
      if !stockTxn.particular.stock
        stockTxn.inventory.quantity = ledger.panel.quantity
        if ledger.panel.unit
          stockTxn.inventory.unit = ledger.panel.unit
          stockTxn.inventory.unit.code = ledger.panel.unit.stockUnitCode
      else
        stockTxn.inventory.stock = stockTxn.particular.stock
        stockTxn.inventory.quantity = ledger.panel.quantity
        stockTxn.inventory.unit = ledger.panel.unit
        stockTxn.inventory.unit.code = ledger.panel.unit.stockUnitCode

      if stockTxn.amount != ledger.panel.amount
        ledgerCtrl.updateTxnAmount()
      # if stockTxn.amount != ledger.panel.total
      #   stockTxn.amount = ledger.panel.total

  ledgerCtrl.addStockDetailsForNewEntry = (ledger) ->
    _.each ledger.transactions, (txn) ->
      if txn.particular.stock
        inventory = {}
        inventory.stock = txn.particular.stock
        inventory.quantity = txn.panel.quantity
        inventory.unit = txn.particular.stock.stockUnit
        txn.inventory = inventory
        txn.amount = txn.panel.total

  ledgerCtrl.isNotDiscountTxn = (txn) ->
    particularAccount = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:txn.particular.uniqueName})
    hasDiscountasParent = _.findWhere(particularAccount.parentGroups, {uniqueName:'discount'})
    if hasDiscountasParent
      return true
    else
      return false

  ledgerCtrl.setAmount = (ledger) ->
    _.each ledger.transactions, (txn) ->
      if !txn.isTax && !ledgerCtrl.isNotDiscountTxn(txn)
        txn.amount = txn.panel.total

  ledgerCtrl.buildLedger = (ledger) ->
    ledger.transactions = ledgerCtrl.removeBlankTransactions(ledger)
    if !ledger.isBlankLedger
      ledgerCtrl.addStockDetails(ledger)
    else
      ledgerCtrl.addStockDetailsForNewEntry(ledger)
      ledgerCtrl.setAmount(ledger)
      ledgerCtrl.ledgerBeforeEdit = {}
      angular.copy(ledger,ledgerCtrl.ledgerBeforeEdit)
    ledgerCtrl.addDiscountTxns(ledger)
    delete ledger.panel
    ledger

  ledgerCtrl.removeTaxTransactions = (ledger) ->
    transactions = []
    _.each ledger.transactions, (txn) ->
      if !txn.isTax
        transactions.push(txn)
    transactions

  ledgerCtrl.lastSelectedLedger = {}
  ledgerCtrl.saveUpdateLedger = (ledger) ->
    if !ledger.isBankTransaction
      ledger = ledgerCtrl.buildLedger(ledger)
    ledgerCtrl.lastSelectedLedger = ledger
    #ledgerCtrl.formatInventoryTxns(ledger)
    if ledgerCtrl.doingEntry == true
      return

    ledgerCtrl.doingEntry = true
    ledgerCtrl.ledgerTxnChanged = false
    if ledger.isBankTransaction
      ledgerCtrl.btIndex = ledger.index
    delete ledger.isCompoundEntry
    if !_.isEmpty(ledger.voucher.shortCode) 
      if _.isEmpty(ledger.uniqueName)
        #add new entry
        unqNamesObj = {
          compUname: $rootScope.selectedCompany.uniqueName
          acntUname: ledgerCtrl.accountUnq
        }
        delete ledger.uniqueName
        delete ledger.voucherNo
        transactionsArray = []
        rejectedTransactions = []
        transactionsArray = _.reject(ledger.transactions, (led) ->
         if led.particular == "" || led.particular.uniqueName == ""
           rejectedTransactions.push(led)
           return led
        )
        ledger.transactions = transactionsArray
        ledger.voucherType = ledger.voucher.shortCode
        ledgerCtrl.addTaxesToLedger(ledger)
        if ledger.transactions.length > 0
          if ledger.transactions.length > 1
            ledgerCtrl.matchTaxTransactions(ledger.transactions, ledgerCtrl.taxList)
            ledgerCtrl.checkManualTaxTransaction(ledger.transactions, ledgerCtrl.ledgerBeforeEdit.transactions)
            ledgerCtrl.checkTaxCondition(ledger)
          ledgerService.createEntry(unqNamesObj, ledger).then(
            (res) -> ledgerCtrl.addEntrySuccess(res, ledger)
            (res) -> ledgerCtrl.addEntryFailure(res,rejectedTransactions, ledger))
        else
          ledgerCtrl.doingEntry = false
          ledger.transactions = rejectedTransactions
          response = {}
          response.data = {}
          response.data.message = "There must be at least a transaction to make an entry."
          response.data.status = "Error"
          ledgerCtrl.addEntryFailure(response,[])
#          toastr.error("There must be at least a transaction to make an entry.")
      else
        #update entry
        #ledgerCtrl.removeEmptyTransactions(ledger.transactions)
        ledger.transactions = ledgerCtrl.removeTaxTransactions(ledger)
        _.each ledger.transactions, (txn) ->
          if !_.isEmpty(txn.particular.uniqueName)
            particular = {}
            particular.name = txn.particular.name
            particular.uniqueName = txn.particular.uniqueName
            txn.particular = particular
          if txn.inventory && (txn.inventory.quantity == "" || txn.inventory.quantity == undefined || txn.inventory.quantity == null)
            delete txn.inventory
  #      ledger.isInclusiveTax = false
        unqNamesObj = {
          compUname: $rootScope.selectedCompany.uniqueName
          acntUname: ledgerCtrl.accountUnq
          entUname: ledger.uniqueName
        }
        if ledgerCtrl.currentTxn.isCompoundEntry && ledgerCtrl.currentTxn.isBaseAccount
          unqNamesObj.acntUname = ledgerCtrl.currentTxn.particular.uniqueName

        # transactionsArray = []
        # _.every(ledgerCtrl.blankLedger.transactions,(led) ->
        #   delete led.date
        #   delete led.parentGroups
        # )
        # _.each(ledger.)
        # transactionsArray = _.reject(ledgerCtrl.blankLedger.transactions, (led) ->
        #   led.particular.uniqueName == ""
        # )
        ledgerCtrl.addTaxesToLedger(ledger)
#        console.log ledger
        #ledger.transactions.push(transactionsArray)
        ledger.voucher = _.findWhere(ledgerCtrl.voucherTypeList,{'shortCode':ledger.voucher.shortCode})
        ledger.voucherType = ledger.voucher.shortCode
        if ledger.transactions.length > 0
          ledgerCtrl.matchTaxTransactions(ledger.transactions, ledgerCtrl.taxList)
          ledgerCtrl.matchTaxTransactions(ledgerCtrl.ledgerBeforeEdit.transactions, ledgerCtrl.taxList)
          ledgerCtrl.checkManualTaxTransaction(ledger.transactions, ledgerCtrl.ledgerBeforeEdit.transactions)
          updatedTxns = ledgerCtrl.updateEntryTaxes(ledger.transactions)
          ledger.transactions = updatedTxns
          ledgerCtrl.checkTaxCondition(ledger)
          isModified = false
          if ledger.taxes.length > 0
            isModified = ledgerCtrl.checkPrincipleModifications(ledger, ledgerCtrl.ledgerBeforeEdit.transactions)
          if isModified
            # ledgerCtrl.selectedTxn.isOpen = false
            modalService.openConfirmModal(
              title: 'Update'
              body: 'Principle transaction updated, Would you also like to update tax transactions?',
              ok: 'Yes',
              cancel: 'No'
            ).then(
                (res) -> ledgerCtrl.UpdateEntry(ledger, unqNamesObj, true),
                (res) -> ledgerCtrl.UpdateEntry(ledger, unqNamesObj, false)
            )
          else
           ledgerService.updateEntry(unqNamesObj, ledger).then(
             (res) -> ledgerCtrl.updateEntrySuccess(res, ledger)
             (res) -> ledgerCtrl.updateEntryFailure(res, ledger)
           )
        else
          ledgerCtrl.doingEntry = false
          response = {}
          response.data = {}
          response.data.message = "There must be at least a transaction to make an entry."
          response.data.status = "Error"
          ledgerCtrl.addEntryFailure(response,[])
    else
      toastr.error("Select voucher type.")


  ledgerCtrl.checkTaxCondition = (ledger) ->
    transactions = []
    _.each ledger.transactions, (txn) ->
      if ledger.isInclusiveTax && !txn.isTax
        transactions.push(txn)
    if ledger.isInclusiveTax
      ledger.transactions = transactions

  ledgerCtrl.checkPrincipleModifications = (ledger, uTxnList) ->
    withoutTaxesLedgerTxn = ledgerCtrl.getPrincipleTxnOnly(ledger.transactions)
    withoutTaxesUtxnList = ledgerCtrl.getPrincipleTxnOnly(uTxnList)
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

  ledgerCtrl.checkManualTaxTransaction = (txnList, uTxnList) ->
    #console.log txnList.length, uTxnList.length
    _.each txnList, (txn) ->
      txn.isManualTax = true
      _.each uTxnList, (uTxn) ->
        if txn.particular.uniqueName == uTxn.particular.uniqueName && txn.isTax
          txn.isManualTax = false
    return 

  ledgerCtrl.getPrincipleTxnOnly = (txnList) ->
    transactions = []
    _.each txnList, (txn) ->
      if txn.isTax == undefined || !txn.isTax
        transactions.push(txn)
    transactions

  ledgerCtrl.addTaxesToLedger = (ledger) ->
    ledger.taxes = []
    _.each(ledgerCtrl.taxList, (tax) ->
      if tax.isChecked == true
        ledger.taxes.push(tax.uniqueName)
    )

  ledgerCtrl.updateEntryTaxes = (txnList) ->
    transactions = []
    if txnList.length > 1
      _.each txnList, (txn, idx) ->
        _.each ledgerCtrl.taxList, (tax) ->
          if txn.particular.uniqueName == tax.account.uniqueName && !tax.isChecked
            if !txn.isManualTax
              txn.toRemove = true 
              #transactions.push(txn)
              #txnList.splice(idx, 1)
    txnList = _.filter(txnList, (txn)->
      return txn.toRemove == undefined || txn.toRemove == false
    )
    txnList

  ledgerCtrl.isTransactionContainsTax = (ledger) ->
    if ledger.taxes and ledger.taxes.length > 0
      ledger.taxList = []
      _.each ledgerCtrl.taxList, (tax) ->
        if ledger.taxes.indexOf(tax.uniqueName) != -1 
          tax.isChecked = true
          ledger.taxList.push(tax)

    # if ledger.taxes != undefined && ledger.taxes.length > 0
    #   _.each(ledgerCtrl.taxList, (tax) ->
    #     tax.isChecked = false
    #     _.each(ledger.taxes, (taxe) ->
    #       if taxe == tax.uniqueName
    #         tax.isChecked = true
    #     )
    #   )
    # else
    #   _.each(ledgerCtrl.taxList, (tax) ->
    #     #tax.isChecked = false
    #     _.each(ledger.transactions, (txn) ->
    #       if txn.particular.uniqueName == tax.account.uniqueName
    #         tax.isChecked = true
    #     )
    #   )

  ledgerCtrl.UpdateEntry = (ledger, unqNamesObj,removeTax) ->
    if removeTax == true
      ledgerCtrl.txnAfterRmovingTax = []
      ledgerCtrl.removeTaxTxnOnPrincipleTxnModified(ledger.transactions)
      ledger.transactions = ledgerCtrl.txnAfterRmovingTax
    if ledger.transactions.length > 0
      ledgerService.updateEntry(unqNamesObj, ledger).then(
        (res) -> ledgerCtrl.updateEntrySuccess(res, ledger)
        (res) -> ledgerCtrl.updateEntryFailure(res, ledger)
      )

  ledgerCtrl.matchTaxTransactions = (txnList, taxList) ->
    _.each txnList, (txn) ->
      _.each taxList, (tax) ->
        if txn.particular.uniqueName == tax.account.uniqueName
          txn.isTax = true

  ledgerCtrl.removeTaxTxnOnPrincipleTxnModified = (txnList) ->
    _.each txnList, (txn) ->
      if !txn.isTax
        ledgerCtrl.txnAfterRmovingTax.push(txn)

  ledgerCtrl.resetBlankLedger = () ->
    ledgerCtrl.newDebitTxn = {
      date: $filter('date')(new Date(), "dd-MM-yyyy")
      particular: {
        name:''
        uniqueName:''
      }
      amount : 0
      type: 'DEBIT'
    }
    ledgerCtrl.newCreditTxn = {
      date: $filter('date')(new Date(), "dd-MM-yyyy")
      particular: {
        name:''
        uniqueName:''
      }
      amount : 0
      type: 'CREDIT'
    }
    ledgerCtrl.blankLedger = {
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
        ledgerCtrl.newDebitTxn
        ledgerCtrl.newCreditTxn
      ]
      unconfirmedEntry:false
      isInclusiveTax: true
      uniqueName:""
      voucher:{
        name:"Sales"
        shortCode:"sal"
      }
      tax:[]
      taxList: []
      voucherNo:null
    }

  ledgerCtrl.addEntrySuccess = (res, ledger) ->
    ledgerCtrl.doingEntry = false
    ledger.failed = false
    toastr.success("Entry created successfully", "Success")
    #addThisLedger = {}
    #_.extend(addThisLedger,ledgerCtrl.selectedLedger)
    #ledgerCtrl.ledgerData.ledgers.push(res.body)
    #ledgerCtrl.getLedgerData(false)
    # ledgerCtrl.getPaginatedLedger(ledgerCtrl.currentPage)
    ledgerCtrl.resetBlankLedger()
    ledgerCtrl.selectedLedger = ledgerCtrl.blankLedger
    _.each(ledgerCtrl.taxList, (tax) ->
      tax.isChecked = false
    )
    ledgerCtrl.selectedTxn.isOpen = false
    if ledgerCtrl.mergeTransaction
      $timeout ( ->
        ledgerCtrl.mergeBankTransactions(ledgerCtrl.mergeTransaction)
      ), 2000
    #ledgerCtrl.updateLedgerData('new',res.body[0])
    #ledgerCtrl.addToIdb([res.body], ledgerCtrl.accountUnq)
    #ledgerCtrl.pushNewEntryToLedger(res.body)
    if ledger.isBankTransaction
      ledgerCtrl.updateBankLedger(ledger)
    #ledgerCtrl.getPaginatedLedger(ledgerCtrl.currentPage)
    ledgerCtrl.getTransactions(ledgerCtrl.currentPage)
    # $timeout ( ->
    #   ledgerCtrl.pageLoader = false
    #   ledgerCtrl.showLoader = false
    # ), 1000

  ledgerCtrl.addEntryFailure = (res, rejectedTransactions, ledger) ->
    ledgerCtrl.doingEntry = false
    ledger.failed = true
    toastr.error(res.data.message, res.data.status)
    ledgerCtrl.selectedLedger = ledgerCtrl.ledgerBeforeEdit
    # if rejectedTransactions.length > 0
    #   _.each(rejectedTransactions, (rTransaction) ->
    #     ledgerCtrl.selectedLedger.transactions.push(rTransaction)
    #   )
    # $timeout ( ->
    #   ledgerCtrl.pageLoader = false
    #   ledgerCtrl.showLoader = false
    # ), 1000

  ledgerCtrl.updateBankLedger = (ledger) ->
    _.each ledgerCtrl.eLedgerData, (eledger, idx) ->
      if ledger.transactionId == eledger.transactionId
        ledgerCtrl.eLedgerData.splice(idx, 1)
    #ledgerCtrl.getLedgerData()
    # ledgerCtrl.getPaginatedLedger(ledgerCtrl.currentPage)
    ledgerCtrl.getTransactions(ledgerCtrl.currentPage)

  # ledgerCtrl.pushNewEntryToLedger = (newLedgers) ->
  #   console.log newLedgers

    # _.each newLedgers, (ledger) ->
    #   ledgerCtrl.calculateEntryTotal(ledger)
    #   ledgerCtrl.ledgerData.ledgers.push(ledger)

  ledgerCtrl.resetLedger = () ->
    ledgerCtrl.resetBlankLedger()
    ledgerCtrl.selectedLedger = ledgerCtrl.blankLedger
    _.each(ledgerCtrl.taxList, (tx) ->
      tx.isChecked = false
    )

  ledgerCtrl.updateEntrySuccess = (res, ledger) ->
    ledgerCtrl.doingEntry = false
    ledger.failed = false
    ledgerCtrl.paginatedLedgers = [res.body]
    ledgerCtrl.selectedLedger = res.body
    ledgerCtrl.clearTaxSelection(ledgerCtrl.selectedLedger)
    ledgerCtrl.clearDiscounts(ledgerCtrl.selectedLedger)
    ledgerCtrl.isTransactionContainsTax(ledgerCtrl.selectedLedger)
    ledgerCtrl.createPanel(ledgerCtrl.selectedLedger)
    ledgerCtrl.entryTotal = ledgerCtrl.getEntryTotal(ledgerCtrl.selectedLedger)
    ledgerCtrl.matchInventory(ledgerCtrl.selectedLedger)
    toastr.success("Entry updated successfully.", "Success")
    # ledgerCtrl.paginatedLedgers = [res.body]
    # ledgerCtrl.selectedLedger = res.body
    # ledgerCtrl.clearTaxSelection(ledgerCtrl.selectedLedger)
    # ledgerCtrl.clearDiscounts(ledgerCtrl.selectedLedger)
    # ledgerCtrl.isTransactionContainsTax(ledgerCtrl.selectedLedger)
    # ledgerCtrl.createPanel(ledgerCtrl.selectedLedger)
    # ledgerCtrl.entryTotal = ledgerCtrl.getEntryTotal(ledgerCtrl.selectedLedger)
    # ledgerCtrl.matchInventory(ledgerCtrl.selectedLedger)
    ledgerCtrl.addBlankTransactionIfOneSideEmpty(ledgerCtrl.selectedLedger)
    ledgerCtrl.ledgerBeforeEdit = {}
    ledgerCtrl.ledgerBeforeEdit = angular.copy(res.body,ledgerCtrl.ledgerBeforeEdit)
    _.each res.body.transactions, (txn) ->
      if txn.particular.uniqueName == ledgerCtrl.clickedTxn.particular.uniqueName
        ledgerCtrl.selectedTxn = txn
    if ledgerCtrl.mergeTransaction
      ledgerCtrl.mergeBankTransactions(ledgerCtrl.mergeTransaction)
    ledgerCtrl.setVoucherCode(ledgerCtrl.selectedLedger)
    ledgerCtrl.getTransactions(ledgerCtrl.currentPage)
    
  ledgerCtrl.updateEntryFailure = (res, ledger) ->
    ledgerCtrl.doingEntry = false
    ledger = ledgerCtrl.ledgerBeforeEdit
    toastr.error(res.data.message, res.data.status)
    # $timeout ( ->
    #   ledgerCtrl.pageLoader = false
    #   ledgerCtrl.showLoader = false
    # ), 1000
    
  ledgerCtrl.createLedger = (ledger, type) ->
    txns = []
    tLdr = {}
    tLdr = angular.copy(ledger, tLdr)
    if tLdr.transactions.length
      _.each tLdr.transactions, (txn) ->
        if txn.type == type
          txns.push(txn)
      tLdr.transactions = txns
    tLdr

  ledgerCtrl.closePopOverSingleLedger = (ledger) ->
    _.each ledger.transactions, (txn) ->
      txn.isOpen = false

  ledgerCtrl.deleteEntryConfirm = (ledger) ->
    modalService.openConfirmModal(
      title: 'Delete'
      body: 'Are you sure you want to delete this entry?',
      ok: 'Yes',
      cancel: 'No'
    ).then(
      (res) -> 
        ledgerCtrl.deleteEntry(ledger)
      (res) -> 
        $dismiss()
    )

  ledgerCtrl.deleteEntry = (ledger) ->
    # ledgerCtrl.pageLoader = true
    # ledgerCtrl.showLoader = true
    ledgerCtrl.lastSelectedLedger = ledger
    if (ledger.uniqueName == undefined || _.isEmpty(ledger.uniqueName)) && (ledger.isBankTransaction)
      return
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: ledgerCtrl.accountUnq
      entUname: ledger.uniqueName
    }
    if unqNamesObj.acntUname != '' || unqNamesObj.acntUname != undefined
      ledgerService.deleteEntry(unqNamesObj).then((res) ->
        ledgerCtrl.deleteEntrySuccess(ledger, res)
      , ledgerCtrl.deleteEntryFailure)

  ledgerCtrl.deleteEntrySuccess = (item, res) ->
    toastr.success("Entry deleted successfully","Success")
    ledgerCtrl.removeDeletedLedger(item)
    ledgerCtrl.resetBlankLedger()
    ledgerCtrl.selectedLedger = ledgerCtrl.blankLedger
    #ledgerCtrl.getLedgerData(false)
    # ledgerCtrl.getPaginatedLedger(ledgerCtrl.currentPage)
    ledgerCtrl.getTransactions(ledgerCtrl.currentPage)
    if ledgerCtrl.mergeTransaction
      $timeout ( ->
        ledgerCtrl.mergeBankTransactions(ledgerCtrl.mergeTransaction)
      ), 2000
#    ledgerCtrl.calculateLedger(ledgerCtrl.ledgerData, "deleted")
    #ledgerCtrl.updateLedgerData('delete')

  
  ledgerCtrl.deleteEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  ledgerCtrl.removeDeletedLedger = (item) ->
    if ledgerCtrl.dLedgerContainer.ledgerData[item.uniqueName]
      ledgerCtrl.dLedgerContainer.remove(item)
    if ledgerCtrl.cLedgerContainer.ledgerData[item.uniqueName]
      ledgerCtrl.cLedgerContainer.remove(item)

  ledgerCtrl.clearTaxSelection = (ledger) ->
    _.each ledgerCtrl.taxList, (tax) ->
      if ledger.taxes.indexOf(tax.uniqueName) == -1
        tax.isChecked = false

  ledgerCtrl.b64toBlob = (b64Data, contentType, sliceSize) ->
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


  $scope.invoiceFile = {}
  $scope.getInvoiceFile = (files) ->
    file = files[0]
    formData = new FormData()
    formData.append('file', file)
    formData.append('company', $rootScope.selectedCompany.uniqueName)

    @success = (res) ->
      ledgerCtrl.selectedLedger.attachedFile = res.data.body.uniqueName
      ledgerCtrl.selectedLedger.attachedFileName = res.data.body.name
      toastr.success('file uploaded successfully')

    @failure = (res) ->
      if typeof res == 'object'
        toastr.error(res.data.message)
      else
        toastr.error('Upload failed, please check that file size is less than 1 mb')

    url = '/upload-invoice'
    $http.post(url, formData, {
      transformRequest: angular.identity,
      headers: {'Content-Type': undefined}
    }).then(@success, @failure)

  ledgerCtrl.downloadAttachedFile = (file, e) ->
    e.stopPropagation()
    @success = (res) ->
      data = ledgerCtrl.b64toBlob(res.body.uploadedFile, "image/"+res.body.fileType)
      blobUrl = URL.createObjectURL(data)
      FileSaver.saveAs(data, res.body.name)

    @failure = (res) ->
      toastr.error(res.data.message)
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      accountsUniqueName: $rootScope.selectedAccount.uniqueName
      file:file
    }
    ledgerService.downloadInvoiceFile(reqParam).then(@success, @failure)

  ledgerCtrl.deleteAttachedFile = () ->
    modalService.openConfirmModal(
      title: 'Delete'
      body: 'Are you sure you want to delete the attached file?',
      ok: 'Yes',
      cancel: 'No'
    ).then(
      (res) -> 
          ledgerCtrl.selectedLedger.attachedFile = ''
          ledgerCtrl.selectedLedger.attachedFileName = ''
      (res) -> 
        $dismiss()
    )


  $timeout ( ->
    ledgerCtrl.getDiscountGroupDetail()
    ledgerCtrl.getTaxList()
  ), 2000

  if ledgerCtrl.accountUnq
    ledgerCtrl.getAccountDetail(ledgerCtrl.accountUnq)
  else
    ledgerCtrl.loadDefaultAccount() 

  $rootScope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE' 
      ledgerCtrl.loadDefaultAccount()
      ledgerCtrl.getTaxList()
      ledgerCtrl.getDiscountGroupDetail()
      #ledgerCtrl.getBankTransactions($rootScope.selectedAccount.uniqueName)

  $(document).on 'click', (e) ->
    if (!$(e.target).is('.account-list-item') && !$(e.target).is('.account-list-item strong')) && ledgerCtrl.prevTxn
      ledgerCtrl.prevTxn.isOpen = false
    return 0

#########################################################
  ledgerCtrl.ledgerPerPageCount = 15
  ledgerCtrl.getTransactions = (page) ->
    @success = (res) ->
      ledgerCtrl.txnData = res.body
      ledgerCtrl.totalLedgerPages = res.body.totalPages
      ledgerCtrl.currentPage = res.body.page
      ledgerCtrl.totalCreditTxn = res.body.creditTransactionsCount
      ledgerCtrl.totalDebitTxn = res.body.debitTransactionsCount
      ledgerCtrl.totalCredit = ledgerCtrl.getTotalBalance(ledgerCtrl.txnData.creditTransactions)
      ledgerCtrl.totalDebit = ledgerCtrl.getTotalBalance(ledgerCtrl.txnData.debitTransactions)
      ledgerCtrl.addLedgerPages()
      ledgerCtrl.showLedgers = true
      ledgerCtrl.calculateReckonging(ledgerCtrl.txnData)

    @failure = (res) ->
      toastr.error(res.data.message)

    if _.isUndefined($rootScope.selectedCompany.uniqueName)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: ledgerCtrl.accountUnq
      fromDate: $filter('date')($scope.cDate.startDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.cDate.endDate, "dd-MM-yyyy")
      count: ledgerCtrl.ledgerPerPageCount
      page: page
      sort: 'asc'
      reversePage: false
    }
    if not _.isEmpty(ledgerCtrl.accountUnq)
      ledgerService.getAllTransactions(unqNamesObj).then(@success, @failure)

  ledgerCtrl.calculateReckonging = () ->
    if ledgerCtrl.txnData.forwardedBalance.amount == 0
        recTotal = 0
        if ledgerCtrl.txnData.creditTotal > ledgerCtrl.txnData.debitTotal then  recTotal = ledgerCtrl.txnData.creditTotal else recTotal = ledgerCtrl.txnData.debitTotal
        ledgerCtrl.txnData.reckoningCreditTotal = recTotal
        ledgerCtrl.txnData.reckoningDebitTotal = recTotal
    else
      if ledgerCtrl.txnData.forwardedBalance.type == 'DEBIT'
        if ledgerCtrl.txnData.forwardedBalance.amount + ledgerCtrl.txnData.debitTotal <= ledgerCtrl.txnData.creditTotal
          ledgerCtrl.txnData.reckoningCreditTotal = ledgerCtrl.txnData.creditTotal
          ledgerCtrl.txnData.reckoningDebitTotal = ledgerCtrl.txnData.creditTotal
        else
          ledgerCtrl.txnData.reckoningCreditTotal = ledgerCtrl.txnData.forwardedBalance.amount + ledgerCtrl.txnData.debitTotal
          ledgerCtrl.txnData.reckoningDebitTotal = ledgerCtrl.txnData.forwardedBalance.amount + ledgerCtrl.txnData.debitTotal
      else
        if ledgerCtrl.txnData.forwardedBalance.amount + ledgerCtrl.txnData.creditTotal <= ledgerCtrl.txnData.debitTotal
          ledgerCtrl.txnData.reckoningCreditTotal = ledgerCtrl.txnData.debitTotal
          ledgerCtrl.txnData.reckoningDebitTotal = ledgerCtrl.txnData.debitTotal
        else
          ledgerCtrl.txnData.reckoningCreditTotal = ledgerCtrl.txnData.forwardedBalance.amount + ledgerCtrl.txnData.creditTotal
          ledgerCtrl.txnData.reckoningDebitTotal = ledgerCtrl.txnData.forwardedBalance.amount + ledgerCtrl.txnData.creditTotal

  ledgerCtrl.getEntryTotal = (ledger) ->
    entryTotal = {}
    entryTotal.crTotal = 0
    entryTotal.drTotal = 0
    _.each ledger.transactions, (txn) ->
      if txn.type == 'DEBIT'
        entryTotal.drTotal += Number(txn.amount)
      else
        entryTotal.crTotal += Number(txn.amount)
    if entryTotal.drTotal > entryTotal.crTotal then entryTotal.reckoning = entryTotal.drTotal else entryTotal.reckoning = entryTotal.crTotal
    entryTotal

  ledgerCtrl.selectCompoundEntry = (txn) ->
    ledgerCtrl.currentTxn = txn  

  ledgerCtrl.setVoucherCode = (ledger) ->
    _.each ledgerCtrl.voucherTypeList, (vc, i) ->
      if vc.shortCode == ledger.voucher.shortCode
        ledgerCtrl.paginatedLedgers[0].voucher = ledgerCtrl.voucherTypeList[i]

  ledgerCtrl.fetchEntryDetails = (entry) ->
    ledgerCtrl.clickedTxn = entry

    @success = (res) ->
      ledgerCtrl.paginatedLedgers = [res.body]
      ledgerCtrl.selectedLedger = res.body
      ledgerCtrl.clearTaxSelection(ledgerCtrl.selectedLedger)
      ledgerCtrl.clearDiscounts(ledgerCtrl.selectedLedger)
      ledgerCtrl.isTransactionContainsTax(ledgerCtrl.selectedLedger)
      ledgerCtrl.createPanel(ledgerCtrl.selectedLedger)
      ledgerCtrl.entryTotal = ledgerCtrl.getEntryTotal(ledgerCtrl.selectedLedger)
      ledgerCtrl.matchInventory(ledgerCtrl.selectedLedger)
      ledgerCtrl.addBlankTransactionIfOneSideEmpty(ledgerCtrl.selectedLedger)
      ledgerCtrl.ledgerBeforeEdit = {}
      
      ledgerCtrl.ledgerBeforeEdit = angular.copy(res.body,ledgerCtrl.ledgerBeforeEdit)
      _.each res.body.transactions, (txn) ->
        if txn.particular.uniqueName == ledgerCtrl.clickedTxn.particular.uniqueName
          ledgerCtrl.selectedTxn = txn
      ledgerCtrl.setVoucherCode(ledgerCtrl.selectedLedger)
      ledgerCtrl.displayEntryModal()

    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.selectedAccount.uniqueName
      entUname: entry.entryUniqueName
    }

    ledgerCtrl.baseAccount = ledgerCtrl.accountToShow

    if entry.isCompoundEntry && entry.isBaseAccount 
      reqParam.acntUname = entry.particular.uniqueName
      ledgerCtrl.editModeBaseAccount = entry.particular.name
      ledgerCtrl.baseAccount = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:entry.particular.uniqueName})
    else
      ledgerCtrl.editModeBaseAccount = ledgerCtrl.accountToShow.name

    ledgerService.getEntry(reqParam).then(@success, @failure)
    return 

  ledgerCtrl.addBlankTransactionIfOneSideEmpty = (ledger) ->
    cTxn = _.findWhere(ledger.transactions, {type:'CREDIT'})
    dTxn = _.findWhere(ledger.transactions, {type:'DEBIT'})
    if !cTxn
      txn = new txnModel('CREDIT')
      txn.blankRow = 'CREDIT'
      ledger.transactions.push(txn)
    if !dTxn
      txn = new txnModel('DEBIT')
      txn.blankRow = 'DEBIT'
      ledger.transactions.push(txn)

  ledgerCtrl.displayEntryModal = () ->
    $scope.ledgerCtrl = ledgerCtrl
    ledgerCtrl.entryModalInstance = $uibModal.open(
      templateUrl: '/public/webapp/Ledger/entryPopup.html'
      size: "liq90"
      animation: true
      backdrop: 'static'
      scope: $scope
    )

  ledgerCtrl.getTotalBalance = (transactions) ->
    total = 0
    _.each transactions, (txn) ->
      total += ledgerCtrl.cutToTwoDecimal(txn.amount)
    return total


  ledgerCtrl.deleteEntryConfirm = () ->
    modalService.openConfirmModal(
      title: 'Delete'
      body: 'Are you sure you want to delete this entry?',
      ok: 'Yes',
      cancel: 'No'
    ).then(
      (res) -> 
        ledgerCtrl.deleteEntry()
      (res) -> 
        $dismiss()
    )

  ledgerCtrl.deleteEntry = () ->
    @success = (res) ->
      toastr.success("Entry deleted successfully","Success")
      ledgerCtrl.getTransactions(ledgerCtrl.currentPage)
      ledgerCtrl.entryModalInstance.close()
    @failure = (res) ->
      toastr.error(res.data.message)
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: ledgerCtrl.accountUnq
      entUname: ledgerCtrl.selectedLedger.uniqueName
    }
    if unqNamesObj.acntUname != '' || unqNamesObj.acntUname != undefined
      ledgerService.deleteEntry(unqNamesObj).then(@success, @failure)

  ledgerCtrl.onEnterPress = (e, index, ledger) ->
    if e.keyCode == 13
      $('#saveLedger').focus()
      e.stopPropagation()
    if e.keyCode == 9
      e.preventDefault()
      pItems = $('.pItem')
      $(pItems[0]).find('input').focus()
    return false

  ledgerCtrl.closeShareModal = () ->
    ledgerCtrl.magicLink = ''
    ledgerCtrl.shareModalInstance.close()

  ledgerCtrl.newAccountModel = {
    group : ''
    account: ''
    accUnqName: ''
  }

  ledgerCtrl.addNewAccount = () ->
    ledgerCtrl.newAccountModel.group = ''
    ledgerCtrl.newAccountModel.account = ''
    ledgerCtrl.newAccountModel.accUnqName = ''
    ledgerCtrl.selectedTxn.isOpen = false
    ledgerCtrl.getFlattenGrpWithAccList($rootScope.selectedCompany.uniqueName, true)
    ledgerCtrl.AccmodalInstance = $uibModal.open(
      templateUrl:'/public/webapp/Ledger/createAccountQuick.html'
      size: "sm"
      backdrop: 'static'
      scope: $scope
    )

  ledgerCtrl.addNewAccountConfirm = () ->

    @success = (res) ->
      toastr.success('Account created successfully')
      $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
      ledgerCtrl.AccmodalInstance.close()
      $scope.noResults = false

    @failure = (res) ->
      toastr.error(res.data.message)
    newAccount = {
      email:""
      mobileNo:""
      name:ledgerCtrl.newAccountModel.account
      openingBalanceDate: $filter('date')(ledgerCtrl.today, "dd-MM-yyyy")
      uniqueName:ledgerCtrl.newAccountModel.accUnqName
    }
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: ledgerCtrl.newAccountModel.group.groupUniqueName
      acntUname: ledgerCtrl.newAccountModel.accUnqName
    }
    if ledgerCtrl.newAccountModel.group.groupUniqueName == '' || ledgerCtrl.newAccountModel.group.groupUniqueName == undefined
      toastr.error('Please select a group.')
    else
      accountService.createAc(unqNamesObj, newAccount).then(@success, @failure) 

  ledgerCtrl.genearateUniqueName = (unqName) ->
    unqName = unqName.replace(/ |,|\//g,'')
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
      ledgerCtrl.newAccountModel.accUnqName = unq
    else
      ledgerCtrl.newAccountModel.accUnqName = ''

  ledgerCtrl.genUnq = (unqName) ->
    $timeout ( ->
      ledgerCtrl.genearateUniqueName(unqName)
    )

  ledgerCtrl.gwaList = {
    page: 1
    count: 5000
    totalPages: 0
    currentPage : 1
    limit: 5
  }

  ledgerCtrl.getFlattenGrpWithAccList = (compUname, showEmpty) ->
    @success = (res) ->
      ledgerCtrl.gwaList.totalPages = res.body.totalPages
      ledgerCtrl.flatGrpList = ledgerCtrl.markFixedGrps(res.body.results)
      ledgerCtrl.gwaList.limit = 5
    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: ledgerCtrl.gwaList.page
      count: ledgerCtrl.gwaList.count
    }
    if(showEmpty) 
      reqParam.showEmptyGroups = true
    groupService.getFlattenGroupAccList(reqParam).then(@success, @failure)

  ledgerCtrl.markFixedGrps = (flatGrpList) ->
    temp = []
    _.each ledgerCtrl.detGrpList, (detGrp) ->
      _.each flatGrpList, (fGrp) ->
        if detGrp.uniqueName == fGrp.groupUniqueName && detGrp.isFixed
          fGrp.isFixed = true
    _.each flatGrpList, (grp) ->
      if !grp.isFixed
        temp.push(grp)
    temp

  ledgerCtrl.getGroupsWithDetail = () ->
    if $rootScope.allowed == true
      groupService.getGroupsWithoutAccountsInDetail($rootScope.selectedCompany.uniqueName).then(
        (success)->
          ledgerCtrl.detGrpList = success.body
        (failure) ->
          toastr.error('Failed to get Detailed Groups List')
      )
  ledgerCtrl.getGroupsWithDetail()

  ledgerCtrl.downloadInvoice = (invoiceNumber, e) ->
    e.stopPropagation()

    @success = (res) ->
      data = ledgerCtrl.b64toBlob(res.body, "application/pdf", 512)
      blobUrl = URL.createObjectURL(data)
      ledgerCtrl.dlinv = blobUrl
      FileSaver.saveAs(data, ledgerCtrl.accountToShow.name+ '-' + invoiceNumber+".pdf")

    @failure = (res) ->
      toastr.error(res.data.message, res.data.status)

    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: ledgerCtrl.accountUnq
    data=
      invoiceNumber: [invoiceNumber]
      template: ''
    accountService.downloadInvoice(obj, data).then(@success, @failure)



  ledgerCtrl.shareAccount = () ->
    @success = (res) ->
      ledgerCtrl.getSharedWithList()
      toastr.success(res.body)
    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {}
    reqParam.compUname = $rootScope.selectedCompany.uniqueName
    reqParam.acntUname = ledgerCtrl.accountToShow.uniqueName
    permission = {}
    permission.user = ledgerCtrl.shareRequest.user
    permission.role = ledgerCtrl.shareRequest.role
    accountService.share(reqParam, permission).then(@success,@failure)

  ledgerCtrl.getSharedWithList = () ->
    @success = (res) ->
      ledgerCtrl.sharedUsersList = res.body

    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {}
    reqParam.compUname = $rootScope.selectedCompany.uniqueName
    reqParam.acntUname = ledgerCtrl.accountToShow.uniqueName
    accountService.sharedWith(reqParam).then(@success,@failure)

  ledgerCtrl.unshare = (user, index) ->
    @success = (res) ->
      ledgerCtrl.sharedUsersList.splice(index,1)
      toastr.success(res.body)

    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {}
    reqParam.compUname = $rootScope.selectedCompany.uniqueName
    reqParam.acntUname = ledgerCtrl.accountToShow.uniqueName

    userObj = {}
    userObj.user = user
    accountService.unshare(reqParam, userObj).then(@success,@failure)

  ledgerCtrl.updateSharePermission = (user, role) ->

    @success = (res) ->
      ledgerCtrl.getSharedWithList()

    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {}
    reqParam.compUname = $rootScope.selectedCompany.uniqueName
    reqParam.acntUname = ledgerCtrl.accountToShow.uniqueName
    permission = {}
    permission.user = user
    permission.role = role
    accountService.share(reqParam, permission).then(@success,@failure)


  return ledgerCtrl
giddh.webApp.controller 'ledgerController', ledgerController