"use strict"
networthController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService) ->
  $scope.series = ['Net worth']
  $scope.chartData = [
    [1424785, 1425744, 1425874, 1425985, 1435200, 1432999, 1437010]
  ]
  $scope.labels = ["January", "February", "March", "April", "May", "June", "July"]
  $scope.chartOptions = {
    datasetFill:true
  }

  $scope.getNetWorthData = () ->
#    get net worth data here


angular.module('networthControllers', [])
.controller('networthController', networthController)