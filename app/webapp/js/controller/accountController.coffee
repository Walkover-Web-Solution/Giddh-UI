"use strict"

accountController = ($scope, $rootScope, localStorageService, toastr, groupService, modalService, accountService, ledgerService, $filter, DAServices) ->
  $scope.groupList = {}
  $scope.flattenGroupList = {}
  $scope.flattenAccountListWithParent = {}
  $scope.flatAccntWGroupsList = {}
  $scope.showAccountList = false
  $scope.selectedAccountUniqueName = "";

  $scope.getAccountsGroups = ->
    $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    $scope.showAccountList = false
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllWithAccountsFor($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess,
          $scope.getGroupListFailure)

  $scope.getGroupListSuccess = (result) ->
    $scope.groupList = result.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList, [])
    $scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($scope.flattenGroupList)
    $scope.showAccountList = true
    $rootScope.makeAccountFlatten(groupService.flattenAccount($scope.groupList))


  $scope.getGroupListFailure = () ->
    toastr.error("Unable to get group details.", "Error")

  $scope.showManageGroups = () ->
    modalService.openManageGroupsModal()

  $scope.setLedgerData = (data, acData) ->
    $scope.selectedAccountUniqueName = acData.uniqueName
    DAServices.LedgerSet(data, acData)

  # Collapse all account menus
  $scope.collapseAllSubMenus = () ->
    $rootScope.showSubMenus = true

  # Expand all account menus
  $scope.expandAllSubMenus = () ->
    $rootScope.showSubMenus = false


  $rootScope.$on '$reloadAccount', ->
    $scope.getAccountsGroups()

  $rootScope.$on '$viewContentLoaded', ->
    $scope.getAccountsGroups()

#init angular app
angular.module('giddhWebApp').controller 'accountController', accountController
