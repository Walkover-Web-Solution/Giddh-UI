'use strict'

giddh.serviceModule.service 'accountService', ($resource, $q) ->
  createAccount = $resource('/company/:companyUniqueName/groups/:groupUniqueName/accounts',
    {
      'companyUniqueName': @companyUniqueName
      'groupUniqueName': @groupUniqueName
      'accountsUniqueName': @accountsUniqueName
      'toDate': @toDate
      'fromDate': @fromDate
    },
    { 
      create: {
        method: 'POST'
      } 
    }
  )

  Account = $resource('/company/:companyUniqueName/accounts',
    {
      'companyUniqueName': @companyUniqueName
      'accountsUniqueName': @accountsUniqueName
      'toDate': @toDate
      'fromDate': @fromDate
      'invoiceUniqueID': @invoiceUniqueID
    },
    {
      update:
        method: 'PUT'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName'
      share:
        method: 'PUT'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/share'

      unshare:
        method: 'PUT'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/unshare'

      merge:
        method: 'PUT'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/merge'

      # unMerge : {method: 'PUT', url: '/company/:companyUniqueName/accounts/:accountsUniqueName/merge'}

      unMergeDelete :
        method: 'POST'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/un-merge'

      sharedWith:
        method: 'GET'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/shared-with'
      
      delete:
        method: 'DELETE'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName'
      get:
        method: 'GET'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName'
      move:
        method: 'PUT'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/move'

      export:
        method: 'GET',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/export-ledger'
      
      getlist:
        method: 'GET',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/xls-imports'
      
      emailLedger:
        method: 'POST',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/ledgers/mail'

      getInvList:
        method: 'GET',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/invoices?fromDate=:fromDate&toDate=:toDate'

      prevInvoice:
        method: 'POST'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/invoices/preview'

      genInvoice:
        method: 'POST'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/invoices/generate'

      downloadInvoice:
        method: 'POST'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/invoices/download'

      prevOfGenInvoice:
        method: 'GET',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/invoices/:invoiceUniqueID/preview'

      mailInvoice:
        method: 'POST',
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/invoices/mail'

      updateInvoice:
        method: 'PUT',
        url: '/company/:companyUniqueName/invoices'

      generateMagicLink:
        method: 'POST'
        url: '/company/:companyUniqueName/accounts/:accountsUniqueName/magic-link?fromDate=:fromDate&toDate=:toDate'

      getTaxHierarchy:
        method: 'GET'
        url: '/company/:companyUniqueName/accounts/:accountUniqueName/tax-hierarchy'
      
    })

  accountService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    createAc: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> createAccount.create({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname
      }, data, onSuccess, onFailure))

    updateAc: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.update({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    deleteAc: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.delete({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    get: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Account.get({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, onSuccess, onFailure))

    share: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.share({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    unshare: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.unshare({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    sharedWith: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Account.sharedWith({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, onSuccess, onFailure))

    move: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.move({
        companyUniqueName: unqNamesObj.compUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    exportLedger: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Account.export({
        companyUniqueName: unqNamesObj.compUname
        accountsUniqueName: unqNamesObj.acntUname
        toDate: unqNamesObj.toDate
        fromDate: unqNamesObj.fromDate
        ltype:unqNamesObj.lType
      }, onSuccess, onFailure))

    ledgerImportList: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Account.getlist({
        companyUniqueName: unqNamesObj.compUname
        accountsUniqueName: unqNamesObj.acntUname
      }, onSuccess, onFailure))

    merge: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.merge({
        companyUniqueName: unqNamesObj.compUname
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    unMergeDelete: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.unMergeDelete({
        companyUniqueName: unqNamesObj.compUname
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    # unMerge: (unqNamesObj, data) ->
    #   @handlePromise((onSuccess, onFailure) -> Account.merge({
    #     companyUniqueName: unqNamesObj.compUname
    #     accountsUniqueName: unqNamesObj.acntUname
    #   }, data, onSuccess, onFailure))

    emailLedger: (obj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.emailLedger({
        companyUniqueName: obj.compUname
        accountsUniqueName: obj.acntUname
        toDate: obj.toDate
        fromDate: obj.fromDate
      }, data, onSuccess, onFailure))

    getInvList: (obj, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Account.getInvList({
          companyUniqueName: obj.compUname
          accountsUniqueName: obj.acntUname
          fromDate: obj.fromDate
          toDate: obj.toDate
        }, onSuccess, onFailure))

    prevInvoice: (obj, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Account.prevInvoice({
          companyUniqueName: obj.compUname
          accountsUniqueName: obj.acntUname
        },data, onSuccess, onFailure))

    genInvoice: (obj, data, onSuccess, onFailure) ->
      console.log data
      @handlePromise((onSuccess, onFailure) -> Account.genInvoice({
          companyUniqueName: obj.compUname
          accountsUniqueName: obj.acntUname
        },data, onSuccess, onFailure))

    downloadInvoice: (obj, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Account.downloadInvoice({
          companyUniqueName: obj.compUname
          accountsUniqueName: obj.acntUname
        },data, onSuccess, onFailure))

    prevOfGenInvoice: (obj, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Account.prevOfGenInvoice({
          companyUniqueName: obj.compUname
          accountsUniqueName: obj.acntUname
          invoiceUniqueID: obj.invoiceUniqueID
        }, onSuccess, onFailure))

    mailInvoice: (obj, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Account.mailInvoice({
          companyUniqueName: obj.compUname
          accountsUniqueName: obj.acntUname
        },data, onSuccess, onFailure))

    generateMagicLink: (obj) ->
      @handlePromise((onSuccess, onFailure) -> Account.generateMagicLink({
        companyUniqueName: obj.compUname
        accountsUniqueName: obj.acntUname
        fromDate: obj.fromDate
        toDate: obj.toDate
      }, {}, onSuccess, onFailure))

    updateInvoice: (obj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.updateInvoice({
        companyUniqueName: obj.compUname
      }, data, onSuccess, onFailure))

    getTaxHierarchy: (companyUniqueName, accountUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Account.getTaxHierarchy({
        companyUniqueName: companyUniqueName
        accountUniqueName: accountUniqueName
      }, onSuccess, onFailure))

  accountService
