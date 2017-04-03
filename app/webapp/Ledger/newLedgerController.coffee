
newLedgerController = ($scope, $rootScope, $window,localStorageService, toastr, modalService, ledgerService,FileSaver , $filter, DAServices, $stateParams, $timeout, $location, $document, permissionService, accountService, groupService, $uibModal, companyServices, $state,idbService, $http) ->
  lc = this
  if _.isUndefined($rootScope.selectedCompany)
    $rootScope.selectedCompany = localStorageService.get('_selectedCompany')
  lc.pageLoader = false
  #date time picker code starts here
  lc.today = new Date()
  d = moment(new Date()).subtract(8, 'month')
  lc.fromDate = {date: d._d}
  lc.toDate = {date: new Date()}
  lc.fromDatePickerIsOpen = false
  lc.toDatePickerIsOpen = false
  lc.format = "dd-MM-yyyy"
  lc.showPanel = false
  lc.accountUnq = $stateParams.unqName  
  lc.accountToShow = {}
  lc.mergeTransaction = false
  lc.showEledger = true
  lc.pageAccount = {}
  lc.showLoader = true
  lc.showExportOption = false
  lc.showLedgerPopover = false
  lc.adjustHeight = 0
  lc.dLedgerLimit = 10
  lc.cLedgerLimit = 10
  lc.entrySettings = {}
  lc.firstLoad = true
  $rootScope.flyAccounts = true
  
  $scope.creditTotal = 0
  $scope.debitTotal = 0

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
          lc.getLedgerData(false, true)
      }
  }
  $scope.setStartDate = ->
    $scope.cDate.startDate = moment().subtract(4, 'days').toDate()

  $scope.setRange = ->
    $scope.cDate =
        startDate: moment().subtract(5, 'days')
        endDate: moment()
  ###date range picker end###

  lc.sortDirection = Object.freeze({'asc' : 0, 'desc' : 1})
  lc.sortDirectionInvert = (dir) ->
    if lc.sortDirection.asc == dir 
      return lc.sortDirection.desc
    else if lc.sortDirection.desc == dir
      return lc.sortDirection.asc

  lc.sortOrderChange = (type) ->
    if type == 'dr'
      lc.dLedgerContainer = new lc.ledgerContainer()
    else if type == 'cr'
      lc.cLedgerContainer = new lc.ledgerContainer()
    else
      return 0
    if !lc.query
      lc.readLedgers $rootScope.selectedAccount.uniqueName, lc.page, 'next', type
    else if lc.query
      lc.readLedgersFiltered $rootScope.selectedAccount.uniqueName, lc.page, 'next', type


  lc.scrollDirection = Object.freeze({'next' : 0, 'prev' : 1})

  lc.sortOrder = {
    debit : lc.sortDirection.desc
    credit: lc.sortDirection.desc
  }

  # $scope.cDatePicker.date = {startDate: d._d, endDate: new Date()};


  # $scope.options = {
  #   applyClass: 'btn-green',
  #   locale: {
  #     applyLabel: "Apply",
  #     fromLabel: "From",
  #     format: "YYYY-MM-DD",
  # # //format: "D-MMM-YY", //will give you 6-Jan-17
  # # //format: "D-MMMM-YY", //will give you 6-January-17
  #     toLabel: "To",
  #     cancelLabel: 'Cancel',
  #     customRangeLabel: 'Custom range'
  #   },
  #   ranges: {
  #     'Today': [moment(), moment()],
  #     'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
  #     'Last 7 Days': [moment().subtract(6, 'days'), moment()],
  #     'Last 30 Days': [moment().subtract(29, 'days'), moment()],
  #     'This Month': [moment().startOf('month'), moment().endOf('month')],
  #     'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
  #   }
  # }

  lc.popover = {

    templateUrl: 'panel'
    draggable: false
    position: "bottom"
  }
  lc.newAccountModel = {
    group : ''
    account: ''
    accUnqName: ''
  }
  lc.ledgerEmailData = {}

  lc.hideEledger = () ->
    lc.showEledger = !lc.showEledger 

  lc.closePanel = () ->
    lc.showPanel = false

  lc.progressBar = {
    max : 6000,
    value: 0,
    type: 'success'
  }
  ################################### indexedDB functions ############################

  lc.showLogs = false
  lc.readLedgersFinished = false
  lc.filteredLedgers = []
  lc.totalLedgers = 0
  lc.savedLedgers = 0
  lc.isLedgerSeeded = false
  lc.cNonemptyTxn = 0
  lc.dNonemptyTxn = 0
  lc.pageCount = 50
  lc.page = 1
  lc.dbConfig = 
    name: 'giddh_db'
    storeName: 'ledgers'
    version: 20
    success: (e) ->
    failure: (e) ->
    upgrade: (e) ->

  lc.parseLedgerDate = (date) ->
    date = date.split('-')
    date = new Date(date[2], date[1], date[0]).getTime()
    date

  lc.addToIdb = (ledgers, accountUniqueName) ->
    cNonemptyTxn = 0
    dNonemptyTxn = 0
    lc.savedLedgers = 0
    lc.isLedgerSeeded = false
    drTransSeeded = false
    crTransSeeded = false
    lc.dbConfig.success = (e) ->
      db = e.target.result
      search = db.transaction([ 'ledgers' ], 'readwrite').objectStore('ledgers')

      keyRange = IDBKeyRange.bound(
        $rootScope.selectedCompany.uniqueName + " " + accountUniqueName + ' ',
        $rootScope.selectedCompany.uniqueName + " " + accountUniqueName + ' ' + '\xFF'
      )

      delReq = search.delete(keyRange)

      delReq.onsuccess = (e) ->

        drObjs = [];
        crObjs = [];
        crSavedLedgersCount = 0;
        drSavedLedgersCount = 0;
        seedLedgerInDB = (ledger, index) -> 
          ledger.uniqueId = $rootScope.selectedCompany.uniqueName + " " + accountUniqueName + " " + ledger.uniqueName
          ledger.accountUniqueName = accountUniqueName
          ledger.index = index
          date = lc.parseLedgerDate(ledger.entryDate)
          ledger.timestamp = Math.floor(date / 1000)

          addReq = search.put(ledger)

          addReq.onsuccess = (e) ->
            lc.progressBar.value += 1
            lc.savedLedgers += 1
          return

        ledgers.forEach (ledger, index) ->
          seedLedgerInDB(ledger, index)
          drTrans = []
          crTrans = []
          ledger.transactions.forEach (tr, index) -> 
            if ( tr.type == 'CREDIT')
              crTrans.push tr
              cNonemptyTxn++
            else
              drTrans.push tr
              dNonemptyTxn++
          if crTrans.length != 0
            crObj = {};
            crObj = _.extend(crObj, ledger)
            crObj.accountUniqueName = accountUniqueName
            crObj.company = $rootScope.selectedCompany.uniqueName
            crObj.transactions = crTrans
            crObjs.push(crObj)
          if drTrans.length != 0
            drObj = {};
            drObj = _.extend(drObj, ledger)
            drObj.accountUniqueName = accountUniqueName
            drObj.company = $rootScope.selectedCompany.uniqueName
            drObj.transactions = drTrans
            drObjs.push(drObj)
        lc.cNonemptyTxn = cNonemptyTxn
        lc.dNonemptyTxn = dNonemptyTxn

        drTrans = db.transaction([ 'drTransactions' ], 'readwrite')
        drTrans.oncomplete = (e) ->
          drTransSeeded = true
          if crTransSeeded
            lc.onLedgerSeeded()
        drOS = drTrans.objectStore('drTransactions')
        drOS.delete(keyRange)
        drObjs.forEach (drOb) -> 
          addDrReq = drOS.put(drOb)
          addDrReq.onsuccess = (e) ->
            drSavedLedgersCount += 1
            # lc.progressBar.value += 1
            # console.log 'dr', e.target.result, drSavedLedgersCount, lc.savedLedgers, crSavedLedgersCount

          addDrReq.onerror = (e) ->
            #console.log e.target.error
            return
        crTrans = db.transaction([ 'crTransactions' ], 'readwrite')
        crTrans.oncomplete = (e) ->
          crTransSeeded = true
          if drTransSeeded
            lc.onLedgerSeeded()

        crOS = crTrans.objectStore('crTransactions')
        crOS.delete(keyRange)
        crObjs.forEach (crOb) -> 
          addCrReq = crOS.put(crOb)
          addCrReq.onsuccess = (e) ->
            crSavedLedgersCount += 1
            # lc.progressBar.value += 1
            # console.log 'cr', e.target.result, drSavedLedgersCount, lc.savedLedgers, crSavedLedgersCount

          addCrReq.onerror = (e) ->
            #console.log e.target.error
            return
      delReq.onerror = (e) ->
        #console.log('failed', e.target.error)

      #search.clear()
      

    lc.dbConfig.failure = (e) ->
      toastr.error(e.target.error.message)
      return

    lc.dbConfig.upgrade = (e) ->
      db = e.target.result
      lc.commonOnUpgrade(db)
      return

    lc.dbConfig.onblocked = (e) ->
      toastr.error(e.target.error)
      
    dbInstance = idbService.openDb(lc.dbConfig)

  lc.onLedgerSeeded = () ->
    lc.cLedgerContainer = new lc.ledgerContainer()
    lc.dLedgerContainer = new lc.ledgerContainer()
    lc.readLedgers($rootScope.selectedAccount.uniqueName, 1, 'next')
    lc.isLedgerSeeded = false
    lc.showLoader = false


  ###read ledgers ###
  lc.readLedgers = (accountname, page, scrollDir, type) ->
    lc.readLedgersFinished = false
    type = type || null
    if type == null 
      drLoadCompleted = false
      crLoadCompleted = false
    else if type == 'dr'
      crLoadCompleted = true
    else if type == 'cr'
      drLoadCompleted = true
    lc.dbConfig.success = (e) ->
      db = e.target.result
      #console.log "Inside readledgers."

      #DEBIT READ STARTS
      if type == 'dr' || type == null
        keyAndDir = lc.generateKeyRange(accountname, lc.dLedgerContainer, lc.sortOrder.debit, scrollDir)

        drTrCount = 0
        drTrans = db.transaction([ 'drTransactions' ], 'readonly')
        drTrans.oncomplete = (e) ->
          drLoadCompleted = true
          lc.dLedgerContainer.scrollDisable = false
          if crLoadCompleted
            $scope.$apply ()->
              lc.readLedgersFinished = true
          return
        drOS = drTrans.objectStore('drTransactions')
        drSearch = drOS.index('company+accountUniqueName+index', true).openCursor(keyAndDir.keyRange, keyAndDir.scrollDir)
        
        drSearch.onsuccess = (e) ->
          cursor = e.target.result
          if cursor
            if keyAndDir.scrollDir == 'next'
              lc.dLedgerContainer.add cursor.value, lc.pageCount
            else if keyAndDir.scrollDir = 'prev'
              lc.dLedgerContainer.addAtTop cursor.value, lc.pageCount

            drTrCount += cursor.value.transactions.length

            if drTrCount >= lc.pageCount
              return
            cursor.continue()
          else
            if (
              scrollDir == 'next' && lc.sortOrder.debit == lc.sortDirection.asc ||
              scrollDir == 'prev' && lc.sortOrder.debit == lc.sortDirection.desc
            )
              lc.dLedgerContainer.upperBoundReached = true
            if (
              scrollDir == 'prev' && lc.sortOrder.debit == lc.sortDirection.asc ||
              scrollDir == 'next' && lc.sortOrder.debit == lc.sortDirection.desc
            )
              lc.dLedgerContainer.lowerBoundReached = true

        drSearch.onerror = (e) -> 
          #console.log 'error', e

      #CREDIT READ STARTS
      if type == 'cr' || type == null
        keyAndDir = lc.generateKeyRange(accountname, lc.cLedgerContainer, lc.sortOrder.credit, scrollDir)

        crTrCount = 0
        crTrans = db.transaction([ 'crTransactions' ], 'readonly')
        crTrans.oncomplete = (e) ->
          crLoadCompleted = true
          lc.cLedgerContainer.scrollDisable = false
          if drLoadCompleted
            $scope.$apply ()->
              lc.readLedgersFinished = true
          return
        crOS = crTrans.objectStore('crTransactions')
        crSearch = crOS.index('company+accountUniqueName+index', true).openCursor(keyAndDir.keyRange, keyAndDir.scrollDir)
        
        crSearch.onsuccess = (e) ->
          cursor = e.target.result
          if cursor
            if keyAndDir.scrollDir == 'next'
              lc.cLedgerContainer.add cursor.value, lc.pageCount
            else if keyAndDir.scrollDir = 'prev'
              lc.cLedgerContainer.addAtTop cursor.value, lc.pageCount

            crTrCount += cursor.value.transactions.length
            if crTrCount >= lc.pageCount
              return
            cursor.continue()
          else
            if (
              scrollDir == 'next' && lc.sortOrder.credit == lc.sortDirection.asc ||
              scrollDir == 'prev' && lc.sortOrder.credit == lc.sortDirection.desc
            )
              lc.cLedgerContainer.upperBoundReached = true
            if (
              scrollDir == 'prev' && lc.sortOrder.credit == lc.sortDirection.asc ||
              scrollDir == 'next' && lc.sortOrder.credit == lc.sortDirection.desc
            )
              lc.cLedgerContainer.lowerBoundReached = true

        crSearch.onerror = (e) -> 
          #console.log 'error', e
      db.close()
      return

    lc.dbConfig.failure = (e) ->
      #console.log e.target.error
      return

    lc.dbConfig.upgrade = (e) ->
      db = e.target.result
      lc.commonOnUpgrade(db)
      return

    idbService.openDb lc.dbConfig
    return

  lc.readLedgersFiltered = (accountUniqueName, page, scrollDir, type) ->
    lc.readLedgersFinished = false
    type = type || null
    if type == null 
      drLoadCompleted = false
      crLoadCompleted = false
    else if type == 'dr'
      crLoadCompleted = true
    else if type == 'cr'
      drLoadCompleted = true
    lc.dbConfig.success = (e) ->
      db = e.target.result
      #DEBIT READ STARTS
      if type == 'dr' || type == null
        keyAndDir = lc.generateKeyRange(accountUniqueName, lc.dLedgerContainer, lc.sortOrder.debit, scrollDir)

        drTrCount = 0
        drTrans = db.transaction([ 'drTransactions' ], 'readonly')
        drTrans.oncomplete = () ->
          drLoadCompleted = true
          lc.dLedgerContainer.scrollDisable = false
          if crLoadCompleted
            $scope.$apply ()->
              lc.readLedgersFinished = true
          return
        drOS = drTrans.objectStore('drTransactions')
        drSearch = drOS.index('company+accountUniqueName+index', true).openCursor(keyAndDir.keyRange, keyAndDir.scrollDir)

        drSearch.onsuccess = (e) ->
          cursor = e.target.result
          if cursor
            # lc.dLedgerData[cursor.value.uniqueName] = cursor.value
            if lc.filteredLedgers.indexOf(cursor.value.index) > -1
              drTrCount += cursor.value.transactions.length
              if keyAndDir.scrollDir == 'next'
                lc.dLedgerContainer.add cursor.value, lc.pageCount
              else if keyAndDir.scrollDir = 'prev'
                lc.dLedgerContainer.addAtTop cursor.value, lc.pageCount

            if drTrCount >= lc.pageCount
              return
            cursor.continue()
          else
            if (
              scrollDir == 'next' && lc.sortOrder.debit == lc.sortDirection.asc ||
              scrollDir == 'prev' && lc.sortOrder.debit == lc.sortDirection.desc
            )
              lc.dLedgerContainer.upperBoundReached = true
            if (
              scrollDir == 'prev' && lc.sortOrder.debit == lc.sortDirection.asc ||
              scrollDir == 'next' && lc.sortOrder.debit == lc.sortDirection.desc
            )
              lc.dLedgerContainer.lowerBoundReached = true

        drSearch.onerror = (e) -> 
          #console.log 'error', e

      #CREDIT READ STARTS
      if type == 'cr' || type == null
        keyAndDir = lc.generateKeyRange(accountUniqueName, lc.cLedgerContainer, lc.sortOrder.credit, scrollDir)

        crTrCount = 0
        crTrans = db.transaction([ 'crTransactions' ], 'readonly')
        crTrans.oncomplete = (e) ->
          crLoadCompleted = true
          lc.cLedgerContainer.scrollDisable = false
          if drLoadCompleted
            $scope.$apply ()->
              lc.readLedgersFinished = true
          return
        crOS = crTrans.objectStore('crTransactions')
        crSearch = crOS.index('company+accountUniqueName+index', true).openCursor(keyAndDir.keyRange, keyAndDir.scrollDir)
        crSearch.onsuccess = (e) ->
          cursor = e.target.result
          if cursor
            # lc.cLedgerData[cursor.value.uniqueName] = cursor.value
            if lc.filteredLedgers.indexOf(cursor.value.index) > -1
              if keyAndDir.scrollDir == 'next'
                lc.cLedgerContainer.add cursor.value, lc.pageCount
              else if keyAndDir.scrollDir = 'prev'
                lc.cLedgerContainer.addAtTop cursor.value, lc.pageCount

              crTrCount += cursor.value.transactions.length

            if crTrCount >= lc.pageCount
              return
            cursor.continue()
          else
            if (
              scrollDir == 'next' && lc.sortOrder.credit == lc.sortDirection.asc ||
              scrollDir == 'prev' && lc.sortOrder.credit == lc.sortDirection.desc
            )
              lc.cLedgerContainer.upperBoundReached = true
            if (
              scrollDir == 'prev' && lc.sortOrder.credit == lc.sortDirection.asc ||
              scrollDir == 'next' && lc.sortOrder.credit == lc.sortDirection.desc
            )
              lc.cLedgerContainer.lowerBoundReached = true

        crSearch.onerror = (e) -> 
          #console.log 'error', e
      db.close()
      
    lc.dbConfig.failure = (e) ->
      #console.log e.target.error
      return

    lc.dbConfig.upgrade = (e) ->
      db = e.target.result
      lc.commonOnUpgrade(db)
      return

    idbService.openDb lc.dbConfig
    return

  lc.readLedgersWithQuery = (accountUniqueName, query, page, scrollDir, type) ->
    type = type || null
    lc.dbConfig.success = (e) ->
      db = e.target.result
      lc.filteredLedgers = []

      ledgerTrans = db.transaction([ 'ledgers' ], 'readwrite')
      ledgerTrans.onerror = (e) -> 
        lc.log('transaction error')
        db.close()
      ledgerTrans.onabort = (e) ->
        lc.log('transaction abort')
        db.close()
      ledgerTrans.oncomplete = (e) ->
        lc.readLedgersFiltered(accountUniqueName, page, scrollDir, type)
            
      ledger = ledgerTrans.objectStore('ledgers')
      keyRange = IDBKeyRange.lowerBound([
          accountUniqueName,
          Number.MIN_SAFE_INTEGER
        ], true)
      ledgerSearch = ledger.index('accountUniqueName+index').openCursor(keyRange)
      ledgerSearch.onsuccess = (e) ->
        # console.log('succ', e)
        cursor = e.target.result
        if cursor
          if lc.filterByQueryNew(cursor.value, query)
            lc.filteredLedgers.push cursor.value.index
          cursor.continue()
        return
      ledgerSearch.onerror = (e) ->
        return

      # db.close()
      return

    lc.dbConfig.failure = (e) ->
      #console.log e.target.error
      return

    lc.dbConfig.upgrade = (e) ->
      db = e.target.result
      lc.commonOnUpgrade(db)
      return

    idbService.openDb lc.dbConfig
    return

  # $scope.$watch('lc.isLedgerSeeded', (newVal, oldVal)->
  #   if( !oldVal && newVal)
  #     lc.cLedgerContainer = new lc.ledgerContainer()
  #     lc.dLedgerContainer = new lc.ledgerContainer()
  #     lc.readLedgers($rootScope.selectedAccount.uniqueName, 1, 'next')
  #   lc.isLedgerSeeded = false
  #   lc.showLoader = false
  # )

  # $scope.$watch('lc.readLedgersFinished', (newVal, oldVal) -> 
  #   if ( newVal && !oldVal )
  #     lc.log "Read Ledgers Finished."
  #     # $scope.$apply()
  #     lc.readLedgersFinished = false
  #   else if !newVal && !oldVal
  #     lc.readLedgersFinished = false
  # )

  # $scope.$watch('lc.savedLedgers', (newVal, oldVal)->
  #   if(newVal > 0 && newVal == lc.totalLedgers)
  #     lc.readLedgers($rootScope.selectedAccount.uniqueName, 1, 'next')
  #     lc.showLoader = false
  # )

  lc.onScrollDebit = (sTop, sHeight, pos) ->
    if !lc.query
      lc.readLedgers $rootScope.selectedAccount.uniqueName, lc.page, pos, 'dr'
      # $scope.$apply()
    else if lc.query
      lc.readLedgersFiltered $rootScope.selectedAccount.uniqueName, lc.page, pos, 'dr'
      # $scope.$apply()
    return

  lc.onScrollCredit = (sTop, sHeight, pos) ->
    if !lc.query
      lc.readLedgers $rootScope.selectedAccount.uniqueName, lc.page, pos, 'cr'
      # $scope.$apply()
    else if lc.query
      lc.readLedgersFiltered $rootScope.selectedAccount.uniqueName, lc.page, pos, 'cr'
      # $scope.$apply()
    return

  lc.filterLedgers = (accountname, query, page) ->
    lc.log query
    if query
      lc.dLedgerContainer = new lc.ledgerContainer()
      lc.cLedgerContainer = new lc.ledgerContainer()
      lc.readLedgersWithQuery accountname, query, lc.page, 'next'
    else
      lc.dLedgerContainer = new lc.ledgerContainer()
      lc.cLedgerContainer = new lc.ledgerContainer()
      lc.readLedgers accountname, lc.page, 'next'
    return

    lc.dbConfig.failure = (e) ->
      #console.log e.target.error, 'update failed'
      return

    lc.dbConfig.upgrade = (e) ->
      db = e.target.result
      lc.commonOnUpgrade(db)
      return

    idbService.openDb lc.dbConfig
    return
