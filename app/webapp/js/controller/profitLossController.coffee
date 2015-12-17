"use strict"

profitLossController = ($scope, $rootScope, companyServices, localStorageService, $filter, toastr, $timeout, $window) ->
  pl = this
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  $scope.sendRequest = true
  $scope.today = $filter('date')(new Date(),'dd-MM-yyyy')
  $scope.year = moment().get('year')
  $scope.month = moment().get('month')
  $scope.date = moment().get('date')

  $scope.getPl = (data) ->
    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'toDate': $scope.today
      'fromDate':''
    }
    companyServices.getPL(reqParam).then $scope.getPlSuccess, $scope.getPlFailure

  $scope.getPlSuccess = (res) ->
    $scope.data = res.body
    console.log $scope.data

  $scope.getPlFailure = (res) ->
     console.log res

     
     


  
  $scope.$on '$viewContentLoaded', ->
    if $scope.sendRequest
      reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'toDate': $scope.today
      'fromDate': ''
      }
      $scope.getPl(reqParam) 
      $scope.sendRequest = false



angular.module('giddhWebApp').controller 'profitLossController', profitLossController