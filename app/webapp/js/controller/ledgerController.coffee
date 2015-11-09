"use strict"

ledgerController = ($scope, $rootScope, localStorageService, toastr, modalService, ledgerService, $filter, DAServices) ->
  $scope.accntTitle = undefined
  $scope.showLedgerBox = false
  $scope.selectedAccountUname = undefined
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
    $scope.showLedgerBox = false
    $scope.selectedLedgerAccount = acData
    $scope.selectedLedgerGroup = data
    $scope.accntTitle = acData.name
    $scope.selectedAccountUname = acData.uniqueName
    $scope.selectedGroupUname = data.groupUniqueName
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUname
      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    }
    ledgerService.getLedger(unqNamesObj).then($scope.loadLedgerSuccess, $scope.loadLedgerFailure)

  $scope.loadLedgerSuccess = (response) ->
    response.body.ledgers.push(angular.copy(dummyValueDebit))
    response.body.ledgers.push(angular.copy(dummyValueCredit))
    $scope.ledgerData = response.body
    $scope.showLedgerBox = true
    $scope.calculateLedger($scope.ledgerData, "server")

  $scope.debitOnly = (ledger) ->
    'DEBIT' == ledger.transactions[0].type

  $scope.creditOnly = (ledger) ->
    'CREDIT' == ledger.transactions[0].type

  $scope.loadLedgerFailure = (response) ->
    console.log response


  $scope.addNewAccount = () ->
    if _.isEmpty($scope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalService.openManageGroupsModal()


  $scope.deleteEntry = (item) ->
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUname
      entUname: item.uniqueName
    }
    ledgerService.deleteEntry(unqNamesObj).then((response) ->
      $scope.deleteEntrySuccess(item, response)
    , $scope.deleteEntryFailure)

  $scope.deleteEntrySuccess = (item, response) ->
    count = 0
    rpl = 0
    _.each($scope.ledgerData.ledgers, (entry) ->
      if entry.uniqueName is item.uniqueName
        rpl = count
      count++
    )
    $scope.ledgerData.ledgers.splice(rpl, 1)
    toastr.success(response.message, response.status)
    $scope.removeLedgerDialog()
    $scope.calculateLedger($scope.ledgerData, "deleted")

  $scope.deleteEntryFailure = (response) ->
    console.log "deleteEntryFailure", response

  $scope.addNewEntry = (data) ->
    edata = {}
    angular.copy(data, edata)

    edata.voucherType = data.voucher.shortCode

    if _.isObject(data.transactions[0].particular)
      unk = data.transactions[0].particular.uniqueName
      edata.transactions[0].particular = unk

    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUname
    }
    ledgerService.createEntry(unqNamesObj, edata).then($scope.addEntrySuccess, $scope.addEntryFailure)

  $scope.addEntrySuccess = (response) ->
    toastr.success("Entry created successfully", "Success")
    $scope.removeLedgerDialog()
    tType = response.body.transactions[0].type
    count = 0
    rpl = 0
    _.each($scope.ledgerData.ledgers, (ledger) ->
      if ledger.uniqueName is undefined && ledger.transactions[0].type is tType
        rpl = count
      count++
    )
    $scope.ledgerData.ledgers[rpl] = response.body

    if tType is 'DEBIT'
      $scope.ledgerData.ledgers.push(angular.copy(dummyValueDebit))
    if tType is 'CREDIT'
      $scope.ledgerData.ledgers.push(angular.copy(dummyValueCredit))

    $scope.calculateLedger($scope.ledgerData, "add")


  $scope.addEntryFailure = (response) ->
    console.log response, "addEntryFailure"


  $scope.updateEntry = (data) ->
    edata = {}
    angular.copy(data, edata)

    if not _.isUndefined(data.voucher)
      edata.voucherType = data.voucher.shortCode

    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUname
      entUname: data.uniqueName
    }
    if _.isObject(data.transactions[0].particular)
      unk = data.transactions[0].particular.uniqueName
      edata.transactions[0].particular = unk

    ledgerService.updateEntry(unqNamesObj, edata).then($scope.updateEntrySuccess, $scope.updateEntryFailure)

  $scope.updateEntrySuccess = (response) ->
    toastr.success("Entry updated successfully", "Success")
    $scope.removeLedgerDialog()
    count = 0
    rpl = 0
    _.each($scope.ledgerData.ledgers, (ledger) ->
      if ledger.uniqueName is response.body.uniqueName
        rpl = count
      count++
    )
    $scope.ledgerData.ledgers[rpl] = response.body
    $scope.calculateLedger($scope.ledgerData, "update")

  $scope.updateEntryFailure = (response) ->
    console.log response, "updateEntryFailure"

  $scope.removeLedgerDialog = () ->
    allPopElem = angular.element(document.querySelector('.ledgerPopDiv'))
    allPopElem.remove()
    return true

  $scope.calculateLedger = (data, loadtype) ->
    crt = 0
    drt = 0

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

    if drt > crt
      # console.log "debit is greater"
      $scope.ledgBalType = 'DEBIT'
      $scope.creditBalanceAmount = drt - crt
      $scope.debitTotal = drt
      $scope.creditTotal = parseInt(crt) + parseInt($scope.creditBalanceAmount)
    if crt > drt
      # console.log "credit is greater"
      $scope.ledgBalType = 'CREDIT'
      $scope.debitBalanceAmount = crt - drt
      $scope.debitTotal = parseInt(drt) + parseInt($scope.debitBalanceAmount)
      $scope.creditTotal = crt

    # if calculation is wrong than make entry in newrelic
    if loadtype is 'server'
      if parseInt(data.debitTotal) isnt parseInt($scope.debitTotal)
        console.log "something is wrong in calculateLedger debitTotal"
        console.log parseInt(data.debitTotal), parseInt($scope.debitTotal)
      if parseInt(data.creditTotal) isnt parseInt($scope.creditTotal)
        console.log "something is wrong in calculateLedger creditTotal"
        console.log parseInt(data.creditTotal), parseInt($scope.creditTotal)

  $scope.onScroll = (sp, tsS, event) ->
    if  !_.isUndefined($scope.ledgerData)
      ledgerLength = $scope.ledgerData.ledgers.length
      if ledgerLength > 50
        if sp + 200 >= tsS
          event.preventDefault()
          event.stopPropagation()
          $scope.quantity += 20

  $rootScope.$on '$loadLedgerHere', (data, acdtl) ->
    $scope.loadLedger(data, acdtl)

  $rootScope.$on '$viewContentLoaded', ->
    $scope.fromDate.date.setDate(1)
    ledgerObj = DAServices.LedgerGet()
    ledgerObj = DAServices.LedgerGet()
    if !_.isEmpty(ledgerObj.ledgerData)
      $scope.loadLedger(ledgerObj.ledgerData, ledgerObj.selectedAccount)
    else
      console.log "not to load anything"


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