# {
#             "transactions": [{
#                 "particular": {
#                     "name": "Sales",
#                     "uniqueName": "sales"
#                 },
#                 "amount": 200,
#                 "inventory": null
#             }],
#             "total": {
#                 "amount": 200,
#                 },
#             "invoiceNumber": "",
#             "entryDate": "25-03-2017",
#             "voucher": {
#                 "name": "sales",
#             },
#             "voucherNo": 1,
#             "attachedFile": "",
#             "description": "",
#             "tag": ""
#         }

  lc.filterByQueryNew = (ledger, query) ->
    for txn in ledger.transactions
      if ( lc.filterItemByQuery(txn.particular, query) ||
        lc.filterItemByQuery(txn.amount, query) ||
        lc.filterItemByQuery(txn.inventory, query)
      )
        return true
    if (
      lc.filterItemByQuery(ledger.total.amount, query) ||
      lc.filterItemByQuery(ledger.invoiceNumber, query) ||
      lc.filterItemByQuery(ledger.entryDate, query) ||
      lc.filterItemByQuery(ledger.voucher, query) ||
      lc.filterItemByQuery(ledger.voucherNo, query) ||
      #lc.filterItemByQuery(ledger.attachedFile, query) ||
      lc.filterItemByQuery(ledger.description, query) ||
      lc.filterItemByQuery(ledger.tag, query)
    )
      return true
    return false

  lc.filterItemByQuery = (item, query) ->
    switch typeof item
      when 'object'
        for key of item
          if lc.filterItemByQuery(item[key], query)
            return true
      when 'string'
        if item.toLowerCase().indexOf(query.toLowerCase()) != -1
          return true
      when 'number'
        if item.toString().toLowerCase().indexOf(query.toLowerCase()) != -1
          return true
    return false

  lc.filterByQuery = (ledger, query) ->
    hasQuery = false
    for key of ledger
      if !hasQuery
        switch typeof ledger[key]
          when 'object'
            hasQuery = lc.filterByQuery(ledger[key], query)
          when 'string'
            if ledger[key].toLowerCase().indexOf(query.toLowerCase()) != -1
              return hasQuery = true
              break
          when 'number'
            if ledger[key].toString().toLowerCase().indexOf(query.toLowerCase()) != -1
              return hasQuery = true
              break
    hasQuery

  ################################### indexedDB functions end ############################

  lc.ledgerData = {
    ledgers: []
  }

  lc.newDebitTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: {
      name:''
      uniqueName:''
    }
    amount : 0
    type: 'DEBIT'
  }

  lc.newCreditTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: {
      name:''
      uniqueName:''
    }
    amount : 0
    type: 'CREDIT'
  }

  lc.blankLedger = {
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
        lc.newDebitTxn
        lc.newCreditTxn
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

  lc.addBlankTxn= (str, ledger) ->
    txn = new txnModel(str)
    txn.isBlank = true
#    if ledger.uniqueName != ""
    lc.hasBlankTxn = false
    lc.checkForExistingblankTransaction(ledger, str)
    if !lc.hasBlankTxn
      if str == 'DEBIT'
        if ledger.uniqueName
          if ! lc.dLedgerContainer.ledgerData[ledger.uniqueName]
            crObj = {};
            crObj = _.extend(crObj, ledger)
            crObj.accountUniqueName = $rootScope.selectedAccount.uniqueName
            crObj.company = $rootScope.selectedCompany.uniqueName
            crObj.transactions = []
            lc.dLedgerContainer.add(crObj)
          lc.dLedgerContainer.ledgerData[ledger.uniqueName].transactions.push(txn)
          lc.drMatch = lc.scrollMatchObject(lc.dLedgerContainer.ledgerData[ledger.uniqueName], 'dr')
        else
          lc.blankLedger.transactions.push(txn)

      else if str == 'CREDIT'
        if ledger.uniqueName
          if ! lc.dLedgerContainer.ledgerData[ledger.uniqueName]
          else
            crObj = {};
            crObj = _.extend(crObj, ledger)
            crObj.accountUniqueName = $rootScope.selectedAccount.uniqueName
            crObj.company = $rootScope.selectedCompany.uniqueName
            crObj.transactions = []
            lc.cLedgerContainer.add(crObj)
          lc.cLedgerContainer.ledgerData[ledger.uniqueName].transactions.push(txn)
          lc.crMatch = lc.scrollMatchObject(lc.cLedgerContainer.ledgerData[ledger.uniqueName], 'cr')
        else
          lc.blankLedger.transactions.push(txn)
    #lc.prevTxn = txn
    # if str.toLowerCase() == "debit" && lc.sortOrder.debit
    #   lc.popover.position = "top"
    # else if str.toLowerCase() == "credit" && lc.sortOrder.credit
    #   lc.popover.position = "top"

    lc.setFocusToBlankTxn(ledger, txn, str)
    lc.blankCheckCompEntry(ledger)
  
  lc.setFocusToBlankTxn = (ledger, transaction, str) ->
    lc.prevTxn.isOpen = false
    lc.prevTxn.isblankOpen = false
    if str == 'DEBIT'
      if ledger.uniqueName
        _.each lc.dLedgerContainer.ledgerData[ledger.uniqueName].transactions, (txn) ->
          if txn.amount == 0 && txn.particular.name == "" && txn.particular.uniqueName == "" && txn.type == str
            txn.isOpen = true
            lc.prevTxn = txn
      else
        _.each lc.blankLedger.transactions, (txn) ->
          if txn.amount == 0 && txn.particular.name == "" && txn.particular.uniqueName == "" && txn.type == str
            txn.isOpen = true
            lc.prevTxn = txn
    else if str == 'CREDIT'
      if ledger.uniqueName 
        _.each lc.cLedgerContainer.ledgerData[ledger.uniqueName].transactions, (txn) ->
            if txn.amount == 0 && txn.particular.name == "" && txn.particular.uniqueName == "" && txn.type == str
              txn.isOpen = true
              lc.prevTxn = txn
      else
        _.each lc.blankLedger.transactions, (txn) ->
          if txn.amount == 0 && txn.particular.name == "" && txn.particular.uniqueName == "" && txn.type == str
            txn.isOpen = true
            lc.prevTxn = txn
        #lc.openClosePopOver(txn, ledger)

  lc.getFocus = (txn, ledger) ->
    if txn.particular.name == "" && txn.particular.uniqueName == "" && txn.amount == 0
      txn.isOpen = true
      #lc.openClosePopOver(txn,ledger)

  lc.checkForExistingblankTransaction = (ledger, str) ->
    if str == 'DEBIT'
      if ledger.uniqueName
        if lc.dLedgerContainer.ledgerData[ledger.uniqueName]
          _.each lc.dLedgerContainer.ledgerData[ledger.uniqueName].transactions, (txn) ->
            if txn.particular.uniqueName == '' && txn.amount == 0 && txn.type == str
              lc.hasBlankTxn = true
      else
        _.each lc.blankLedger.transactions, (txn) ->
          if txn.particular.uniqueName == '' && txn.amount == 0 && txn.type == str
            lc.hasBlankTxn = true
    else if str == 'CREDIT'
      if ledger.uniqueName
        if lc.cLedgerContainer.ledgerData[ledger.uniqueName]
          _.each lc.cLedgerContainer.ledgerData[ledger.uniqueName].transactions, (txn) ->
            if txn.particular.uniqueName == '' && txn.amount == 0 && txn.type == str
              lc.hasBlankTxn = true
      else
        _.each lc.blankLedger.transactions, (txn) ->
          if txn.particular.uniqueName == '' && txn.amount == 0 && txn.type == str
            lc.hasBlankTxn = true

  lc.taxList = []
  lc.voucherTypeList = [
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

  lc.selectedLedger = {
    description:null
    entryDate:$filter('date')(new Date(), "dd-MM-yyyy")
#    hasCredit:false
#    hasDebit:false
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
    isInclusiveTax: false
    uniqueName:""
    voucher:{
      name:"Sales"
      shortCode:"sal"
    }
    voucherNo:null
  }

  # lc.isSelectedAccount = () ->
  #   #$rootScope.selectedAccount = localStorageService.get('_selectedAccount')
  #   if _.isEmpty($rootScope.selectedAccount)
  #     lc.accountToShow = $rootScope.selectedAccount
  #   else
  #     cash = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:'cash'})
  #     if cash
  #       #$state.go('company.content.ledgerContent', {uniqueName:'cash'}, {notify: false})
  #       lc.getAccountDetail('cash')
  #     else
  #       #$state.go('company.content.ledgerContent', {uniqueName:'sales'}, {notify: false})
  #       lc.getAccountDetail('sales')

    # if _.isUndefined($rootScope.selectedAccount) || _.isNull($rootScope.selectedAccount)
    #   $rootScope.selectedAccount = lc.accountUnq
    #   lc.accountToShow = lc.accountUnq
    # else
    # if !_.isNull($rootScope.selectedAccount)
    #   if $rootScope.selectedAccount.uniqueName != $stateParams.unqName
    #     unq = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:$stateParams.unqName})
    #     localStorageService.set('_selectedAccount', unq)
    #     lc.accountToShow = unq
    #   else
    #     lc.accountToShow = $rootScope.selectedAccount
    # else
    #   unq = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:$stateParams.unqName})
    #   localStorageService.set('_selectedAccount', unq)
    #   lc.accountToShow = unq

  lc.isCurrentAccount =(acnt) ->
    acnt.uniqueName is lc.accountUnq

  lc.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  lc.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  # upper icon functions starts here
  # generate magic link
  lc.getMagicLink = () ->
    accUname = lc.accountUnq
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      accountUniqueName: accUname
      from: $filter('date')($scope.cDate.startDate, 'dd-MM-yyyy')
      to: $filter('date')($scope.cDate.endDate, 'dd-MM-yyyy')
    }
    companyServices.getMagicLink(reqParam).then(lc.getMagicLinkSuccess, lc.getMagicLinkFailure)

  lc.getMagicLinkSuccess = (res) ->
    lc.magicLink = res.body.magicLink
    modalInstance = $uibModal.open(
      template: '<div>
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" ng-click="$dismiss()" aria-label="Close"><span
        aria-hidden="true">&times;</span></button>
          <h3 class="modal-title">Magic Link</h3>
          </div>
          <div class="modal-body">
            <input id="magicLink" class="form-control" type="text" ng-model="lc.magicLink">
          </div>
          <div class="modal-footer">
            <button class="btn btn-default" ngclipboard data-clipboard-target="#magicLink">Copy</button>
          </div>
      </div>'
      size: "md"
      backdrop: 'static'
      scope: $scope
    )

  lc.getMagicLinkFailure = (res) ->
    toastr.error(res.data.message)

  # ledger send email
  lc.sendLedgEmail = (emailData, emailType) ->
    data = emailData
    if _.isNull(lc.toDate.date) || _.isNull($scope.cDate.startDate)
      toastr.error("Date should be in proper format", "Error")
      return false
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: lc.accountUnq
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

    accountService.emailLedger(unqNamesObj, sendData).then(lc.emailLedgerSuccess, lc.emailLedgerFailure)

  lc.emailLedgerSuccess = (res) ->
    toastr.success(res.body, res.status)
    #lc.ledgerEmailData.email = ''
    lc.ledgerEmailData = {}

  lc.emailLedgerFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #export ledger
  lc.exportLedger = (type)->
    lc.showExportOption = false
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: lc.accountUnq
      fromDate: $filter('date')($scope.cDate.startDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.cDate.endDate, "dd-MM-yyyy")
      lType:type
    }
    accountService.exportLedger(unqNamesObj).then(lc.exportLedgerSuccess, lc.exportLedgerFailure)

  lc.exportLedgerSuccess = (res)->
    # blob = new Blob([res.body.filePath], {type:'file'})
    # fileName = res.body.filePath.split('/')
    # fileName = fileName[fileName.length-1]
    # FileSaver.saveAs(blob, fileName)
    lc.isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0
    if $rootScope.msieBrowser()
      $rootScope.openWindow(res.body.filePath)
    else if lc.isSafari       
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

  lc.exportLedgerFailure = (res)->
    toastr.error(res.data.message, res.data.status)


  # upper icon functions ends here

  lc.getAccountDetail = (accountUniqueName) ->
    if not _.isUndefined(accountUniqueName) && not _.isEmpty(accountUniqueName) && not _.isNull(accountUniqueName)
      unqObj = {
        compUname : $rootScope.selectedCompany.uniqueName
        acntUname : accountUniqueName
      }
      accountService.get(unqObj)
      .then(
        (res)->
          lc.getAccountDetailSuccess(res)
      ,(error)->
        lc.getAccountDetailFailure(error)
      )

  lc.getAccountDetailFailure = (res) ->
    if lc.accountUnq != 'sales'
      toastr.error(res.data.message, res.data.status)
    else
      lc.getAccountDetail($rootScope.fltAccntListPaginated[0].uniqueName)

  lc.getAccountDetailSuccess = (res) ->
    localStorageService.set('_selectedAccount', res.body)
    $rootScope.selectedAccount = res.body
    lc.accountToShow = $rootScope.selectedAccount
    $state.go($state.current, {unqName: res.body.uniqueName}, {notify: false})
    lc.getLedgerData(true)
    if res.body.yodleeAdded == true && $rootScope.canUpdate
      #get bank transaction here
      $timeout ( ->
        lc.getBankTransactions(res.body.uniqueName)
      ), 2000

  lc.loadDefaultAccount = () ->
    
    @success = (res) ->
      lc.accountUnq = 'cash'
      lc.getAccountDetail(lc.accountUnq)

    @failure = (res) ->
      lc.accountUnq = 'sales'
      lc.getAccountDetail(lc.accountUnq)

    unqObj = {
      compUname : $rootScope.selectedCompany.uniqueName
      acntUname : 'cash'
    }
    accountService.get(unqObj).then(@success, @failure)
          

  lc.getBankTransactions = (accountUniqueName) ->
    unqObj = {
      compUname : $rootScope.selectedCompany.uniqueName
      acntUname : accountUniqueName
    }
    # get other ledger transactions
    ledgerService.getOtherTransactions(unqObj)
    .then(
      (res)->
        lc.getBankTransactionsSuccess(res)
    ,(error)->
      lc.getBankTransactionsFailure(error)
    )

  lc.getBankTransactionsFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  lc.getBankTransactionsSuccess = (res) ->
    lc.eLedgerData = lc.formatBankLedgers(res.body)
    lc.calculateELedger()
    #lc.removeUpdatedBankLedger()

  lc.calculateELedger = () ->
    lc.eLedgType = undefined
    lc.eCrBalAmnt = 0
    lc.eDrBalAmnt = 0
    lc.eDrTotal = 0
    lc.eCrTotal = 0
    crt = 0
    drt = 0
    _.each(lc.eLedgerData, (ledger) ->
      _.each(ledger.transactions, (transaction) ->
        if transaction.type == 'DEBIT'
          drt += Number(transaction.amount)
        else if transaction.type == 'CREDIT'
          crt += Number(transaction.amount)
      )
    )
    crt = parseFloat(crt)
    drt = parseFloat(drt)
    lc.eCrTotal = crt
    lc.eDrTotal = drt


  lc.formatBankLedgers = (bankArray) ->
    formattedBankLedgers = []
    if bankArray.length > 0
      _.each bankArray, (bank) ->
        ledger = new blankLedgerModel()
        ledger.entryDate = bank.date
        ledger.isBankTransaction = true
        ledger.transactionId = bank.transactionId
        ledger.transactions = lc.formatBankTransactions(bank.transactions, bank, ledger)
        ledger.description = bank.description
        formattedBankLedgers.push(ledger)
    formattedBankLedgers

  lc.formatBankTransactions = (transactions, bank, ledger, type) ->
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

  lc.mergeBankTransactions = (toMerge) ->
    if toMerge
      lc.mergeTransaction = true
      _.each lc.eLedgerData, (ld) ->
        if ld.uniqueName.length < 1 then ld.uniqueName = ld.transactionId else ld.uniqueName
        if ld.transactions[0].type == 'DEBIT'
          lc.dLedgerContainer.addAtTop(ld)
        else if ld.transactions[0].type == 'CREDIT'
          lc.cLedgerContainer.addAtTop(ld)
      # lc.ledgerData.ledgers.push(lc.eLedgerData)
      # lc.ledgerData.ledgers = lc.sortTransactions(_.flatten(lc.ledgerData.ledgers), 'entryDate')
      lc.showEledger = false
    else
    #   lc.AddBankTransactions()
    #   lc.showEledger = false
    # else
      lc.mergeTransaction = false
      lc.removeBankTransactions()
    #   lc.showEledger = true

  # lc.AddBankTransactions = () ->
  #   bankTxnDuplicate = lc.eLedgerData
  #   bankTxntoMerge = lc.fromBanktoLedgerObject(bankTxnDuplicate)
  #   lc.ledgerData.ledgers.push(bankTxntoMerge)
  #   lc.ledgerData.ledgers = _.flatten(lc.ledgerData.ledgers)

  lc.sortTransactions = (ledger, sortType) ->
    ledger = _.sortBy(ledger, sortType)
    ledger = ledger.reverse()
    ledger

  lc.removeBankTransactions = () ->
    withoutBankTxn = []
    _.each lc.cLedgerContainer.ledgerData, (ledger) ->
      if ledger.isBankTransaction 
        lc.cLedgerContainer.remove(ledger)
    _.each lc.dLedgerContainer.ledgerData, (ledger) ->
      if ledger.isBankTransaction 
        lc.dLedgerContainer.remove(ledger)
    lc.showEledger = true

  # lc.fromBanktoLedgerObject = (bankArray) ->
  #   bank2LedgerArray = []
  #   _.each bankArray, (txn) ->
  #     led = {}
  #     led.entryDate = txn.date
  #     led.transactions = txn.transactions
  #     led.isBankTransaction = true
  #     lc.renameBankTxnKeys(led.transactions)
  #     bank2LedgerArray.push(led)
  #   bank2LedgerArray

  # lc.renameBankTxnKeys = (txnArray) ->
  #   _.each txnArray, (txn) ->
  #     txn.particular = txn.remarks
  lc.getLedgerData = (showLoaderCondition, firstLoad) ->
    if firstLoad
      lc.firstLoad = false
      $rootScope.accClicked = false
    lc.progressBar.value = 0
    $rootScope.superLoader = true
    lc.showLoader = showLoaderCondition || true
    if _.isUndefined($rootScope.selectedCompany.uniqueName)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: lc.accountUnq
      fromDate: $filter('date')($scope.cDate.startDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.cDate.endDate, "dd-MM-yyyy")
    }
    if not _.isEmpty(lc.accountUnq)
      ledgerService.getLedger(unqNamesObj).then(lc.getLedgerDataSuccess, lc.getLedgerDataFailure)

  lc.getLedgerDataSuccess = (res) ->
    lc.ledgerData = {}
    lc.fetchLedgerDataSuccess(res)
    lc.totalLedgers= res.body.ledgers.length
    $rootScope.flyAccounts = false
    #lc.countTotalTransactions()
    # lc.paginateledgerData(res.body.ledgers)
    if res.body.ledgers.length < 1
      lc.showLoader = false
    #lc.showLoader = false
    #if lc.firstLoad || $rootScope.accClicked
      #lc.blankLedger.transactions[0].isOpen = true
    $rootScope.superLoader = false

  lc.getLedgerDataFailure = (res) ->
    toastr.error(res.data.message)
    lc.showLoader = false
    $rootScope.superLoader = false

  lc.filterTxnType = (ledgers, type) ->
    if ledgers.length
      _.each ledgers, (ledger) ->
        if ledger.transactions.length
          dTxn = []
          cTxn = []
          _.each ledger.transactions, (txn) ->
            if txn.type == 'CREDIT'
              cTxn.push(txn)
            else
              dTxn.push(txn)
          ledgerObj = {}
          ledgerObj = _.extend(ledgerObj, ledger)
          ledgerObj.transactions = dTxn
          lc.dLedgerData[ledger.uniqueName] = {}
          #if(ledgerObj.transactions.length > 0)
          lc.dLedgerData[ledger.uniqueName] = _.extend(lc.dLedgerData[ledger.uniqueName], ledgerObj)
          ledgerObj.transactions = cTxn
          lc.cLedgerData[ledger.uniqueName] = {}
          #if(ledgerObj.transactions.length > 0)
          lc.cLedgerData[ledger.uniqueName] = _.extend(lc.cLedgerData[ledger.uniqueName], ledgerObj)
    #console.log lc.dLedgerData, lc.cLedgerData

  lc.updateLedgerData = (condition, ledger) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: lc.accountUnq
      fromDate: $filter('date')($scope.cDate.startDate, "dd-MM-yyyy")
      toDate: $filter('date')($scope.cDate.endDate, "dd-MM-yyyy")
    }
    if not _.isEmpty(lc.accountUnq)
      ledgerService.getLedger(unqNamesObj).then(
        (res) -> lc.updateLedgerDataSuccess(res, condition, ledger)
        (res) -> lc.updateLedgerDataFailure
      )

  lc.fetchLedgerDataSuccess = (res) ->
    lc.ledgerData.balance = res.body.balance
    lc.ledgerData.forwardedBalance = res.body.forwardedBalance
    lc.ledgerData.creditTotal = res.body.creditTotal
    lc.ledgerData.debitTotal = res.body.debitTotal
    if lc.ledgerData.forwardedBalance.amount == 0
      recTotal = 0
      if lc.ledgerData.creditTotal > lc.ledgerData.debitTotal then  recTotal = lc.ledgerData.creditTotal else recTotal = lc.ledgerData.debitTotal
      lc.ledgerData.reckoningCreditTotal = recTotal
      lc.ledgerData.reckoningDebitTotal = recTotal
    else
      if lc.ledgerData.forwardedBalance.type == 'DEBIT'
        if lc.ledgerData.forwardedBalance.amount + lc.ledgerData.debitTotal <= lc.ledgerData.creditTotal
          lc.ledgerData.reckoningCreditTotal = lc.ledgerData.creditTotal
          lc.ledgerData.reckoningDebitTotal = lc.ledgerData.creditTotal
        else
          lc.ledgerData.reckoningCreditTotal = lc.ledgerData.forwardedBalance.amount + lc.ledgerData.debitTotal
          lc.ledgerData.reckoningDebitTotal = lc.ledgerData.forwardedBalance.amount + lc.ledgerData.debitTotal
      else
        if lc.ledgerData.forwardedBalance.amount + lc.ledgerData.creditTotal <= lc.ledgerData.debitTotal
          lc.ledgerData.reckoningCreditTotal = lc.ledgerData.debitTotal
          lc.ledgerData.reckoningDebitTotal = lc.ledgerData.debitTotal
        else
          lc.ledgerData.reckoningCreditTotal = lc.ledgerData.forwardedBalance.amount + lc.ledgerData.creditTotal
          lc.ledgerData.reckoningDebitTotal = lc.ledgerData.forwardedBalance.amount + lc.ledgerData.creditTotal
    # lc.ledgerData.reckoningCreditTotal = res.body.creditTotal
    # lc.ledgerData.reckoningDebitTotal = res.body.debitTotal
    # if lc.ledgerData.balance.type == 'CREDIT'
    #   lc.ledgerData.reckoningDebitTotal += lc.ledgerData.balance.amount
    #   lc.ledgerData.reckoningCreditTotal += lc.ledgerData.forwardedBalance.amount
    # else if lc.ledgerData.balance.type == 'DEBIT'    
    #   lc.ledgerData.reckoningCreditTotal += lc.ledgerData.balance.amount
    #   lc.ledgerData.reckoningDebitTotal += lc.ledgerData.forwardedBalance.amount
    lc.addToIdb(res.body.ledgers, $rootScope.selectedAccount.uniqueName)

  lc.updateLedgerDataSuccess = (res,condition, ledger) ->
    # lc.setEntryTotal(ledger, res.body, condition)
    lc.fetchLedgerDataSuccess(res)
    # lc.countTotalTransactions(res.body.ledgers)
    #lc.updateTotalTransactions()
    #lc.paginateledgerData(res.body.ledgers)

  lc.updateLedgerDataFailure = (res) ->
    toastr.error(res.data.message)

  lc.paginateledgerData = (ledgers) ->
    lc.ledgerCount = 50
    lc.dLedgerLimit = lc.setCounter(ledgers, 'DEBIT')
    lc.cLedgerLimit = lc.setCounter(ledgers, 'CREDIT')

  lc.setCounter = (ledgers, type) ->
    txns = 0
    ledgerCount = 0  
    _.each ledgers, (led) ->
      l = 0
      #count transactions in ledger
      _.each led.transactions, (txn) ->
        if txn.type == type
          l += 1 
      if txns <= lc.ledgerCount
        txns += l
        ledgerCount += 1
    # if ledgerCount < txns
    #   ledgerCount = txns
    if ledgerCount < 50
      ledgerCount = lc.ledgerCount
    ledgerCount

