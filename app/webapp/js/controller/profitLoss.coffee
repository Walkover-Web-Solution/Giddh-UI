"use strict"

profitLossController = ($scope, $rootScope, plService, localStorageService, $filter, toastr, $timeout, $window) ->
  pl = this
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  $scope.sendRequest = true

  $scope.getPl = (data) ->
    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName,
    }
    plService.getAllFor(reqParam).then $scope.getPlSuccess, $scope.getPlFailure

  $scope.getPlSuccess = (res) ->
    $scope.data = res
    console.log $scope.data

  $scope.getPlFailure = (res) ->
     console.log res

  $scope.$on '$viewContentLoaded', ->
    if $scope.sendRequest
      reqParam = {
        'companyUniqueName': $rootScope.selectedCompany.uniqueName,
      }
      $scope.getPl(reqParam) 
      $scope.sendRequest = false



angular.module('giddhWebApp').controller 'profitLossController', profitLossController