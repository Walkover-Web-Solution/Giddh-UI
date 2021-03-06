'use strict'

giddh.serviceModule.service 'groupService', ($resource, $q) ->
  Group = $resource('company/:companyUniqueName/groups',
    {
      'companyUniqueName': @companyUniqueName
      'groupUniqueName': @groupUniqueName
      'date1': @date1
      'date2': @date2
      'q':@q
      'page':@page
      'count':@count
      'refressh':@refresh
      'showEmptyGroups':@showEmptyGroups
    },
    {
      add: {
        method: 'POST'
      }
      getAll: {
        method: 'GET'
      }
      getAllWithAccounts: {
        method: 'GET',
        url: '/company/:companyUniqueName/groups/with-accounts'
      }
      getAllInDetail: {
        method: 'GET'
        url: '/company/:companyUniqueName/groups/detailed-groups'
      }
      getAllWithAccountsInDetail: {
        method: 'GET',
        url: '/company/:companyUniqueName/groups/detailed-groups-with-accounts'
      }
      getFlattenGrpWithAcc: {
        method: 'GET'
        url: '/company/:companyUniqueName/groups/flatten-groups-accounts?q=:q&page=:page&count=:count&showEmptyGroups=:showEmptyGroups'
      }
      getFlatAccList: {
        method: 'GET'
        url: '/company/:companyUniqueName/groups/flatten-accounts'
      }
      postFlatAccList:{
        method: 'POST'
        url: '/company/:companyUniqueName/groups/flatten-accounts'
      }
      update: {
        method: 'PUT'
        url: '/company/:companyUniqueName/groups/:groupUniqueName'
      }
      delete: {
        method: 'DELETE'
        url: '/company/:companyUniqueName/groups/:groupUniqueName'
      }
      get: {
        method: 'GET'
        url: '/company/:companyUniqueName/groups/:groupUniqueName'
      }
      move: {
        method: 'PUT'
        url: '/company/:companyUniqueName/groups/:groupUniqueName/move'
      }
      share: {
        method: 'PUT'
        url: '/company/:companyUniqueName/groups/:groupUniqueName/share'
      }
      unshare: {
        method: 'PUT'
        url: '/company/:companyUniqueName/groups/:groupUniqueName/unshare'
      }
      sharedWith: {
        method: 'GET'
        url: '/company/:companyUniqueName/groups/:groupUniqueName/shared-with'
      }
      getUserList: {
        method: 'GET'
        url: '/company/:companyUniqueName/users'
      }
      getClosingBal: {
        method: 'GET'
        url: '/company/:companyUniqueName/groups/:groupUniqueName/closing-balance?fromDate=:date1&toDate=:date2&refresh=:refresh'
      }
      deleteLogs: {
        method: 'DELETE'
        url: '/company/:companyUniqueName/logs/:beforeDate'
      }
      getSubgroups: {
        method: 'GET'
        url: '/company/:companyUniqueName/groups/:groupUniqueName/subgroups-with-accounts'
      }
      getMultipleSubGroups:{
        method:'POST'
        url: '/company/:companyUniqueName/subgroups-with-accounts'
      }
      getTaxHierarchy:{
        method:'GET'
        url:'/company/:companyUniqueName/groups/:groupUniqueName/tax-hierarchy'
      }
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

#   All groups with full detail, without account
    getGroupsWithoutAccountsInDetail: (companyUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAllInDetail({companyUniqueName: companyUniqueName}, onSuccess,
        onFailure))

#   All groups with full detail, with account
    getGroupsWithAccountsInDetail: (companyUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAllWithAccountsInDetail({companyUniqueName: companyUniqueName},
        onSuccess, onFailure))

#   All groups with less detail, without account
    getGroupsWithoutAccountsCropped: (companyUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAll({companyUniqueName: companyUniqueName}, onSuccess,
        onFailure))

#   All groups with less detail, with account
    getGroupsWithAccountsCropped: (companyUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAllWithAccounts({companyUniqueName: companyUniqueName},
        onSuccess, onFailure))

#   search groups with accounts
    searchGroupsWithAccountsCropped:(reqParam, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getAllWithAccounts({companyUniqueName: reqParam.companyUniqueName, q:reqParam.query},
        onSuccess, onFailure))

#   Get flatten groups with accounts list
    getFlattenGroupAccList: (reqParam, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getFlattenGrpWithAcc({companyUniqueName: reqParam.companyUniqueName, q:reqParam.q, page:reqParam.page, count:reqParam.count, showEmptyGroups:reqParam.showEmptyGroups},
        onSuccess, onFailure))

#   Get sub goups with accounts
    getSubgroupsWithAccounts: (reqParam, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getSubgroups({
            companyUniqueName: reqParam.companyUniqueName,
            groupUniqueName:reqParam.groupUniqueName
          },onSuccess, onFailure))

    getMultipleSubGroups:(reqParam,data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getMultipleSubGroups({
        companyUniqueName: reqParam.companyUniqueName
      },data,onSuccess, onFailure))

#   Get flat accounts list
    getFlatAccList: (reqParam, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.getFlatAccList({companyUniqueName: reqParam.companyUniqueName, q:reqParam.q, page:reqParam.page, count:reqParam.count},
        onSuccess, onFailure))

    postFlatAccList: (reqParam, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.postFlatAccList({
            companyUniqueName: reqParam.companyUniqueName,
            q:reqParam.q,
            page:reqParam.page,
            count:reqParam.count
          },data, onSuccess, onFailure))

    update: (companyUniqueName, group) ->
      @handlePromise((onSuccess, onFailure) -> Group.update({
        companyUniqueName: companyUniqueName,
        groupUniqueName: group.oldUName
      }, group, onSuccess, onFailure))

    get: (companyUniqueName, groupUniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Group.get({
        companyUniqueName: companyUniqueName,
        groupUniqueName: groupUniqueName
      }, onSuccess, onFailure))

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

    getClosingBal: (obj) ->
      @handlePromise((onSuccess, onFailure) -> Group.getClosingBal({
        companyUniqueName: obj.compUname
        groupUniqueName: obj.selGrpUname
        date1: obj.fromDate
        date2: obj.toDate
        refresh: obj.refresh
      }, onSuccess, onFailure))

    matchAndReturnObj: (src, dest)->
      _.find(dest, (key)->
        return key.uniqueName is src.groupUniqueName
      )

    matchAndReturnGroupObj: (src, dest)->
      _.find(dest, (key)->
        return key.uniqueName is src.uniqueName
      )

    makeGroupListFlatwithLessDtl: (rawList) ->
      obj = _.map(rawList, (item) ->
        obj = {}
        obj.name = item.name
        obj.uniqueName = item.uniqueName
        obj.synonyms = item.synonyms
        obj.parentGroups = item.parentGroups
        obj
      )
      return obj

    makeAcListWithLessDtl: (rawList) ->
      obj = _.map(rawList, (item) ->
        obj = {}
        obj.name = item.name
        obj.uniqueName = item.uniqueName
        obj.mergedAccounts = item.mergedAccounts
        obj.parentGroups = item.parentGroups
        obj
      )
      return obj

    flattenGroup: (rawList, parents) ->
      listofUN = _.map(rawList, (listItem) ->
        newParents = _.union([], parents)
        newParents.push({name: listItem.name, uniqueName: listItem.uniqueName})
        listItem.parentGroups = newParents
        if listItem.groups.length > 0
          result = groupService.flattenGroup(listItem.groups, newParents)
          result.push(_.omit(listItem, "groups"))
        else
          result = _.omit(listItem, "groups")
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
          addThisGroup.beforeFilter = groupItem.accounts
          addThisGroup.groupSynonyms = groupItem.synonyms
          addThisGroup
      )
      _.without(_.flatten(listGA), undefined)

    flattenGroupsAndAccounts: (groupList) ->
      listGA = _.map(groupList, (groupItem) ->
        addThisGroup = {}
        addThisGroup.open = false
        addThisGroup.groupName = groupItem.name
        addThisGroup.groupUniqueName = groupItem.uniqueName
        addThisGroup.accountDetails = groupItem.accounts
        addThisGroup.beforeFilter = groupItem.accounts
        addThisGroup.groupSynonyms = groupItem.synonyms
        addThisGroup
      )
      _.without(_.flatten(listGA), undefined)

    flattenAccount: (list) ->
      listofUN = _.map(list, (listItem) ->
        if listItem.groups.length > 0
          uniqueList = groupService.flattenAccount(listItem.groups)
          _.each(listItem.accounts, (accntItem) ->
            if _.isUndefined(accntItem.parentGroups)
              accntItem.parentGroups = [{name: listItem.name, uniqueName: listItem.uniqueName}]
            else
              accntItem.parentGroups.push({name: listItem.name, uniqueName: listItem.uniqueName})
          )
          uniqueList.push(listItem.accounts)
          _.each(uniqueList, (accntItem) ->
            if _.isUndefined(accntItem.parentGroups)
              accntItem.parentGroups = [{name: listItem.name, uniqueName: listItem.uniqueName}]
            else
              accntItem.parentGroups.push({name: listItem.name, uniqueName: listItem.uniqueName})
          )
          uniqueList
        else
          _.each(listItem.accounts, (accntItem) ->
            if _.isUndefined(accntItem.parentGroups)
              accntItem.parentGroups = [{name: listItem.name, uniqueName: listItem.uniqueName}]
            else
              accntItem.parentGroups.push({name: listItem.name, uniqueName: listItem.uniqueName})
          )
          listItem.accounts
      )
      _.flatten(listofUN)


    flattenSearchGroupsAndAccounts: (rawList) ->
      listofUN = _.map(rawList, (obj) ->
        if not(_.isNull(obj.childGroups)) and obj.childGroups.length > 0
          uniqueList = groupService.flattenSearchGroupsAndAccounts(obj.childGroups)
          _.each(obj.accounts, (account)->
            account.parent = obj.groupName
            account.closeBalType = account.closingBalance.type
            account.closingBalance = account.closingBalance.amount
            account.openBalType = account.openingBalance.type
            account.openingBalance = account.openingBalance.amount
          )
          uniqueList.push(obj.accounts)
          uniqueList
        else
          _.each(obj.accounts, (account)->
            account.parent = obj.groupName
            account.closeBalType = account.closingBalance.type
            account.closingBalance = account.closingBalance.amount
            account.openBalType = account.openingBalance.type
            account.openingBalance = account.openingBalance.amount
          )
          obj.accounts
      )
      _.flatten(listofUN)

    getUserList: (unqNamesObj) ->
      @handlePromise((onSuccess, onFailure) -> Group.getUserList({
        companyUniqueName: unqNamesObj.compUname
      }, onSuccess, onFailure))

    deleteLogs: (reqParam, onSuccess, onFailure) ->
      console.log(reqParam)
      @handlePromise((onSuccess, onFailure) -> Group.deleteLogs({
        companyUniqueName: reqParam.companyUniqueName,
        beforeDate: reqParam.beforeDate
      }, onSuccess, onFailure))

    getTaxHierarchy:(companyUniqueName, groupUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Group.getTaxHierarchy({
        companyUniqueName: companyUniqueName,
        groupUniqueName: groupUniqueName
      }, onSuccess, onFailure))

  groupService