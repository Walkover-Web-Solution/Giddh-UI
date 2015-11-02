"use strict"

ledgerController = ($scope, $rootScope, localStorageService, toastr, groupService, modalService, accountService, ledgerService, $filter, locationService, DAServices) ->
  $scope.accntTitle = undefined
  $scope.showLedgerBox = false
  $scope.selectedAccountUname = undefined
  $scope.selectedGroupUname = undefined


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

  dummyValueDebit =
  {
    "transactions": [
      {
        "particular": {
          "name": "",
          "uniqueName": ""
        },
        "amount": "",
        "type": "DEBIT"
      }
    ],
    "description": "",
    "tag": "",
    "uniqueName": undefined,
    "voucher": {
      "name": "sales"
      "shortCode": "sal"
    },
    "entryDate": ""
  }
  dummyValueCredit =
  {
    "transactions": [
      {
        "particular": {
          "name": "",
          "uniqueName": ""
        },
        "amount": "",
        "type": "CREDIT"
      }
    ],
    "description": "",
    "tag": "",
    "uniqueName": undefined,
    "voucher": {
      "name": "sales"
      "shortCode": "sal"
    },
    "entryDate": ""
  }


  # ledger
  # load ledger start
  $scope.loadLedger = (data, acData) ->
    $scope.showLedgerBox = false
    $scope.accntTitle = acData.name
    $scope.selectedAccountUname = acData.uniqueName
    $scope.selectedGroupUname = data.groupUniqueName

    # console.log $scope.selectedAccountUname, $scope.selectedGroupUname

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
    console.log "addNewAccount"
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalService.openManageGroupsModal()


  $scope.deleteEntry = (item) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUname
      entUname: item.uniqueName
    }
    ledgerService.deleteEntry(unqNamesObj).then((response) ->
      $scope.deleteEntrySuccess(item, response)
    , $scope.deleteEntryFailure)

  $scope.deleteEntrySuccess = (item, response) ->
    console.log $scope.ledgerData.ledgers.length, "before"
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
    console.log $scope.ledgerData.ledgers.length, "after"
    $scope.calculateLedger($scope.ledgerData, "deleted")

  $scope.deleteEntryFailure = (response) ->
    console.log "deleteEntryFailure", response

  $scope.addNewEntry = (data) ->
    console.log "addNewEntry"
    edata = {}
    angular.copy(data, edata)

    if angular.isUndefined(data.voucher)
      console.log "true"
    else
      edata.voucherType = data.voucher.shortCode

    if angular.isObject(data.transactions[0].particular)
      unk = data.transactions[0].particular.uniqueName
      edata.transactions[0].particular = unk

    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
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
      console.log "in DEBIT"
      $scope.ledgerData.ledgers.push(angular.copy(dummyValueDebit))
    if tType is 'CREDIT'
      console.log "in CREDIT"
      $scope.ledgerData.ledgers.push(angular.copy(dummyValueCredit))

    $scope.calculateLedger($scope.ledgerData, "add")


  $scope.addEntryFailure = (response) ->
    console.log response, "addEntryFailure"


  $scope.updateEntry = (data) ->
    edata = {}
    angular.copy(data, edata)

    if _.isUndefined(data.voucher)
      console.log "voucher undefined", data.voucher
    else
      edata.voucherType = data.voucher.shortCode

    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUname
      entUname: data.uniqueName
    }
    if angular.isObject(data.transactions[0].particular)
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
    console.log "calculateLedger", data
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
      console.log "debit is greater"
      $scope.ledgBalType = 'DEBIT'
      $scope.creditBalanceAmount = drt - crt
      $scope.debitTotal = drt
      $scope.creditTotal = parseInt(crt) + parseInt($scope.creditBalanceAmount)
    if crt > drt
      console.log "credit is greater"
      $scope.ledgBalType = 'CREDIT'
      $scope.debitBalanceAmount = crt - drt
      console.log $scope.debitBalanceAmount, "$scope.debitBalanceAmount"
      $scope.debitTotal = parseInt(drt) + parseInt($scope.debitBalanceAmount)
      $scope.creditTotal = crt


    # if calculation is wrong than make entry in newrelic
    if loadtype is 'server'
      if drt > crt
        if parseInt(data.debitTotal) isnt parseInt(drt)
          console.log "something is wrong in calculateLedger debitTotal"
          console.log parseInt(data.debitTotal), parseInt(drt)
      if crt > drt
        if parseInt(data.creditTotal) isnt parseInt(crt)
          console.log "something is wrong in calculateLedger creditTotal"
          console.log parseInt(data.creditTotal), parseInt(crt)


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

  $scope.onScroll = (sp, tsS) ->
    if  !_.isUndefined($scope.ledgerData)
      ledgerLength = $scope.ledgerData.ledgers.length
      console.log sp, "onScroll", tsS, ledgerLength
      if ledgerLength > 50
        console.log "will load data onScroll"
        if sp+100 >= tsS
          $scope.quantity += 50
          console.log "hurray data added in scope", $scope.quantity

  $rootScope.$on '$loadLedgerHere', (data, acdtl) ->
    $scope.loadLedger(data, acdtl)

  $rootScope.$on '$viewContentLoaded', ->
    $scope.fromDate.date.setDate(1)
    ledgerObj = DAServices.LedgerGet()
    $scope.loadLedger(ledgerObj.ledgerData, ledgerObj.selectedAccount)


angular.module('giddhWebApp').controller 'ledgerController', ledgerController