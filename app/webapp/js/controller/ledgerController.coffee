"use strict"

ledgerController = ($scope, $rootScope, localStorageService, toastr, modalService, ledgerService, $filter, DAServices, $stateParams, $timeout, $location, $document, permissionService, accountService, Upload) ->
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
  $scope.quantity = 50
  $rootScope.cmpViewShow = true
  $rootScope.lItem = []
  #date time picker code starts here
  $scope.today = new Date()
  d = moment(new Date()).subtract(1, 'month')
  $scope.fromDate = {date: d._d}
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
    $scope.canAddAndEdit = $scope.hasAddAndUpdatePermission(acData)
    $rootScope.showLedgerBox = false
    $rootScope.showLedgerLoader = true
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

    $scope.showLedgerBreadCrumbs(acData.parentGroups.reverse())

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
        transaction.amount = parseFloat(transaction.amount).toFixed(2)
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
    $rootScope.showLedgerLoader = false
    $scope.ledgerData = angular.copy(_.omit(res.body, 'ledgers'))
    $scope.calculateLedger($scope.ledgerData, "server")

  $scope.loadLedgerFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.addNewAccount = () ->
    if _.isEmpty($scope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalService.openManageGroupsModal()

  $scope.addNewEntry = (data) ->
    edata = {}
    edata.transactions = []
    _.extend(edata, data.sharedData)
    if data.sharedData.addType
      _.filter($scope.ledgerOnlyDebitData, (entry) ->
        if entry.sharedData.addType and entry.transactions[0].amount isnt ""
          edata.transactions.push(entry.transactions[0])
      )
      _.filter($scope.ledgerOnlyCreditData, (entry) ->
        if entry.sharedData.addType and entry.transactions[0].amount isnt ""
          edata.transactions.push(entry.transactions[0])
      )
    else
      _.extend(edata.transactions, data.transactions)
    edata.voucherType = data.sharedData.voucher.shortCode
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUniqueName
    }
    ledgerService.createEntry(unqNamesObj, edata).then($scope.addEntrySuccess, $scope.addEntryFailure)

  $scope.addEntrySuccess = (res) ->
    $rootScope.lItem = []
    toastr.success("Entry created successfully", "Success")
    $scope.removeClassInAllEle("ledgEntryForm", "newMultiEntryRow")
    $scope.removeClassInAllEle("ledgEntryForm", "open")
    $scope.$broadcast('$reloadLedger')
    $scope.removeLedgerDialog()

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
    $document.off 'click'
    $rootScope.lItem = []
    $scope.removeClassInAllEle("ledgEntryForm", "newMultiEntryRow")
    $scope.removeClassInAllEle("ledgEntryForm", "highlightRow")
    $scope.removeClassInAllEle("ledgEntryForm", "open")
    toastr.success("Entry updated successfully", "Success")
    $scope.removeLedgerDialog()
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
            sharedData = _.omit(uLedger, 'transactions')
            ledger.sharedData = sharedData
            if _.isEqual(ledger.transactions[0], transaction)
              ledger.transactions[0] = transaction

        )
      if transaction.type is "CREDIT"
        _.filter($scope.ledgerOnlyCreditData, (ledger) ->
          if ledger.sharedData.uniqueName is uLedger.uniqueName
            sharedData = _.omit(uLedger, 'transactions')
            ledger.sharedData = sharedData
            if _.isEqual(ledger.transactions[0], transaction)
              ledger.transactions[0] = transaction
        )
    )
    # after update check if updated row is last row
    ddR = _.last($scope.ledgerOnlyDebitData)
    cdR = _.last($scope.ledgerOnlyCreditData)
    if !_.isUndefined(ddR.sharedData.uniqueName)
      $scope.ledgerOnlyDebitData.push(angular.copy(dummyValueDebit))
    if !_.isUndefined(cdR.sharedData.uniqueName)
      $scope.ledgerOnlyCreditData.push(angular.copy(dummyValueCredit))
    $scope.calculateLedger($scope.ledgerData, "update")

  $scope.updateEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

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

  $scope.removeClassInAllEle = (target, clName)->
    el = document.getElementsByClassName(target)
    angular.element(el).removeClass(clName)

  $scope.forwardtoCntrlScope = (ele, data) ->
    if data.sharedData.multiEntry
      el = document.getElementsByClassName(ele[0].classList[3])
      angular.element(el).addClass('newMultiEntryRow')
    else
      angular.element(ele).addClass('newMultiEntryRow')
    
  $scope.addEntryInCredit =(data)->
    arLen = $scope.ledgerOnlyCreditData.length-1
    lastRow = $scope.ledgerOnlyCreditData[arLen]

    if lastRow.sharedData.entryDate isnt "" and  not _.isEmpty(lastRow.transactions[0].amount) and not _.isEmpty(lastRow.transactions[0].particular.uniqueName)
      $scope.ledgerOnlyCreditData.push(angular.copy(dummyValueCredit))
      $timeout ->
        $scope.sameMethodForDrCr(arLen+1, ".crLedgerEntryForm")
      , 200
    else
      $scope.sameMethodForDrCr(arLen, ".crLedgerEntryForm")

    if _.isUndefined(data.sharedData.uniqueName)
      data.sharedData.addType = true

    wt = _.omit(data, 'transactions')
    wt.id = wt.id + arLen
    _.extend(_.last($scope.ledgerOnlyCreditData), wt)

  
  $scope.addEntryInDebit =(data)->
    arLen = $scope.ledgerOnlyDebitData.length-1
    lastRow = $scope.ledgerOnlyDebitData[arLen]

    if lastRow.sharedData.entryDate isnt "" and  not _.isEmpty(lastRow.transactions[0].amount) and not _.isEmpty(lastRow.transactions[0].particular.uniqueName)
      $scope.ledgerOnlyDebitData.push(angular.copy(dummyValueDebit))
      $timeout ->
        $scope.sameMethodForDrCr(arLen+1, ".drLedgerEntryForm")
      , 200
    else
      $scope.sameMethodForDrCr(arLen, ".drLedgerEntryForm")

    if _.isUndefined(data.sharedData.uniqueName)
      data.sharedData.addType = true

    wt = _.omit(data, 'transactions')
    wt.id = wt.id + arLen
    _.extend(_.last($scope.ledgerOnlyDebitData), wt)
    
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
      drt += Number(entry.transactions[0].amount)
    )
    _.each($scope.ledgerOnlyCreditData, (entry) ->
      crt += Number(entry.transactions[0].amount)
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
    ledgerObj = DAServices.LedgerGet()
    if !_.isEmpty(ledgerObj.ledgerData)
      $scope.loadLedger(ledgerObj.ledgerData, ledgerObj.selectedAccount)
    else
      if !_.isNull(localStorageService.get("_ledgerData"))
        $scope.loadLedger(localStorageService.get("_ledgerData"), localStorageService.get("_selectedAccount"))
      else
        console.log "nothing selected to load"

  $scope.hasAddAndUpdatePermission = (account) ->
    permissionService.hasPermissionOn(account, "UPDT") and permissionService.hasPermissionOn(account, "ADD")

  #show breadcrumbs on ledger
  $scope.showLedgerBreadCrumbs = (data) ->
    $scope.ledgerBreadCrumbList = data

  #export ledger
  $scope.exportLedger = ()->
    console.log "exportLedger"
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUniqueName
      fromDate: $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    }
    accountService.exportLedger(unqNamesObj).then($scope.exportLedgerSuccess, $scope.exportLedgerFailure)

  # get IE version
  GetIEVersion = ->
    sAgent = window.navigator.userAgent
    Idx = sAgent.indexOf('MSIE')
    if Idx > 0
      parseInt sAgent.substring(Idx + 5, sAgent.indexOf('.', Idx))
    else if ! !navigator.userAgent.match(/Trident\/7\./)
      11
    else
      0



  $scope.exportLedgerSuccess = (res)->
    #window.open(res.body.filePath)
    isIE = false
    if GetIEVersion() > 0
      isIE = true
    else
      isIe = false

    if !isIE
      window.open(res.body.filePath)
    else
      win = window.open()
      win.document.write('sep=,\r\n',res.body.filePath)
      win.document.close()
      win.document.execCommand('SaveAs',true, 'abc' + ".xls")
      win.close()




  $scope.exportLedgerFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  # upload by progressbar
  $scope.importLedger = (files, errFiles) ->
    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUniqueName
    }
    $scope.impLedgBar = false
    $scope.impLedgFiles = files
    $scope.impLedgErrFiles = errFiles
    angular.forEach files, (file) ->
      file.upload = Upload.upload(
        url: '/upload/' + $scope.selectedCompany.uniqueName + '/import-ledger'
        file: file
        data:{
          'urlObj': unqNamesObj
        }
      )
      file.upload.then ((res) ->
        $timeout ->
          $scope.impLedgBar = true
          file.result = res.data
          toastr.success(res.data.body.message, res.data.status)
      ), ((res) ->
        console.log res, "error"
      ), (evt) ->
        file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))

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