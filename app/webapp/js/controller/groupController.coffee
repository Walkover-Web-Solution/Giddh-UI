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
    groupService.update(localStorageService.selectedCompany.uniqueName, $scope.selectedGroup,updateSuccess)

  updateSuccess = (result) ->
    console.log result

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController