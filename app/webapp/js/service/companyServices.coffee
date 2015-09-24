'use strict'

angular.module('giddhWebApp').service 'companyServices', ($resource) ->
  compResource = $resource('/createCompany', {}, {
    addCmpny: {method: 'POST'}
  })

  compGetResource = $resource('/getCompanyList', {}, {
    getCmpny: {method: 'GET'}
  })

  searchCity = $resource('/getLocation', {"queryString": @queryString}, {
    getCity: {method: 'GET'}
  })

  companyServices =
    createCompany: (cdata, onSuccess, onFailure) ->
      compResource.addCmpny(cdata, onSuccess, onFailure)

    getCompList: (onSuccess, onFailure) ->
      compGetResource.getCmpny(onSuccess, onFailure)

    getLocation: (searchThis, onSuccess, onFailure)->
      searchCity.getCity({"queryString": searchThis}, onSuccess, onFailure)

  companyServices