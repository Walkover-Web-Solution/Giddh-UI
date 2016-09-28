"use strict"

combined = angular.module('combinedModule', [])

combinedController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService, $timeout, $state, $http, $window) ->
  $scope.monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  $scope.chartDataAvailable = false
  $scope.errorMessage = ""
  $scope.fromDate = moment().format('DD-MM-YYYY')
  $scope.toDate = moment().format('DD-MM-YYYY')
  $scope.chartOptions = {
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
  $scope.plData = {
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
    "options": $scope.chartOptions
  }
  $scope.networthData = {
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
          "label": "Monthly change",
          "type": "number",
          "p": {}
        },{
          "id": "yearlyBalance",
          "label": "Net worth",
          "type": "number",
          "p": {}
        }]
    },
    "options": $scope.chartOptions
  }


  $scope.getCombinedData = () ->
    $scope.chartDataAvailable = false
    $scope.errorMessage = ""
    if _.isUndefined($rootScope.selectedCompany)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    if $rootScope.currentFinancialYear == undefined
      $timeout ( ->
        $scope.getCombinedData()
      ),2000
    else
      $scope.setDateByFinancialYear()
      $scope.getComData($scope.fromDate,$scope.toDate)

  $scope.getComData = (fromDate, toDate) ->
    $scope.errorMessage = ""
    $scope.chartDataAvailable = false
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': fromDate
      'toDate': toDate
      'interval': "monthly"
    }
    $scope.getCombinedGraphData(reqParam)

  $scope.getCombinedGraphData = (reqParam) ->
    reportService.networthNprofitloss(reqParam).then $scope.getCGraphDataSuccess, $scope.getCGraphDataFailure

  $scope.getCGraphDataSuccess = (res) ->
    $scope.errorMessage = ""
    nwGraphData = res.body
    $scope.formatNetworthData (nwGraphData.networth)
    $scope.formatPLdata(nwGraphData.profitLoss)

  $scope.getCGraphDataFailure = (res) ->
    if res.data.code == "INVALID_DATE"
      setDate = ""
      if moment().get('months') > 4
        setDate = "01-04-" + moment().get('YEARS')
      else
        setDate = "01-04-" + moment().subtract(1, 'years').get('YEARS')
      $scope.fromDate = setDate
      $scope.toDate = moment().format('DD-MM-YYYY')
      $scope.getComData(setDate,moment().format('DD-MM-YYYY'))
    else
      $scope.chartDataAvailable = false
      $scope.chartData = []
      #    toastr.error(res.data.message)
      $scope.errorMessage = res.data.message

  $scope.formatNetworthData = (data) ->
    $scope.networthData.data.rows = []
    monthlyBalances = []
    yearlyBalances = []
    _.each data.periodBalances, (nw) ->
      row = {}
      row.c = []
      str = $scope.monthArray[moment(nw.to, 'DD-MM-YYYY').get('months')] + moment(nw.to, 'DD-MM-YYYY').get('y')
      monthlyBalances.push(nw.monthlyBalance)
      yearlyBalances.push(nw.yearlyBalance)
      row.c.push({v:str})
      row.c.push({v:nw.monthlyBalance})
      row.c.push({v:nw.yearlyBalance})
      $scope.networthData.data.rows.push(row)
    $scope.chartDataAvailable = true

  $scope.formatPLdata = (data) ->
    $scope.plData.data.rows = []
    monthlyBalances = []
    yearlyBalances = []
    _.each data.periodBalances, (nw) ->
      row = {}
      row.c = []
      str = $scope.monthArray[moment(nw.to, 'DD-MM-YYYY').get('months')] + moment(nw.to, 'DD-MM-YYYY').get('y')
      monthlyBalances.push(nw.monthlyBalance)
      yearlyBalances.push(nw.yearlyBalance)
      row.c.push({v:str})
      row.c.push({v:nw.monthlyBalance})
      $scope.plData.data.rows.push(row)
    $scope.chartDataAvailable = true

  $scope.setDateByFinancialYear = () ->
    presentYear = $scope.getPresentFinancialYear()
    if $rootScope.currentFinancialYear == presentYear
      if $rootScope.selectedCompany.financialYears.length > 1
        $scope.fromDate = moment().subtract(1, 'years').add(1,'months').set('date',1).format('DD-MM-YYYY')
        $scope.toDate = moment().format('DD-MM-YYYY')
      else
        $scope.fromDate = $rootScope.selectedCompany.activeFinancialYear.financialYearStarts
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

  $scope.goToReports = () ->
    $rootScope.stateParam = {'frmDt': $scope.fromDate, 'toDt': $scope.toDate, 'type': 'networth'}
    $state.go('Reports',{'frmDt': $scope.fromDate, 'toDt': $scope.toDate, 'type': 'networth'})

  $scope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE' || changeData.type == 'SELECT'
      $scope.setDateByFinancialYear()
      $scope.getComData($scope.fromDate,$scope.toDate)

combined.controller('combinedController',combinedController)

.directive 'combined',[($locationProvider,$rootScope) -> {
  restrict: 'E',
  templateUrl: 'https://giddh-fs8eefokm8yjj.stackpathdns.com/public/webapp/Dashboard/networthNprofitloss/combined.html'
}]