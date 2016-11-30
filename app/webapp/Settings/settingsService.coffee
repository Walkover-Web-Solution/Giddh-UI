giddh.serviceModule.service 'settingsService', ($resource, $q) ->
  setService = $resource('/company/:companyUniqueName/templates',
    {
      'companyUniqueName': @companyUniqueName
      'templateUniqueName': @templateUniqueName
    },
    {
      save: {
        method: 'POST',
        url: '/company/:companyUniqueName/templates'
      }
      getAllTemplates: {
        method: 'GET',
        url: '/company/:companyUniqueName/templates/all'
      }
      getTemplate: {
        method: 'GET',
        url: '/company/:companyUniqueName/templates/:templateUniqueName'
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

    getAllTemplates: (reqParam) ->
      @handlePromise((onSuccess, onFailure) -> setService.getAllTemplates({companyUniqueName: reqParam.companyUniqueName},onSuccess,
        onFailure))

    getTemplate: (reqParam) ->
      @handlePromise((onSuccess, onFailure) -> setService.getTemplate({
            companyUniqueName: reqParam.companyUniqueName,
            templateUniqueName: reqParam.templateUniqueName}
      ,onSuccess,onFailure))

  settingsService
