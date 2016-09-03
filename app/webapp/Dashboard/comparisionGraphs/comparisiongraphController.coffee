"use strict"

compare = angular.module('compareModule', [])

comparisiongraphController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, $timeout, reportService) ->
  $scope.dataAvailable = true
  $scope.errorMessage = ""
  $scope.chartType = "ComboChart"
  $scope.monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  $scope.chartOptions = {
    seriesType: 'line',
    series: {1:{type: 'bars'},2: {type: 'line',pointShape: 'star'},3:{type:'bars'}},
    colors: ['#d35f29','#d35f29','#337ab7','#337ab7'],
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
      scaleType: 'mirrorLog',
      format: 'long'
    }
  }
  $scope.chartOptionsWODiff = {
    seriesType: 'line',
    series: {1: {type: 'line',pointShape: 'star'}},
    colors: ['#d35f29', '#337ab7'],
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
      scaleType: 'mirrorLog',
      format: 'long'
    }
  }
  $scope.chartColumnFormation = [
      {
        "id": "sMonth",
        "label": "Month",
        "type": "string",
        "p": {}
      },
      {
        "id": "previousSBalance",
        "label": "Previous",
        "type": "number",
        "p": {}
      },{
        "id": "toolP",
        "type": "string",
        "role": "tooltip"
      },{
        "id": "previousTBalance",
        "label": "Total",
        "type": "number",
        "p": {}
      },{
        "id": "toolPT",
        "type": "string",
        "role": "tooltip"
      },{
        "id": "currentSBalance",
        "label": "Current",
        "type": "number",
        "p": {}
      },{
        "id": "tool",
        "type": "string",
        "role": "tooltip"
      },
      {
        "id": "currentTBalance",
        "label": "Total",
        "type": "number",
        "p": {}
      },{
        "id": "toolST",
        "type": "string",
        "role": "tooltip"
      }
  ]
  $scope.chartData = {
    "type": $scope.chartType,
    "data": {
      "cols" : $scope.chartColumnFormation
    },
    "options": $scope.chartOptions
  }
  $scope.chartColumnFormationWODiff = [
    {
      "id": "sMonth",
      "label": "Month",
      "type": "string",
      "p": {}
    },
    {
      "id": "previousSBalance",
      "label": "Previous",
      "type": "number",
      "p": {}
    },{
      "id": "toolP",
      "type": "string",
      "role": "tooltip"
    },{
      "id": "currentSBalance",
      "label": "Current",
      "type": "number",
      "p": {}
    },{
      "id": "tool",
      "type": "string",
      "role": "tooltip"
    }
  ]
  $scope.chartDataWODiff = {
    "type": $scope.chartType,
    "data": {
      "cols": $scope.chartColumnFormationWODiff
    },
    "options": $scope.chartOptionsWODiff
  }
  $scope.groupArray = {
    sales: ["revenue_from_operations"]
    expense: ["indirect_expenses","operating_cost"]
  }

  $scope.salesData = []
  $scope.expenseData = []
  $scope.unformatData = []
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
      $scope.generateData(type, $scope.fromDate, moment().format('DD-MM-YYYY'))
      $scope.generateData(type, moment($scope.fromDate, 'DD-MM-YYYY').subtract(1,'years').format('DD-MM-YYYY'),moment($scope.toDate, 'DD-MM-YYYY').subtract(1,'years').format('DD-MM-YYYY'))

  $scope.generateData = (type, fromDate, toDate) ->
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': fromDate
      'toDate': toDate
      'interval': "monthly"
    }
    graphParam = {
      'groups' : $scope.groupArray[type]
    }
    $scope.getYearlyData(reqParam, graphParam)

  $scope.getYearlyData = (reqParam,graphParam) ->
    reportService.newHistoricData(reqParam, graphParam).then $scope.getYearlyDataSuccess, $scope.getYearlyDataFailure

  $scope.getYearlyDataSuccess = (res) ->
    $scope.graphData = res.body
#    console.log($scope.selectedChart + " we get : ",res.body)
    $scope.combineCategoryWise($scope.graphData.groups)

  $scope.getYearlyDataFailure = (res) ->
    if res.data.code == "INVALID_DATE"
      setDate = ""
      if moment().get('months') > 4
        setDate = "01-04-" + moment().get('YEARS')
      else
        setDate = "01-04-" + moment().subtract(1, 'years').get('YEARS')
