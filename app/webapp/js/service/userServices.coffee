'use strict'

angular.module('giddhWebApp').service 'userServices', ($resource, $q) ->
  UserSET = $resource('/users/auth-key', 
    {
      'uniqueName': @uniqueName
    }, 
    {
      getUserDetails: {
        method: 'GET', url: '/users/:uniqueName'
      }
      getSetAuthKey: {
        method: 'GET', url: '/users/auth-key/:uniqueName'
      }
    }
  )

  userServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    get: (name) ->
      @handlePromise((onSuccess, onFailure) -> UserSET.getUserDetails({uniqueName: name}, onSuccess, onFailure))

    getKey: (name) ->
      console.log "in get key service", name
      @handlePromise((onSuccess, onFailure) -> 
        UserSET.getSetAuthKey({uniqueName: name}, onSuccess, onFailure)
      )

  userServices