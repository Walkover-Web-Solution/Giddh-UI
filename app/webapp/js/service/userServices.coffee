'use strict'

angular.module('giddhWebApp').service 'userServices', ($resource, $q) ->
  User = $resource('/users', {'uniqueName': @uniqueName}, {
    getUserDetails: {method: 'GET', url: '/users/:uniqueName'}
  })

  userServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    get: (uniqueName) ->
      console.log "uniqueName", uniqueName
      @handlePromise((onSuccess, onFailure) -> User.getUserDetails({uniqueName: uniqueName}, onSuccess,
          onFailure))

  userServices