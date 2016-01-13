'use strict'

giddh.serviceModule.service 'groupService', ($resource, $q) ->
  Group = $resource('/company/:companyUniqueName/groups',
    {'companyUniqueName': @companyUniqueName, 'groupUniqueName': @groupUniqueName},
    {
      add: {method: 'POST'}
      getAll: {method: 'GET'}
      getAllWithAccounts: {
        method: 'GET',
        url: '/company/:companyUniqueName/groups/with-accounts'
      }
      getAllInDetail: {method: 'GET', url: '/company/:companyUniqueName/groups/detailed-groups'}
      getAllWithAccountsInDetail: {
        method: 'GET',
        url: '/company/:companyUniqueName/groups/detailed-groups-with-accounts'
      }
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
      @handlePromise((onSuccess, onFailure) -> Group.getAllInDetail({companyUniqueName: companyUniqueName}, onSuccess,
        onFailure))

    getAllWithAccountsFor: (companyUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAllWithAccountsInDetail({companyUniqueName: companyUniqueName},
        onSuccess, onFailure))

    getAllCroppedFor: (companyUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAll({companyUniqueName: companyUniqueName}, onSuccess,
        onFailure))

    getAllCroppedWithAccountsFor: (companyUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAllWithAccounts({companyUniqueName: companyUniqueName},
        onSuccess, onFailure))

    update: (companyUniqueName, group) ->
      @handlePromise((onSuccess, onFailure) -> Group.update({
        companyUniqueName: companyUniqueName,
        groupUniqueName: group.oldUName
      }, group, onSuccess, onFailure))


    delete: (companyUniqueName, group, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.delete({
        companyUniqueName: companyUniqueName,
        groupUniqueName: group.uniqueName
      }, onSuccess, onFailure))

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
      }, onSuccess, onFailure))


    flattenGroup: (rawList, parents) ->
      listofUN = _.map(rawList, (listItem) ->
        newParents = _.union([], parents)
        newParents.push({name: listItem.name, uniqueName: listItem.uniqueName, role: listItem.role})
        if listItem.groups.length > 0
          result = groupService.flattenGroup(listItem.groups, newParents)
          result.push(listItem)
        else
          result = listItem
        listItem.parentGroups = newParents
        result
      )
      _.flatten(listofUN)

    flattenGroupsWithAccounts: (groupList) ->
      listGA = _.map(groupList, (groupItem) ->
        if groupItem.accounts.length > 0
          addThisGroup = {}
          addThisGroup.open = false
          addThisGroup.groupName = groupItem.name
          addThisGroup.groupUniqueName = groupItem.uniqueName
          addThisGroup.accountDetails = groupItem.accounts
          addThisGroup
        else
          #do nothing
      )
      _.without(_.flatten(listGA), undefined)

    flattenAccount: (list) ->
      listofUN = _.map(list, (listItem) ->
        if listItem.groups.length > 0
          uniqueList = groupService.flattenAccount(listItem.groups)
          _.each(listItem.accounts, (accntItem) ->
            if _.isUndefined(accntItem.parentGroups)
              accntItem.parentGroups = [{name: listItem.name, uniqueName: listItem.uniqueName, role: listItem.role}]
            else
              accntItem.parentGroups.push({name: listItem.name, uniqueName: listItem.uniqueName, role: listItem.role})
          )
          uniqueList.push(listItem.accounts)
          _.each(uniqueList, (accntItem) ->
            if _.isUndefined(accntItem.parentGroups)
              accntItem.parentGroups = [{name: listItem.name, uniqueName: listItem.uniqueName, role: listItem.role}]
            else
              accntItem.parentGroups.push({name: listItem.name, uniqueName: listItem.uniqueName, role: listItem.role})
          )
          uniqueList
        else
          _.each(listItem.accounts, (accntItem) ->
            if _.isUndefined(accntItem.parentGroups)
              accntItem.parentGroups = [{name: listItem.name, uniqueName: listItem.uniqueName, role: listItem.role}]
            else
              accntItem.parentGroups.push({name: listItem.name, uniqueName: listItem.uniqueName, role: listItem.role})
          )
          listItem.accounts
      )
      _.flatten(listofUN)

  groupService