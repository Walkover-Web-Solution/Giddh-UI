'use strict'

angular.module('giddhWebApp').service 'groupService', ($resource, $q) ->
  Group = $resource('/company/:companyUniqueName/groups',
      {'companyUniqueName': @companyUniqueName, 'groupUniqueName': @groupUniqueName},
      {
        add: {method: 'POST'}
        getAll: {method: 'GET'}
        getAllWithAccounts: {method: 'GET', url: '/company/:companyUniqueName/groups/with-accounts'}
        update: {method: 'PUT', url: '/company/:companyUniqueName/groups/:groupUniqueName'}
        delete: {method: 'DELETE', url: '/company/:companyUniqueName/groups/:groupUniqueName'}
        move: {method: 'PUT', url: '/company/:companyUniqueName/groups/:groupUniqueName/move'}
        share: {method: 'PUT', url: '/company/:companyUniqueName/groups/:groupUniqueName/share'}
        unshare: {method: 'PUT', url: '/company/:companyUniqueName/groups/:groupUniqueName/unshare'}
        sharedWith: {method: 'GET', url: '/company/:companyUniqueName/groups/:groupUniqueName/shared-with'}
      })

  groupService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    create: (companyUniqueName, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.add({companyUniqueName: companyUniqueName}, data, onSuccess,
          onFailure))

    getAllFor: (companyUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAll({companyUniqueName: companyUniqueName}, onSuccess,
          onFailure))

    getAllWithAccountsFor: (companyUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAllWithAccounts({companyUniqueName: companyUniqueName},
          onSuccess, onFailure))

    update: (companyUniqueName, group) ->
      @handlePromise((onSuccess, onFailure) -> Group.update({
        companyUniqueName: companyUniqueName,
        groupUniqueName: group.oldUName
      },group, onSuccess, onFailure))


    delete: (companyUniqueName, group, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.delete({
            companyUniqueName: companyUniqueName,
            groupUniqueName: group.uniqueName
          },
          onSuccess, onFailure))

    move: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Group.move({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname
      }, data, onSuccess, onFailure))

    share: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Group.share({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname
      }, data, onSuccess, onFailure))

    unshare: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Group.unshare({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname
      }, data, onSuccess, onFailure))

    sharedList: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Group.sharedWith({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname
      },onSuccess, onFailure))

  groupService


angular.module('giddhWebApp').service 'accountService', ($resource, $q) ->
  
  Account = $resource('/company/:companyUniqueName/groups/:groupUniqueName/accounts',
      {
        'companyUniqueName': @companyUniqueName, 
        'groupUniqueName': @groupUniqueName,
        'accountsUniqueName': @accountsUniqueName
      },
      {
        create: {method: 'POST'}
        update: {method: 'PUT', url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName'}
        delete: {method: 'DELETE', url: '/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountsUniqueName'}
      })

  accountService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    createAc: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> Account.create({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
      },data, onSuccess, onFailure))

    updateAc: (unqNamesObj, data) ->
      console.log "in updateAc"
      @handlePromise((onSuccess, onFailure) -> Account.update({
        companyUniqueName: unqNamesObj.compUname,
        groupUniqueName: unqNamesObj.selGrpUname,
        accountsUniqueName: unqNamesObj.acntUname
      },data, onSuccess, onFailure))

  accountService