'use strict'

angular.module('giddhWebApp').service 'companyServices', ($resource) ->
  compResource = $resource('/company', {}, {
    addCmpny: {method: 'POST'}
  })

  compGetResource = $resource('/company/all', {}, {
    getCmpny: {method: 'GET'}
  })

  companyServices =
    createCompany: (cdata, onSuccess, onFailure) ->
      compResource.addCmpny(cdata, onSuccess, onFailure)

    getCompList: (onSuccess, onFailure) ->
      compGetResource.getCmpny(onSuccess, onFailure)

  companyServices