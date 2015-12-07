'use strict'

angular.module('giddhWebApp').service 'ledgerService', ($resource, $q) ->
  Ledger = $resource('/company/:companyUniqueName/groups/:groupUniqueName/accounts',
    {
      'companyUniqueName': @companyUniqueName,
      'groupUniqueName': @groupUniqueName,
      'accountsUniqueName': @accountsUniqueName
      'date1': @date1
      'date2': @date2
      'entryUniqueName': @entryUniqueName
    },
    {
      get: {
        method: 'GET',
        url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName/ledgers?fromDate=:date1&toDate=:date2'
      }
      create: {
        method: 'POST'
        url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName/ledgers/'
      }
      update: {
        method: 'PUT'
        url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName/ledgers/:entryUniqueName'
      }
      delete: {
        method: 'DELETE',
        url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName/ledgers/:entryUniqueName'
      }
    })

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
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
        date1: unqNamesObj.fromDate
        date2: unqNamesObj.toDate
      }, onSuccess, onFailure))

    createEntry: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.create({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
      }, data, onSuccess, onFailure))

    updateEntry: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.update({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
        entryUniqueName: unqNamesObj.entUname
      }, data, onSuccess, onFailure))

    deleteEntry: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Ledger.delete({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
        entryUniqueName: unqNamesObj.entUname
      }, onSuccess, onFailure))

  ledgerService