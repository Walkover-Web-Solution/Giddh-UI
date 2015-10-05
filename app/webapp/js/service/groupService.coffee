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
      console.log "in group service update"
      @handlePromise((onSuccess, onFailure) -> Group.update({
            companyUniqueName: companyUniqueName,
            groupUniqueName: group.uniqueName
          },
          group, (result) -> console.log result, onFailure))

    delete: (companyUniqueName, group) ->
      @handlePromise((onSuccess, onFailure) -> Group.delete({
            companyUniqueName: companyUniqueName,
            groupUniqueName: group.uniqueName
          },
          onSuccess, onFailure))

  groupService