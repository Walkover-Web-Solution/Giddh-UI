'use strict'

giddh.serviceModule.service 'reportService', ($resource, $q) ->
  Report = $resource('/company/:companyUniqueName/history',
    {
      'companyUniqueName': @companyUniqueName
      'date1': @date1
      'date2': @date2
    },
    {
      historicData: {
        method: 'POST',
        url: '/company/:companyUniqueName/history?fromDate=:date1&toDate=:date2'
      }
      # historicData: {
      #   method: 'PUT'
      #   url: '/company/:companyUniqueName/'
      # }
    })
  reportService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    historicData: (argData, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Report.historicData({companyUniqueName: argData.cUname
        date1: argData.fromDate
        date2: argData.toDate
      }, data, onSuccess,  onFailure))

  reportService