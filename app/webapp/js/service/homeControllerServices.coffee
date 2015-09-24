'use strict'

angular.module('giddhWebApp').service 'homeControllerServices', ($resource) ->
  compResource = $resource('/createCompany', {}, {
    addCmpny: {method: 'POST'}
  })

  compGetResource = $resource('/getCompanyList', {}, {
    getCmpny: {method: 'GET'}
  })

  homeControllerServices =
    createCompany: (cdata, onSuccess, onFailure) ->
      compResource.addCmpny({name: cdata.name, city : cdata.city, uniqueName : cdata.uniqueName}, onSuccess, onFailure)
    getCompList: (onSuccess, onFailure) ->
      compGetResource.getCmpny(onSuccess, onFailure)
        
  homeControllerServices