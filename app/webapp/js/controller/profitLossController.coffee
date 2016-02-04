"use strict"

profitLossController = ($scope, $rootScope, companyServices, localStorageService, $filter, toastr, $timeout) ->
  pl = this
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  $scope.sendRequest = true
  $scope.today = $filter('date')(new Date(),'dd-MM-yyyy')
  $scope.noData = false
  $scope.incomeTotal = 0
  $scope.expenseTotal = 0


  $scope.getPl = (data) ->
    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'toDate': ''
      'fromDate':''
    }
    companyServices.getPL(reqParam).then $scope.getPlSuccess, $scope.getPlFailure

  $scope.getPlSuccess = (res) ->
    if _.isEmpty(res.body.expenseGroups)
      $scope.expenseTotal = 0
    else
      $scope.expenseTotal = $scope.calCulateTotal(res.body.expenseGroups)

    if _.isEmpty(res.body.incomeGroups)
      $scope.incomeTotal = 0
    else
      $scope.incomeTotal = $scope.calCulateTotal(res.body.incomeGroups)
    $scope.data = res.body
    $rootScope.showLedgerBox = true
    if $scope.data.closingBalance is 0
      $scope.noData = true

  $scope.getPlFailure = (res) ->
     toastr.error(res.data.message, res.data.status)

  $scope.calCulateTotal = (data) ->
    eTtl = 0
    _.each(data, (item) ->
      eTtl += Number(item.closingBalance)
    )
    return (eTtl).toFixed(2)


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