#   lc.countTotalTransactionsAfterSomeTime = (ledgers) ->
#     $timeout ( ->
#       lc.countTotalTransactions(ledgers)
# #      lc.showLoader = true
#     ), 1000

  lc.countTotalTransactions = (ledgers) ->
    # lc.cNonemptyTxn = 0
    # lc.dNonemptyTxn = 0

    # lc.dbConfig.success = (e) ->
    #   db = e.target.result
    #   drOS = db.transaction([ 'drTransactions' ], 'readwrite').objectStore('drTransactions')
    #   dCountReq = drOS.count()
    #   dCountReq.onsuccess = (e) ->
    #     lc.dNonemptyTxn = e.target.result
    #   crOS = db.transaction([ 'crTransactions' ], 'readwrite').objectStore('crTransactions')
    #   cCountReq = crOS.count()
    #   cCountReq.onsuccess = (e) ->
    #     lc.cNonemptyTxn = e.target.result

    # dbInstance = idbService.openDb(lc.dbConfig)
    # $scope.creditTotal = 0
    # $scope.debitTotal = 0
    # $scope.dTxnCount = 0
    # $scope.cTxnCount = 0
    # if ledgers.length > 0
    #   _.each ledgers, (ledger) ->
    #     if ledger.transactions.length > 0
    #       _.each ledger.transactions, (txn) ->
    #         txn.isOpen = false
    #         if txn.type == 'DEBIT'
    #           $scope.dTxnCount += 1
    #           $scope.debitTotal += Number(txn.amount)
    #         else
    #           $scope.cTxnCount += 1
    #           $scope.creditTotal += Number(txn.amount)
    return

  # lc.updateTotalTransactions = () ->
  #   $timeout ( ->
  #     lc.countTotalTransactions()
  #   ), 500

  # lc.filterLedgers = (ledgers) ->
  #   _.each ledgers, (lgr) ->
  #     lgr.hasDebit = false
  #     lgr.hasCredit = false
  #     if lgr.transactions.length > 0
  #       _.each lgr.transactions, (txn) ->
  #         if txn.type == 'DEBIT'
  #           lgr.hasDebit = true
  #         else if txn.type == 'CREDIT'
  #           lgr.hasCredit = true

  # get tax list

  lc.getTaxList = () ->
    lc.taxList = []
    if $rootScope.canUpdate and $rootScope.canDelete
      companyServices.getTax($rootScope.selectedCompany.uniqueName).then(lc.getTaxListSuccess, lc.getTaxListFailure)

  lc.getTaxListSuccess = (res) ->
    _.each res.body, (tax) ->
      tax.isSelected = false
      if tax.account == null
        tax.account = {}
        tax.account.uniqueName = 0
      lc.taxList.push(tax)
    lc.matchTaxAccounts(lc.taxList)

  lc.getTaxListFailure = (res) ->
    toastr.error(res.data.message, res.status)

  lc.matchTaxAccounts = (taxlist) ->
    _.each taxlist, (tax) ->
      

  # lc.addTaxEntry = (tax, item) ->
  #   if tax.isSelected
  #     lc.selectedTaxes.push(tax)
  #   else
  #     lc.selectedTaxes = _.without(lc.selectedTaxes, tax)
