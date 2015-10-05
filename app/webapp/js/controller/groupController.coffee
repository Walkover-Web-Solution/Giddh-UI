'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr) ->
  $scope.groupList = {}
  $scope.selectedGroup = {}

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

  $scope.updateGroup = (groupD) ->
    console.log $rootScope.selectedCompany.uniqueName
    console.log $scope.selectedGroup
    groupService.update($rootScope.selectedCompany.uniqueName, $scope.selectedGroup).then(updateGroupSuccess,
        updateGroupFailure)

  updateGroupSuccess = (result) ->
    console.log result, "in group success"

  updateGroupFailure = (result) ->
    console.log result, "in group failure"

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController