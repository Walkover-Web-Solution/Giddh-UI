'use strict'

angular.module('giddhWebApp').service 'companyServices', ($resource) ->
  compResource = $resource('/createCompany', {}, {
    addCmpny: {method: 'POST'}
  })

  compGetResource = $resource('/getCompanyList', {}, {
    getCmpny: {method: 'GET'}
  })

  companyServices =
    createCompany: (cdata, onSuccess, onFailure) ->
      compResource.addCmpny(cdata, onSuccess, onFailure)
    getCompList: (onSuccess, onFailure) ->
      compGetResource.getCmpny(onSuccess, onFailure)

  companyServices