'use strict'

angular.module('giddhWebApp').service 'locationService', ($resource) ->
  searchCity = $resource('/getLocation', {"queryString": @queryString}, {
    getCity: {method: 'GET'}
  })

  locationService =
    search: (searchThis, onSuccess, onFailure)->
      searchCity.getCity({"queryString": searchThis}, onSuccess, onFailure)

  locationService