'use strict'

angular.module('giddhWebApp').service 'groupService', ($resource, $q) ->
  Group = $resource('/company/:company/groups',
    {'company': @company, 'groupUniqueName': @groupUniqueName},
    {
      add: {method: 'POST'}
      getAll: {method: 'GET'}
      getAllWithAccounts: {method: 'GET', url: '/company/:company/groups/with-accounts'}
      update: {method: 'PUT', url: '/company/:company/groups/:groupUniqueName'}
      delete: {method: 'DELETE', url: '/company/:company/groups/:groupUniqueName'}
    })

  groupService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    create: (company, data) ->
      @handlePromise((onSuccess, onFailure) -> Group.add({company: company}, data, onSuccess, onFailure))

    getAllFor: (company) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAll({company: company}, onSuccess, onFailure))

    getAllWithAccountsFor: (company) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAllWithAccounts({company: company}, onSuccess, onFailure))

    update: (company, group) ->
      @handlePromise((onSuccess, onFailure) -> Group.update({company: company, groupUniqueName: group.uniqueName},
        group, onSuccess, onFailure))

    delete: (company, group) ->
      @handlePromise((onSuccess, onFailure) -> Group.delete({company: company, groupUniqueName: group.uniqueName},
        onSuccess, onFailure))

  groupService