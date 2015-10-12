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
    _.each($scope.groupList, (groupItem) ->
      groupItem.isFixed = true
    )
    $scope.flattenGroupList = $scope.FlattenGroupList($scope.groupList)
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

  $scope.updateGroup = ->
    $scope.selectedGroup.uniqueName = $scope.selectedGroup.uniqueName.toLowerCase()
    groupService.update($rootScope.selectedCompany.uniqueName, $scope.selectedGroup).then(onUpdateGroupSuccess,
        onUpdateGroupFailure)

  onUpdateGroupSuccess = (result) ->
    $scope.selectedGroup.oldUName = $scope.selectedGroup.uniqueName
    toastr.success("Group has been updated successfully.", "Success")

  onUpdateGroupFailure = (result) ->
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

  $scope.shareGroup = () ->
    body = {
      "user": "xyz1",
      "role": "edit"
    }
    groupService.share($rootScope.selectedCompany.uniqueName, $scope.selectedGroup.uniqueName,
        body).then(onShareGroupSuccess, onShareGroupFailure)

  onShareGroupSuccess = (result) ->
    toastr.success("Group shared successfully.", "Success")
    $scope.selectedGroup = {}
    $scope.showGroupDetails = false
    $scope.getGroups()

  onShareGroupFailure = (result) ->
    toastr.error("Unable to share group.", "Error")

  $scope.moveGroup = (group) ->
    if $scope.selectedGroup.isFixed
      toastr.error("You can not move permanent groups.","Error")
      return

    console.log group
    body = {
      "parentGroupUniqueName": group.uniqueName
    }
    groupService.move($rootScope.selectedCompany.uniqueName, $scope.selectedGroup.uniqueName,
        body).then(onMoveGroupSuccess, onMoveGroupFailure)

  onMoveGroupSuccess = (result) ->
    toastr.success("Group moved successfully.", "Success")
    $scope.selectedGroup = {}
    $scope.showGroupDetails = false
    $scope.moveto = undefined
    $scope.getGroups()

  onMoveGroupFailure = (result) ->
    toastr.error("Unable to move group.", "Error")


#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController