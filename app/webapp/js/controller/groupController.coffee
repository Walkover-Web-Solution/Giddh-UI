'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr, $confirm) ->
  $scope.groupList = {}
  $scope.flattenGroupList = {}
  $scope.moveto = undefined
  $scope.selectedGroup = {}
  $scope.selectedSubGroup = {}
  $scope.selectedGroupUName = ""

  $scope.showGroupDetails = false
  $scope.subGroupVisible = false
  $scope.showListGroupsNow = false
  $scope.showAccountDetails = false
  $scope.showAccountListDetails = false

  #set a object for share group
  $scope.shareGroupObj = {
    role: "view_only"
    user: ""
  }

  # expand and collapse all tree structure
  getRootNodesScope = ->
    angular.element(document.getElementById('tree-root')).scope()

  $scope.collapseAll = ->
    scope = getRootNodesScope()
    scope.collapseAll()
    $scope.subGroupVisible = true

  $scope.expandAll = ->
    scope = getRootNodesScope()
    scope.expandAll()
    $scope.subGroupVisible = false

  $scope.getGroups = ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllWithAccountsFor($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess,
          $scope.getGroupListFailure)

  $scope.getGroupListSuccess = (result) ->
    $scope.groupList = result.body
    $scope.flattenGroupList = $scope.FlattenGroupList($scope.groupList)
    $scope.flatAccntList = $scope.FlattenAccountList($scope.groupList)
    $scope.showListGroupsNow = true

    

  $scope.getGroupListFailure = () ->
    toastr.error("Unable to get group details.", "Error")

  $scope.selectGroupToEdit = (group) ->
    $scope.selectedGroup = group
    if _.isEmpty($scope.selectedGroup.oldUName)
      $scope.selectedGroup.oldUName = $scope.selectedGroup.uniqueName
    else
      console.log "inside else condition"

    $scope.selectedSubGroup = {}
    
    $scope.showGroupDetails = true
    $scope.showAccountListDetails = true
    $scope.showAccountDetails = false

    $scope.getGroupSharedList(group)
    $scope.groupAccntList = group.accounts
    $scope.accountsSearch = undefined

  $scope.getGroupSharedList = (group) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
    }
    groupService.sharedList(unqNamesObj).then($scope.onsharedListSuccess, $scope.onsharedListFailure)
  
  $scope.onsharedListSuccess = (result) ->
    $scope.groupSharedUserList = result.body

  $scope.onsharedListFailure = (result) ->
    console.log result, "onsharedListFailure"

  
  #share group with user
  $scope.shareGroup = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
    }
    groupService.share(unqNamesObj, $scope.shareGroupObj).then($scope.onShareGroupSuccess, $scope.onShareGroupFailure)

  $scope.onShareGroupSuccess = (response) ->
    $scope.shareGroupObj = {
      role: "view_only"
      user: ""
    }
    toastr.success(response.body, response.status)
    $scope.getGroupSharedList($scope.selectedGroup)
    
  $scope.onShareGroupFailure = (response) ->
    toastr.error(response.data.message, response.data.status)

  #unShare group with user
  $scope.unShareGroup = (user) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
    }
    data = {
      user: user
    }
    groupService.unshare(unqNamesObj, data).then($scope.unShareGroupSuccess, $scope.unShareGroupFailure)
  
  $scope.unShareGroupSuccess = (response)->
    toastr.success(response.body, response.status)
    $scope.getGroupSharedList($scope.selectedGroup)

  $scope.unShareGroupFailure = (response)->
    toastr.error(response.data.message, response.data.status)

  $scope.updateGroup = ->
    $scope.selectedGroup.uniqueName = $scope.selectedGroup.uniqueName.toLowerCase()
    groupService.update($scope.selectedCompany.uniqueName, $scope.selectedGroup).then($scope.onUpdateGroupSuccess, $scope.onUpdateGroupFailure)

  $scope.onUpdateGroupSuccess = (result) ->
    $scope.selectedGroup.oldUName = $scope.selectedGroup.uniqueName
    toastr.success("Group has been updated successfully.", "Success")

  $scope.onUpdateGroupFailure = (result) ->
    toastr.error("Unable to update group at the moment. Please try again later.", "Error")

  $scope.getUniqueNameFromGroupList = (list) ->
    listofUN = _.map(list, (listItem) ->
      if listItem.groups.length > 0
        uniqueList = $scope.getUniqueNameFromGroupList(listItem.groups)
        uniqueList.push(listItem.uniqueName)
        uniqueList
      else
        listItem.uniqueName
    )
    _.flatten(listofUN)

  $scope.FlattenGroupList = (list) ->
    listofUN = _.map(list, (listItem) ->
      if listItem.groups.length > 0
        uniqueList = $scope.FlattenGroupList(listItem.groups)
        uniqueList.push(listItem)
        uniqueList
      else
        listItem
    )
    _.flatten(listofUN)

  $scope.addNewSubGroup = ->
    uNameList = $scope.getUniqueNameFromGroupList($scope.groupList)
    UNameExist = _.contains(uNameList, $scope.selectedSubGroup.uniqueName)
    if UNameExist
      toastr.error("Unique name is already in use.", "Error")
      return

    if _.isEmpty($scope.selectedSubGroup.name)
      return

    body = {
      "name": $scope.selectedSubGroup.name,
      "uniqueName": $scope.selectedSubGroup.uniqueName.toLowerCase(),
      "parentGroupUniqueName": $scope.selectedGroup.uniqueName,
      "description": $scope.selectedSubGroup.desc
    }
    groupService.create($rootScope.selectedCompany.uniqueName, body).then(onCreateGroupSuccess, onCreateGroupFailure)

  onCreateGroupSuccess = (result) ->
    toastr.success("Sub group added successfully", "Success")
    $scope.selectedSubGroup = {}
    $scope.getGroups()

  onCreateGroupFailure = (result) ->
    toastr.error("Unable to create subgroup.", "Error")

  $scope.deleteGroup = ->
    if not $scope.selectedGroup.isFixed
      $confirm.openModal(
        title: 'Are you sure you want to delete this group? All child groups will also be deleted. ',
        ok: 'Yes',
        cancel: 'No').then -> groupService.delete($rootScope.selectedCompany.uniqueName,
          $scope.selectedGroup).then(onDeleteGroupSuccess,
          onDeleteGroupFailure)


  onDeleteGroupSuccess = (result) ->
    toastr.success("Group deleted successfully.", "Success")
    $scope.selectedGroup = {}
    $scope.showGroupDetails = false
    $scope.getGroups()

  onDeleteGroupFailure = (result) ->
    toastr.error("Unable to delete group.", "Error")

  

  $scope.moveGroup = (group) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
    }
    body = {
      "parentGroupUniqueName": group.uniqueName
    }
    groupService.move(unqNamesObj, body).then($scope.onMoveGroupSuccess, $scope.onMoveGroupFailure)

  $scope.onMoveGroupSuccess = (result) ->
    toastr.success("Group moved successfully.", "Success")
    $scope.getGroups()
    $scope.selectedGroup = {}
    $scope.showGroupDetails = false
    $scope.moveto = undefined

  $scope.onMoveGroupFailure = (result) ->
    toastr.error("Unable to move group.", "Error")

  #select group
  $scope.selectItem = (item) ->
    $scope.selectedItem = item

  #account code
  $scope.FlattenAccountList = (list) ->
    listofUN = _.map(list, (listItem) ->
      if listItem.groups.length > 0
        uniqueList = $scope.FlattenAccountList(listItem.groups)
        _.each(listItem.accounts, (accntItem) ->
          if _.isUndefined(accntItem.pName)
            accntItem.pName = [listItem.name]
            accntItem.pUnqName = [listItem.uniqueName]
          else 
            accntItem.pName.push(listItem.name) 
            accntItem.pUnqName.push(listItem.uniqueName)
        )
        uniqueList.push(listItem.accounts)
        _.each(uniqueList, (accntItem) ->
          if _.isUndefined(accntItem.pName)
            accntItem.pName = [listItem.name]
            accntItem.pUnqName = [listItem.uniqueName]
          else 
            accntItem.pName.push(listItem.name) 
            accntItem.pUnqName.push(listItem.uniqueName)
        )
        uniqueList
      else
        _.each(listItem.accounts, (accntItem) ->
            if _.isUndefined(accntItem.pName)
              accntItem.pName = [listItem.name]
              accntItem.pUnqName = [listItem.uniqueName]
            else 
              accntItem.pName.push(listItem.name) 
              accntItem.pUnqName.push(listItem.uniqueName)
          )
        listItem.accounts
    )
    _.flatten(listofUN)

  #show account
  $scope.showAccount = (data) ->
    console.log data, "showAccount"
    $scope.showGroupDetails = false
    $scope.showAccountDetails = true

    $scope.selectedAccount = data


  #check if object is empty
  $scope.isEmptyObject =(obj) ->
    return angular.equals({}, obj)

  #highlight account menus
  $scope.selectAcMenu = (item) ->
    $scope.selectedAccntMenu = item

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController