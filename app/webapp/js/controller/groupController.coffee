'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr) ->
  $scope.companyBasicInfo = {}
  $scope.groupList = {}
  $scope.selectedGroup = {}

  $scope.showGroupDetails = false

  $scope.getGroups = ->
    lsKeys = localStorageService.keys()
    if _.contains(lsKeys, "_selectedCompany")
      $scope.companyBasicInfo = localStorageService.get("_selectedCompany")
      groupService.getAllFor($scope.companyBasicInfo.uniqueName).then($scope.getGroupListSuccess,
          $scope.getGroupListFailure)
    else
      toastr.error("Select company first.", "Error")

  $scope.getGroupListSuccess = (result) ->
    $scope.groupList = result.body

  $scope.getGroupListFailure = (result) ->
    toastr.error("Unable to get group details.", "Error")

  $scope.selectGroupToEdit = (group) ->
    $scope.selectedGroup = group
    $scope.showGroupDetails = true

  $scope.updateGroup = (groupD) ->
    console.log $scope.companyBasicInfo.uniqueName
    console.log groupD
    #groupService.update(localStorageService.companyBasicInfo.uniqueName,$scope.selectedGroup)

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController