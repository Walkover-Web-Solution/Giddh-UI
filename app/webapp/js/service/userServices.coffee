'use strict'

giddh.serviceModule.service 'userServices', ($resource, $q) ->
  UserSET = $resource('/users',
      {
        'uniqueName': @uniqueName,
        'page': @page
      },
      {
        getUserDetails: {
          method: 'GET' 
          url: '/users/:uniqueName'
        }
        getSetAuthKey: {
          method: 'GET' 
          url: '/users/auth-key/:uniqueName'
        }
        generateAuthKey: {
          method: 'PUT'
          url: '/users/:uniqueName/generate-auth-key'
        }
        getSubList: {
          method: 'GET'
          url: '/users/:uniqueName/subscribed-companies'
        }
        getUserSubList: {
          method: 'GET'
          url: '/users/:uniqueName/transactions?page=:page'
        }
        getWltBal: {
          method: 'GET'
          url: '/users/:uniqueName/available-credit'
        }
        cancelAutoPay: {
          method: 'PUT'
          url: '/users/:uniqueName/delete-payee'
        }
        payBillViaRazor: {
          method: 'POST'
          url: '/users/:uniqueName/balance'
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

    getsublist: (name) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.getSubList({uniqueName: name}, onSuccess, onFailure)
      )

    getUserSublist: (obj) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.getUserSubList({uniqueName: obj.name, page: obj.num}, onSuccess, onFailure)
      )

    getWltBal: (name) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.getWltBal({uniqueName: name}, onSuccess, onFailure)
      )

    cancelAutoPay: (data) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.cancelAutoPay({uniqueName: data.uUname}, data, onSuccess, onFailure)
      )

    payBillViaRazor: (data) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.payBillViaRazor({uniqueName: data.uUname}, data, onSuccess, onFailure)
      )

  userServices