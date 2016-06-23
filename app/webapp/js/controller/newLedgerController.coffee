
newLedgerController = ($scope, $rootScope, localStorageService, toastr, modalService, ledgerService, $filter, DAServices, $stateParams, $timeout, $location, $document, permissionService, accountService, Upload, groupService, $uibModal, companyServices) ->

  #date time picker code starts here
  $scope.today = new Date()
  d = moment(new Date()).subtract(1, 'month')
  $scope.fromDate = {date: d._d}
  $scope.toDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.format = "dd-MM-yyyy"
  $scope.accountUnq = $stateParams.unqName
  $scope.ledgerData = {} 
  $scope.newDebitTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: ''
    amount : 0
  }
  $scope.newCreditTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: ''
    amount : 0
  }
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

  $scope.isCurrentAccount =(acnt) ->
    acnt.uniqueName is $scope.accountUnq

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

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
    $scope.filterLedgers(res.body.ledgers)
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
    console.log(res)
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

  $scope.getLedgerData()


  $scope.popOver = {
    template : "ledgerPopover.html"
    position:"bottom"
  }
  $scope.fltAccntListcount5 = []

  $timeout ( ->
    $scope.getTaxList()
  ), 3000

  $scope.addItem = (ledger, txn) ->
    console.log txn

  $scope.flatAccListC5 = {
      page: 1
      count: 5
      totalPages: 0
      currentPage : 1
    }

  $scope.getFlatAccountListCount5 = (compUname) ->
    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: $scope.flatAccListC5.page
      count: $scope.flatAccListC5.count
    }
    groupService.getFlatAccList(reqParam).then($scope.getFlatAccountListCount5ListSuccess, $scope.getFlatAccountListCount5ListFailure)

  $scope.getFlatAccountListCount5ListSuccess = (res) ->
    $scope.fltAccntListcount5 = res.body.results

  $scope.getFlatAccountListCount5ListFailure = (res) ->
    toastr.error(res.data.message)

  # search flat accounts list
  $scope.searchAccountsC5 = (str) ->
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    if str.length > 2
      reqParam.q = str
      groupService.getFlatAccList(reqParam).then($scope.getFlatAccountListCount5ListSuccess, $scope.getFlatAccountListCount5ListFailure)
    else
      reqParam.q = ''
      reqParam.count = 5
      groupService.getFlatAccList(reqParam).then($scope.getFlatAccountListCount5ListSuccess, $scope.getFlatAccountListCount5ListFailure)


giddh.webApp.controller 'newLedgerController', newLedgerController