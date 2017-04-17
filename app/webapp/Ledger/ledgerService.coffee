'use strict'

giddh.serviceModule.service 'ledgerService', ($resource, $q) ->
  Ledger = $resource('/company/:companyUniqueName/accounts',
    {
      'companyUniqueName': @companyUniqueName,
      'accountsUniqueName': @accountsUniqueName
      'date1': @date1
      'date2': @date2
      'entryUniqueName': @entryUniqueName
      'chequeNumber':@chequeNumber
    },
    {
      get: {
        method: 'GET',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/ledgers?fromDate=:date1&toDate=:date2'
      }
      create: {
        method: 'POST'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/ledgers/'
      }
      update: {
        method: 'PUT'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/ledgers/:entryUniqueName'
      }
      delete: {
        method: 'DELETE',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/ledgers/:entryUniqueName'
      }
      getEntrySettings: {
        method: 'GET',
        url: '/company/:companyUniqueName/entry-settings'
      }
      updateEntrySettings: {
        method: 'PUT',
        url: '/company/:companyUniqueName/update-entry-settings'
      }
      getInvoiceFile: {
        method: 'GET',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/ledgers/invoice-file'
      }
      getReconcileEntries: {
        method: 'GET',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/ledgers/reconcile'
      }
      
    }
  )

  otherLedger = $resource('/company/:companyUniqueName/accounts/:accountsUniqueName/',
    {
      'companyUniqueName': @companyUniqueName
      'accountsUniqueName': @accountsUniqueName
      'transactionId': @transactionId
      # 'refresh': @refresh
    },
    { 
      getTransactions: {
        method: 'GET',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/eledgers'
      }
      getFreshTransactions: {
        method: 'GET',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/eledgers?refresh=true'
      }
      trashTransaction: {
        method: 'DELETE',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/eledgers/:transactionId'
      }
      mapEntry: {
        method: 'PUT',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/eledgers/map/:transactionId'
      }
    }
  )

  ledgerService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    getLedger: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.get({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
        date1: unqNamesObj.fromDate
        date2: unqNamesObj.toDate
      }, onSuccess, onFailure))

    createEntry: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.create({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    updateEntry: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.update({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
        entryUniqueName: unqNamesObj.entUname
      }, data, onSuccess, onFailure))

    deleteEntry: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.delete({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
        entryUniqueName: unqNamesObj.entUname
      }, onSuccess, onFailure))

    getOtherTransactions: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> otherLedger.getTransactions({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, onSuccess, onFailure))

    trashTransaction: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> otherLedger.trashTransaction({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
        transactionId: unqNamesObj.trId
      }, onSuccess, onFailure))

    getSettings: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.getEntrySettings({
        companyUniqueName: unqNamesObj.compUname
      }, onSuccess, onFailure))

    updateEntrySettings: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.updateEntrySettings({
        companyUniqueName: unqNamesObj.compUname
      }, data, onSuccess, onFailure))

    downloadInvoiceFile: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.getInvoiceFile({
        companyUniqueName: unqNamesObj.companyUniqueName,
        accountsUniqueName: unqNamesObj.accountsUniqueName,
        fileName:unqNamesObj.file
      }, onSuccess, onFailure))

    getReconcileEntries: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.getReconcileEntries({
        companyUniqueName: unqNamesObj.companyUniqueName,
        accountsUniqueName: unqNamesObj.accountUniqueName,
        chequeNumber:unqNamesObj.chequeNumber,
        from:unqNamesObj.from
        to:unqNamesObj.to
      }, onSuccess, onFailure))

    mapBankEntry: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> otherLedger.mapEntry({
        companyUniqueName: unqNamesObj.companyUniqueName,
        accountsUniqueName: unqNamesObj.accountUniqueName
        transactionId: unqNamesObj.transactionId
      },data, onSuccess, onFailure))

  ledgerService