'use strict'

angular.module('giddhWebApp').service 'companyServices', ($resource, $q) ->
  Company = $resource('/company', {'uniqueName': @uniqueName}, {
    add: {method: 'POST'}
    get: {method: 'GET', url: '/company/:uniqueName'}
    getList: {method: 'GET', url: '/company/all'}
    delete:{method: 'DELETE', url: '/company/:uniqueName'}
  })

  companyServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    create: (cdata) ->
      @handlePromise((onSuccess, onFailure) -> Company.add(cdata, onSuccess, onFailure))

    getAll: () ->
      @handlePromise((onSuccess, onFailure) -> Company.getList(onSuccess, onFailure))

    get: (uniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.get({uniqueName: uniqueName}, onSuccess, onFailure))

    delete: (uniqueName, onSuccess, onFailure) ->
      console.log "in delete company", uniqueName
      @handlePromise((onSuccess, onFailure) -> Company.delete({
        uniqueName: uniqueName}, onSuccess, onFailure))

    confirm: (name) ->
      console.log "in company confirm", name
      

  companyServices