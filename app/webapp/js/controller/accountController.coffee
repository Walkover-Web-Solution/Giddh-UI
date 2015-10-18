"use strict"

accountController = ($scope, $rootScope, localStorageService, toastr, groupService, modalService) ->
  $scope.groupList = {}
  $scope.flattenGroupList = {}
  $scope.flattenAccountListWithParent = {}
  $scope.flatAccntWGroupsList = {}
  $scope.showAccountList = false

  $scope.getAccountsGroups = ->
    $scope.showAccountList = false
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllWithAccountsFor($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess,
          $scope.getGroupListFailure)

  $scope.getGroupListSuccess = (result) ->
    $scope.groupList = result.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList)
    $scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($scope.flattenGroupList)
    $scope.showAccountList = true

  $scope.getGroupListFailure = () ->
    toastr.error("Unable to get group details.", "Error")

  $scope.showManageGroups = () ->
    modalService.openManageGroupsModal()

  $rootScope.$on '$viewContentLoaded', ->
    $scope.getAccountsGroups()

  $rootScope.$on '$reloadAccount', ->
    $scope.getAccountsGroups()

#init angular app
angular.module('giddhWebApp').controller 'accountController', accountController
