'use strict'

angular.module('giddhWebApp').service 'currencyService', ($resource) ->
  currencyGetResource = $resource('/currency', {}, {
    currencyList: {method: 'GET'}
  })

  currencyService =
    getList: (onSuccess, onFailure) ->
      currencyGetResource.currencyList(onSuccess, onFailure)

  currencyService