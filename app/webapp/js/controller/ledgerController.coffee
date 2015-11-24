"use strict"

ledgerController = ($scope, $rootScope, localStorageService, toastr, modalService, ledgerService, $filter, DAServices, $stateParams) ->
  $scope.accntTitle = undefined
  $scope.selectedAccountUniqueName = undefined
  $scope.selectedGroupUname = undefined
  $scope.selectedLedgerAccount = undefined
  $scope.selectedLedgerGroup = undefined

  $scope.selectedCompany = {}
  lsKeys = localStorageService.get("_selectedCompany")
  if not _.isNull(lsKeys) && not _.isEmpty(lsKeys) && not _.isUndefined(lsKeys)
    $scope.selectedCompany = lsKeys

  $scope.creditTotal = undefined
  $scope.debitTotal = undefined
  $scope.creditBalanceAmount = undefined
  $scope.debitBalanceAmount = undefined
  $rootScope.cmpViewShow = true

  $scope.quantity = 50

  #date time picker code starts here
  $scope.today = new Date()
  $scope.fromDate = {date: new Date()}
  $scope.toDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

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
  ]

  $scope.dynamicPopover = {
    content: 'Hello, World!',
    templateUrl: 'myPopoverTemplate.html',
    title: 'Title'
  }
  
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }

  $scope.format = "dd-MM-yyyy"
  $scope.ftypeAdd = "add"
  $scope.ftypeUpdate = "update"

  dummyValueDebit = new angular.Ledger("DEBIT")
  dummyValueCredit = new angular.Ledger("CREDIT")

  # ledger
  # load ledger start
  $scope.reloadLedger = () ->
    if not _.isUndefined($scope.selectedLedgerGroup)
      $scope.loadLedger($scope.selectedLedgerGroup, $scope.selectedLedgerAccount)

  $scope.loadLedger = (data, acData) ->
    if _.isNull($scope.toDate.date) || _.isNull($scope.fromDate.date)
      toastr.error("Date should be in proper format", "Error")
      return false
    $rootScope.showLedgerBox = false
    $scope.selectedLedgerAccount = acData
    $scope.selectedLedgerGroup = data
    $scope.accntTitle = acData.name
    $scope.selectedAccountUniqueName = acData.uniqueName
    $scope.selectedGroupUname = data.groupUniqueName
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUniqueName
      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    }
    ledgerService.getLedger(unqNamesObj).then($scope.loadLedgerSuccess, $scope.loadLedgerFailure)
    $stateParams.unqName = $scope.selectedAccountUniqueName
    $stateParams.grpName = $scope.selectedGroupUname

  $scope.loadLedgerSuccess = (res) ->
    res.body.ledgers.push(angular.copy(dummyValueDebit))
    res.body.ledgers.push(angular.copy(dummyValueCredit))
    $scope.ledgerData = res.body
    $rootScope.showLedgerBox = true
    $scope.calculateLedger($scope.ledgerData, "server")



  $scope.debitOnly = (ledger) ->
    'DEBIT' == ledger.transactions[0].type

  $scope.creditOnly = (ledger) ->
    'CREDIT' == ledger.transactions[0].type

  $scope.loadLedgerFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.addNewAccount = () ->
    if _.isEmpty($scope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalService.openManageGroupsModal()

  $scope.deleteEntry = (item) ->
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUniqueName
      entUname: item.uniqueName
    }
    ledgerService.deleteEntry(unqNamesObj).then((res) ->
      $scope.deleteEntrySuccess(item, res)
    , $scope.deleteEntryFailure)

  $scope.deleteEntrySuccess = (item, res) ->
    count = 0
    rpl = 0
    _.each($scope.ledgerData.ledgers, (entry) ->
      if entry.uniqueName is item.uniqueName
        rpl = count
      count++
    )
    $scope.ledgerData.ledgers.splice(rpl, 1)
    toastr.success(res.message, res.status)
    $scope.removeLedgerDialog()
    $scope.calculateLedger($scope.ledgerData, "deleted")

  $scope.deleteEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.addNewEntry = (data) ->
    edata = {}
    angular.copy(data, edata)
    edata.voucherType = data.voucher.shortCode
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUniqueName
    }
    ledgerService.createEntry(unqNamesObj, edata).then($scope.addEntrySuccess, $scope.addEntryFailure)

  $scope.addEntrySuccess = (res) ->
    toastr.success("Entry created successfully", "Success")
    $scope.removeLedgerDialog()
    tType = res.body.transactions[0].type
    count = 0
    rpl = 0
    _.each($scope.ledgerData.ledgers, (ledger) ->
      if ledger.uniqueName is undefined && ledger.transactions[0].type is tType
        rpl = count
      count++
    )
    $scope.ledgerData.ledgers[rpl] = res.body

    if tType is 'DEBIT'
      $scope.ledgerData.ledgers.push(angular.copy(dummyValueDebit))
    if tType is 'CREDIT'
      $scope.ledgerData.ledgers.push(angular.copy(dummyValueCredit))

    $scope.calculateLedger($scope.ledgerData, "add")

  $scope.addEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.updateEntry = (data) ->
    edata = {}
    angular.copy(data, edata)

    if not _.isUndefined(data.voucher)
      edata.voucherType = data.voucher.shortCode

    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUniqueName
      entUname: data.uniqueName
    }

    ledgerService.updateEntry(unqNamesObj, edata).then($scope.updateEntrySuccess, $scope.updateEntryFailure)

  $scope.updateEntrySuccess = (res) ->
    toastr.success("Entry updated successfully", "Success")
    $scope.removeLedgerDialog()
    count = 0
    rpl = 0
    _.each($scope.ledgerData.ledgers, (ledger) ->
      if ledger.uniqueName is res.body.uniqueName
        rpl = count
      count++
    )
    $scope.ledgerData.ledgers[rpl] = res.body
    $scope.calculateLedger($scope.ledgerData, "update")

  $scope.updateEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.removeLedgerDialog = () ->
    allPopElem = angular.element(document.querySelector('.ledgerPopDiv'))
    allPopElem.remove()
    return true

  $scope.calculateLedger = (data, loadtype) ->
    crt = 0
    drt = 0
    $scope.creditBalanceAmount = 0
    $scope.debitBalanceAmount = 0
    $scope.ledgBalType = undefined

    if data.forwardedBalance.type is 'CREDIT'
      crt += data.forwardedBalance.amount

    if data.forwardedBalance.type is 'DEBIT'
      drt += data.forwardedBalance.amount

    _.each(data.ledgers, (entry) ->
      if entry.transactions[0].type is 'DEBIT'
        drt += entry.transactions[0].amount

      if entry.transactions[0].type is 'CREDIT'
        crt += entry.transactions[0].amount
    )
    crt = parseFloat(crt)
    drt = parseFloat(drt)

    if drt > crt
      $scope.ledgBalType = 'DEBIT'
      $scope.creditBalanceAmount = drt - crt
      $scope.debitTotal = drt
      $scope.creditTotal = crt + (drt - crt)
    else if crt > drt
      $scope.ledgBalType = 'CREDIT'
      $scope.debitBalanceAmount = crt - drt
      $scope.debitTotal = drt + (crt - drt)
      $scope.creditTotal = crt
    else
      $scope.creditTotal = crt
      $scope.debitTotal = drt

    # if calculation is wrong than make entry in newrelic
    if loadtype is 'server'
      if data.debitTotal isnt parseFloat($scope.debitTotal)
        console.log "something is wrong in calculateLedger debitTotal"
        console.log data.debitTotal, parseFloat($scope.debitTotal)
      if data.creditTotal isnt parseFloat($scope.creditTotal)
        console.log "something is wrong in calculateLedger creditTotal"
        console.log data.creditTotal, parseFloat($scope.creditTotal)

  $scope.onScroll = (sp, tsS, event) ->
    if  !_.isUndefined($scope.ledgerData)
      ledgerLength = $scope.ledgerData.ledgers.length
      if ledgerLength > 50
        if sp + 200 >= tsS
          event.preventDefault()
          event.stopPropagation()
          $scope.quantity += 20

  $scope.$on '$viewContentLoaded',  ->
    $scope.fromDate.date.setDate(1)
    ledgerObj = DAServices.LedgerGet()
    ledgerObj = DAServices.LedgerGet()
    if !_.isEmpty(ledgerObj.ledgerData)
      $scope.loadLedger(ledgerObj.ledgerData, ledgerObj.selectedAccount)
    else
      console.log "not to load anything"

  $rootScope.$on '$reloadLedger',  ->
    $scope.reloadLedger()

  $scope.removeClassInAllEle = (clName)->
     el = $scope.el
     # console.log el, clName
     
  setTimeout (->
    $scope.removeClassInAllEle('popover')
  ), 1000
 




angular.module('giddhWebApp').controller 'ledgerController', ledgerController

class angular.Ledger
  constructor: (type)->
    @transactions = [new angular.Transaction(type)]
    @description = ""
    @tag = ""
    @uniqueName = undefined
    @entryDate = ""
    @voucher = new angular.Voucher()

class angular.Transaction
  constructor: (type)->
    @amount = ""
    @type = type
    @particular = new angular.Particular

class angular.Voucher
  constructor: ()->
    @name = "sales"
    @shortCode = "sal"

class angular.Particular
  constructor: ()->
    @name = ""
    @uniqueName = ""