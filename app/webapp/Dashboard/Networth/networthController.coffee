"use strict"

networth = angular.module('networthModule', [
#"networthControllers"
#"networthDirectives"
])

networthController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService, $timeout, $state) ->
  $scope.unq = 0
  $scope.monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  $scope.series = ['Net worth']
  $scope.chartData = [
    [1424785, 1425744, 1425874, 1425985, 1435200, 1432999, 1437010]
  ]
  $scope.labels = ["January", "February", "March", "April", "May", "June", "July"]
  $scope.chartOptions = {
    datasetFill:true
  }
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
    "options": {
      seriesType: 'bars',
      series: {1: {type: 'line'}},
      colors: ['#d35f29','#337ab7'],
      legend:{position:'none'},
      chartArea:{
        width:'85%',
        right: 10
      },
      curveType: 'function'
    }
  }

  $scope.getNetWorthData = () ->
#    get net worth data here
    $scope.chartDataAvailable = false
    $scope.errorMessage = ""
    if _.isUndefined($rootScope.selectedCompany)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    if $rootScope.currentFinancialYear == undefined
      $timeout ( ->
        $scope.getNetWorthData()
      ),2000
    else
      $scope.setDateByFinancialYear()
      $scope.getNWdata($scope.fromDate,$scope.toDate)

  # for networth graph

  $scope.getNWdata = (fromDate, toDate) ->
    $scope.errorMessage = ""
    $scope.chartDataAvailable = false
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': fromDate
      'toDate': toDate
      'interval': "monthly"
    }
    $scope.getNWgraphData(reqParam)

  $scope.getNWgraphData = (reqParam) ->
    reportService.networthData(reqParam).then $scope.getNWgraphDataSuccess, $scope.getNWgraphDataFailure

  $scope.getNWgraphDataSuccess = (res) ->
    $scope.errorMessage = ""
    nwGraphData = res.body
    $scope.formatNWgraphData (nwGraphData)

  $scope.getNWgraphDataFailure = (res) ->
    if res.data.code == "INVALID_DATE"
      setDate = ""
      if moment().get('months') > 4
        setDate = "01-04-" + moment().get('YEARS')
      else
        setDate = "01-04-" + moment().subtract(1, 'years').get('YEARS')
      $scope.getNWdata(setDate,moment().format('DD-MM-YYYY'))
    else
      $scope.chartDataAvailable = false
      $scope.chartData = []
      #    toastr.error(res.data.message)
      $scope.errorMessage = res.data.message

  $scope.formatNWgraphData = (nwData) ->
    $scope.myChartData.data.rows = []
    $scope.nwSeries = []
    $scope.nwChartData = []
    $scope.nwLabels = []
    monthlyBalances = []
    yearlyBalances = []
    _.each nwData.periodBalances, (nw) ->
      row = {}
      row.c = []
      str = $scope.monthArray[moment(nw.to, 'DD-MM-YYYY').get('months')] + moment(nw.to, 'DD-MM-YYYY').get('y')
      $scope.nwLabels.push(str)
      monthlyBalances.push(nw.monthlyBalance)
      $scope.nwSeries.push('Monthly Balances')
      yearlyBalances.push(nw.yearlyBalance)
      $scope.nwSeries.push('Yearly Balances')
      row.c.push({v:str})
      row.c.push({v:nw.monthlyBalance})
      row.c.push({v:nw.yearlyBalance})
      $scope.myChartData.data.rows.push(row)

    $scope.chartData = []
    $scope.chartData.push(yearlyBalances)
    $scope.labels = []
    $scope.labels = $scope.nwLabels
    $scope.chartDataAvailable = true

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

  $scope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE'
      $scope.setDateByFinancialYear()
      $scope.getNWdata($scope.fromDate,$scope.toDate)


networth.controller('networthController', networthController)


.directive 'netWorth',[() -> {
  restrict: 'E'
  templateUrl: '/public/webapp/Dashboard/Networth/net-worth.html'
#  controller: 'networthController'
  link: (scope,elem,attr) ->
  #    console.log "networth scope : ",scope
}]
