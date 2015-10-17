"use strict"

onlyAccountController = ($scope, $rootScope, localStorageService, toastr, groupService) ->
  $scope.groupList = {}
  $scope.flattenGroupList = {}
  $scope.flattenAccountListWithParent = {}

  $scope.getGroups = ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllWithAccountsFor($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess,
          $scope.getGroupListFailure)

  $scope.getGroupListSuccess = (result) ->
    $scope.groupList = result.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList)
    $scope.flatAccntList = groupService.flattenGroupsWithAccounts($scope.groupList)
    console.log "groups With Accounts", $scope.flatAccntList
    $scope.showListGroupsNow = true


  $scope.getGroupListFailure = () ->
    toastr.error("Unable to get group details.", "Error")

#init angular app
angular.module('giddhWebApp').controller 'onlyAccountController', onlyAccountController
