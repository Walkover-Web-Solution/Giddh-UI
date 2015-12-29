'use strict'

giddh.webApp.service 'userServices', ($resource, $q) ->
  UserSET = $resource('/users',
      {
        'uniqueName': @uniqueName,
      },
      {
        getUserDetails: {
          method: 'GET', url: '/users/:uniqueName'
        }
        getSetAuthKey: {
          method: 'GET', url: '/users/auth-key/:uniqueName'
        }
        generateAuthKey: {
          method: 'PUT',
          url: '/users/:uniqueName/generate-auth-key'
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
      @handlePromise((onSuccess, onFailure) ->
        UserSET.getSetAuthKey({uniqueName: name}, onSuccess, onFailure)
      )

    generateKey: (name) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.generateAuthKey({uniqueName: name}, {}, onSuccess, onFailure)
      )

  userServices