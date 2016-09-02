"use strict"

pie = angular.module('piechartModule', [
  "googlechart"
])

piechartController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, $timeout) ->
  $scope.unq = 1
  $scope.series = ['Expense']
  $scope.chartData = []
  $scope.labels = ["Salary", "Vendor", "Welfare", "Other"]
  $scope.chartOptions = {
    legend:{position:'none'}
  }
  $scope.myChartObject = {}
  $scope.myChartObject.data = {"cols":[{
    "id": "account-name",
    "label": "Account name",
    "type": "string",
    "p": {}
  },
    {
      "id": "closing-balance",
      "label": "Closing Balance",
      "type": "number",
      "p": {}
    }],"rows":[
    {c:[
      {v: "Salary"},
      {v: 110}
    ]},
    {c:[
      {v: "Vendor"},
      {v: 90}
    ]},
    {c:[
      {v: "Welfare"},
      {v: 45}
    ]},
    {c:[
      {v: "Other"},
      {v: 30}
    ]},
  ]}
  $scope.myChartObject.type = "PieChart"
  $scope.myChartObject.options = {
    legend:{position:'none'},
    chartArea:{
      height:'80%'
    },
    animation:{
      duration: 1000,
      easing: 'out',
    },
  }
  $scope.chartDataAvailable = false
  $scope.errorMessage = ""
  $scope.accountList = []

  $scope.setDateByFinancialYear = () ->
    presentYear = $scope.getPresentFinancialYear()
    setDate = ""
    if $rootScope.currentFinancialYear == undefined
      $rootScope.currentFinancialYear = moment($rootScope.selectedCompany.activeFinancialYear.financialYearStarts,"DD-MM-YYYY").get("years") + "-"+ moment($rootScope.selectedCompany.activeFinancialYear.financialYearEnds,"DD-MM-YYYY").get("years")
    if $rootScope.currentFinancialYear == presentYear
      setDate = moment().format('DD-MM-YYYY')
    else
      setDate = $rootScope.selectedCompany.activeFinancialYear.financialYearEnds
    setDate

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

  $scope.getExpenseData = () ->
    $scope.chartDataAvailable = false
    $scope.errorMessage = ""
    if _.isUndefined($rootScope.selectedCompany)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    if $rootScope.currentFinancialYear == undefined
      $timeout ( ->
        $scope.getExpenseData()
      ),2000
    else
      duration = {}
      duration.from = $scope.setDateByFinancialYear()
      duration.to = duration.from
      $scope.accountList = []
      $scope.getClosingBalance("operating_cost",duration)
      $scope.getClosingBalance("indirect_expenses",duration)

  $scope.getClosingBalance = (groupUniqueName, duration) ->
    objToSend = {}
    objToSend.compUname = $rootScope.selectedCompany.uniqueName
    objToSend.selGrpUname = groupUniqueName
    objToSend.fromDate = duration.from
    objToSend.toDate = duration.to
    groupService.getClosingBal(objToSend).then($scope.getClosingBalSuccess,$scope.getClosingBalFailure)

  $scope.getClosingBalSuccess = (res) ->
    $scope.extractGroups(res.body[0])
    $scope.generateChartData($scope.accountList)

  $scope.getClosingBalFailure = (res) ->
    $scope.chartDataAvailable = false
    $scope.errorMessage = res.data.message

  $scope.extractAccounts = (data) ->
    if data.accounts.length > 0
      _.each(data.accounts, (account) ->
        $scope.accountList.push(account)
      )
    if data.childGroups.length > 0
      _.each(data.childGroups, (group) ->
        $scope.extractAccounts(group)
      )


  $scope.extractGroups = (data) ->
    if data.childGroups.length > 0
      _.each(data.childGroups, (grp) ->
        if grp.closingBalance.amount > 0
          $scope.accountList.push(grp)
      )

  $scope.generateChartData = (accounts) ->
    chartCreate = false
    accountRows = []
    $scope.labels = []
    $scope.chartData = []
    $scope.series = []
    accounts = _.sortBy(accounts,'closingBalance.amount')
    _.each(accounts, (account) ->
      row = {}
      row.c = []
      row.c.push({v:account.groupName})
      row.c.push({v:account.closingBalance.amount})
      $scope.labels.push(account.name)
      $scope.chartData.push(account.closingBalance.amount)
      $scope.series.push(account.name)
      if account.closingBalance.amount > 0
        chartCreate = true
      accountRows.push(row)
    )
    if chartCreate == false
      $scope.errorMessage = "No data to show."
      $scope.chartDataAvailable = false
    else
      $scope.chartDataAvailable = true
      $scope.errorMessage = ""
    $scope.myChartObject.data.rows = accountRows


  $scope.$on 'company-changed', (event,changeData) ->
    if changeData.type == 'CHANGE'
      $scope.getExpenseData()



pie.controller('piechartController', piechartController)

.directive 'pieChart',[() -> {
  restrict: 'E'
  templateUrl: '/public/webapp/Dashboard/Expensepiechart/expensepiechart.html'
#  controller: 'piechartController'
  link: (scope,elem,attr) ->
  #    console.log "pie chart scope : ",scope
}]