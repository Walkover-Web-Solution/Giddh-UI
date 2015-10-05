'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr) ->
  $scope.groupList = {}
  $scope.selectedGroup = {}

  $scope.showGroupDetails = false

  $scope.getGroups = ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllFor($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess,
          $scope.getGroupListFailure)

  $scope.getGroupListSuccess = (result) ->
    console.log result.body
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