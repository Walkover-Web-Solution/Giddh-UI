'use strict'

angular.module('giddhWebApp').service 'companyServices', ($resource, $q) ->
  Company = $resource('/company', {'uniqueName': @uniqueName}, {
    add: {method: 'POST'}
    get: {method: 'GET', url: '/company/:uniqueName'}
    getList: {method: 'GET', url: '/company/all'}
    delete:{method: 'DELETE', url: '/company/:uniqueName'}
    update:{method: 'PUT', url: '/company/:uniqueName'}
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
      @handlePromise((onSuccess, onFailure) -> Company.delete({
        uniqueName: uniqueName}, onSuccess, onFailure))
    
    update: (updtData, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.update({
        uniqueName: updtData.uniqueName}, updtData,  onSuccess, onFailure))


  companyServices