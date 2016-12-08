giddh.serviceModule.service 'settingsService', ($resource, $q) ->
  setService = $resource('/company/:companyUniqueName/templates',
    {
      'companyUniqueName': @companyUniqueName
      'templateUniqueName': @templateUniqueName
      'operation': @operation
    },
    {
      save: {
        method: 'POST',
        url: '/company/:companyUniqueName/templates'
      }
      update: {
        method: 'PUT',
        url: '/company/:companyUniqueName/templates/:templateUniqueName/update'
      }
      getAllTemplates: {
        method: 'GET',
        url: '/company/:companyUniqueName/templates/all'
      }
      getTemplate: {
        method: 'GET',
        url: '/company/:companyUniqueName/templates/:templateUniqueName?operation=:operation'
      }
      deleteTemplate: {
        method: 'DELETE',
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

    update: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> setService.update({
            companyUniqueName: reqParam.companyUniqueName,
            templateUniqueName: reqParam.templateUniqueName}
        ,data,onSuccess,onFailure))

    getAllTemplates: (reqParam) ->
      @handlePromise((onSuccess, onFailure) -> setService.getAllTemplates({companyUniqueName: reqParam.companyUniqueName},onSuccess,
        onFailure))

    getTemplate: (reqParam) ->
      @handlePromise((onSuccess, onFailure) -> setService.getTemplate({
            companyUniqueName: reqParam.companyUniqueName,
            templateUniqueName: reqParam.templateUniqueName,
            operation: reqParam.operation}
      ,onSuccess,onFailure))

    deleteTemplate: (reqParam) ->
      @handlePromise((onSuccess, onFailure) -> setService.deleteTemplate({
            companyUniqueName: reqParam.companyUniqueName,
            templateUniqueName: reqParam.templateUniqueName}
      ,onSuccess,onFailure))

  settingsService
