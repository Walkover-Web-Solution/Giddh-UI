"use strict"

profitloss = angular.module('profitlossModule', [])

profitlossController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService, $timeout, $state, $http, $window) ->
  $scope.monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  $scope.chartDataAvailable = false
  $scope.errorMessage = ""
  $scope.fromDate = moment().format('DD-MM-YYYY')
  $scope.toDate = moment().format('DD-MM-YYYY')
  $scope.myChartData = {
    "type": "ComboChart",
    "data": {
      "cols": [
        {
          "id": "month",
          "label": "Month",
          "type": "string",
          "p": {}
        },
        {
          "id": "monthlyBalance",
          "label": "Monthly P&L",
          "type": "number",
          "p": {}
        }]
    },
    "options": {
      seriesType: 'bars',
      series: {1: {type: 'line'}},
      colors: ['#d35f29','#337ab7'],
      legend:{position:'none'},
      chartArea:{
        width:'85%',
        right: 10
      },
      curveType: 'function',
      pointSize: 5,
      animation:{
        duration: 1000,
        easing: 'out',
      },
      hAxis:{
        slantedText:true
      },
      vAxis:{
        format: 'long',
        scaleType: 'mirrorLog'
      }
    }
  }
  $scope.getPLData = () ->
    $scope.chartDataAvailable = false
    $scope.errorMessage = ""
    if _.isUndefined($rootScope.selectedCompany)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    if $rootScope.currentFinancialYear == undefined
      $timeout ( ->
        $scope.getPLData()
      ),2000
    else
      $scope.setDateByFinancialYear()
      $scope.getprofitLossData($scope.fromDate,$scope.toDate)

  $scope.getprofitLossData = (fromDate,toDate) ->
    $scope.errorMessage = ""
    $scope.chartDataAvailable = false
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': fromDate
      'toDate': toDate
      'interval': "monthly"
    }
    $scope.getPLgraphData(reqParam)

  $scope.getPLgraphData = (reqParam) ->
    reportService.profitLossData(reqParam).then($scope.getPLSuccess, $scope.getPLFailure)

  $scope.getPLSuccess = (res) ->
    $scope.generateDataForGraph(res.body)

  $scope.getPLFailure = (res) ->
    if res.data.code == "INVALID_DATE"
      setDate = ""
      if moment().get('months') > 4
        setDate = "01-04-" + moment().get('YEARS')
      else
        setDate = "01-04-" + moment().subtract(1, 'years').get('YEARS')
      $scope.getprofitLossData(setDate,moment().format('DD-MM-YYYY'))
    else
      $scope.chartDataAvailable = false
      $scope.chartData = []
      #    toastr.error(res.data.message)
      $scope.errorMessage = res.data.message

  $scope.generateDataForGraph = (plData) ->
    $scope.myChartData.data.rows = []
    $scope.nwSeries = []
    $scope.nwChartData = []
    $scope.nwLabels = []
    monthlyBalances = []
    yearlyBalances = []
    _.each plData.periodBalances, (nw) ->
      row = {}
      row.c = []
      tooltipText = ""
      str = $scope.monthArray[moment(nw.to, 'DD-MM-YYYY').get('months')] + moment(nw.to, 'DD-MM-YYYY').get('y')
      $scope.nwLabels.push(str)
      monthlyBalances.push(nw.monthlyBalance)
      $scope.nwSeries.push('Monthly Balances')
      yearlyBalances.push(nw.yearlyBalance)
      $scope.nwSeries.push('Yearly Balances')
      row.c.push({v:str})
      row.c.push({v:nw.monthlyBalance})
#      row.c.push({v:nw.yearlyBalance})
      $scope.myChartData.data.rows.push(row)
    $scope.chartDataAvailable = true

  $scope.setDateByFinancialYear = () ->
    presentYear = $scope.getPresentFinancialYear()
    if $rootScope.currentFinancialYear == presentYear
      $scope.fromDate = moment().subtract(1, 'years').add(1,'months').set('date',1).format('DD-MM-YYYY')
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

  $scope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE'
      $scope.setDateByFinancialYear()
      $scope.getprofitLossData($scope.fromDate,$scope.toDate)

profitloss.controller('profitlossController',profitlossController)

.directive 'profitLoss', () ->{
  restrict: 'E',
  templateUrl: '/public/webapp/Dashboard/profitLossGraph/profitloss.html'
}