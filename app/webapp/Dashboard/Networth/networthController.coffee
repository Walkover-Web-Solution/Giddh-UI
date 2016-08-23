"use strict"

networth = angular.module('networthModule', [
#"networthControllers"
#"networthDirectives"
])

networthController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService, $timeout) ->
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

  $scope.getNetWorthData = () ->
#    get net worth data here
    $scope.chartDataAvailable = false
    $scope.errorMessage = ""
    $timeout (->
      $scope.getNWdata(moment().subtract(1, 'years').add(1,'months').format('DD-MM-YYYY'),moment().format('DD-MM-YYYY'))
    ),1400

  # for networth graph

  $scope.getNWdata = (fromDate, toDate) ->
    $scope.errorMessage = ""
    $scope.chartDataAvailable = false
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': fromDate
      'toDate': toDate
      'interval': 30
    }
    $scope.getNWgraphData(reqParam)

  $scope.getNWgraphData = (reqParam) ->
    reportService.nwGraphData(reqParam).then $scope.getNWgraphDataSuccess, $scope.getNWgraphDataFailure

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
    $scope.nwSeries = []
    $scope.nwChartData = []
    $scope.nwLabels = []
    monthlyBalances = []
    yearlyBalances = []
    _.each nwData.periodBalances, (nw) ->
      str = $scope.monthArray[moment(nw.to).get('months')] + moment(nw.to).get('y')
      $scope.nwLabels.push(str)
      monthlyBalances.push(nw.monthlyBalance)
      $scope.nwSeries.push('Monthly Balances')
      yearlyBalances.push(nw.yearlyBalance)
      $scope.nwSeries.push('Yearly Balances')

    $scope.chartData = []
    $scope.chartData.push(yearlyBalances)
    $scope.labels = []
    $scope.labels = $scope.nwLabels
    $scope.chartDataAvailable = true


  $rootScope.$on 'company-changed', (event,changeData) ->
# when company is changed, redirect to manage company page
    if changeData.type == 'CHANGE'
      $scope.getNWdata(moment().subtract(1, 'years').add(1,'months').format('DD-MM-YYYY'),moment().format('DD-MM-YYYY'))


networth.controller('networthController', networthController)


.directive 'netWorth',[() -> {
restrict: 'E'
templateUrl: '/public/webapp/Dashboard/Networth/net-worth.html'
controller: 'networthController'
link: (scope,elem,attr) ->
#    console.log "networth scope : ",scope
}]
