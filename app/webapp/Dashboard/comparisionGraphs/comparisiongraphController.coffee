"use strict"

compare = angular.module('compareModule', [])

comparisiongraphController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, $timeout, reportService) ->
  $scope.salesDataAvailable = true
  $scope.expenseDataAvailable = true
  $scope.chartType = "ComboChart"
  $scope.chartOptions = {
    seriesType: 'line',
    series: {1: {type: 'line'}},
    colors: ['#d35f29','#337ab7'],
    legend:{position:'none'},
    chartArea:{
      width: '100%',
      height: '100%'
    },
    curveType: 'function'
  }
  $scope.salesChartData = {
    "type": $scope.chartType,
    "data": {
      "cols": [
        {
          "id": "sMonth",
          "label": "Month",
          "type": "string",
          "p": {}
        },
        {
          "id": "currentSBalance",
          "label": "Current",
          "type": "number",
          "p": {}
        },{
          "id": "previousSBalance",
          "label": "Previous",
          "type": "number",
          "p": {}
        }]
    },
    "options": $scope.chartOptions
  }
  $scope.expenseChartData = {
    "type": $scope.chartType,
    "data": {
      "cols": [
        {
          "id": "eMonth",
          "label": "Month",
          "type": "string",
          "p": {}
        },
        {
          "id": "currentEBalance",
          "label": "Current",
          "type": "number",
          "p": {}
        },{
          "id": "previousEBalance",
          "label": "Previous",
          "type": "number",
          "p": {}
        }]
    },
    "options": $scope.chartOptions
  }

  $scope.setDateByFinancialYear = () ->
    presentYear = $scope.getPresentFinancialYear()
    if $rootScope.currentFinancialYear == presentYear
      $scope.fromDate = moment().subtract(1, 'years').add(1,'months').format('DD-MM-YYYY')
      $scope.toDate = moment().format('DD-MM-YYYY')
    else
      $scope.fromDate = $rootScope.selectedCompany.activeFinancialYear.financialYearStarts
      $scope.toDate = $rootScope.selectedCompany.activeFinancialYear.financialYearEnds

  $scope.getPresentFinancialYear = () ->
    setDate = ""
    toDate = ""
    if moment().get('months') > 4
      setDate = moment().get('YEARS')
      toDate = moment().add(1,'years').get('YEARS')
    else
      setDate = moment().subtract(1, 'years').get('YEARS')
      toDate = moment().get('YEARS')
    setDate+"-"+toDate

  $rootScope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE'
#      $scope.getHistory()
      console.log("")

compare.controller('comparisiongraphController',comparisiongraphController)

.directive 'compareGraph', () ->{
  restrict: 'E'
  templateUrl: '/public/webapp/Dashboard/comparisionGraphs/compare.html'
}