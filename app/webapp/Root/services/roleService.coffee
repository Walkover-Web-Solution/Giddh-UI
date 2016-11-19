'use strict'

giddh.serviceModule.service 'roleServices', ($resource, $q) ->
  Role = $resource('/roles', {}
    {
      all: {
        method: 'GET'
      }
      getEnvVar:{
        method: 'GET'
        url: '/roles/getEnvVars'
      }
    }
  )
  roleServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    getAll: () ->
      @handlePromise((onSuccess,  onFailure) -> Role.all(onSuccess, onFailure))

    getEnvVars: () ->
      @handlePromise((onSuccess, onFailure) -> Role.getEnvVar(onSuccess, onFailure))

  roleServices