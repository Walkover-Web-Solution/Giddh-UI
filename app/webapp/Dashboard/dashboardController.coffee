"use strict"

dashboard = angular.module('dashboard', [
  "networthModule"
  "liveaccountsModule"
  "piechartModule"
  "historicalModule"
  "compareModule"
  "revenuechartModule"
  "profitlossModule"
  "combinedModule"
])

dashboardController = ($scope, $rootScope, toastr) ->
  $rootScope.cmpViewShow = true

  $rootScope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE' || changeData.type == 'SELECT'
      $scope.$broadcast('reloadAll')

  toastr.warning("Data can be delayed by one hour")

  $scope.hardRefresh = () ->
    $scope.$broadcast('reloadAll')

dashboard.controller 'dashboardController',dashboardController