#    item.sharedData.taxes = lc.selectedTaxes

  #lc.isSelectedAccount()

  $timeout ( ->
    lc.getTaxList()

  ), 2000

  if lc.accountUnq
    lc.getAccountDetail(lc.accountUnq)
  else
    lc.loadDefaultAccount()  
  # $scope.$on('account-list-updated', ()->
  #   lc.loadDefaultAccount() 
  # )
  # lc.flatAccListC5 = {
  #     page: 1
  #     count: 5
  #     totalPages: 0
  #     currentPage : 1
  #   }

  lc.exportOptions = () ->
    lc.showExportOption = !lc.showExportOption

  lc.calculateEntryTotal = (ledger) ->
    if ledger != undefined
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

  # lc.setPopoverPlacement = (offset) ->
  #   fromTop = $(window).height() / 3 * 2
  #   if(offset > fromTop)
  #     lc.popover.position = "top"
  #   else
  #     lc.popover.position = "bottom"
  #   return false

  lc.prevTxn = null
  lc.selectTxn = (ledger, txn, index ,e) ->
    #setPopoverPlacement(e.clientY)
    if lc.accountToShow.stock != null && txn.inventory == undefined
      txn.inventory = {}
      txn.rate = lc.accountToShow.stock.rate
    if txn.inventory && txn.inventory.quantity
      txn.rate = txn.amount/txn.inventory.quantity
    if txn.particular.stock
      txn.rate = txn.particular.stock.rate
    #txn.rate = $filter('number')(Number(txn.rate), 4)
    lc.selectedTxn = txn
    if lc.prevTxn != null
      lc.prevTxn.isOpen = false
    lc.selectedTxn.isOpen = true
    lc.prevTxn = txn
    lc.calculateEntryTotal(ledger)
    lc.showLedgerPopover = true
    lc.matchInventory(txn)
    lc.ledgerBeforeEdit = {}
    angular.copy(ledger,lc.ledgerBeforeEdit)
    if lc.popover.draggable
      lc.showPanel = true
    #else
      #lc.openClosePopOver(txn, ledger)
    if ledger.isBankTransaction != undefined
      _.each(ledger.transactions,(transaction) ->
        if transaction.type == 'DEBIT'
          ledger.voucher.shortCode = "rcpt"
        else if transaction.type == 'CREDIT'
          ledger.voucher.shortCode = "pay"
      )
    lc.selectedLedger = ledger
    lc.selectedLedger.index = index
    #if ledger.uniqueName != '' || ledger.uniqueName != undefined || ledger.uniqueName != null
    lc.checkCompEntry(ledger)
    #lc.blankCheckCompEntry(ledger)
    lc.isTransactionContainsTax(ledger)
    e.stopPropagation()

  $scope.$watch('selectedTxn.amount', (newVal, oldVal) ->
    if newVal != oldVal
      lc.calculateEntryTotal(lc.selectedLedger)
  )

  lc.matchInventory = (txn) ->
    match = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:txn.particular.uniqueName})
    if match && match.stock != null && txn.inventory == null
      txn.inventory = angular.copy(match.stock, txn.inventory)

  lc.setEntryTotal = (pre, post, condition) ->
    if condition != 'delete'
      _.each post.ledgers, (l) ->
        if pre.uniqueName == l.uniqueName
          pre.total = l.total
          if condition == 'update'
            lc.updatedLedgerTotal = l.total

  lc.openClosePopOver = (txn, ledger, e) ->
    if lc.prevTxn != null
      lc.prevTxn.isOpen = false
    txn.isOpen = true
    txn.isblankOpen = true
    lc.prevTxn = txn
    lc.selectedTxn = txn
    lc.selectedLedger = ledger

    if $(e.currentTarget).offset().top > $(window).height() / 3 * 2
      lc.popover.position = "top"
    else
      lc.popover.position = "bottom"

    # lc.openClosePopoverForLedger(txn, ledger)
    # lc.openClosePopoverForBlankLedger(txn, ledger)
    # lc.openClosePopoverForeLedger(txn, ledger)

  lc.checkCompEntry = (ledger) ->
    if !ledger.uniqueName
      lc.blankLedger.isCompoundEntry = true
      if lc.prevLedger.uniqueName
        if lc.cLedgerContainer.ledgerData[lc.prevLedger.uniqueName]
          lc.cLedgerContainer.ledgerData[lc.prevLedger.uniqueName].isCompoundEntry = false
        if lc.dLedgerContainer.ledgerData[lc.prevLedger.uniqueName]
          lc.dLedgerContainer.ledgerData[lc.prevLedger.uniqueName].isCompoundEntry = false
    else
      if lc.cLedgerContainer.ledgerData[ledger.uniqueName]
        lc.cLedgerContainer.ledgerData[ledger.uniqueName].isCompoundEntry = true
      if lc.dLedgerContainer.ledgerData[ledger.uniqueName]
        lc.dLedgerContainer.ledgerData[ledger.uniqueName].isCompoundEntry = true
      if lc.prevLedger && lc.prevLedger.uniqueName && ledger.uniqueName != lc.prevLedger.uniqueName
        if lc.cLedgerContainer.ledgerData[lc.prevLedger.uniqueName]
          lc.cLedgerContainer.ledgerData[lc.prevLedger.uniqueName].isCompoundEntry = false
        if lc.dLedgerContainer.ledgerData[lc.prevLedger.uniqueName]
          lc.dLedgerContainer.ledgerData[lc.prevLedger.uniqueName].isCompoundEntry = false
      else if lc.prevLedger && !lc.prevLedger.uniqueName
        lc.blankLedger.isCompoundEntry = false

  lc.blankCheckCompEntry = (ledger) ->
    if ledger.isBlankLedger
      _.each ledger.transactions, (txn) ->
        if txn.particular.uniqueName != undefined && txn.particular.uniqueName.length > 0
          ledger.isBlankCompEntry = true
    else
      ledger.isBlankCompEntry = false 
      lc.blankLedger.isBlankCompEntry = false

  # lc.formatInventoryTxns = (ledger) ->
  #   if ledger.transactions.length > 0
  #     _.each ledger.transactions, (txn) ->
  #       if txn.inventory != undefined && txn.inventory.quantity != null && Number(txn.inventory.quantity) > 0
  #         txn.inventory.stock = {}
  #         if txn.particular.stock != null
  #           txn.inventory.stock.uniqueName = txn.particular.uniqueName
  #         else
  #           txn.inventory.stock.uniqueName = lc.accountToShow.uniqueName

  lc.buildLedger = (ledger) ->
    if !ledger.uniqueName
      ledger = lc.blankLedger
    else
      transactions = []
      if lc.cLedgerContainer.ledgerData[ledger.uniqueName]
        ctxn = lc.cLedgerContainer.ledgerData[ledger.uniqueName].transactions
        transactions.push(ctxn)
      if lc.dLedgerContainer.ledgerData[ledger.uniqueName]
        dtxn = lc.dLedgerContainer.ledgerData[ledger.uniqueName].transactions
        transactions.push(dtxn)
      transactions = _.flatten(transactions)
      ledger.transactions = transactions
    ledger


  # $scope.invoiceFile = {}
  # $scope.getInvoiceFile = (files) ->
  #   file = files[0]
  #   formData = new FormData()
  #   formData.append('file', file)
  #   formData.append('company', $rootScope.selectedCompany.uniqueName)

  #   @success = (res) ->
  #     lc.selectedLedger.attachedFile = res.data.body.uniqueName
  #     toastr.success('file uploaded successfully')

  #   @failure = (res) ->
  #     toastr.error(res.data.message)

  #   url = 'upload-invoice'
  #   $http.post(url, formData, {
  #     transformRequest: angular.identity,
  #     headers: {'Content-Type': undefined}
  #   }).then(@success, @failure)

  # lc.downloadAttachedFile = (file, e) ->
  #   e.stopPropagation()
  #   @success = (res) ->
  #     data = lc.b64toBlob(res.body.uploadedFile, "image/"+res.body.fileType)
  #     blobUrl = URL.createObjectURL(data)
  #     FileSaver.saveAs(data, res.body.name)

  #   @failure = (res) ->
  #     toastr.error(res.data.message)
  #   reqParam = {
  #     companyUniqueName: $rootScope.selectedCompany.uniqueName
  #     accountsUniqueName: $rootScope.selectedAccount.uniqueName
  #     file:file
  #   }
  #   ledgerService.downloadInvoiceFile(reqParam).then(@success, @failure)

  # lc.deleteAttachedFile = () ->
  #   lc.selectedLedger.attachedFile = ''
  #   lc.selectedLedger.attachedFileName = ''


  lc.doingEntry = false
  lc.lastSelectedLedger = {}
  lc.saveUpdateLedger = (ledger) ->
    if !ledger.isBankTransaction
      ledger = lc.buildLedger(ledger)
    # lc.pageLoader = true
    # lc.showLoader = true
    lc.lastSelectedLedger = ledger
    lc.dLedgerLimitBeforeUpdate = lc.dLedgerLimit
    lc.cLedgerLimitBeforeUpdate = lc.cLedgerLimit
    #lc.formatInventoryTxns(ledger)
    if lc.doingEntry == true
      return

    lc.doingEntry = true
    lc.ledgerTxnChanged = false
    if ledger.isBankTransaction
      lc.btIndex = ledger.index
    delete ledger.isCompoundEntry
    if !_.isEmpty(ledger.voucher.shortCode) 
      if _.isEmpty(ledger.uniqueName)
        #add new entry
        unqNamesObj = {
          compUname: $rootScope.selectedCompany.uniqueName
          acntUname: lc.accountUnq
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
        lc.addTaxesToLedger(ledger)
        if ledger.transactions.length > 0
          if ledger.transactions.length > 1
            lc.matchTaxTransactions(ledger.transactions, lc.taxList)
            lc.checkManualTaxTransaction(ledger.transactions, lc.ledgerBeforeEdit.transactions)
            lc.checkTaxCondition(ledger)
          ledgerService.createEntry(unqNamesObj, ledger).then(
            (res) -> lc.addEntrySuccess(res, ledger)
            (res) -> lc.addEntryFailure(res,rejectedTransactions, ledger))
        else
          lc.doingEntry = false
          ledger.transactions = rejectedTransactions
          response = {}
          response.data = {}
          response.data.message = "There must be at least a transaction to make an entry."
          response.data.status = "Error"
          lc.addEntryFailure(response,[])
#          toastr.error("There must be at least a transaction to make an entry.")
      else
        #update entry
        #lc.removeEmptyTransactions(ledger.transactions)
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
          acntUname: lc.accountUnq
          entUname: ledger.uniqueName
        }
        # transactionsArray = []
        # _.every(lc.blankLedger.transactions,(led) ->
        #   delete led.date
        #   delete led.parentGroups
        # )
        # _.each(ledger.)
        # transactionsArray = _.reject(lc.blankLedger.transactions, (led) ->
        #   led.particular.uniqueName == ""
        # )
        lc.addTaxesToLedger(ledger)
