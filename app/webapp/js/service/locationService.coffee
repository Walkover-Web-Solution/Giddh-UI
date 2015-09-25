'use strict'

angular.module('giddhWebApp').service 'locationService', ($resource, $q) ->
  Search = $resource('/getLocation', {"queryString": @queryString}, {
    getCity: {method: 'GET'}
  })

  locationService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    search: (searchThis, onSuccess, onFailure)->
      @handlePromise((onSuccess, onFailure) -> Search.getCity({"queryString": searchThis}, onSuccess, onFailure))

  locationService