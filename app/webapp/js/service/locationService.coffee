'use strict'

angular.module('giddhWebApp').service 'locationService', ($resource, $q) ->
  Search = $resource('/location/search',
    {
      "queryString": @queryString, 
      "administrator_level": @administrator_level, 
      "country": @country,
      "onlyCity": @onlyCity
    }, 
    {
      getCity: {method: 'GET'}
    }
  )

  locationService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    searchCity: (searchThis, state)->
      @handlePromise((onSuccess, onFailure) -> Search.getCity({"queryString": searchThis, "administrator_level": state},
          onSuccess, onFailure))

    searchOnlyCity: (val)->
      @handlePromise((onSuccess, onFailure) -> Search.getCity({"queryString": val, "onlyCity": true}, onSuccess, onFailure))

    searchState: (searchThis, country)->
      @handlePromise((onSuccess, onFailure) -> Search.getCity({"queryString": searchThis, "country": country},
          onSuccess, onFailure))

    searchCountry: (searchThis)->
      @handlePromise((onSuccess, onFailure) -> Search.getCity({"queryString": searchThis}, onSuccess, onFailure))

    #getCountryCode: 

  locationService