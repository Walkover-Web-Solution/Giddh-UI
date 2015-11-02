"use strict"

accountController = ($scope, $rootScope, localStorageService, toastr, groupService, modalService, accountService, ledgerService, $filter, DAServices) ->
  $scope.groupList = {}
  $scope.flattenGroupList = {}
  $scope.flattenAccountListWithParent = {}
  $scope.flatAccntWGroupsList = {}
  $scope.showAccountList = false
  #$rootScope.selectedCompany = {}

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
    console.log "inside setLedgerData"
    DAServices.LedgerSet(data, acData)

  #highlight account menus
  # $scope.selAccnt = (item, index) ->
  #   console.log item, index, "selAccnt"
  #   $scope.selAccntMenu = item

  $rootScope.$on '$reloadAccount', ->
    $scope.getAccountsGroups()

  $rootScope.$on '$viewContentLoaded', ->
    $scope.getAccountsGroups()

#init angular app
angular.module('giddhWebApp').controller 'accountController', accountController
