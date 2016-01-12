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
  # variable to show chart on ui
  $scope.chartDataAvailable = false
  # parameters required to create graph
  $scope.series = []
  $scope.data = []
  $scope.labels = []
  $scope.chartOptions = {
    datasetFill:false
  }
  $scope.chartTypes = ['Bar', 'Line']
  $scope.chartType = $scope.chartTypes[1]


  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $scope.intervalVals = [1, 3, 7, 30, 90, 180, 365]

  $scope.graphInterval = $scope.intervalVals[0]

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
    #$scope.selectedGroups = [$scope.groups[0]]
    $scope.selectedAccounts = [$scope.accounts[0]]
    $rootScope.showLedgerBox = true

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
  
  $scope.formatGraphData = (graphData) ->
    $scope.series = []
    $scope.data = []
    $scope.labels = []
    data = graphData
    groups = []
    accounts = []
    $scope.series = []

    # sort data.groups
    if data.groups.length > 0
      _.each data.groups, (grp) ->
        group = {
          name :''
          values: []
          to: []
        }
        group.name = grp.name
        _.each grp.intervalBalances, (bal) ->
          console.log bal
          group.values.push(bal.closingBalance.amount)
          group.to.push(bal.to)
        groups.push(group)

    # add details to graph params 
    _.each groups, (grp) ->
      # add names to $scope.series
      $scope.series.push(grp.name)
      # add data array to $scope.data
      $scope.data.push(grp.values)
    
    # add dates to $scope.labels
    _.each groups[0].to, (date) ->
      $scope.labels.push(date)

    $scope.series = $scope.series.reverse()

    # set variable to show chart on ui
    $scope.chartDataAvailable = true


  $scope.getGraphData  = (reqParam,graphParam) ->
    reportService.historicData(reqParam, graphParam).then $scope.getGraphDataSuccess, $scope.getGraphDataFailure

  $scope.getGraphDataSuccess = (res) ->
    $scope.graphData = res.body
    $scope.formatGraphData($scope.graphData)

  $scope.getGraphDataFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  $scope.generateGraph = () ->
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': $filter('date')($scope.fromDate.date,'dd-MM-yyyy')
      'toDate': $filter('date')($scope.toDate.date, "dd-MM-yyyy")
      'interval': $scope.graphInterval
    }
    graphParam = {
      'groups' : createArrayWithUniqueName($scope.selectedGroups)
      'accounts' : createArrayWithUniqueName($scope.selectedAccounts)
    }
    $scope.getGraphData(reqParam, graphParam)
    
    #method to get grpah data here
    



  $scope.$watch('fromDate.date', (newVal,oldVal) ->
    oldDate = new Date(oldVal).getTime()
    newDate = new Date(newVal).getTime()

    toDate = new Date($scope.toDate.date).getTime()

    if newDate > toDate
      $scope.toDate.date =  $filter('date')(newDate, 'dd-MM-yyyy')
  )

  $scope.addGroup = (item) ->
    $scope.selectedGroups.push(item)

  $scope.addAccount = (item) ->
    $scope.selectedAccounts.push(item)

  $scope.removeGroup = (item) ->
    console.log item



#init angular app
giddh.webApp.controller 'reportsController', reportsController
