"use strict"

trialBalanceController = ($scope, $rootScope, trialBalService, localStorageService, $filter, toastr, $timeout) ->
  $scope.expanded = false

  #date time picker code starts here
  $scope.today = new Date()
  $scope.fromDate = {date: new Date()}
  $scope.toDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

  $scope.getDefaultDate = ->
    date = undefined
    mm = '04'
    dd = '01'
    year = moment().get('year')
    currentMonth = moment().get('month') + 1
    getDate = ->
      if currentMonth >= 4
        date = dd + '-' + mm + '-' + year
      else
        year -= 1
        date = dd + '-' + mm + '-' + year
      date
    {date: getDate()}


  $scope.fromDate = {
    date: $scope.getDefaultDate().date
  }

  $scope.getTrialBal = (data) ->
    if _.isNull(data.fromDate) || _.isNull(data.toDate)
      toastr.error("Date should be in proper format", "Error")
      return false

    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'fromDate': data.fromDate
      'toDate': data.toDate
    }
    trialBalService.getAllFor(reqParam).then $scope.getTrialBalSuccess, $scope.getTrialBalFailure

  $scope.getTrialBalSuccess = (res) ->
    $scope.data = res.body
    $rootScope.showLedgerBox = true


  $scope.getTrialBalFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.filterBydate = () ->
    dateObj = {
      'fromDate': $scope.getDefaultDate().date
      'toDate': $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    }
    $scope.expanded = false
    $rootScope.showLedgerBox = false
    dateObj.fromDate = $filter('date')($scope.fromDate.date, "dd-MM-yyyy")
    dateObj.toDate = $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    $scope.getTrialBal(dateObj)


  #expand accordion on search
  $scope.expandAccordion = (e) ->
    $timeout (->
      l = e.currentTarget.value.length
      if l > 0
        $scope.expanded = true
      else
        $scope.expanded = false
    ), 100

  $scope.$on '$viewContentLoaded', ->
    dateObj = {
      'fromDate': $scope.getDefaultDate().date
      'toDate': $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    }
    $scope.getTrialBal(dateObj)

angular.module('giddhWebApp').controller 'trialBalanceController', trialBalanceController