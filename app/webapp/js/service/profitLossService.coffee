angular.module('giddhWebApp').service 'plService', ($resource, $q) ->
  profitLoss = $resource('/company/:companyUniqueName/profit-loss',
    {
      'companyUniqueName': @companyUniqueName,
      'to': @date1,
      'from': @date2
    },
    {
      getAll: {
        method: 'GET',
        url: '/company/:companyUniqueName/profit-loss'
      },
      getWithDate: {
        method: 'GET',
        url: '/company/:companyUniqueName/profit-loss'
      }
    })

  plService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    getAllFor: (reqParam, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> profitLoss.getAll({companyUniqueName: reqParam.companyUniqueName}, onSuccess,
        onFailure))

    getWithDate: (reqParam, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> profitLoss.getWithDate({companyUniqueName: reqParam.companyUniqueName, from: reqParam.fromDate, to:reqParam.toDate}, onSuccess, onFailure))

  plService