#        console.log ledger
        #ledger.transactions.push(transactionsArray)
        ledger.voucher = _.findWhere(lc.voucherTypeList,{'shortCode':ledger.voucher.shortCode})
        ledger.voucherType = ledger.voucher.shortCode
        if ledger.transactions.length > 0
          lc.matchTaxTransactions(ledger.transactions, lc.taxList)
          lc.matchTaxTransactions(lc.ledgerBeforeEdit.transactions, lc.taxList)
          lc.checkManualTaxTransaction(ledger.transactions, lc.ledgerBeforeEdit.transactions)
          updatedTxns = lc.updateEntryTaxes(ledger.transactions)
          ledger.transactions = updatedTxns
          lc.checkTaxCondition(ledger)
          isModified = false
          if ledger.taxes.length > 0
            isModified = lc.checkPrincipleModifications(ledger, lc.ledgerBeforeEdit.transactions)
          if isModified
            lc.selectedTxn.isOpen = false
            modalService.openConfirmModal(
              title: 'Update'
              body: 'Principle transaction updated, Would you also like to update tax transactions?',
              ok: 'Yes',
              cancel: 'No'
            ).then(
                (res) -> lc.UpdateEntry(ledger, unqNamesObj, true),
                (res) -> lc.UpdateEntry(ledger, unqNamesObj, false)
            )
          else
           ledgerService.updateEntry(unqNamesObj, ledger).then(
             (res) -> lc.updateEntrySuccess(res, ledger)
             (res) -> lc.updateEntryFailure(res, ledger)
           )
        else
          lc.doingEntry = false
          response = {}
          response.data = {}
          response.data.message = "There must be at least a transaction to make an entry."
          response.data.status = "Error"
          lc.addEntryFailure(response,[])
    else
      toastr.error("Select voucher type.")


  lc.checkTaxCondition = (ledger) ->
    transactions = []
    _.each ledger.transactions, (txn) ->
      if ledger.isInclusiveTax && !txn.isTax
        transactions.push(txn)
    if ledger.isInclusiveTax
      ledger.transactions = transactions

  lc.checkPrincipleModifications = (ledger, uTxnList) ->
    withoutTaxesLedgerTxn = lc.getPrincipleTxnOnly(ledger.transactions)
    withoutTaxesUtxnList = lc.getPrincipleTxnOnly(uTxnList)
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

  lc.checkManualTaxTransaction = (txnList, uTxnList) ->
    #console.log txnList.length, uTxnList.length
    _.each txnList, (txn) ->
      txn.isManualTax = true
      _.each uTxnList, (uTxn) ->
        if txn.particular.uniqueName == uTxn.particular.uniqueName && txn.isTax
          txn.isManualTax = false
    return 

  lc.getPrincipleTxnOnly = (txnList) ->
    transactions = []
    _.each txnList, (txn) ->
      if txn.isTax == undefined || !txn.isTax
        transactions.push(txn)
    transactions

  lc.addTaxesToLedger = (ledger) ->
    ledger.taxes = []
    _.each(lc.taxList, (tax) ->
      if tax.isChecked == true
        ledger.taxes.push(tax.uniqueName)
    )

  lc.updateEntryTaxes = (txnList) ->
    transactions = []
    if txnList.length > 1
      _.each txnList, (txn, idx) ->
        _.each lc.taxList, (tax) ->
          if txn.particular.uniqueName == tax.account.uniqueName && !tax.isChecked
            if !txn.isManualTax
              txn.toRemove = true 
              #transactions.push(txn)
              #txnList.splice(idx, 1)
    txnList = _.filter(txnList, (txn)->
      return txn.toRemove == undefined || txn.toRemove == false
    )
    txnList

  lc.isTransactionContainsTax = (ledger) ->
    if ledger.taxes != undefined && ledger.taxes.length > 0
      _.each(lc.taxList, (tax) ->
        tax.isChecked = false
        _.each(ledger.taxes, (taxe) ->
          if taxe == tax.uniqueName
            tax.isChecked = true
        )
      )
    else
      _.each(lc.taxList, (tax) ->
        #tax.isChecked = false
        _.each(ledger.transactions, (txn) ->
          if txn.particular.uniqueName == tax.account.uniqueName
            tax.isChecked = true
        )
      )

  lc.UpdateEntry = (ledger, unqNamesObj,removeTax) ->
    if removeTax == true
      lc.txnAfterRmovingTax = []
      lc.removeTaxTxnOnPrincipleTxnModified(ledger.transactions)
      ledger.transactions = lc.txnAfterRmovingTax
    if ledger.transactions.length > 0
      ledgerService.updateEntry(unqNamesObj, ledger).then(
        (res) -> lc.updateEntrySuccess(res, ledger)
        (res) -> lc.updateEntryFailure(res, ledger)
      )

  lc.matchTaxTransactions = (txnList, taxList) ->
    _.each txnList, (txn) ->
      _.each taxList, (tax) ->
        if txn.particular.uniqueName == tax.account.uniqueName
          txn.isTax = true

  lc.removeTaxTxnOnPrincipleTxnModified = (txnList) ->
    _.each txnList, (txn) ->
      if !txn.isTax
        lc.txnAfterRmovingTax.push(txn)

  lc.resetBlankLedger = () ->
    lc.newDebitTxn = {
      date: $filter('date')(new Date(), "dd-MM-yyyy")
      particular: {
        name:''
        uniqueName:''
      }
      amount : 0
      type: 'DEBIT'
    }
    lc.newCreditTxn = {
      date: $filter('date')(new Date(), "dd-MM-yyyy")
      particular: {
        name:''
        uniqueName:''
      }
      amount : 0
      type: 'CREDIT'
    }
    lc.blankLedger = {
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
        lc.newDebitTxn
        lc.newCreditTxn
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

  lc.addEntrySuccess = (res, ledger) ->
    lc.doingEntry = false
    ledger.failed = false
    toastr.success("Entry created successfully", "Success")
    #addThisLedger = {}
    #_.extend(addThisLedger,lc.selectedLedger)
    #lc.ledgerData.ledgers.push(res.body)
    #lc.getLedgerData(false)
    lc.resetBlankLedger()
    lc.selectedLedger = lc.blankLedger
    _.each(lc.taxList, (tax) ->
      tax.isChecked = false
    )
    lc.selectedTxn.isOpen = false
    if lc.mergeTransaction
      $timeout ( ->
        lc.mergeBankTransactions(lc.mergeTransaction)
      ), 2000
    lc.updateLedgerData('new',res.body[0])
    #lc.addToIdb([res.body], lc.accountUnq)
    #lc.pushNewEntryToLedger(res.body)
    if ledger.isBankTransaction
      lc.updateBankLedger(ledger)
    # $timeout ( ->
    #   lc.pageLoader = false
    #   lc.showLoader = false
    # ), 1000

  lc.addEntryFailure = (res, rejectedTransactions, ledger) ->
    lc.doingEntry = false
    ledger.failed = true
    toastr.error(res.data.message, res.data.status)
    if rejectedTransactions.length > 0
      _.each(rejectedTransactions, (rTransaction) ->
        lc.selectedLedger.transactions.push(rTransaction)
      )
    # $timeout ( ->
    #   lc.pageLoader = false
    #   lc.showLoader = false
    # ), 1000

  lc.updateBankLedger = (ledger) ->
    _.each lc.eLedgerData, (eledger, idx) ->
      if ledger.transactionId == eledger.transactionId
        lc.eLedgerData.splice(idx, 1)
    lc.getLedgerData()

  # lc.pushNewEntryToLedger = (newLedgers) ->
  #   console.log newLedgers

    # _.each newLedgers, (ledger) ->
    #   lc.calculateEntryTotal(ledger)
    #   lc.ledgerData.ledgers.push(ledger)

  lc.resetLedger = () ->
    lc.resetBlankLedger()
    lc.selectedLedger = lc.blankLedger
    _.each(lc.taxList, (tx) ->
      tx.isChecked = false
    )

  lc.updateEntrySuccess = (res, ledger) ->
    lc.doingEntry = false
    ledger.failed = false
    toastr.success("Entry updated successfully.", "Success")
    #addThisLedger = {}
    #_.extend(addThisLedger,lc.blankLedger)
#    lc.ledgerData.ledgers.push(addThisLedger)
    #lc.getLedgerData(false)
    #_.extend(ledger, res.body)
    lc.updateEntryOnUI(res.body)
    lc.resetBlankLedger()
    lc.selectedLedger = lc.blankLedger
    lc.selectedTxn.isOpen = false
    if lc.mergeTransaction
      lc.mergeBankTransactions(lc.mergeTransaction)
    #lc.dLedgerLimit = lc.dLedgerLimitBeforeUpdate
    #lc.openClosePopOver(res.body.transactions[0], res.body)
    lc.updateLedgerData('update',res.body)
    $timeout ( ->
      ledger.total = lc.updatedLedgerTotal
      #lc.countTotalTransactions()
      # lc.pageLoader = false
      # lc.showLoader = false
    ), 2000
    
  lc.updateEntryFailure = (res, ledger) ->
    lc.doingEntry = false
    ledger.failed = true
    toastr.error(res.data.message, res.data.status)
    # $timeout ( ->
    #   lc.pageLoader = false
    #   lc.showLoader = false
    # ), 1000
    
  lc.createLedger = (ledger, type) ->
    txns = []
    tLdr = {}
    tLdr = angular.copy(ledger, tLdr)
    if tLdr.transactions.length
      _.each tLdr.transactions, (txn) ->
        if txn.type == type
          txns.push(txn)
      tLdr.transactions = txns
    tLdr

  lc.updateEntryOnUI = (ledger) ->
    if ledger.transactions.length
      dLedger = lc.createLedger(ledger, 'DEBIT')
      cLedger = lc.createLedger(ledger, 'CREDIT')
      lc.cLedgerContainer.ledgerData[ledger.uniqueName] = _.extend(lc.cLedgerContainer.ledgerData[ledger.uniqueName], cLedger)
      lc.dLedgerContainer.ledgerData[ledger.uniqueName] = _.extend(lc.dLedgerContainer.ledgerData[ledger.uniqueName], dLedger)

  lc.closePopOverSingleLedger = (ledger) ->
    _.each ledger.transactions, (txn) ->
      txn.isOpen = false

  lc.deleteEntryConfirm = (ledger) ->
    modalService.openConfirmModal(
      title: 'Delete'
      body: 'Are you sure you want to delete this entry?',
      ok: 'Yes',
      cancel: 'No'
    ).then(
      (res) -> 
        lc.deleteEntry(ledger)
      (res) -> 
        $dismiss()
    )

  lc.deleteEntry = (ledger) ->
    # lc.pageLoader = true
    # lc.showLoader = true
    lc.lastSelectedLedger = ledger
    if (ledger.uniqueName == undefined || _.isEmpty(ledger.uniqueName)) && (ledger.isBankTransaction)
      return
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: lc.accountUnq
      entUname: ledger.uniqueName
    }
    if unqNamesObj.acntUname != '' || unqNamesObj.acntUname != undefined
      ledgerService.deleteEntry(unqNamesObj).then((res) ->
        lc.deleteEntrySuccess(ledger, res)
      , lc.deleteEntryFailure)

  lc.deleteEntrySuccess = (item, res) ->
    toastr.success("Entry deleted successfully","Success")
    lc.removeDeletedLedger(item)
    lc.resetBlankLedger()
    lc.selectedLedger = lc.blankLedger
    #lc.getLedgerData(false)
    if lc.mergeTransaction
      $timeout ( ->
        lc.mergeBankTransactions(lc.mergeTransaction)
      ), 2000
