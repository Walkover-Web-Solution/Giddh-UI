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
    $scope.groupList = result.body

  $scope.getGroupListFailure = () ->
    toastr.error("Unable to get group details.", "Error")

  $scope.selectGroupToEdit = (group) ->
    $scope.selectedGroup = group
    $scope.showGroupDetails = true

  $scope.updateGroup = (groupD) ->
    console.log $rootScope.selectedCompany.uniqueName
    console.log groupD
    #groupService.update(localStorageService.selectedCompany.uniqueName,$scope.selectedGroup)

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController