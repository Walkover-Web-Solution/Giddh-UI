"use strict"

history = angular.module('historicalModule',[])

historicalgraphController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, $timeout, reportService) ->
  $scope.dataAvailable = false
  $scope.errorMessage = ""
  $scope.groupArray = ["revenue_from_operations","indirect_expenses","operating_cost"]
  $scope.monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  $scope.chartData = {
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
        "id": "expenseBalance",
        "label": "Expense",
        "type": "number",
        "p": {}
      },{
        "id": "incomeBalance",
        "label": "Revenue",
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
    }
    vAxis:{
      format: 'long'
    }
  }
  }
  $scope.secondTime = 0

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

  $scope.getHistory = (fromDate, toDate) ->
#    write code to get history data
    $scope.errorMessage = ""
    $scope.dataAvailable = false
    if _.isUndefined($rootScope.selectedCompany)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    if $rootScope.currentFinancialYear == undefined
      $timeout ( ->
        $scope.setDateByFinancialYear()
        $scope.getHistory($scope.fromDate,$scope.toDate)
      ),2000
    else
      $scope.graphData = []
      $scope.chartData.data.rows = []
      reqParam = {
        'cUname': $rootScope.selectedCompany.uniqueName
        'fromDate': fromDate
        'toDate': toDate
        'interval': "monthly"
      }
      graphParam = {
        'groups': ["indirect_expenses","operating_cost"]
      }
      $scope.getHistoryData(reqParam, {"groups":["revenue_from_operations"]})
      $scope.getHistoryData(reqParam, graphParam)

  $scope.getGraphParam = (groupUName) ->
    graphParam = {
      'groups': [groupUName]
    }
    graphParam

  $scope.getHistoryData = (reqParam,graphParam) ->
    reportService.newHistoricData(reqParam, graphParam).then $scope.getHistoryDataSuccess, $scope.getHistoryDataFailure

  $scope.getHistoryDataSuccess = (res) ->
    $scope.graphData.push(res.body.groups)
    $scope.combineCategoryWise(_.flatten($scope.graphData))

  $scope.getHistoryDataFailure = (res) ->
    if res.data.code == "INVALID_DATE"
      if $scope.secondTime <= 0
        $scope.secondTime = $scope.secondTime + 1
        setDate = ""
        if moment().get('months') > 4
          setDate = "01-04-" + moment().get('YEARS')
        else
          setDate = "01-04-" + moment().subtract(1, 'years').get('YEARS')
        $scope.getHistory(setDate, moment().format('DD-MM-YYYY'))
      else
        $scope.secondTime = 0
    else
      $scope.dataAvailable = false
      $scope.errorMessage = res.data.message

  $scope.combineCategoryWise = (result) ->
    categoryWise = _.groupBy(result,'category')
    addInThis = []
    _.each(categoryWise, (groups) ->
      category = groups[0].category
      duration = ""
      interval = []
      interval = _.toArray(_.groupBy(_.flatten(_.pluck(groups, 'intervalBalances')), 'from'))
      _.each(interval, (group) ->
        closingBalance = {}
        closingBalance.amount = 0
        closingBalance.type = "DEBIT"
        duration = ""
        _.each(group, (grp) ->
          duration = $scope.monthArray[moment(grp.to, "YYYY-MM-DD").get('months')] + moment(grp.to, "YYYY-MM-DD").get('years')
          if category == "income"
            closingBalance.amount = closingBalance.amount + (grp.creditTotal - grp.debitTotal)
          else
            sum = grp.debitTotal - grp.creditTotal
            closingBalance.amount = closingBalance.amount + sum
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
    rowsToAdd = []
    _.each(data, (monthly) ->
      row = {}
      row.c = []
      row.c.push({v:monthly[0].month})
      sortedMonth = _.sortBy(monthly, 'category')
      _.each(sortedMonth, (account) ->
        row.c.push({v:account.closingBalance.amount})
      )
      rowsToAdd.push(row)
    )
    $scope.chartData.data.rows = rowsToAdd
    $scope.dataAvailable = true

  $scope.setDateByFinancialYear()

  $scope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE'
      $scope.setDateByFinancialYear()
      $scope.getHistory($scope.fromDate,$scope.toDate)


history.controller('historicalgraphController',historicalgraphController)

.directive 'history',[($locationProvider,$rootScope) -> {
  restrict: 'E'
  templateUrl: $rootScope.prefixThis+'/public/webapp/Dashboard/historicalGraph/historicalGraph.html'
#  controller: 'historicalgraphController'
}]