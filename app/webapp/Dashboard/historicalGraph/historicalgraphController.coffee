"use strict"

history = angular.module('historicalModule',[])

historicalgraphController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, $timeout, reportService) ->
  $scope.dataAvailable = false
  $scope.errorMessage = ""
  $scope.groupArray = ["revenue_from_operations","indirect_expenses","operating_cost"]
  $scope.monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

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

  $scope.getHistory = () ->
#    write code to get history data
    if _.isUndefined($rootScope.selectedCompany)
      $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    $scope.setDateByFinancialYear()
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': $scope.fromDate
      'toDate': $scope.toDate.date
      'interval': 30
    }
    graphParam = {
      'groups' : $scope.groupArray
    }
    $scope.getHistoryData(reqParam, graphParam)

  $scope.getHistoryData = (reqParam,graphParam) ->
    reportService.historicData(reqParam, graphParam).then $scope.getHistoryDataSuccess, $scope.getHistoryDataFailure

  $scope.getHistoryDataSuccess = (res) ->
    $scope.graphData = res.body
    console.log($scope.graphData)
    $scope.combineCategoryWise($scope.graphData.groups)
#    $scope.formatGraphData($scope.graphData)

  $scope.getHistoryDataFailure = (res) ->
    $scope.dataAvailable = false
    $scope.errorMessage = res.data.message

  $scope.combineCategoryWise = (result) ->
    categoryWise = _.groupBy(result,'category')
    groupWise = []
    addThis = []
    _.each(categoryWise, (groups) ->
#      console.log("where is category : ", groups)
      addInThis = []
      category = ""
      duration = ""
      interval = []
      interval = _.toArray(_.groupBy(_.flatten(_.pluck(groups, 'intervalBalances')), 'to'))
      _.each(interval, (group) ->
#        console.log("info to retreive : ", group)
        closingBalance = {}
        closingBalance.amount = 0
        closingBalance.type = "DEBIT"
        duration = ""
        _.each(group, (grp) ->
          duration = $scope.monthArray[moment(grp.to, "YYYY-MM-DD").get('months')]
          if grp.closingBalance.type == "DEBIT"
            closingBalance.amount = closingBalance.amount + grp.closingBalance.amount
          else
            closingBalance.amount = closingBalance.amount - grp.closingBalance.amount
          if closingBalance.amount < 0
            closingBalance.type = "CREDIT"
          else
            closingBalance.type = "DEBIT"
        )
        intB = {}
        intB.closingBalance = closingBalance
        intB.duration = duration
        addInThis.push(intB)
      )
      console.log("finally : ", addInThis)
#      filterNow = _.groupBy(interval, 'to')
    )


history.controller('historicalgraphController',historicalgraphController)

.directive 'history', () ->{
  restrict: 'E'
  templateUrl: '/public/webapp/Dashboard/historicalGraph/historicalGraph.html'
}