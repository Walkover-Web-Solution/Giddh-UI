'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService) ->
  $scope.companyBasicInfo = {}

  $scope.getGroups = ->
    console.log "we are here to get groups"
    lsKeys = localStorageService.keys()
    if _.contains(lsKeys, "_selectedCompany")
      console.log lsKeys
      $scope.companyBasicInfo = localStorageService.get("_selectedCompany")

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController