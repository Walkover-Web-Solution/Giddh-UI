'use strict'

giddh.serviceModule.service 'accountService', ($resource, $q) ->
  Account = $resource('/company/:companyUniqueName/groups/:groupUniqueName/accounts',
    {
      'companyUniqueName': @companyUniqueName
      'groupUniqueName': @groupUniqueName
      'accountsUniqueName': @accountsUniqueName
      'toDate': @toDate
      'fromDate': @fromDate
    },
    {
      create: {method: 'POST'}
      update: {method: 'PUT', url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName'}
      share: {method: 'PUT', url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName/share'}
      unshare: {method: 'PUT', url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName/unshare'}
      sharedWith: {
        method: 'GET'
        url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName/shared-with'
      }
      delete: {method: 'DELETE', url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName'}
      move: {method: 'PUT', url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName/move'}
      export: {
        method: 'GET',
        url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName/export-ledger'
      }
    })

  accountService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    createAc: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.create({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname
      }, data, onSuccess, onFailure))

    updateAc: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.update({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    deleteAc: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.delete({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    share: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.share({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    unshare: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.unshare({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    sharedWith: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Account.sharedWith({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, onSuccess, onFailure))

    move: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.move({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    exportLedger: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Account.export({
        companyUniqueName: unqNamesObj.compUname
        groupUniqueName: unqNamesObj.selGrpUname
        accountsUniqueName: unqNamesObj.acntUname
        toDate: unqNamesObj.toDate
        fromDate: unqNamesObj.fromDate
      }, onSuccess, onFailure))

  accountService
