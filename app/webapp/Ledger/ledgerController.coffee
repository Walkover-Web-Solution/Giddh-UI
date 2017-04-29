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

  ledgerCtrl.popover = {

    templateUrl: 'panel'
    draggable: false
    position: "bottom"
  }
# mustafa
  

  ledgerCtrl.toggleShareFucntion = () ->
    ledgerCtrl.LedgerExport = false
    ledgerCtrl.toggleShare = false
    ledgerCtrl.toggleShare = !ledgerCtrl.toggleShare

  ledgerCtrl.toggleExportFucntion = () ->
    ledgerCtrl.toggleShare = false
    ledgerCtrl.LedgerExport = false
    ledgerCtrl.LedgerExport = !ledgerCtrl.LedgerExport

  ledgerCtrl.toggleDropdown = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    $scope.status.isopen = !$scope.status.isopen
  
  ledgerCtrl.shareLedger =() ->
    $uibModal.open(
      templateUrl: '/public/webapp/Ledger/shareLedger.html',
      size: "md",
      backdrop: 'true',
      animation: true,
      scope: $scope
    )

  if _.isUndefined($rootScope.selectedCompany)
    $rootScope.selectedCompany = localStorageService.get('_selectedCompany')

  ledgerCtrl.accountUnq = $stateParams.unqName

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
    $state.go($state.current, {unqName: res.body.uniqueName}, {notify: false})
    if res.body.uniqueName == 'cash'
      $rootScope.ledgerState = true
    ledgerCtrl.getPaginatedLedger(1)
    # if res.body.yodleeAdded == true && $rootScope.canUpdate
    #   #get bank transaction here
    #   $timeout ( ->
    #     ledgerCtrl.getBankTransactions(res.body.uniqueName)
    #   ), 2000

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
          $scope.cDate.startDate = e.model.startDate._d
          $scope.cDate.endDate = e.model.endDate._d
          ledgerCtrl.getPaginatedLedger(1)
      }
  }
  $scope.setStartDate = ->
    $scope.cDate.startDate = moment().subtract(4, 'days').toDate()

  $scope.setRange = ->
    $scope.cDate =
        startDate: moment().subtract(5, 'days')
        endDate: moment()
  ###date range picker end###



  ledgerCtrl.ledgerPerPageCount = 5
  ledgerCtrl.pages = []
  ledgerCtrl.getPaginatedLedger = (page) ->
    @success = (res) ->
      ledgerCtrl.pages = []
      ledgerCtrl.paginatedLedgers = res.body.ledgers
      ledgerCtrl.totalLedgerPages = res.body.totalPages
      ledgerCtrl.currentPage = res.body.page
      ledgerCtrl.totalCreditTxn = res.body.totalCreditTransactions
      ledgerCtrl.totalDebitTxn = res.body.totalDebitTransactions
      ledgerCtrl.addLedgerPages()

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
      page: page || 1
    }
    if not _.isEmpty(ledgerCtrl.accountUnq)
      ledgerService.getLedger(unqNamesObj).then(@success, @failure)

  ledgerCtrl.getPaginatedLedger(1)

  ledgerCtrl.addLedgerPages = () ->
    i = 0
    while i <= ledgerCtrl.totalLedgerPages
      if i > 0
        ledgerCtrl.pages.push(i)
      i++

# mustafa
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
    ledgerCtrl.getLink = false

  ledgerCtrl.getMagicLinkFailure = (res) ->
    toastr.error(res.data.message)
# mustafa end


  ledgerCtrl.ledgerEmailData = {}
  
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
    #lc.ledgerEmailData.email = ''
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


# mustafa end

  ledgerCtrl.prevTxn = null
  ledgerCtrl.selectTxn = (ledger, txn, index ,e) ->
    #setPopoverPlacement(e.clientY)
    if ledgerCtrl.accountToShow.stock != null && txn.inventory == undefined
      txn.inventory = {}
      txn.rate = ledgerCtrl.accountToShow.stock.rate
    if txn.inventory && txn.inventory.quantity
      txn.rate = txn.amount/txn.inventory.quantity
    if txn.particular.stock
      txn.rate = txn.particular.stock.rate
    #txn.rate = $filter('number')(Number(txn.rate), 4)
    ledgerCtrl.selectedTxn = txn
    if ledgerCtrl.prevTxn != null
      ledgerCtrl.prevTxn.isOpen = false
    ledgerCtrl.selectedTxn.isOpen = true
    ledgerCtrl.prevTxn = txn
    # mustafa ledgerCtrl.calculateEntryTotal(ledger)
    ledgerCtrl.showLedgerPopover = true
    # mustafa ledgerCtrl.matchInventory(txn)
    ledgerCtrl.ledgerBeforeEdit = {}
    angular.copy(ledger,ledgerCtrl.ledgerBeforeEdit)
    # if ledgerCtrl.popover.draggable
    #   ledgerCtrl.showPanel = true
    #else
      #ledgerCtrl.openClosePopOver(txn, ledger)
    if ledger.isBankTransaction != undefined
      _.each(ledger.transactions,(transaction) ->
        if transaction.type == 'DEBIT'
          ledger.voucher.shortCode = "rcpt"
        else if transaction.type == 'CREDIT'
          ledger.voucher.shortCode = "pay"
      )
    ledgerCtrl.selectedLedger = ledger
    ledgerCtrl.selectedLedger.index = index
    #if ledger.uniqueName != '' || ledger.uniqueName != undefined || ledger.uniqueName != null
    # mustafa ledgerCtrl.checkCompEntry(ledger)
    #ledgerCtrl.blankCheckCompEntry(ledger)
    # mustafa ledgerCtrl.isTransactionContainsTax(ledger)
    e.stopPropagation()


  return ledgerCtrl
giddh.webApp.controller 'ledgerController', ledgerController