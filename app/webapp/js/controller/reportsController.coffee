"use strict"
reportsController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService) ->

  $scope.today = new Date()
  $scope.fromDate = {date: new Date()}
  $scope.toDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.selected = {
    groups: []
    accounts: []
    interval: 1
    createChartBy : 'Closing Balance'
    createChartByMultiple: []
  }
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false,
    'container': "body"
    'minViewMode': 0
  }
  $scope.format = "dd-MM-yyyy"
  # variable to show chart on ui
  $scope.chartDataAvailable = true
  # parameters required to create graph
  $scope.series = []
  $scope.chartData = []
  $scope.labels = []
  $scope.chartOptions = {
    datasetFill:false
  }
  $scope.chartTypes = ['Bar', 'Line']
  $scope.chartType = $scope.chartTypes[1]
  $scope.listBeforeLimit = {
    groups: []
    accounts: []
  }

  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $scope.intervalVals = [1, 3, 7, 30, 90, 180, 365]
  $scope.chartParams = ['Opening Balance', 'Closing Balance', 'Credit Total', 'Debit Total']


  $scope.getAccountsGroupsList = ()->
    $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    $scope.showAccountList = false
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getGroupsWithAccountsInDetail($rootScope.selectedCompany.uniqueName).then($scope.getGroupsSuccess,
        $scope.getGroupsFailure)

  $scope.getGroupsSuccess = (res) ->
    $scope.groupList = res.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList, [])
    $scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($scope.flattenGroupList)
    $scope.sortGroupsAndAccounts($scope.flatAccntWGroupsList)
    $scope.selected.groups = [$scope.groups[0]]
    $scope.selected.accounts = [$scope.accounts[0]]
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
      $scope.listBeforeLimit.groups.push(group)
      if obj.accountDetails.length > 0
        _.each obj.accountDetails, (acc) ->
          account = {}
          account.name = acc.name
          account.uniqueName = acc.uniqueName
          $scope.accounts.push(account)
          $scope.listBeforeLimit.accounts.push(account)

  createArrayWithUniqueName = (dataArray) ->
    finalArray = []
    _.each dataArray, (obj) ->
      finalArray.push(obj.uniqueName)
    finalArray


  $scope.getAccountsGroupsList()
  
  $scope.createChartWithParam = (param) ->
    switch param
      when 'Closing Balance'
        $scope.chartData = $scope.sortedChartData.cb
      when 'Opening Balance'
        $scope.chartData = $scope.sortedChartData.op
      when 'Credit Total'
        $scope.chartData = $scope.sortedChartData.ct
      when 'Debit Total'
        $scope.chartData = $scope.sortedChartData.dt


  $scope.formatGraphData = (graphData) ->
    if $scope.selected.groups.length == 1 && $scope.selected.accounts.length == 0 || $scope.selected.groups.length == 0 && $scope.selected.accounts.length == 1
      $scope.series = []
      $scope.labels = []
      $scope.chartData = []
      data = graphData
      chartParams = $scope.selected.createChartByMultiple
      sortedChartData = {
        cb: [] #closingBalance
        op: [] #openingBalance
        ct: [] #creditTotal
        dt: [] #debitTotal
      }

      if data.groups.length == 1
        group = data.groups[0]
      if data.accounts.length == 1
        account = data.accounts[0]
      intBal = group.intervalBalances || account.intervalBalances

      _.each intBal, (obj) ->
        $scope.labels.push(obj.to)
        sortedChartData.cb.push(obj.closingBalance.amount)
        sortedChartData.op.push(obj.openingBalance.amount)
        sortedChartData.ct.push(obj.creditTotal)
        sortedChartData.dt.push(obj.debitTotal)
      
      if chartParams.length > 0
        _.each chartParams, (param) ->
          switch param
            when 'Closing Balance'
              $scope.series.push('Closing Balance')
              $scope.chartData.push(sortedChartData.cb)
            when 'Opening Balance'
              $scope.series.push('Opening Balance')
              $scope.chartData.push(sortedChartData.op)
            when 'Credit Total'
              $scope.series.push('Credit Total')
              $scope.chartData.push(sortedChartData.ct)
            when 'Debit Total'
              $scope.series.push('Debit Total')
              $scope.chartData.push(sortedChartData.dt)
      else
        toastr.error('Please select atleast one parameter for chart')




    else
      $scope.series = []
      $scope.sortedChartData = {
        cb: [] #closingBalance
        op: [] #openingBalance
        ct: [] #creditTotal
        dt: [] #debitTotal
      }
      $scope.labels = []
      data = graphData
      groups = []
      accounts = []

      # sort data.groups
      if data.groups.length > 0
        _.each data.groups, (grp) ->
          group = {
            name :''
            cbs: []
            op: []
            ct: []
            dt: []
            to: []
          }
          group.name = grp.name
          _.each grp.intervalBalances, (bal) ->
            group.cbs.push(bal.closingBalance.amount)
            group.op.push(bal.openingBalance.amount)
            group.ct.push(bal.creditTotal)
            group.dt.push(bal.debitTotal)
            group.to.push(bal.to)
          groups.push(group)

      # add details to graph params 
      _.each groups, (grp) ->
        # add names to $scope.series
        $scope.series.push(grp.name)
        # add data array to $scope.chartData
        $scope.sortedChartData.cb.push(grp.cbs)
        $scope.sortedChartData.op.push(grp.op)
        $scope.sortedChartData.ct.push(grp.ct)
        $scope.sortedChartData.dt.push(grp.dt)

      if data.accounts.length > 0
          _.each data.accounts, (acc) ->
            account = {
              name :''
              cbs: []
              op: []
              ct: []
              dt: []
              to: []
            }
            account.name = acc.name
            _.each acc.intervalBalances, (bal) ->
              account.cbs.push(bal.closingBalance.amount)
              account.op.push(bal.openingBalance.amount)
              account.ct.push(bal.creditTotal)
              account.dt.push(bal.debitTotal)
              account.to.push(bal.to)
            accounts.push(account)

      _.each accounts, (acc) ->
        # add names to $scope.series
        $scope.series.push(acc.name)
        # add data array to $scope.chartData
        $scope.sortedChartData.cb.push(acc.cbs)
        $scope.sortedChartData.op.push(acc.op)
        $scope.sortedChartData.ct.push(acc.ct)
        $scope.sortedChartData.dt.push(acc.dt)
      
      $scope.createChartWithParam($scope.selected.createChartBy)

      # add dates to $scope.labels
      if groups.length > 0
        _.each groups[0].to, (date) ->
          $scope.labels.push(date)
      else
        _.each accounts[0].to, (date) ->
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
    $scope.chartDataAvailable = false
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': $filter('date')($scope.fromDate.date,'dd-MM-yyyy')
      'toDate': $filter('date')($scope.toDate.date, "dd-MM-yyyy")
      'interval': $scope.selected.interval
    }
    graphParam = {
      'groups' : createArrayWithUniqueName($scope.selected.groups)
      'accounts' : createArrayWithUniqueName($scope.selected.accounts)
    }
    if $scope.selected.groups.length > 0 || $scope.selected.accounts.length > 0
      $scope.getGraphData(reqParam, graphParam)
    else
      toastr.error('Please select atleast one group or account to create graph')
      $scope.chartDataAvailable = true
    
  $scope.$watch('selected.groups', (newVal, oldVal)->
    if newVal != oldVal
      if newVal.length > 9
        $scope.groups = []
      else if newVal.length < 10
        $scope.groups = $scope.listBeforeLimit.groups
  ) 

  $scope.$watch('selected.accounts', (newVal, oldVal)->
    if newVal != oldVal
      if newVal.length > 9
        $scope.accounts = []
      else if newVal.length < 10
        $scope.accounts = $scope.listBeforeLimit.accounts
  )


  $scope.$watch('fromDate.date', (newVal,oldVal) ->
    oldDate = new Date(oldVal).getTime()
    newDate = new Date(newVal).getTime()

    toDate = new Date($scope.toDate.date).getTime()

    if newDate > toDate
      $scope.toDate.date =  newDate
  )

  

#init angular app
giddh.webApp.controller 'reportsController', reportsController