#      $scope.generateData($scope.selectedChart, setDate, moment().format('DD-MM-YYYY'))
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
      interval = _.toArray(_.groupBy(_.flatten(_.pluck(groups, 'intervalBalances')), 'to'))
      _.each(interval, (group) ->
        closingBalance = {}
        closingBalance.amount = 0
        closingBalance.type = "DEBIT"
        total = {}
        total.amount = 0
        total.type = 'DEBIT'
        duration = ""
        year = moment().get('y')
        month = ""
        monthNum = 0
        _.each(group, (grp) ->
          duration = $scope.monthArray[moment(grp.to, "YYYY-MM-DD").get('months')] + moment(grp.to, "YYYY-MM-DD").get('years')
          month = $scope.monthArray[moment(grp.to, "YYYY-MM-DD").get('months')]
          monthNum = moment(grp.to, "YYYY-MM-DD").get('months') + 1
          year = moment(grp.to, "YYYY-MM-DD").get('years')
          if category == "income"
            total.amount = total.amount + (grp.creditTotal - grp.debitTotal)
          else
            sum = grp.debitTotal - grp.creditTotal
            total.amount = total.amount + sum
          if category == "income"
            if grp.closingBalance.type == "DEBIT"
              closingBalance.amount = closingBalance.amount - grp.closingBalance.amount
            else
              closingBalance.amount = closingBalance.amount + grp.closingBalance.amount
          else
            if grp.closingBalance.type == "DEBIT"
              closingBalance.amount = closingBalance.amount + grp.closingBalance.amount
            else
              closingBalance.amount = closingBalance.amount - grp.closingBalance.amount
          if closingBalance.amount < 0
            closingBalance.type = "CREDIT"
          else
            closingBalance.type = "DEBIT"
          if total.amount < 0
            total.type = "CREDIT"
          else
            total.type = "DEBIT"
        )
        intB = {}
        intB.closingBalance = closingBalance
        intB.duration = duration
        intB.year = year
        intB.month = month
        intB.monthNum = monthNum
        intB.category = category
        intB.total = total
        addInThis.push(intB)
      )
    )
#    monthWise = _.groupBy(addInThis,'duration')
#    console.log("monthly data : ", addInThis)
    $scope.generateChartData(addInThis)

  $scope.generateChartData = (data) ->
    $scope.chartData.data.rows = []
    _.each(data, (monthly) ->
      if $scope.selectedChart == "sales"
        $scope.salesData.push(monthly)
      else
        $scope.expenseData.push(monthly)
    )
    if $scope.selectedChart == "sales"
      $scope.unformatData = $scope.salesData
      $scope.formatData($scope.unformatData)
    else
      $scope.unformatData = $scope.expenseData
      $scope.formatData($scope.unformatData)
    $scope.dataAvailable = true

  $scope.formatData = (data) ->
    $scope.chartData.data.rows = []
    temp = _.sortBy(data,'year')
    startWith = temp[0].monthNum
    groupedData = []
    before = []
    after = []
    _.each(temp, (group) ->
      if group.monthNum < startWith
        after.push(group)
      else
        before.push(group)
    )
    final = []
    final.push(_.groupBy(before, 'monthNum'))
    final.push(_.groupBy(after, 'monthNum'))
    _.each(final, (grouped) ->
      _.each(grouped, (addThis) ->
        groupedData.push(addThis)
      )
    )
    rowsToAdd = []
    _.each(groupedData, (itr) ->
      row = {}
      row.c = []
      row.c.push({v:itr[0].month})
      sortedData = _.sortBy(itr, 'year')
      _.each(sortedData, (monthly) ->
        row.c.push({
          "v":monthly.closingBalance.amount
        })
        tooltipText = monthly.year + ": "+$filter('currency')(Number(monthly.closingBalance.amount).toFixed(0), '', 0)
        row.c.push({"v": tooltipText})
        row.c.push({
          "v":monthly.total.amount
        })
        tooltipText = "Monthly change : "+monthly.year + ": "+$filter('currency')(Number(monthly.total.amount).toFixed(0), '', 0)
        row.c.push({"v": tooltipText})
      )
      rowsToAdd.push(row)
    )
    $scope.chartData.data.rows = rowsToAdd

  $scope.switchData = (condition, rowsToAdd) ->
    if condition == true
      $scope.chartData.data.rows = rowsToAdd
    else
      $scope.chartDataWODiff.data.rows = rowsToAdd

  $scope.setDateByFinancialYear = () ->
#    presentYear = $scope.getPresentFinancialYear()
#    if $rootScope.currentFinancialYear == presentYear
#      $scope.fromDate = moment().subtract(1, 'years').add(1,'months').format('DD-MM-YYYY')
#      $scope.toDate = moment().format('DD-MM-YYYY')
#    else
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
      $scope.getData($scope.selectedChart)

compare.controller('comparisiongraphController',comparisiongraphController)

.directive 'compareGraph', () ->{
  restrict: 'E'
  templateUrl: '/public/webapp/Dashboard/comparisionGraphs/compare.html'
#  controller: 'comparisiongraphController'
}