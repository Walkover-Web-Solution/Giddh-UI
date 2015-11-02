'use strict'

angular.module('giddhWebApp').service 'userServices', ($resource, $q) ->
  User = $resource('/users', {'uniqueName': @uniqueName}, {
    getUserDetails: {method: 'GET', url: '/users/:uniqueName'}
    getAuthKey: {
      method: 'GET',
      url: '/users/auth-key?uniqueName=:uniqueName'
    }
  })

  userServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    get: (uniqueName) ->
      @handlePromise((onSuccess, onFailure) -> User.getUserDetails({uniqueName: uniqueName}, onSuccess,
          onFailure))

    getAuthKey: (uniqueName) ->
      console.log "get Auth key in service"
      @handlePromise((onSuccess, onFailure) -> User.getAuthKey({uniqueName: uniqueName}, onSuccess, onFailure))

  userServices