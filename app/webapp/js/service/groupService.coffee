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
      })

  groupService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    create: (companyUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) -> Group.add({companyUniqueName: companyUniqueName}, data, onSuccess,
          onFailure))

    getAllFor: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAll({companyUniqueName: companyUniqueName}, onSuccess,
          onFailure))

    getAllWithAccountsFor: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAllWithAccounts({companyUniqueName: companyUniqueName},
          onSuccess, onFailure))

    update: (companyUniqueName, group) ->
      @handlePromise((onSuccess, onFailure) -> Group.update({
            companyUniqueName: companyUniqueName,
            groupUniqueName: group.oldUName
          },
          group, (result) -> console.log result, onFailure))

    delete: (companyUniqueName, group) ->
      @handlePromise((onSuccess, onFailure) -> Group.delete({
            companyUniqueName: companyUniqueName,
            groupUniqueName: group.uniqueName
          },
          onSuccess, onFailure))

    move: (companyUniqueName, groupUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) -> Group.move({
        companyUniqueName: companyUniqueName,
        groupUniqueName: group.uniqueName
      }, data, onSuccess, onFailure))

    share: (companyUniqueName, groupUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) -> Group.share({
        companyUniqueName: companyUniqueName,
        groupUniqueName: group.uniqueName
      }, data, onSuccess, onFailure))

  groupService