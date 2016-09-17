'use strict'

angular.module('giddhApp').service 'sindhuServices', ($resource, $q) ->
  sindhu = $resource('/sindhu',
      {
        'uniqueName': @uniqueName,
        'companyUniqueName' : @companyUniqueName
      },{
        getCompanyList:{
          method: 'GET'
          url: '/admin/:uniqueName'
        }
      }
  )
  sindhuServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

  sindhuServices