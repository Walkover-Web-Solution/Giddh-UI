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
      groupService.getAllFor($scope.companyBasicInfo.uniqueName).then(
        (result) ->
          $scope.groupList = result.body
        (result) ->
          console.log result, "in error"
      )
    else
      toastr.error("Select company first.", "Error")

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController