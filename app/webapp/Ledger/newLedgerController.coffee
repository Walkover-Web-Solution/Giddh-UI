
newLedgerController = ($scope, $rootScope, $window,localStorageService, toastr, modalService, ledgerService,FileSaver , $filter, DAServices, $stateParams, $timeout, $location, $document, permissionService, accountService, Upload, groupService, $uibModal, companyServices, $state,idbService) ->
  lc = this
  if _.isUndefined($rootScope.selectedCompany)
    $rootScope.selectedCompany = localStorageService.get('_selectedCompany')
  lc.pageLoader = false
  #date time picker code starts here
  lc.today = new Date()
  d = moment(new Date()).subtract(7, 'month')
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

  lc.sortDirection = Object.freeze({'asc' : 0, 'desc' : 1})
  lc.sortDirectionInvert = (dir) ->
    if lc.sortDirection.asc == dir 
      return lc.sortDirection.desc
    else if lc.sortDirection.desc == dir
      return lc.sortDirection.asc

  lc.scrollDirection = Object.freeze({'next' : 0, 'prev' : 1})

  lc.sortOrder = {
    debit : lc.sortDirection.asc
    credit: lc.sortDirection.asc
  }
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

  lc.totalLedgers = 0
  lc.savedLedgers = 0
  lc.isLedgerSeeded = false
  lc.pageCount = 50
  lc.page = 1
  lc.dbConfig = 
    name: 'giddh_db'
    storeName: 'ledgers'
    version: 12
    success: (e) ->
    failure: (e) ->
    upgrade: (e) ->

  lc.parseLedgerDate = (date) ->
    date = date.split('-')
    date = new Date(date[2], date[1], date[0]).getTime()
    date

  lc.addToIdb = (ledgers, accountname) ->
    lc.savedLedgers = 0
    lc.isLedgerSeeded = false
    lc.dbConfig.success = (e) ->
      db = e.target.result
      search = db.transaction([ 'ledgers' ], 'readwrite').objectStore('ledgers')
      account = search.index('account')

      lc.prevLedgerCount = account.count()
      keyRange = IDBKeyRange.bound(accountname + ' ', accountname + ' ' + '\xFF', true, true)

      delReq = search.delete(keyRange)

      delReq.onsuccess = (e) ->

        drObjs = [];
        crObjs = [];
        crSavedLedgersCount = 0;
        drSavedLedgersCount = 0;
        ledgers.forEach (ledger, index) ->

          ledger.accUniqueName = accountname + " " + ledger.uniqueName
          ledger.accountUniqueName = accountname
          ledger.index = index
          date = lc.parseLedgerDate(ledger.entryDate)
          ledger.timestamp = Math.floor(date / 1000)

          addReq = search.put(ledger)

          addReq.onsuccess = (e) ->
            lc.progressBar.value += 1
            lc.savedLedgers += 1

          addReq.onerror = (e) ->
            return

        ledgers.forEach (ledger, index) ->
          drTrans = []
          crTrans = []
          ledger.transactions.forEach (tr, index) -> 
            if ( tr.type == 'CREDIT')
              crTrans.push tr
            else
              drTrans.push tr
          crObj = {};
          crObj.uniqueId = ledger.accUniqueName
          crObj = _.extend(crObj, ledger)
          #crObj.uniqueName = ledger.uniqueName
          # crObj.entryDate = ledger.entryDate
          crObj.accLedgerUniqueName = ledger.accUniqueName
          crObj.timestamp = ledger.timestamp
          crObj.lIndex = ledger.index
          crObj.accountUniqueName = accountname
          crObj.company = $rootScope.selectedCompany.uniqueName
          crObj.transactions = crTrans
          crObjs.push(crObj)

          drObj = {};
          drObj.uniqueId = ledger.accUniqueName
          drObj = _.extend(drObj, ledger)
          # drObj.uniqueName = ledger.uniqueName
          # drObj.entryDate = ledger.entryDate
          drObj.accLedgerUniqueName = ledger.accUniqueName
          drObj.timestamp = ledger.timestamp
          drObj.lIndex = ledger.index
          drObj.accountUniqueName = accountname
          drObj.company = $rootScope.selectedCompany.uniqueName
          drObj.transactions = drTrans
          drObjs.push(drObj)


        drOS = db.transaction([ 'drTransactions' ], 'readwrite').objectStore('drTransactions')
        drOS.clear()
        drObjs.forEach (drOb) -> 
          addDrReq = drOS.put(drOb)
          addDrReq.onsuccess = (e) ->
            drSavedLedgersCount += 1
            # lc.progressBar.value += 1
            if drSavedLedgersCount == lc.savedLedgers && crSavedLedgersCount == lc.savedLedgers
              lc.isLedgerSeeded = true
            # console.log 'dr', e.target.result, drSavedLedgersCount, lc.savedLedgers, crSavedLedgersCount

          addDrReq.onerror = (e) ->
            console.log e.target.error
            return
        crOS = db.transaction([ 'crTransactions' ], 'readwrite').objectStore('crTransactions')
        crOS.clear()
        crObjs.forEach (crOb) -> 
          addCrReq = crOS.put(crOb)
          addCrReq.onsuccess = (e) ->
            crSavedLedgersCount += 1
            # lc.progressBar.value += 1
            if drSavedLedgersCount == lc.savedLedgers && crSavedLedgersCount == lc.savedLedgers
              lc.isLedgerSeeded = true
            # console.log 'cr', e.target.result, drSavedLedgersCount, lc.savedLedgers, crSavedLedgersCount

          addCrReq.onerror = (e) ->
            console.log e.target.error
            return
      delReq.onerror = (e) ->
        console.log('failed', e.target.error)

      #search.clear()
      

    lc.dbConfig.failure = (e) ->
      toastr.error(e.target.error)
      return

    lc.dbConfig.upgrade = (e) ->
      db = e.target.result
      lc.commonOnUpgrade(db)
      return

    lc.dbConfig.onblocked = (e) ->
      toastr.error(e.target.error)
      
    dbInstance = idbService.openDb(lc.dbConfig)

  ###read ledgers ###
  lc.ledgersUpdated = false
  lc.readLedgers = (accountname, page, pos, type) ->
    lc.ledgersUpdated = false
    # lc.filtered = []
    # lc.tempLedgers = []
    # lc.filterPage = 1
    type = type || null
    lc.dbConfig.success = (e) ->
      db = e.target.result

      #DEBIT READ STARTS
      if type == 'dr' || type == null
        keyAndDir = lc.generateKeyRange(accountname, lc.sortOrder.debit, pos)

        drTrCount = 0
        drOS = db.transaction([ 'drTransactions' ], 'readonly').objectStore('drTransactions')
        drSearch = drOS.index('company+accountUniqueName+lIndex', true).openCursor(keyAndDir.keyRange, keyAndDir.scrollDir)

        drSearch.onsuccess = (e) ->
          cursor = e.target.result
          if cursor
            # lc.dLedgerData[cursor.value.uniqueName] = cursor.value
            if keyAndDir.scrollDir == 'next'
              lc.dLedgerContainer.add cursor.value, lc.pageCount
            else if keyAndDir.scrollDir = 'prev'
              lc.dLedgerContainer.addAtTop cursor.value, lc.pageCount

            drTrCount += cursor.value.transactions.length

            if drTrCount >= lc.pageCount
              return
            cursor.continue()

        drSearch.onerror = (e) -> 
          console.log 'error', e

      #CREDIT READ STARTS
      if type == 'cr' || type == null
        keyAndDir = lc.generateKeyRange(accountname, lc.sortOrder.debit, pos)

        crTrCount = 0
        pos = pos || 'next'
        crOS = db.transaction([ 'crTransactions' ], 'readonly').objectStore('crTransactions')
        crSearch = crOS.index('company+accountUniqueName+lIndex', true).openCursor(keyAndDir.keyRange, keyAndDir.scrollDir)

        crSearch.onsuccess = (e) ->
          cursor = e.target.result
          if cursor
            # lc.cLedgerData[cursor.value.uniqueName] = cursor.value
            if keyAndDir.scrollDir == 'next'
              lc.cLedgerContainer.add cursor.value, lc.pageCount
            else if keyAndDir.scrollDir = 'prev'
              lc.cLedgerContainer.addAtTop cursor.value, lc.pageCount

            crTrCount += cursor.value.transactions.length
            if crTrCount >= lc.pageCount
              return
            cursor.continue()

        crSearch.onerror = (e) -> 
          console.log 'error', e

      db.close()
      return

    lc.dbConfig.failure = (e) ->
      console.log e.target.error
      return

    lc.dbConfig.upgrade = (e) ->
      db = e.target.result
      lc.commonOnUpgrade(db)
      return

    idbService.openDb lc.dbConfig
    return

  lc.readLedgersWithQuery = (accountname, query, page, pos, type) ->
    type = type || null
    t0 = performance.now()
    console.log "readLedger with query Started: ", t0
    lc.dbConfig.success = (e) ->
      db = e.target.result
      filteredLedgers = []
      ledger = db.transaction([ 'ledgers' ], 'readwrite').objectStore('ledgers')
      ledgerSearch = ledger.index('entryIndex').openCursor()
      ledgerSearch.onsuccess = (e) ->
        # console.log('succ', e)
        cursor = e.target.result
        if cursor
          if lc.filterByQuery(cursor.value, query)
            filteredLedgers.push cursor.value.index
          cursor.continue()
        return

      ledgerSearch.onerror = (e) ->
        console.log 'error', e
        return

      #MAYANK
      #DEBIT READ STARTS
      if type == 'dr' || type == null
        keyAndDir = lc.generateKeyRange(accountname, lc.sortOrder.debit, pos)

        drTrCount = 0
        drOS = db.transaction([ 'drTransactions' ], 'readonly').objectStore('drTransactions')
        drSearch = drOS.index('company+accountUniqueName+lIndex', true).openCursor(keyAndDir.keyRange, keyAndDir.scrollDir)

        drSearch.onsuccess = (e) ->
          cursor = e.target.result
          if cursor
            # lc.dLedgerData[cursor.value.uniqueName] = cursor.value
            if filteredLedgers.indexOf(cursor.value.lIndex) > -1
              if pos == 'next'
                lc.dLedgerContainer.add cursor.value, lc.pageCount
              else if pos = 'prev'
                lc.dLedgerContainer.addAtTop cursor.value, lc.pageCount

              drTrCount += cursor.value.transactions.length

            if drTrCount >= lc.pageCount
              return
            cursor.continue()

        drSearch.onerror = (e) -> 
          console.log 'error', e

      #CREDIT READ STARTS
      if type == 'cr' || type == null
        keyAndDir = lc.generateKeyRange(accountname, lc.sortOrder.debit, pos)

        crTrCount = 0
        pos = pos || 'next'
        crOS = db.transaction([ 'crTransactions' ], 'readonly').objectStore('crTransactions')
        crSearch = crOS.index('company+accountUniqueName+lIndex', true).openCursor(keyAndDir.keyRange, keyAndDir.scrollDir)

        crSearch.onsuccess = (e) ->
          cursor = e.target.result
          if cursor
            # lc.cLedgerData[cursor.value.uniqueName] = cursor.value
            if filteredLedgers.indexOf(cursor.value.lIndex) > -1
              if pos == 'next'
                lc.cLedgerContainer.add cursor.value, lc.pageCount
              else if pos = 'prev'
                lc.cLedgerContainer.addAtTop cursor.value, lc.pageCount

              crTrCount += cursor.value.transactions.length

            if crTrCount >= lc.pageCount
              return
            cursor.continue()

        crSearch.onerror = (e) -> 
          console.log 'error', e

      #MAYANK
      t1 = performance.now()
      console.log  t1-t0
      db.close()
      return

    lc.dbConfig.failure = (e) ->
      console.log e.target.error
      return

    lc.dbConfig.upgrade = (e) ->
      db = e.target.result
      lc.commonOnUpgrade(db)
      return

    idbService.openDb lc.dbConfig
    return

  $scope.$watch('lc.isLedgerSeeded', (newVal, oldVal)->
    if( !oldVal && newVal)
      lc.readLedgers($rootScope.selectedAccount.uniqueName, 1, 'next')
    lc.isLedgerSeeded = false
  )

  # $scope.$watch('lc.savedLedgers', (newVal, oldVal)->
  #   if(newVal > 0 && newVal == lc.totalLedgers)
  #     lc.readLedgers($rootScope.selectedAccount.uniqueName, 1, 'next')
  #     lc.showLoader = false
  # )

  $scope.$watch('lc.isLedgerSeeded', (newVal, oldVal)->
   if( !oldVal && newVal)
     lc.readLedgers($rootScope.selectedAccount.uniqueName, 1, 'next')
   lc.isLedgerSeeded = false
   lc.showLoader = false
  )

  $scope.$watch('lc.ledgersUpdated', (newVal, oldVal)->
    # if(newVal)
    #   lc.ledgerData.ledgers = lc.ledgerData.ledgers.splice(0, (lc.ledgerData.ledgers.length/2)-1)
    #   _.each lc.tempLedgers, (ledger) ->
    #     lc.ledgerData.ledgers.push(ledger)
  )

  lc.onScrollDebit = (sTop, sHeight, pos) ->
    if !lc.query and pos == 'next'
      lc.page += 1
      #lc.ledgerData.ledgers = []
      lc.readLedgers $rootScope.selectedAccount.uniqueName, lc.page, pos, 'dr'
      $scope.$apply()
    else if !lc.query and pos == 'prev'
      lc.page += 1
      #lc.ledgerData.ledgers = []
      lc.readLedgers $rootScope.selectedAccount.uniqueName, lc.page, pos, 'dr'
      $scope.$apply()
    # else if !lc.query and pos == 'top' and lc.page > 1
    #   lc.page -= 1
    #   lc.readLedgers $rootScope.selectedAccount.uniqueName, lc.page, pos
    #Mayank\
    # if !lc.query and pos == 'next'

    # else if !lc.query and pos == 'prev'
    #mayank
    return

  lc.onScrollCredit = (sTop, sHeight, pos) ->
    if !lc.query and pos == 'next'
      lc.page += 1
      #lc.ledgerData.ledgers = []
      lc.readLedgers $rootScope.selectedAccount.uniqueName, lc.page, pos, 'cr'
      $scope.$apply()
    else if !lc.query and pos == 'prev' 
      lc.page += 1
      #lc.ledgerData.ledgers = []
      lc.readLedgers $rootScope.selectedAccount.uniqueName, lc.page, pos, 'cr'
      $scope.$apply()
    # else if !lc.query and pos == 'top' and lc.page > 1
    #   lc.page -= 1
    #   lc.readLedgers $rootScope.selectedAccount.uniqueName, lc.page, pos
    return

  lc.filterLedgers = (accountname, query, page) ->
    if query
      lc.dLedgerContainer = new lc.ledgerContainer()
      lc.cLedgerContainer = new lc.ledgerContainer()
      lc.readLedgersWithQuery accountname, query, lc.page || 1, 'next'
    else
      lc.dLedgerContainer = new lc.ledgerContainer()
      lc.cLedgerContainer = new lc.ledgerContainer()
      lc.readLedgers accountname, lc.page || 1, 'next'
    # lc.dbConfig.success = (e) ->
    #   db = e.target.result
    #   search = db.transaction([ 'ledgers' ], 'readwrite').objectStore('ledgers')

    #   keyRange = IDBKeyRange.bound(accountname + ' ', accountname + ' ' + '\xFF', true, true)

    #   requestSearchable = search.openCursor(keyRange)

    #   requestSearchable.onsuccess = (e) ->
    #     # console.log('succ', e)
    #     cursor = e.target.result
    #     if cursor
    #       if query and lc.filterByQuery(cursor.value, query)
    #         lc.ledgerData.ledgers.push cursor.value
    #       cursor.continue()
    #     # else
    #     #   lc.ledgerData.ledgers = lc.filtered
    #     $scope.$apply()
    #     return

    #   requestSearchable.onerror = (e) ->
    #     console.log 'error', e
    #     return

    #   db.close()
    return

    lc.dbConfig.failure = (e) ->
      console.log e.target.error, 'update failed'
      return

    lc.dbConfig.upgrade = (e) ->
      db = e.target.result
      if !db.objectStoreNames.contains(accountname)
        search = db.createObjectStore('ledgers', keyPath: 'accUniqueName')
        search.createIndex 'entryIndex', [
          'accountUniqueName'
          'index'
        ], unique: true
        search.createIndex 'dateIndex', [
          'accountUniqueName'
          'timestamp'
        ], unique: false
        search.createIndex 'account', [
          'accountUniqueName'
        ], unique: false
      return

    idbService.openDb lc.dbConfig
    return

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
      description:''
      entryDate:''
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
#    if ledger.uniqueName != ""
    lc.hasBlankTxn = false
    lc.checkForExistingblankTransaction(ledger, str)
    if !lc.hasBlankTxn
      if str == 'DEBIT'
        if ledger.uniqueName
          lc.dLedgerContainer.ledgerData[ledger.uniqueName].transactions.push(txn)
        else
          lc.blankLedger.transactions.push(txn)
      else if str == 'CREDIT'
        if ledger.uniqueName
          lc.cLedgerContainer.ledgerData[ledger.uniqueName].transactions.push(txn)
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
        _.each lc.dLedgerContainer.ledgerData[ledger.uniqueName].transactions, (txn) ->
          if txn.particular.uniqueName == '' && txn.amount == 0 && txn.type == str
            lc.hasBlankTxn = true
      else
        _.each lc.blankLedger.transactions, (txn) ->
          if txn.particular.uniqueName == '' && txn.amount == 0 && txn.type == str
            lc.hasBlankTxn = true
    else if str == 'CREDIT'
      if ledger.uniqueName
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

  lc.isSelectedAccount = () ->
    $rootScope.selectedAccount = localStorageService.get('_selectedAccount')
    lc.accountToShow = $rootScope.selectedAccount
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
      from: $filter('date')(lc.fromDate.date, 'dd-MM-yyyy')
      to: $filter('date')(lc.toDate.date, 'dd-MM-yyyy')
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
            <input id="magicLink" class="form-control" type="text" ng-model="magicLink">
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
    if _.isNull(lc.toDate.date) || _.isNull(lc.fromDate.date)
      toastr.error("Date should be in proper format", "Error")
      return false
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: lc.accountUnq
      toDate: $filter('date')(lc.toDate.date, "dd-MM-yyyy")
      fromDate: $filter('date')(lc.fromDate.date, "dd-MM-yyyy")
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
      fromDate: $filter('date')(lc.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')(lc.toDate.date, "dd-MM-yyyy")
      lType:type
    }
    accountService.exportLedger(unqNamesObj).then(lc.exportLedgerSuccess, lc.exportLedgerFailure)

  lc.exportLedgerSuccess = (res)->
    lc.isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0
    if lc.msieBrowser()
      lc.openWindow(res.body.filePath)
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
    toastr.error(res.data.message, res.data.status)

  lc.getAccountDetailSuccess = (res) ->
    if res.body.yodleeAdded == true && $rootScope.canUpdate
      #get bank transaction here
      $timeout ( ->
        lc.getBankTransactions(res.body.uniqueName)
      ), 2000
      

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
      lc.ledgerData.ledgers.push(lc.eLedgerData)
      lc.ledgerData.ledgers = lc.sortTransactions(_.flatten(lc.ledgerData.ledgers), 'entryDate')
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
    _.each lc.ledgerData.ledgers, (ledger) ->
      if ledger.isBankTransaction == undefined
        withoutBankTxn.push(ledger)
    lc.ledgerData.ledgers = withoutBankTxn
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
  lc.getLedgerData = (showLoaderCondition) ->
    lc.progressBar.value = 0
    $rootScope.superLoader = true
    lc.showLoader = showLoaderCondition || true
    if _.isUndefined($rootScope.selectedCompany.uniqueName)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    lc.getAccountDetail(lc.accountUnq)
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: lc.accountUnq
      fromDate: $filter('date')(lc.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')(lc.toDate.date, "dd-MM-yyyy")
    }
    if not _.isEmpty(lc.accountUnq)
      ledgerService.getLedger(unqNamesObj).then(lc.getLedgerDataSuccess, lc.getLedgerDataFailure)

  lc.getLedgerDataSuccess = (res) ->
    lc.totalLedgers= res.body.ledgers.length
    # lc.dLedgerData = {}
    # lc.cLedgerData = {}
    # lc.cLedgerContainer = new lc.ledgerContainer(lc.cLedgerData)
    # lc.dLedgerContainer = new lc.ledgerContainer(lc.dLedgerData)
    lc.cLedgerContainer = new lc.ledgerContainer()
    lc.dLedgerContainer = new lc.ledgerContainer()
    #lc.filterLedgers(res.body.ledgers)
    #lc.sortTransactions(res.body.ledgers, 'entryDate')
    lc.ledgerData = {}
    lc.ledgerData.balance = res.body.balance
    lc.ledgerData.forwardedBalance = res.body.forwardedBalance
    lc.ledgerData.creditTotal = res.body.creditTotal
    lc.ledgerData.debitTotal = res.body.debitTotal
    lc.addToIdb(res.body.ledgers, $rootScope.selectedAccount.uniqueName)
    # lc.dLedgerData = lc.dLedgerContainer.ledgerData
    # lc.cLedgerData = lc.cLedgerContainer.ledgerData
    #lc.filterTxnType(res.body.ledgers)
    # lc.dLedgerData = lc.filterLedgers(res.body.ledgers, 'DEBIT')
    $rootScope.flyAccounts = false
    #lc.countTotalTransactions()
    # lc.paginateledgerData(res.body.ledgers)
    if res.body.ledgers.length < 1
      lc.showLoader = false
    #lc.showLoader = false
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
      fromDate: $filter('date')(lc.fromDate.date, "dd-MM-yyyy")
      toDate: $filter('date')(lc.toDate.date, "dd-MM-yyyy")
    }
    if not _.isEmpty(lc.accountUnq)
      ledgerService.getLedger(unqNamesObj).then(
        (res) -> lc.updateLedgerDataSuccess(res, condition, ledger)
        (res) -> lc.updateLedgerDataFailure
      )


  lc.updateLedgerDataSuccess = (res,condition, ledger) ->
    lc.setEntryTotal(ledger, res.body, condition)
    lc.ledgerData.balance.amount = res.body.balance.amount
    lc.ledgerData.balance.type = res.body.balance.type
    lc.ledgerData.creditTotal = res.body.creditTotal
    lc.ledgerData.debitTotal = res.body.debitTotal
    lc.ledgerData.forwardedBalance.amount = res.body.forwardedBalance.amount
    lc.ledgerData.forwardedBalance.type = res.body.forwardedBalance.type
    lc.addToIdb(res.body.ledgers, $rootScope.selectedCompany.uniqueName)
    lc.countTotalTransactions(res.body.ledgers)
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

  lc.countTotalTransactionsAfterSomeTime = (ledgers) ->
    $timeout ( ->
      lc.countTotalTransactions(ledgers)
#      lc.showLoader = true
    ), 1000

  $scope.creditTotal = 0
  $scope.debitTotal = 0
  lc.countTotalTransactions = (ledgers) ->
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

  lc.isSelectedAccount()
  lc.getLedgerData(true)

  $timeout ( ->
    lc.getTaxList()
  ), 2000

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

  lc.setEntryTotal = (pre,post, condition) ->
    if condition != 'delete'
      _.each post.ledgers, (led) ->
        if pre.uniqueName == led.uniqueName
          pre.total = led.total
          if condition == 'update'
            lc.updatedLedgerTotal = led.total

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
      if lc.prevLedger
        lc.prevLedger.isCompoundEntry = false
    else
      lc.cLedgerContainer.ledgerData[ledger.uniqueName].isCompoundEntry = true
      lc.dLedgerContainer.ledgerData[ledger.uniqueName].isCompoundEntry = true
      if lc.prevLedger && lc.prevLedger.uniqueName && ledger.uniqueName != lc.prevLedger.uniqueName
        lc.cLedgerContainer.ledgerData[lc.prevLedger.uniqueName].isCompoundEntry = false
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
      ctxn = lc.cLedgerContainer.ledgerData[ledger.uniqueName].transactions
      dtxn = lc.dLedgerContainer.ledgerData[ledger.uniqueName].transactions
      transactions = []
      transactions.push(dtxn)
      transactions.push(ctxn)
      transactions = _.flatten(transactions)
      ledger.transactions = transactions
    ledger


  lc.doingEntry = false
  lc.lastSelectedLedger = {}
  lc.saveUpdateLedger = (ledger) ->
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
        tax.isChecked = false
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
    _.extend(ledger, res.body)
    lc.resetBlankLedger()
    lc.selectedLedger = lc.blankLedger
    lc.selectedTxn.isOpen = false
    if lc.mergeTransaction
      lc.mergeBankTransactions(lc.mergeTransaction)
    lc.dLedgerLimit = lc.dLedgerLimitBeforeUpdate
    #lc.openClosePopOver(res.body.transactions[0], res.body)
    lc.updateLedgerData('update',res.body)
    $timeout ( ->
      ledger.total = lc.updatedLedgerTotal
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
    delete lc.dLedgerContainer.ledgerData[item.uniqueName]
    delete lc.cLedgerContainer.ledgerData[item.uniqueName]
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
          if lc.selectedTxn.rate > 0
            lc.selectedTxn.amount = lc.selectedTxn.rate * lc.selectedTxn.inventory.quantity
        when 'amount'
          lc.selectedTxn.rate = lc.selectedTxn.amount/lc.selectedTxn.inventory.quantity
        when 'rate'
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



  lc.prevTxn = null
  lc.prevLedger = null
  lc.slctxn = (ledger, txn, e) ->
    if !txn.isOpen
      txn.isOpen = true
    if lc.prevTxn && lc.prevTxn != txn
      lc.prevTxn.isOpen = false
    lc.prevTxn = txn
    lc.selectedLedger = ledger
    lc.selectedTxn = txn
    lc.matchInventory(txn)
    lc.ledgerBeforeEdit = {}
    lc.checkCompEntry(ledger)
    angular.copy(ledger,lc.ledgerBeforeEdit)
    lc.prevLedger = ledger
    if lc.cLedgerContainer.ledgerData['0']
      delete lc.cLedgerContainer.ledgerData['0']
    if lc.dLedgerContainer.ledgerData['0']
      delete lc.dLedgerContainer.ledgerData['0']
    if e
      e.stopPropagation()

  lc.dBlankTxn = {
    amount:0
    particular: ''
    type: 'DEBIT'
  }

  lc.cBlankTxn = {
      amount:0
      particular: ''
      type: 'CREDIT'
  }


  lc.blankLedger = new blankLedgerModel()
  lc.blankLedger.entryDate = $filter('date')(lc.today, 'dd-MM-yyyy')
  lc.blankLedger.transactions.push(lc.dBlankTxn)
  lc.blankLedger.transactions.push(lc.cBlankTxn)

  # $scope.$on 'company-changed', (event,changeData) ->
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

  $rootScope.$on('account-selected', ()->
    lc.isSelectedAccount()
    #$rootScope.$emit('catchBreadcumbs', lc.accountToShow.name)
  )

  lc.commonOnUpgrade = (db) ->
    console.log db.objectStoreNames
    if !db.objectStoreNames.contains('ledgers')
      search = db.createObjectStore('ledgers', keyPath: 'accUniqueName')
      search.createIndex 'entryIndex', [
        'accountUniqueName'
        'index'
      ], unique: true
      search.createIndex 'dateIndex', [
        'accountUniqueName'
        'timestamp'
      ], unique: false
      search.createIndex 'account', [
        'accountUniqueName'
      ], unique: false
    if !db.objectStoreNames.contains('drTransactions')
      abc = db.createObjectStore('drTransactions', keyPath: 'uniqueId')
      # abc.createIndex 'accLedgerUniqueName+ltIndex', [
      #   'accLedgerUniqueName'
      #   'ltIndex'
      # ], unique: true
      abc.createIndex 'accLedgerUniqueName+timestamp', [
        'accLedgerUniqueName'
        'timestamp'
      ], unique: false
      abc.createIndex 'company+accountUniqueName+lIndex', [
        'company'
        'accountUniqueName'
        'lIndex'
      ], unique: false
    if !db.objectStoreNames.contains('crTransactions')
      abd = db.createObjectStore('crTransactions', keyPath: 'uniqueId')
      # abd.createIndex 'accLedgerUniqueName+ltIndex', [
      #   'accLedgerUniqueName'
      #   'ltIndex'
      # ], unique: true
      abd.createIndex 'accLedgerUniqueName+timestamp', [
        'accLedgerUniqueName'
        'timestamp'
      ], unique: false
      abd.createIndex 'company+accountUniqueName+lIndex', [
        'company'
        'accountUniqueName'
        'lIndex'
      ], unique: false
    return

  lc.ledgerContainer = () -> 
    this.ledgerData = {}
    this.trCount = 0
    this.firstLedger = null
    this.lastLedger = null
    return this

  lc.ledgerContainer.prototype.add = (o) -> 
    if ! this.ledgerData.hasOwnProperty(o.uniqueName)
      this.trCount += o.transactions.length
      this.ledgerData[o.uniqueName] = o
      if this.firstLedger == null
        this.firstLedger = this.ledgerData[o.uniqueName]
      this.lastLedger = this.ledgerData[o.uniqueName]
    return

  lc.ledgerContainer.prototype.add = (o, count) -> 
    if ! this.ledgerData.hasOwnProperty(o.uniqueName)
      this.trCount += o.transactions.length
      this.ledgerData[o.uniqueName] = o
      while this.trCount > count + count/3
        this.removeTop()
      tempTop = this.top()
      this.firstLedger = tempTop
      this.lastLedger = this.ledgerData[o.uniqueName]
    return

  lc.ledgerContainer.prototype.addAtTop = (o, count) -> 
    if ! this.ledgerData.hasOwnProperty(o.uniqueName)
      this.trCount += o.transactions.length
      this.ledgerData[o.uniqueName] = o
      while this.trCount > count + count/3
        this.removeBottom()
      this.firstLedger = this.ledgerData[o.uniqueName]
      tempBottom = this.bottom()
      this.lastLedger = tempBottom
    return

  lc.ledgerContainer.prototype.top = () -> 
    least = Number.MAX_SAFE_INTEGER
    topKey = null
    for key in Object.keys(this.ledgerData)
      if this.ledgerData[key].lIndex < least
        least = this.ledgerData[key].lIndex
        topKey = key
    return this.ledgerData[topKey]

  lc.ledgerContainer.prototype.bottom = () -> 
    last = Number.MIN_SAFE_INTEGER
    bottomKey = null
    for key in Object.keys(this.ledgerData)
      if this.ledgerData[key].lIndex > last
        last = this.ledgerData[key].lIndex
        bottomKey = key
    return this.ledgerData[bottomKey]

  lc.ledgerContainer.prototype.remove = (o) -> 
    delete this.ledgerData[o.uniqueName]
    this.trCount -= o.transactions.length
    return

  lc.ledgerContainer.prototype.removeTop = () -> 
    this.remove(this.top())
    return
    
  lc.ledgerContainer.prototype.removeBottom = () -> 
    this.remove(this.bottom())
    return
  lc.ledgerContainer.prototype.getFirstLIndex = () ->
    return if this.firstLedger != null then this.firstLedger.lIndex else Number.MAX_SAFE_INTEGER
  lc.ledgerContainer.prototype.getLastLIndex = () ->
    return if this.lastLedger != null then this.lastLedger.lIndex else Number.MIN_SAFE_INTEGER

  lc.generateKeyRange = (accUniqueName, sortDir, scrollDir) ->
    sortDir = if sortDir == null then lc.sortDirection.asc else sortDir
    if sortDir == lc.sortDirection.asc
      if ( scrollDir == 'prev' )
        keyRange = IDBKeyRange.upperBound([
          $rootScope.selectedCompany.uniqueName
          accUniqueName
          lc.dLedgerContainer.getFirstLIndex()
        ], true)
        fetchDirection = 'prev'
      if ( scrollDir == 'next' || scrollDir == null) 
        keyRange = IDBKeyRange.lowerBound([
          $rootScope.selectedCompany.uniqueName
          accUniqueName
          lc.dLedgerContainer.getLastLIndex()
        ], true)
        fetchDirection = 'next'

    else if sortDir == lc.sortDirection.desc
      if ( scrollDir == 'prev' )
        keyRange = IDBKeyRange.lowerBound([
          $rootScope.selectedCompany.uniqueName
          accUniqueName
          lc.dLedgerContainer.getLastLIndex()
        ], true)
        fetchDirection = 'next'
      if ( scrollDir == 'next' || scrollDir == null ) 
        keyRange = IDBKeyRange.upperBound([
          $rootScope.selectedCompany.uniqueName
          accUniqueName
          lc.dLedgerContainer.getFirstLIndex()
        ], true)
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
      Search = OS.index('company+accountUniqueName+lIndex', true)
      key = $rootScope.selectedCompany.uniqueName+lc.accountUnq+ledger.lIndex
      searchReq = crSearch.get(key)

      searchReq.onsuccess = (e) ->
        if type == 'CR'
          lc.cLedgerContainer.ledgerData['0'] = e.target.result
          lc.crMatch = e.target.result
        else if type == 'DR'
          lc.dLedgerContainer.ledgerData['0'] = e.target.result
          lc.drMatch = e.target.result

    lc.dbConfig.onerror = (e) ->
      e

     dbInstance = idbService.openDb(lc.dbConfig)


  lc.getMatchingTxn = (ledger, type) ->
    if type == 'CR'
      lc.crMatch = lc.cLedgerContainer.ledgerData[ledger.uniqueName]
    else if type == 'DR'
      lc.drMatch = lc.dLedgerContainer.ledgerData[ledger.uniqueName]
    # if lc.drMatch || lc.crMatch
    #   #console.log(lc.match)
    #   #scroll to match
    else
      lc.getMatchingTxnFromIdb(ledger, type)



  return lc

giddh.webApp.controller 'newLedgerController', newLedgerController