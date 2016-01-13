"use strict"

accountController = ($scope, $rootScope, localStorageService, toastr, groupService, modalService, accountService, ledgerService, $filter, DAServices, $location, $timeout) ->
  $scope.groupList = {}
  $scope.flattenGroupList = {}
  $scope.flattenAccountListWithParent = {}
  $scope.flatAccntWGroupsList = {}
  $scope.showAccountList = false
  $scope.selectedAccountUniqueName = undefined

  $scope.getAccountsGroups = ()->
    $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    $scope.showAccountList = false
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllWithAccountsFor($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess,
        $scope.getGroupListFailure)

  $scope.getGroupListSuccess = (res) ->
    $scope.groupList = res.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList, [])
    $scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($scope.flattenGroupList)
    $scope.showAccountList = true
    $rootScope.makeAccountFlatten(groupService.flattenAccount($scope.groupList))
    $scope.highlightAcMenu()

  $scope.getGroupListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.showManageGroups = () ->
    modalService.openManageGroupsModal()

  $scope.setLedgerData = (data, acData) ->
    $scope.selectedAccountUniqueName = acData.uniqueName
    DAServices.LedgerSet(data, acData)
    localStorageService.set("_ledgerData", data)
    localStorageService.set("_selectedAccount", acData)

  $scope.highlightAcMenu = () ->
    url = $location.path().split("/")
    if url[1] is "ledger"
      $timeout ->
        acEle = document.getElementById("ac_" + url[2])
        if acEle is null
          return false
        parentSib = acEle.parentElement.previousElementSibling
        angular.element(parentSib).trigger('click')
        angular.element(acEle).children().trigger('click')
      , 500

  #Expand or  Collapse all account menus
  $scope.toggleAcMenus = (state) ->
    $scope.flatAccntWGroupsList.forEach (e) ->
      e.open = state
      $scope.showSubMenus = state

  # trigger expand or collapse func
  $scope.checkLength = (val)->
    if val is '' || _.isUndefined(val)
      return false
    else if val.length >= 4
      $scope.toggleAcMenus(true)
    else
      $scope.toggleAcMenus(false)

  $scope.$on '$reloadAccount', ->
    $scope.getAccountsGroups()


#init angular app
giddh.webApp.controller 'accountController', accountController
