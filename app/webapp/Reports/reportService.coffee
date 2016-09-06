'use strict'

giddh.serviceModule.service 'reportService', ($resource, $q) ->
  Report = $resource('/company/:companyUniqueName/history',
    {
      'companyUniqueName': @companyUniqueName
      'date1': @date1
      'date2': @date2
      'interval': @interval
    },
    {
      historicData: {
        method: 'POST',
        url: '/company/:companyUniqueName/history?fromDate=:date1&toDate=:date2&interval=:interval'
      },
      newHistoricData: {
        method: 'POST',
        url: '/company/:companyUniqueName/group-history?fromDate=:date1&toDate=:date2&interval=:interval'
      },
      plHistoricData: {
        method: 'GET',
        url: '/company/:companyUniqueName/profit-loss-history?fromDate=:date1&toDate=:date2&interval=:interval'
      },
      profitLossData: {
        method: 'GET',
        url: '/company/:companyUniqueName/profit-loss?fromDate=:date1&toDate=:date2&interval=:interval'
      }
      nwHistoricData: {
        method: 'GET',
        url: '/company/:companyUniqueName/networth-history?fromDate=:date1&toDate=:date2&interval=:interval'
      }
      networthData: {
        method: 'GET',
        url: '/company/:companyUniqueName/networth?fromDate=:date1&toDate=:date2&interval=:interval'
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
      @handlePromise((onSuccess, onFailure) -> Report.historicData({
        companyUniqueName: argData.cUname
        date1: argData.fromDate
        date2: argData.toDate
        interval: argData.interval
      }, data, onSuccess,  onFailure))

    newHistoricData: (argData, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Report.newHistoricData({
        companyUniqueName: argData.cUname
        date1: argData.fromDate
        date2: argData.toDate
        interval: argData.interval
      }, data, onSuccess,  onFailure))

    plGraphData: (argData, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Report.plHistoricData({
        companyUniqueName: argData.cUname
        date1: argData.fromDate
        date2: argData.toDate
        interval: argData.interval
      }, onSuccess,  onFailure))

    profitLossData: (argData, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Report.profitLossData({
        companyUniqueName: argData.cUname
        date1: argData.fromDate
        date2: argData.toDate
        interval: argData.interval
      }, onSuccess,  onFailure))

    nwGraphData: (argData, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Report.nwHistoricData({
        companyUniqueName: argData.cUname
        date1: argData.fromDate
        date2: argData.toDate
        interval: argData.interval
      }, onSuccess,  onFailure))

    networthData: (argData, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Report.networthData({
        companyUniqueName: argData.cUname
        date1: argData.fromDate
        date2: argData.toDate
        interval: argData.interval
      }, onSuccess,  onFailure))

  reportService