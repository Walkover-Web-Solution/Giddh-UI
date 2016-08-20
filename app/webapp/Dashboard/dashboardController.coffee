"use strict"

dashboard = angular.module('dashboard', [
  "networthModule"
])

dashboardController = ($scope, $rootScope) ->
  $rootScope.cmpViewShow = true

dashboard.controller 'dashboardController',dashboardController
