"use strict"

profitLossController = ($scope, $rootScope, companyServices, localStorageService, $filter, toastr, $timeout) ->
  pl = this
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  $scope.sendRequest = true
  $scope.today = $filter('date')(new Date(),'dd-MM-yyyy')
  $scope.year = moment().get('year')
  $scope.month = moment().get('month')
  $scope.date = moment().get('date')
  $scope.noData = false


  $scope.getPl = (data) ->
    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'toDate': $scope.today
      'fromDate':''
    }
    companyServices.getPL(reqParam).then $scope.getPlSuccess, $scope.getPlFailure

  $scope.getPlSuccess = (res) ->
    $scope.data = res.body
    $rootScope.showLedgerBox = true
    if $scope.data.closingBalance is 0
      $scope.noData = true
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



giddh.webApp.controller 'profitLossController', profitLossController