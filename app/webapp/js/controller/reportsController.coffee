"use strict"
reportsController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService) ->

  $scope.today = new Date()
  $scope.fromDate = {date: new Date()}
  $scope.toDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.selectedGroups = []
  $scope.selectedAccounts = []
  $scope.selected = {}
  $scope.format = "dd-MM-yyyy"

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $scope.intervalVals = [1, 3, 7, 30, 90, 180, 365]

  $scope.graphInterval = $scope.intervalVals[2]

  $scope.getAccountsGroupsList = ()->
    $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    $scope.showAccountList = false
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllWithAccountsFor($rootScope.selectedCompany.uniqueName).then($scope.getGroupsSuccess,
        $scope.getGroupsFailure)

  $scope.getGroupsSuccess = (res) ->
    $scope.groupList = res.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList, [])
    $scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($scope.flattenGroupList)
    $scope.showLedgerBox = true
    $scope.sortGroupsAndAccounts($scope.flatAccntWGroupsList)
    $scope.selectedGroups = [$scope.groups[0]]
    $scope.selectedAccounts = [$scope.accounts[0]]

  $scope.getGroupsFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #sort groups and accounts lists
  
  $scope.sortGroupsAndAccounts =  (dataArray) ->
    $scope.groups = []
    $scope.accounts = []
    _.each dataArray,(obj) ->
      group = {}
      group.name = obj.groupName
      group.uniqueName = obj.groupUniqueName
      $scope.groups.push(group)
      if obj.accountDetails.length > 0
        _.each obj.accountDetails, (acc) ->
          account = {}
          account.name = acc.name
          account.uniqueName = acc.uniqueName
          $scope.accounts.push(account)

  createArrayWithUniqueName = (dataArray) ->
    finalArray = []
    _.each dataArray, (obj) ->
      finalArray.push(obj.uniqueName)
    finalArray


  $scope.getAccountsGroupsList()
  
  $scope.generateGraph = () ->
    reqParam = {
      fromDate: $filter('date')($scope.fromDate.date,'dd-MM-yyyy')
      toDate: $filter('date')($scope.toDate.date, "dd-MM-yyyy")
      intreval: $scope.graphInterval
    }
    reqBody = {
      groups : createArrayWithUniqueName($scope.selectedGroups)
      accounts : createArrayWithUniqueName($scope.selectedAccounts)
    }
    console.log reqParam
    console.log reqBody

  $scope.$watch('fromDate.date', (newVal,oldVal) ->
    oldDate = new Date(oldVal).getTime()
    newDate = new Date(newVal).getTime()

    toDate = new Date($scope.toDate.date).getTime()

    if newDate > toDate
      $scope.toDate.date =  $filter('date')(newDate, 'dd-MM-yyyy')
  )





    

















#init angular app
giddh.webApp.controller 'reportsController', reportsController
