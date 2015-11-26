"use strict"

ledgerController = ($scope, $rootScope, localStorageService, toastr, modalService, ledgerService, $filter, DAServices, $stateParams, $timeout, $location, $document) ->
  $scope.ledgerData = undefined 
  $scope.accntTitle = undefined
  $scope.selectedAccountUniqueName = undefined
  $scope.selectedGroupUname = undefined
  $scope.selectedLedgerAccount = undefined
  $scope.selectedLedgerGroup = undefined
  $scope.ledgerOnlyDebitData = []
  $scope.ledgerOnlyCreditData = []


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
  $rootScope.lItem = []

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

  $scope.debitOnly = (ledger) ->
    'DEBIT' == ledger.transactions[0].type

  $scope.creditOnly = (ledger) ->
    'CREDIT' == ledger.transactions[0].type

  $scope.loadLedgerFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.loadLedgerSuccess = (res) ->
    data = {}
    angular.copy(res.body, data)
    $scope.ledgerOnlyCreditData = []
    $scope.ledgerOnlyDebitData = []
    _.each(data.ledgers, (ledger) ->
      if ledger.transactions.length > 1
        ledger.multiEntry = true
      else
        ledger.multiEntry = false
      
      sharedData = _.omit(ledger, 'transactions')
      _.each(ledger.transactions, (transaction, index) ->
        newEntry = {sharedData: sharedData}
        newEntry.id = sharedData.uniqueName + "_" + index
        if transaction.type is "DEBIT"
          newEntry.transactions = [transaction]
          $scope.ledgerOnlyDebitData.push(newEntry)

        if transaction.type is "CREDIT"
          newEntry.transactions = [transaction]
          $scope.ledgerOnlyCreditData.push(newEntry)
      )
    )
    $scope.ledgerOnlyDebitData.push(angular.copy(dummyValueDebit))
    $scope.ledgerOnlyCreditData.push(angular.copy(dummyValueCredit))
    $rootScope.showLedgerBox = true

    $scope.ledgerData = angular.copy(_.omit(res.body, 'ledgers'))
    $scope.calculateLedger($scope.ledgerData, "server")


  $scope.addNewAccount = () ->
    if _.isEmpty($scope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalService.openManageGroupsModal()

  $scope.addNewEntry = (data) ->
    $scope.addEntryMultiObj.push(data)
    console.log $scope.addEntryMultiObj, "addNewEntry", data
    edata = {}
    _.extend(edata, data)
    edata.transactions = []
    _.each($scope.addEntryMultiObj, (entry) ->
      console.log "each", entry.transactions[0]
      edata.transactions.push(entry.transactions[0])
    )
    edata.sharedData.voucherType = data.sharedData.voucher.shortCode
    console.log edata, "finally after each"
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
    _.extend(edata, data.sharedData)
    
    if not _.isUndefined(data.sharedData.voucher)
      edata.voucherType = data.sharedData.voucher.shortCode

    edata.transactions = []
    _.filter($scope.ledgerOnlyDebitData, (entry) ->
      if edata.uniqueName is entry.sharedData.uniqueName
        edata.transactions.push(entry.transactions[0])
    )
    _.filter($scope.ledgerOnlyCreditData, (entry) ->
      if edata.uniqueName is entry.sharedData.uniqueName
        edata.transactions.push(entry.transactions[0])
    )
    
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUniqueName
      entUname: edata.uniqueName
    }
    ledgerService.updateEntry(unqNamesObj, edata).then($scope.updateEntrySuccess, $scope.updateEntryFailure)

  $scope.updateEntrySuccess = (res) ->
    $scope.removeClassInAllEle("ledgEntryForm", "highlightRow")
    $scope.removeClassInAllEle("ledgEntryForm", "open")
    $scope.removeLedgerDialog()
    toastr.success("Entry updated successfully", "Success")
    uLedger = {}
    _.extend(uLedger, res.body)

    if uLedger.transactions.length > 1
      uLedger.multiEntry = true
    else
      uLedger.multiEntry = false

    _.each(uLedger.transactions, (transaction) ->
      if transaction.type is "DEBIT"
        _.filter($scope.ledgerOnlyDebitData, (ledger) ->
          if ledger.sharedData.uniqueName is uLedger.uniqueName
            if _.isEqual(ledger.transactions[0], transaction)
              sharedData = _.omit(uLedger, 'transactions')
              ledger.sharedData = sharedData
              ledger.transactions[0] = transaction

        )
      if transaction.type is "CREDIT"
        _.filter($scope.ledgerOnlyCreditData, (ledger) ->
          if ledger.sharedData.uniqueName is uLedger.uniqueName
            if _.isEqual(ledger.transactions[0], transaction)
              sharedData = _.omit(uLedger, 'transactions')
              ledger.sharedData = sharedData
              ledger.transactions[0] = transaction
        )
    )
    $scope.calculateLedger($scope.ledgerData, "update")

  $scope.updateEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.removeClassInAllEle = (target, clName)->
    el = document.getElementsByClassName(target)
    angular.element(el).removeClass(clName)

  $scope.addEntryInCredit =(data)->
    $document.off 'click'
    console.log data
    arLen = $scope.ledgerOnlyCreditData.length-1
    lastRow = $scope.ledgerOnlyCreditData[arLen]

    if lastRow.sharedData.entryDate isnt "" and  not _.isEmpty(lastRow.transactions[0].amount) and not _.isEmpty(lastRow.transactions[0].particular.uniqueName)
      $scope.ledgerOnlyCreditData.push(angular.copy(dummyValueCredit))
      $timeout ->
        $scope.sameMethodForDrCr(arLen+1, ".crLedgerEntryForm")
      , 300
    else
      $scope.sameMethodForDrCr(arLen, ".crLedgerEntryForm")

  $scope.addEntryMultiObj = []
  $scope.addEntryInDebit =(data)->
    $document.off 'click'
    arLen = $scope.ledgerOnlyDebitData.length-1
    lastRow = $scope.ledgerOnlyDebitData[arLen]

    if lastRow.sharedData.entryDate isnt "" and  not _.isEmpty(lastRow.transactions[0].amount) and not _.isEmpty(lastRow.transactions[0].particular.uniqueName)
      $scope.ledgerOnlyDebitData.push(angular.copy(dummyValueDebit))
      $timeout ->
        $scope.sameMethodForDrCr(arLen+1, ".drLedgerEntryForm")
      , 200
    else
      $scope.sameMethodForDrCr(arLen, ".drLedgerEntryForm")

    console.log data, "addEntryInDebit"

    if _.isUndefined(data.sharedData.uniqueName)
      console.log "from new row"
      $scope.addEntryMultiObj.push(data)
      wt = _.omit(data, 'transactions')
      wd = _.omit(wt.sharedData, 'entryDate')
      _.extend(_.last($scope.ledgerOnlyDebitData).sharedData, wd)
      console.log $scope.addEntryMultiObj
    else
      if data.sharedData.multiEntry
        console.log "multiEntry obj"
      else
        console.log "not multiEntry"

    
    

    
    
  $scope.sameMethodForDrCr =(arLen, name)->
    formEle =  document.querySelectorAll(name)
    inp = angular.element(formEle[arLen]).find('td')[1].children
    $scope.removeLedgerDialog()
    $scope.removeClassInAllEle("ledgEntryForm", "highlightRow")
    $scope.removeClassInAllEle("ledgEntryForm", "open")
    $timeout ->
      angular.element(inp).focus()
    , 300
    return false
      


  $scope.deleteEntry = (item) ->
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUniqueName
      entUname: item.sharedData.uniqueName
    }
    ledgerService.deleteEntry(unqNamesObj).then((res) ->
      $scope.deleteEntrySuccess(item, res)
    , $scope.deleteEntryFailure)

  $scope.deleteEntrySuccess = (item, res) ->
    $scope.removeClassInAllEle("ledgEntryForm", "highlightRow")
    $scope.removeClassInAllEle("ledgEntryForm", "open")
    $scope.removeLedgerDialog()
    toastr.success(res.body, res.status)
    $scope.ledgerOnlyDebitData = _.reject($scope.ledgerOnlyDebitData, (entry) ->
      item.sharedData.uniqueName is entry.sharedData.uniqueName
    )
    $scope.ledgerOnlyCreditData = _.reject($scope.ledgerOnlyCreditData, (entry) ->
      item.sharedData.uniqueName is entry.sharedData.uniqueName
    )
    
    $scope.calculateLedger($scope.ledgerData, "deleted")

  $scope.deleteEntryFailure = (res) ->
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

    _.each($scope.ledgerOnlyDebitData, (entry) ->
      drt += entry.transactions[0].amount
    )
    _.each($scope.ledgerOnlyCreditData, (entry) ->
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
      ledgerDebLength = $scope.ledgerOnlyDebitData.length
      ledgerCrdLength = $scope.ledgerOnlyCreditData.length
      if ledgerDebLength > 50 || ledgerCrdLength > 50 
        if sp + 200 >= tsS
          event.preventDefault()
          event.stopPropagation()
          $scope.quantity += 20

  $scope.$on '$viewContentLoaded',  ->
    $scope.fromDate.date.setDate(1)
    ledgerObj = DAServices.LedgerGet()

    if !_.isEmpty(ledgerObj.ledgerData)
      $scope.loadLedger(ledgerObj.ledgerData, ledgerObj.selectedAccount)
    else
      if !_.isNull(localStorageService.get("_ledgerData"))
        $scope.loadLedger(localStorageService.get("_ledgerData"), localStorageService.get("_selectedAccount"))
        # localStorageService.remove(key)
      else
        console.log "nothing selected to load"

  $scope.$on '$reloadLedger',  ->
    $scope.reloadLedger()


angular.module('giddhWebApp').controller 'ledgerController', ledgerController

class angular.Ledger
  constructor: (type)->
    @transactions = [new angular.Transaction(type)]
    @sharedData = new angular.SharedData

class angular.SharedData
  constructor: () ->
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