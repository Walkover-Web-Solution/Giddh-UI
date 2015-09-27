'use strict'

angular.module('giddhWebApp').service 'companyServices', ($resource, $q) ->
  Company = $resource('/company', {'uniqueName': @uniqueName}, {
    add: {method: 'POST'}
    get: {method: 'GET', url: '/company/:uniqueName'}
    getList: {method: 'GET', url: '/company/all'}
  })

  companyServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    create: (cdata, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.add(cdata, onSuccess, onFailure))

    getAll: (onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.getList(onSuccess, onFailure))

    get: (uniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.get({uniqueName: uniqueName}, onSuccess, onFailure))

  companyServices