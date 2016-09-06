"use strict"

dashboard = angular.module('dashboard', [
  "networthModule"
  "liveaccountsModule"
  "piechartModule"
  "historicalModule"
  "compareModule"
  "revenuechartModule"
  "profitlossModule"
])

dashboardController = ($scope, $rootScope) ->
  $rootScope.cmpViewShow = true

  $scope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE'
      $scope.$broadcast('reloadAll')

#dashboard.controller 'dashboardController',dashboardController