#    lc.calculateLedger(lc.ledgerData, "deleted")
    lc.updateLedgerData('delete')

  
  lc.deleteEntryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  lc.removeDeletedLedger = (item) ->
    if lc.dLedgerContainer.ledgerData[item.uniqueName]
      lc.dLedgerContainer.remove(item)
    if lc.cLedgerContainer.ledgerData[item.uniqueName]
      lc.cLedgerContainer.remove(item)
    # index = 0
    # _.each lc.ledgerData.ledgers, (led, idx ) ->
    #   if led.uniqueName == item.uniqueName
    #     index = idx
    # lc.ledgerData.ledgers.splice(index, 1)

  # select multiple transactions, from same or different entries
  lc.allSelected = []  
  lc.selectMultiple = (ledger, txn, index) ->
    cTxn = {}
    if txn.isSelected == true
      cTxn.unq = ledger.uniqueName
      cTxn.index = index
      cTxn.txn = txn 
      lc.allSelected.push(cTxn)

  lc.deleteMultipleTransactions = () ->
    if lc.allSelected.length > 0
      _.each lc.ledgerData.ledgers, (ledger) ->
        _.each lc.allSelected, (t) ->
          if ledger.uniqueName = t.unq
            ledger.transactions.splice(t.index, 1)
    lc.allSelected = []

  lc.redirectToState = (state) ->
    $state.go(state)


  lc.b64toBlob = (b64Data, contentType, sliceSize) ->
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


  lc.downloadInvoice = (invoiceNumber, e) ->
    e.stopPropagation()
    obj =
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: lc.accountUnq
    data=
      invoiceNumber: [invoiceNumber]
      template: ''
    accountService.downloadInvoice(obj, data).then((res) ->
      lc.downloadInvSuccess(res, invoiceNumber)
    , lc.multiActionWithInvFailure)

  lc.downloadInvSuccess = (res, invoiceNumber)->
    data = lc.b64toBlob(res.body, "application/pdf", 512)
    blobUrl = URL.createObjectURL(data)
    lc.dlinv = blobUrl
    FileSaver.saveAs(data, lc.accountToShow.name+ '-' + invoiceNumber+".pdf")

  # common failure message
  lc.multiActionWithInvFailure=(res)->
    toastr.error(res.data.message, res.data.status)

  lc.triggerPanelFocus = (e) ->
    if e.keyCode == 13
      $('#saveUpdate').focus()
      e.stopPropagation()
      return false

  lc.gwaList = {
    page: 1
    count: 5000
    totalPages: 0
    currentPage : 1
    limit: 5
  }

  lc.getFlattenGrpWithAccList = (compUname) ->
