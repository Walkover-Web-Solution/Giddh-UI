
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

  $scope.ledgerData = {} 
  $scope.newDebitTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: ''
    amount : 0
    type: 'DEBIT'
  }
  $scope.newCreditTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: ''
    amount : 0
    type: 'CREDIT'
  }

  $scope.blankLedger = {
      description:null
      entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
      hasCredit:false
      hasDebit:false
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
    hasCredit:false
    hasDebit:false
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
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $rootScope.selAcntUname
      entUname: ledger.uniqueName
    }
    if _.isEmpty(ledger.uniqueName)
      console.log("creating new entry")
      ledgerService.createEntry(unqNamesObj, ledger).then($scope.addEntrySuccess, $scope.addEntryFailure)
    else
      console.log("updating entry")
      ledgerService.updateEntry(unqNamesObj, ledger).then($scope.updateEntrySuccess, $scope.updateEntryFailure)

  $scope.addEntrySuccess = (res) ->
    toastr.success("Entry created successfully", "Success")

  $scope.addEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.updateEntrySuccess = (res) ->
    toastr.success("Entry updated successfully", "Success")

  $scope.updateEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


giddh.webApp.controller 'newLedgerController', newLedgerController