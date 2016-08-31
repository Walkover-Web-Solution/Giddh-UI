"use strict"

dashboard = angular.module('dashboard', [
  "networthModule"
  "liveaccountsModule"
  "piechartModule"
  "historicalModule"
  "compareModule"
])

dashboardController = ($scope, $rootScope) ->
  $rootScope.cmpViewShow = true

  $rootScope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE'
      $state.reload()

#dashboard.controller 'dashboardController',dashboardController