#    console.log("working  : ",lc.working)
    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: lc.gwaList.page
      count: lc.gwaList.count
    }
    groupService.getFlattenGroupAccList(reqParam).then(lc.getFlattenGrpWithAccListSuccess, lc.getFlattenGrpWithAccListFailure)

  lc.getGroupsWithDetail = () ->
    if $rootScope.allowed == true
      groupService.getGroupsWithoutAccountsInDetail($rootScope.selectedCompany.uniqueName).then(
        (success)->
          lc.detGrpList = success.body
        (failure) ->
          toastr.error('Failed to get Detailed Groups List')
      )
  lc.getGroupsWithDetail()

  lc.markFixedGrps = (flatGrpList) ->
    temp = []
    _.each lc.detGrpList, (detGrp) ->
      _.each flatGrpList, (fGrp) ->
        if detGrp.uniqueName == fGrp.groupUniqueName && detGrp.isFixed
          fGrp.isFixed = true
    _.each flatGrpList, (grp) ->
      if !grp.isFixed
        temp.push(grp)
    temp

  lc.getFlattenGrpWithAccListSuccess = (res) ->
    lc.gwaList.totalPages = res.body.totalPages
    lc.flatGrpList = lc.markFixedGrps(res.body.results)
    #lc.removeEmptyGroups(res.body.results)
    #lc.flatAccntWGroupsList = lc.grpWithoutEmptyAccounts
    #console.log(lc.flatAccntWGroupsList)
    #lc.showAccountList = true
    lc.gwaList.limit = 5
    #$rootScope.companyLoaded = true
    #lc.working = false

  lc.getFlattenGrpWithAccListFailure = (res) ->
    toastr.error(res.data.message)
    #lc.working = false

  lc.addNewAccount = () ->
    lc.newAccountModel.group = ''
    lc.newAccountModel.account = ''
    lc.newAccountModel.accUnqName = ''
    lc.selectedTxn.isOpen = false
    lc.getFlattenGrpWithAccList($rootScope.selectedCompany.uniqueName)
    lc.AccmodalInstance = $uibModal.open(
      templateUrl: $rootScope.prefixThis+'/public/webapp/Ledger/createAccountQuick.html'
      size: "sm"
      backdrop: 'static'
      scope: $scope
    )
    #modalInstance.result.then(lc.addNewAccountCloseSuccess, lc.addNewAccountCloseFailure)

  lc.addNewAccountConfirm = () ->
    newAccount = {
      email:""
      mobileNo:""
      name:lc.newAccountModel.account
      openingBalanceDate: $filter('date')(lc.today, "dd-MM-yyyy")
      uniqueName:lc.newAccountModel.accUnqName
    }
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: lc.newAccountModel.group.groupUniqueName
      acntUname: lc.newAccountModel.accUnqName
    }
    if lc.newAccountModel.group.groupUniqueName == '' || lc.newAccountModel.group.groupUniqueName == undefined
      toastr.error('Please select a group.')
    else
      accountService.createAc(unqNamesObj, newAccount).then(lc.addNewAccountConfirmSuccess, lc.addNewAccountConfirmFailure) 

  lc.addNewAccountConfirmSuccess = (res) ->
    toastr.success('Account created successfully')
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    lc.AccmodalInstance.close()

  lc.addNewAccountConfirmFailure = (res) ->
    toastr.error(res.data.message)

  lc.genearateUniqueName = (unqName) ->
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
      lc.newAccountModel.accUnqName = unq
    else
      lc.newAccountModel.accUnqName = ''

  lc.genUnq = (unqName) ->
    $timeout ( ->
      lc.genearateUniqueName(unqName)
    )

  lc.validateUniqueName = (unq) ->
    unq = unq.replace(/ |,|\//g,'')

  lc.onValueChange = (value, txn) ->
    if txn.particular.stock != null &&  txn.particular.stock != undefined || lc.accountToShow.stock != null || (txn.inventory && txn.inventory.stock)
      switch value
        when 'qty'
          if lc.selectedTxn.rate > 0 && lc.selectedTxn.inventory && lc.selectedTxn.inventory.quantity
            lc.selectedTxn.amount = lc.selectedTxn.rate * lc.selectedTxn.inventory.quantity
        when 'amount'
          if lc.selectedTxn.inventory && lc.selectedTxn.inventory.quantity
            lc.selectedTxn.rate = lc.selectedTxn.amount/lc.selectedTxn.inventory.quantity
        when 'rate'
          if lc.selectedTxn.inventory && lc.selectedTxn.inventory.quantity
            lc.selectedTxn.amount = lc.selectedTxn.rate * lc.selectedTxn.inventory.quantity

  lc.checkStockAccount = (item, txn) ->
    if(item.stock == null && lc.accountToShow.stock == null)
      txn.inventory = null
    else if lc.accountToShow.stock == null && item.stock != null
      txn.rate = item.stock.rate
    else if item.stock != null && lc.accountToShow.stock == null
      txn.rate = lc.accountToShow.stock.rate

  lc.getEntrySettings = () ->
    @success = (res) ->
      lc.entrySettings = res.body
    @failure = (res) ->
      toastr.error(res.data.message)

    reqParam = {
      compUname: $rootScope.selectedCompany.uniqueName
    }

    ledgerService.getSettings(reqParam).then(@success, @failure)

  lc.getEntrySettings()

  lc.updateEntrySettings = (status) ->
    @success = (res) ->
      lc.entrySettings = res.body
      if res.body.status
        toastr.success('Default Date Set for Ledgers')
      else
        toastr.success('Default Date unset for Ledgers')
    @failure = (res) ->
      toastr.error(res.data.message)

    data = lc.entrySettings
    reqParam = {}
    reqParam.compUname = $rootScope.selectedCompany.uniqueName
    ledgerService.updateEntrySettings(reqParam, data).then(@success, @failure)

  lc.clearTaxSelection = (txn, ledger) ->
    if ledger.uniqueName != lc.prevLedger.uniqueName
      _.each lc.taxList, (tax) ->
        tax.isChecked = false


  lc.prevTxn = null
  lc.prevLedger = {}
  lc.slctxn = (ledger, txn, e) ->
    if !txn.isOpen
      txn.isOpen = true
    if lc.prevTxn && lc.prevTxn != txn
      lc.prevTxn.isOpen = false
    if lc.accountToShow.stock != null && lc.accountToShow.stock != undefined && txn.inventory == undefined
      txn.inventory = {}
      txn.rate = lc.accountToShow.stock.rate
    if txn.inventory && txn.inventory.quantity
      txn.rate = txn.amount/txn.inventory.quantity
    if txn.particular.stock
      txn.rate = txn.particular.stock.rate
    lc.clearTaxSelection(txn, ledger)
    if !txn.isTax && ledger.uniqueName != lc.prevLedger.uniqueName
      lc.showTaxTxns(ledger)
    lc.prevTxn = txn
    lc.selectedLedger = ledger
    lc.selectedTxn = txn
    lc.matchInventory(txn)
    lc.ledgerBeforeEdit = {}
    lc.checkCompEntry(ledger)
    angular.copy(ledger,lc.ledgerBeforeEdit)
    lc.isTransactionContainsTax(ledger)
    lc.log lc.prevLedger.uniqueName, ledger.uniqueName
    if lc.prevLedger.uniqueName != ledger.uniqueName
      if lc.cLedgerContainer.ledgerData[lc.prevLedger.uniqueName] && lc.cLedgerContainer.ledgerData[lc.prevLedger.uniqueName].isExtra
        lc.cLedgerContainer.remove(lc.prevLedger)
        lc.log "RemovedCR: ", lc.prevLedger.uniqueName
      if lc.dLedgerContainer.ledgerData[lc.prevLedger.uniqueName] && lc.dLedgerContainer.ledgerData[lc.prevLedger.uniqueName].isExtra
        lc.dLedgerContainer.remove(lc.prevLedger)
        lc.log "RemovedDR: ", lc.prevLedger.uniqueName
      lc.prevLedger = ledger

    if e
      e.stopPropagation()

  lc.dBlankTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: {
      name:''
      uniqueName:''
    }
    amount : 0
    type: 'DEBIT'
  }

  lc.cBlankTxn = {
    date: $filter('date')(new Date(), "dd-MM-yyyy")
    particular: {
      name:''
      uniqueName:''
    }
    amount : 0
    type: 'CREDIT'
  }


  lc.blankLedger = new blankLedgerModel()
  lc.blankLedger.entryDate = $filter('date')(lc.today, 'dd-MM-yyyy')
  lc.blankLedger.transactions.push(lc.dBlankTxn)
  lc.blankLedger.transactions.push(lc.cBlankTxn)

  $rootScope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE' 
      lc.loadDefaultAccount()
    # else if changeData.type == 'SELECT'
    #   console.log 'load same account'
    #$state.reload()
  #   # when company is changed, redirect to manage company page
  #   if changeData.type == 'CHANGE'
  #     # lc.redirectToState('company.content.manage')
  #     $state.go('company.content.ledgerContent', {unqName: ""})
  #     lc.showLoader = true

  $scope.$watch 'popover.draggable', (newVal, oldVal) ->
    if newVal != oldVal
      $('.popover').remove()


  $(document).on 'click', (e) ->
    if lc.prevTxn
      lc.prevTxn.isOpen = false
    return 0

  # $rootScope.$on('account-selected', ()->
  #   lc.getAccountDetail(lc.accountUnq)
  #   #lc.isSelectedAccount()
  #   #$rootScope.$emit('catchBreadcumbs', lc.accountToShow.name)
  # )

  lc.commonOnUpgrade = (db) ->
    if db.objectStoreNames.contains('ledgers')
      db.deleteObjectStore("ledgers")
    if !db.objectStoreNames.contains('ledgers')
      search = db.createObjectStore('ledgers', keyPath: 'uniqueId')
      search.createIndex 'accountUniqueName+index', [
        'accountUniqueName'
        'index'
      ], unique: true
      search.createIndex 'accountUniqueName+timestamp', [
        'accountUniqueName'
        'timestamp'
      ], unique: false
      search.createIndex 'accountUniqueName', [
        'accountUniqueName'
      ], unique: false
    if db.objectStoreNames.contains('drTransactions')
      db.deleteObjectStore("drTransactions")
    if !db.objectStoreNames.contains('drTransactions')
      abc = db.createObjectStore('drTransactions', keyPath: 'uniqueId')
      abc.createIndex 'uniqueId+timestamp', [
        'uniqueId'
        'timestamp'
      ], unique: false
      abc.createIndex 'company+accountUniqueName+index', [
        'company'
        'accountUniqueName'
        'index'
      ], unique: false
    if db.objectStoreNames.contains('crTransactions')
      db.deleteObjectStore("crTransactions")
    if !db.objectStoreNames.contains('crTransactions')
      abd = db.createObjectStore('crTransactions', keyPath: 'uniqueId')
      abd.createIndex 'uniqueId+timestamp', [
        'uniqueId'
        'timestamp'
      ], unique: false
      abd.createIndex 'company+accountUniqueName+index', [
        'company'
        'accountUniqueName'
        'index'
      ], unique: false
    return

  lc.ledgerContainer = () -> 
    this.ledgerData = {}
    this.trCount = 0
    this.firstLedger = null
    this.lastLedger = null
    this.lowerBoundReached = false
    this.upperBoundReached = false
    this.scrollDisable = false
    return this

  lc.ledgerContainer.prototype.add = (o) -> 
    if ! this.ledgerData.hasOwnProperty(o.uniqueName)
      this.trCount += o.transactions.length
      this.ledgerData[o.uniqueName] = o
    return

  lc.ledgerContainer.prototype.add = (o, count) -> 
    if ! this.ledgerData.hasOwnProperty(o.uniqueName)
      this.trCount += o.transactions.length
      this.ledgerData[o.uniqueName] = o
      while this.trCount > this.maxTransactions(count)
        this.removeTop()
        this.lowerBoundReached = false
      tempTop = this.top()
      this.firstLedger = tempTop
      # this.lastLedger = this.ledgerData[o.uniqueName]
      tempBottom = this.bottom()
      this.lastLedger = tempBottom
    return

  lc.ledgerContainer.prototype.addAtTop = (o, count) -> 
    if ! this.ledgerData.hasOwnProperty(o.uniqueName)
      this.trCount += o.transactions.length
      this.ledgerData[o.uniqueName] = o
      while this.trCount > this.maxTransactions(count)
        this.removeBottom()
        this.upperBoundReached = false
      tempBottom = this.bottom()
      this.lastLedger = tempBottom
      # this.firstLedger = this.ledgerData[o.uniqueName]
      tempTop = this.top()
      this.firstLedger = tempTop
    return

  lc.ledgerContainer.prototype.top = () -> 
    least = Number.MAX_SAFE_INTEGER
    topKey = null
    ref = Object.keys(this.ledgerData)
    for key in ref
      if !this.ledgerData[key].isExtra && this.ledgerData[key].index < least
        least = this.ledgerData[key].index
        topKey = key
    return this.ledgerData[topKey]

  lc.ledgerContainer.prototype.bottom = () -> 
    last = Number.MIN_SAFE_INTEGER
    bottomKey = null
    ref = Object.keys(this.ledgerData)
    for key in ref
      if !this.ledgerData[key].isExtra && this.ledgerData[key].index > last
        last = this.ledgerData[key].index
        bottomKey = key
    return this.ledgerData[bottomKey]

  lc.ledgerContainer.prototype.remove = (o) ->
    if (typeof(o) == 'object') 
      this.trCount -= o.transactions.length
      delete this.ledgerData[o.uniqueName]
    
    if (typeof(o) == 'string') 
      this.trCount -= this.ledgerData[o].transactions.length
      delete this.ledgerData[o]
    
    return

  lc.ledgerContainer.prototype.removeTop = () -> 
    this.remove(this.top())
    return

  lc.ledgerContainer.prototype.removeBottom = () -> 
    this.remove(this.bottom())
    return

  lc.ledgerContainer.prototype.getFirstIndex = () ->
    return if this.firstLedger != null then this.firstLedger.index else Number.MAX_SAFE_INTEGER
  lc.ledgerContainer.prototype.getLastIndex = () ->
    return if this.lastLedger != null then this.lastLedger.index else Number.MIN_SAFE_INTEGER
  lc.ledgerContainer.prototype.maxTransactions = (count) ->
    return count + 30 #count + count/2 #replace for dynamic calculations

  lc.generateKeyRange = (accUniqueName, ledgerContainer, sortDir, scrollDir) ->
    sortDir = if sortDir == null then lc.sortDirection.asc else sortDir
    if sortDir == lc.sortDirection.asc
      if ( scrollDir == 'prev' )
        keyRange = IDBKeyRange.bound(
          [
            $rootScope.selectedCompany.uniqueName
            accUniqueName
            Number.MIN_SAFE_INTEGER
          ],
          [
            $rootScope.selectedCompany.uniqueName
            accUniqueName
            ledgerContainer.getFirstIndex()
          ])
        fetchDirection = 'prev'
      if ( scrollDir == 'next' || scrollDir == null) 
        keyRange = IDBKeyRange.bound(
          [
            $rootScope.selectedCompany.uniqueName
            accUniqueName
            ledgerContainer.getLastIndex()
          ],
          [
            $rootScope.selectedCompany.uniqueName
            accUniqueName
            Number.MAX_SAFE_INTEGER
          ])
        fetchDirection = 'next'

    else if sortDir == lc.sortDirection.desc
      if ( scrollDir == 'prev' )
        keyRange = IDBKeyRange.bound(
          [
            $rootScope.selectedCompany.uniqueName
            accUniqueName
            ledgerContainer.getLastIndex()
          ],
          [
            $rootScope.selectedCompany.uniqueName
            accUniqueName
            Number.MAX_SAFE_INTEGER
          ])
        fetchDirection = 'next'
      if ( scrollDir == 'next' || scrollDir == null ) 
        keyRange = IDBKeyRange.bound(
          [
            $rootScope.selectedCompany.uniqueName
            accUniqueName
            Number.MIN_SAFE_INTEGER
          ],
          [
            $rootScope.selectedCompany.uniqueName
            accUniqueName
            ledgerContainer.getFirstIndex()
          ])
        fetchDirection = 'prev'
    return { 'keyRange' : keyRange, 'scrollDir' : fetchDirection }

  lc.crMatch = null
  lc.drMatch = null
  lc.getMatchingTxnFromIdb = (ledger, type) ->
    lc.dbConfig.success = (e) ->
      db = e.target.result
      if type == 'CR'
        OS = db.transaction([ 'crTransactions' ], 'readonly').objectStore('crTransactions')
      else if type == 'DR'
        OS = db.transaction([ 'drTransactions' ], 'readonly').objectStore('drTransactions')
      # Search = OS.index('company+accountUniqueName+index', true)
      # key = $rootScope.selectedCompany.uniqueName+ ' ' +lc.accountUnq + ' ' + ledger.index
      searchReq = OS.get(ledger.uniqueId)

      searchReq.onsuccess = (e) ->
        if e.target.result
          if type == 'CR'
            crObj = e.target.result
            crObj.isExtra = true
            lc.cLedgerContainer.add(crObj)
            lc.crMatch = lc.scrollMatchObject(crObj, 'cr')
          else if type == 'DR'
            drObj = e.target.result
            drObj.isExtra = true
            lc.dLedgerContainer.add(drObj)
            lc.drMatch = lc.scrollMatchObject(drObj, 'dr')

    lc.dbConfig.onerror = (e) ->
      e

     dbInstance = idbService.openDb(lc.dbConfig)


  lc.getMatchingTxn = (ledger, type) ->
    if type == 'CR'
      if lc.cLedgerContainer.ledgerData[ledger.uniqueName]
        lc.crMatch = lc.scrollMatchObject(lc.cLedgerContainer.ledgerData[ledger.uniqueName], 'cr')
      else
        lc.getMatchingTxnFromIdb(ledger, type)
      # if !lc.crMatch
      #   lc.getMatchingTxnFromIdb(ledger, type)
    else if type == 'DR'
      if lc.dLedgerContainer.ledgerData[ledger.uniqueName]
        lc.drMatch = lc.scrollMatchObject(lc.dLedgerContainer.ledgerData[ledger.uniqueName], 'dr')
      else
        lc.getMatchingTxnFromIdb(ledger, type)
      # if !lc.drMatch
      #   lc.getMatchingTxnFromIdb(ledger, type)

  lc.scrollMatchObject = (to, type) ->
    first = null
    if type == 'dr'
      if lc.sortOrder.debit == lc.sortDirection.desc
        first = lc.dLedgerContainer.bottom()
      else
        first = lc.dLedgerContainer.top()
    else
      if lc.sortOrder.credit == lc.sortDirection.desc
        first = lc.cLedgerContainer.bottom()
      else
        first = lc.cLedgerContainer.top()
    return {"first": first, "to": to}


  lc.log = () -> 
    if lc.showLogs
      console.log arguments

  lc.onBankTxnSelect = ($item, $model, $label, $event, txn) ->
    $timeout ( ->
      txn.isOpen = true
    ), 200

  lc.showTaxTxns = (ledger) ->
    if ledger.transactions.length > 1
      _.each ledger.transactions, (txn) ->
        if txn.isTax
          txn.hide = !txn.hide
    if lc.prevLedger.transactions && lc.prevLedger.uniqueName != ledger.uniqueName
      lc.showTaxTxns(lc.prevLedger)
    
  return lc
giddh.webApp.controller 'newLedgerController', newLedgerController