"use strict"

accountController = ($scope, $rootScope, localStorageService, toastr, groupService, modalService) ->
  $scope.groupList = {}
  $scope.flattenGroupList = {}
  $scope.flattenAccountListWithParent = {}
  $scope.flatAccntWGroupsList = {}
  $scope.showAccountList = false
  $scope.selectedCompany = {}

  $scope.getAccountsGroups = ->
    $scope.selectedCompany = localStorageService.get("_selectedCompany")
    $scope.showAccountList = false
    if _.isEmpty($scope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllWithAccountsFor($scope.selectedCompany.uniqueName).then($scope.getGroupListSuccess,
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

  $rootScope.$on '$reloadAccount', ->
    $scope.getAccountsGroups()

  $rootScope.$on '$viewContentLoaded', ->
    $scope.getAccountsGroups()

#init angular app
angular.module('giddhWebApp').controller 'accountController', accountController
