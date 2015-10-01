'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr) ->
  $scope.companyBasicInfo = {}
  $scope.groupList = {}

  $scope.getGroups = ->
    lsKeys = localStorageService.keys()
    if _.contains(lsKeys, "_selectedCompany")
      $scope.companyBasicInfo = localStorageService.get("_selectedCompany")
      console.log $scope.companyBasicInfo
      $scope.groupList = groupService.getAllFor($scope.companyBasicInfo.uniqueName)
    else
      toastr.error("Select company first.", "Error")

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController