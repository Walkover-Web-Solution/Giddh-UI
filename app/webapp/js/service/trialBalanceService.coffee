angular.module('giddhWebApp').service 'trialBalService', ($resource, $q) ->
  trialBal = $resource('/company/:companyUniqueName/trialBalance',
    {
      'companyUniqueName': @companyUniqueName,
      'fromDate': @date1,
      'toDate': @date2
    },
    {
      getAll: {
        method: 'GET',
        url: '/company/:companyUniqueName/trialBalance'
      }
    })

  trialBalService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    getAllFor: (reqParam, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> trialBal.getAll({companyUniqueName: reqParam.companyUniqueName, fromDate: reqParam.fromDate, toDate: reqParam.toDate}, onSuccess,
        onFailure))

  trialBalService