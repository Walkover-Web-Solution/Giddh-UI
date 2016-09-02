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
      width:'100%'
    },
    curveType: 'function',
    pointSize: 5
  }
  }

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

  $scope.getHistory = () ->
#    write code to get history data
    $scope.errorMessage = ""
    $scope.dataAvailable = false
    if _.isUndefined($rootScope.selectedCompany)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    if $rootScope.currentFinancialYear == undefined
      $timeout ( ->
        $scope.getHistory()
      ),2000
    else
      $scope.setDateByFinancialYear()
      reqParam = {
        'cUname': $rootScope.selectedCompany.uniqueName
        'fromDate': $scope.fromDate
        'toDate': $scope.toDate
        'interval': "monthly"
      }
      graphParam = {
        'groups' : $scope.groupArray
      }
      $scope.getHistoryData(reqParam, graphParam)

  $scope.getHistoryData = (reqParam,graphParam) ->
    reportService.newHistoricData(reqParam, graphParam).then $scope.getHistoryDataSuccess, $scope.getHistoryDataFailure

  $scope.getHistoryDataSuccess = (res) ->
    $scope.graphData = res.body
    $scope.combineCategoryWise($scope.graphData.groups)

  $scope.getHistoryDataFailure = (res) ->
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
    console.log("data we have : ",data)
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

  $scope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE'
      $scope.getHistory()


history.controller('historicalgraphController',historicalgraphController)

.directive 'history', () ->{
  restrict: 'E'
  templateUrl: '/public/webapp/Dashboard/historicalGraph/historicalGraph.html'
#  controller: 'historicalgraphController'
}