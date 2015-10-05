'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr) ->
  $scope.groupList = {}
  $scope.selectedGroup = {}
  $scope.selectedSubGroup = {}

  $scope.showGroupDetails = false

  $scope.subGroupVisible = false

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

  $scope.getGroupListFailure = () ->
    toastr.error("Unable to get group details.", "Error")

  $scope.selectGroupToEdit = (group) ->
    $scope.selectedGroup = group
    $scope.showGroupDetails = true

  $scope.updateGroup = ->
    groupService.update($rootScope.selectedCompany.uniqueName, $scope.selectedGroup).then(onUpdateGroupSuccess,
        onUpdateGroupFailure)

  onUpdateGroupSuccess = (result) ->
    console.log result, "in group success"
    toastr.success("Group has been updated successfully.", "Success")

  onUpdateGroupFailure = (result) ->
    console.log result, "in group failure"
    toastr.error("Unable to update group at the moment. Please try again later.", "Error")

  $scope.addNewSubGroup = (subGroupForm) ->
    console.log $scope.selectedSubGroup
    if _.isEmpty($scope.selectedSubGroup.name)
      return
    console.log "name is not empty"
    body = {
      "name": $scope.selectedSubGroup.name,
      "uniqueName": "group",
      "parentGroupUniqueName": $scope.selectedGroup.uniqueName
    }
    groupService.create($rootScope.selectedCompany.uniqueName, body).then(onCreateGroupSuccess, onCreateGroupFailure)

  onCreateGroupSuccess = (result) ->
    console.log result, "in create group success"
    toastr.success("Sub group added successfully", "Success")
    $scope.selectedSubGroup = {}

  onCreateGroupFailure = (result) ->
    console.log result, "in create group failure"
    toastr.error("Unable to create subgroup.", "Error")

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController