'use strict'

giddh.serviceModule.service 'userServices', ($resource, $q) ->
  UserSET = $resource('/users',
      {
        'uniqueName': @uniqueName,
        'companyUniqueName' : @companyUniqueName
        'page': @page
        'memSiteAccId': @memSiteAccId
        'linkedAccount': @linkedAccount
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
        addBalInWallet: {
          method: 'POST'
          url: '/users/:uniqueName/balance'
        }
        searchSite: {
          method: 'POST'
          url: '/ebanks'
        }
        # loginRegister: {
        #   method: 'GET'
        #   url: '/yodlee/login-register'
        # }
        addSiteAccount: {
          method: 'POST'
          url: '/company/:companyUniqueName/ebanks'
        }
        getAccounts: {
          method: 'GET'
          url: '/company/:companyUniqueName/ebanks'
        }
        addGiddhAccount: {
          method: 'PUT'
          url: '/company/:companyUniqueName/ebanks/:itemAccountId'
        }
        verifyMfa: {
          method: 'POST'
          url: '/yodlee/company/:companyUniqueName/verify-mfa'
        }
        refreshAll: {
          method: 'GET'
          url: '/company/:companyUniqueName/ebanks'
        }
        deleteAccount: {
          method: 'DELETE'
          url: '/company/:companyUniqueName/ebanks/:memSiteAccId/remove'
        }
        removeGiddhAccount: {
          method: 'DELETE'
          url: '/company/:companyUniqueName/ebanks/:ItemAccountId'
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

    addBalInWallet: (data) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.addBalInWallet({uniqueName: data.uUname}, data, onSuccess, onFailure)
      )
    searchSite: (data, reqParam) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.searchSite({name: reqParam.pName}, data , onSuccess, onFailure)
    )
    # loginRegister: () ->
    #   @handlePromise((onSuccess, onFailure) ->
    #     UserSET.loginRegister(onSuccess, onFailure)
    # )
    addSiteAccount: (data, companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.addSiteAccount({companyUniqueName: companyUniqueName.cUnq}, data, onSuccess, onFailure)
    )
    getAccounts: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.getAccounts({companyUniqueName: companyUniqueName.cUnq}, onSuccess, onFailure)
    )
    addGiddhAccount: (companyUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.addGiddhAccount({companyUniqueName: companyUniqueName.cUnq, itemAccountId:companyUniqueName.itemAccountId}, data, onSuccess, onFailure)
    )
    verifyMfa: (companyUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.verifyMfa({companyUniqueName: companyUniqueName.cUnq}, data, onSuccess, onFailure)
    )
    refreshAll: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.refreshAll({companyUniqueName: companyUniqueName.cUnq, refresh: companyUniqueName.refresh},onSuccess, onFailure)
    )
    removeAccount: (reqParam) ->
      console.log reqParam
      @handlePromise((onSuccess, onFailure) ->
        UserSET.removeGiddhAccount({companyUniqueName: reqParam.cUnq, linkedAccount: reqParam.linkedAccount, ItemAccountId: reqParam.linkedAccount},onSuccess, onFailure)
    )
    deleteBankAccount: (reqParam) ->
      @handlePromise((onSuccess, onFailure) ->
        UserSET.deleteAccount({companyUniqueName: reqParam.cUnq, memSiteAccId: reqParam.memSiteAccId},onSuccess, onFailure)
    )

  userServices

  