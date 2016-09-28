"use strict"

liveaccount = angular.module('liveaccountsModule', [])

liveaccountsController = ($rootScope, $scope, $uibModal, userServices, localStorageService, toastr) ->
  $scope.unq = 1
  $scope.showThis = []
  $scope.dataAvailable = false
  $scope.errorMessage = ""

  $scope.getLiveData = () ->
    $scope.showThis = []
    $scope.dataAvailable = false
    $scope.errorMessage = ""
    if _.isUndefined($rootScope.selectedCompany)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    userServices.getAccounts(companyUniqueName).then($scope.getLiveAccountsSuccess, $scope.getLiveAccountsFailure)

  $scope.getLiveAccountsSuccess = (res) ->
    $scope.showThis = res.body
    if $scope.showThis.length <= 0
      $scope.dataAvailable = false
      $scope.errorMessage = "No data available"
    else
      $scope.dataAvailable = true
      $scope.errorMessage = ""

  $scope.getLiveAccountsFailure = (res) ->
    $scope.dataAvailable = false
    $scope.errorMessage = res.data.message

  $scope.reconnectBank = (account) ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      loginId: account.loginId
    }
    userServices.reconnectAccount(reqParam).then($scope.reconnectAccountSuccess,$scope.reconnectAccountFailure)

  $scope.reconnectAccountSuccess= (res) ->
    url = res.body.connectUrl
    $scope.connectUrl = url
    modalInstance = $uibModal.open(
      templateUrl: '/public/webapp/Globals/modals/refreshBankAccountsModal.html',
      size: "md",
      backdrop: 'static',
      scope: $scope
    )
    modalInstance.result.then ((selectedItem) ->
      $scope.refreshAccounts()
      return
    ), ->
      $scope.refreshAccounts()
      return

  $scope.reconnectAccountFailure = (res) ->
    toastr.error(res.data.message, "Error")

  $scope.refreshAccounts = () ->
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
      refresh: true
    }
    userServices.refreshAll(companyUniqueName).then($scope.getLiveAccountsSuccess, $scope.getLiveAccountsFailure)

  $scope.refreshBank = (account) ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      loginId: account.loginId
    }
    userServices.refreshAccount(reqParam).then($scope.refreshBankSuccess, $scope.refreshBankFailure )

  $scope.refreshBankSuccess = (res) ->
    url = res.body.connectUrl
    $scope.connectUrl = url
    $uibModal.open(
      templateUrl: '/public/webapp/Globals/modals/refreshBankAccountsModal.html',
      size: "md",
      backdrop: 'static',
      scope: $scope
    )

  $scope.refreshBankFailure = (res) ->
    toastr.error(res.data.message, "Error")

  $scope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE' || changeData.type == 'SELECT'
      $scope.getLiveData()


liveaccount.controller('liveaccountsController',liveaccountsController)

.directive 'liveAccount', [($locationProvider,$rootScope) -> {
  restrict: 'E'
  templateUrl: 'https://giddh-fs8eefokm8yjj.stackpathdns.com/public/webapp/Dashboard/Liveaccounts/liveaccounts.html'
#  controller: 'liveaccountsController'
}]