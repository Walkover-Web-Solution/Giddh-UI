"use strict"

compare = angular.module('compareModule', [])

comparisiongraphController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, $timeout, reportService) ->
  $scope.dataAvailable = true
  $scope.errorMessage = ""
  $scope.chartType = "ComboChart"
  $scope.monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  $scope.chartOptions = {
    seriesType: 'line',
    series: {1: {type: 'line'}},
    colors: ['#d35f29','#337ab7'],
    legend:{position:'none'},
    chartArea:{
      width: '80%'
    },
    curveType: 'function'
  }
  $scope.chartData = {
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
  $scope.groupArray = {
    sales: ["revenue_from_operations"]
    expense: ["indirect_expenses","operating_cost"]
  }

  $scope.salesData = []
  $scope.expenseData = []
  $scope.selectedChart = "sales"

  $scope.getData = (type) ->
    $scope.selectedChart = type
    $scope.errorMessage = ""
    $scope.dataAvailable = false
    if _.isUndefined($rootScope.selectedCompany)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    if $rootScope.currentFinancialYear == undefined
      $timeout ( ->
        $scope.getData(type)
      ),2000
    else
      $scope.setDateByFinancialYear()
      $scope.salesData = []
      $scope.expenseData = []
      $scope.generateData(type, $scope.fromDate, $scope.toDate)
      $scope.generateData(type, moment($scope.fromDate, 'DD-MM-YYYY').subtract(1,'years').format('DD-MM-YYYY'),moment($scope.toDate, 'DD-MM-YYYY').subtract(1,'years').format('DD-MM-YYYY'))

  $scope.generateData = (type, fromDate, toDate) ->
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': fromDate
      'toDate': toDate
      'interval': 30
    }
    graphParam = {
      'groups' : $scope.groupArray[type]
    }
    $scope.getYearlyData(reqParam, graphParam)

  $scope.getYearlyData = (reqParam,graphParam) ->
    reportService.historicData(reqParam, graphParam).then $scope.getYearlyDataSuccess, $scope.getYearlyDataFailure

  $scope.getYearlyDataSuccess = (res) ->
    $scope.graphData = res.body
#    console.log($scope.selectedChart + " we get : ",res.body)
    $scope.combineCategoryWise($scope.graphData.groups)

  $scope.getYearlyDataFailure = (res) ->
    $scope.dataAvailable = false
    $scope.errorMessage = res.data.message

  $scope.combineCategoryWise = (result) ->
    categoryWise = _.groupBy(result,'category')
    addInThis = []
    _.each(categoryWise, (groups) ->
      category = groups[0].category
      duration = ""
      interval = []
      interval = _.toArray(_.groupBy(_.flatten(_.pluck(groups, 'intervalBalances')), 'to'))
      _.each(interval, (group) ->
        closingBalance = {}
        closingBalance.amount = 0
        closingBalance.type = "DEBIT"
        duration = ""
        _.each(group, (grp) ->
          duration = $scope.monthArray[moment(grp.to, "YYYY-MM-DD").get('months')] + moment(grp.to, "YYYY-MM-DD").get('years')
          if category == "income"
            if closingBalance.type == "DEBIT"
              closingBalance.amount = closingBalance.amount + (grp.creditTotal - grp.debitTotal)
            else
              closingBalance.amount = closingBalance.amount - (grp.creditTotal - grp.debitTotal)
          else
            if closingBalance.type == "DEBIT"
              closingBalance.amount = closingBalance.amount + (grp.debitTotal - grp.creditTotal)
            else
              closingBalance.amount = closingBalance.amount - (grp.debitTotal - grp.creditTotal)
          if closingBalance.amount < 0
            closingBalance.type = "CREDIT"
          else
            closingBalance.type = "DEBIT"
        )
        intB = {}
        intB.closingBalance = closingBalance
        intB.duration = duration
        intB.month = duration
        intB.category = category
        addInThis.push(intB)
      )
    )
    monthWise = _.groupBy(addInThis,'duration')
    $scope.generateChartData(monthWise)

  $scope.generateChartData = (data) ->
    $scope.chartData.data.rows = []
    _.each(data, (monthly) ->
      row = {}
      row.c = []
      row.c.push({v:monthly[0].month})
      _.each(monthly, (account) ->
        row.c.push({v:account.closingBalance.amount})
      )
      if $scope.selectedChart == "sales"
        $scope.salesData.push(row)
      else
        $scope.expenseData.push(row)
    )
    if $scope.selectedChart == "sales"
      $scope.chartData.data.rows = $scope.salesData
    else
      $scope.chartData.data.rows = $scope.expenseData
    $scope.dataAvailable = true


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
#      $scope.getHistory()
      console.log("")

compare.controller('comparisiongraphController',comparisiongraphController)

.directive 'compareGraph', () ->{
  restrict: 'E'
  templateUrl: '/public/webapp/Dashboard/comparisionGraphs/compare.html'
#  controller: 'comparisiongraphController'
}