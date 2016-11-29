giddh.serviceModule.service 'settingsService', ($resource, $q) ->
  setService = $resource('/company/:companyUniqueName/templates',
    {
      'companyUniqueName': @companyUniqueName
    },
    {
      save: {
        method: 'POST',
        url: '/company/:companyUniqueName/templates'
      }
      getTemplates: {
        method: 'GET',
        url: '/company/:companyUniqueName/templates/all'
      }
    })

  settingsService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    save: (reqParam,data) ->
      @handlePromise((onSuccess, onFailure) -> setService.save({companyUniqueName: reqParam.companyUniqueName},data, onSuccess,
        onFailure))

    getTemplates: (reqParam) ->
      @handlePromise((onSuccess, onFailure) -> setService.getTemplates({companyUniqueName: reqParam.companyUniqueName},onSuccess,
        onFailure))

  settingsService
