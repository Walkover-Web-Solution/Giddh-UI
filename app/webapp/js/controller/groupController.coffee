'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr) ->
  $scope.companyBasicInfo = {}
  $scope.groupList = {}

  $scope.getGroups = ->
    console.log "inside get groups methods"
    lsKeys = localStorageService.keys()
    if _.contains(lsKeys, "_selectedCompany")
      $scope.companyBasicInfo = localStorageService.get("_selectedCompany")
      console.log $scope.companyBasicInfo
      groupService.getAllFor($scope.companyBasicInfo.uniqueName).then($scope.getGroupListSuccess,
          $scope.getGroupListFailure)
    else
      toastr.error("Select company first.", "Error")

  $scope.getGroupListSuccess = (result) ->
    $scope.groupList = result.body

  $scope.getGroupListFailure = (result) ->
    toastr.error("Unable to get group details.", "Error")

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController