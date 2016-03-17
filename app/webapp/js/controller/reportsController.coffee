"use strict"
reportsController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter, reportService) ->

  $scope.today = new Date()
  $scope.fromDate = {date: new Date()}
  $scope.toDate = {date: new Date()}
  $scope.fromPLDate = {date: new Date()}
  $scope.toPLDate = {date: new Date()}
  $scope.fromNWDate = {date: new Date()}
  $scope.toNWDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.GroupsAndAccounts = []
  $scope.selected = {
    groups: []
    accounts: []
    interval: 1
    filterBy: 'Closing Balance'
    createChartBy : 'Closing Balance'
    createChartByMultiple: []
    filteredGroupsAndAccounts: {}
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
  $scope.showFilters = false
  # parameters required to create graph
  $scope.series = []
  $scope.chartData = []
  $scope.labels = []
  $scope.plSeries = []
  $scope.plChartData = []
  $scope.plLabels = []
  $scope.nwSeries = []
  $scope.nwChartData = []
  $scope.nwLabels = []
  $scope.chartOptions = {
    datasetFill:false
  }
  $scope.chartTypes = ['Bar', 'Line']
  $scope.chartType = $scope.chartTypes[1]
  $scope.listBeforeLimit = {
    groups: []
    accounts: []
  }
  $scope.noData = false
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $scope.intervalVals = [1, 3, 7, 30, 90, 180, 365]
  $scope.chartParams = ['Closing Balance', 'Credit Total', 'Debit Total']


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
    # $scope.selected.groups = [$scope.groups[0]]
    # $scope.selected.accounts = [$scope.accounts[0]]
    if $scope.groups.length < 1 && $scope.accounts.length < 1
      $scope.noData = true
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

  $scope.createArrayWithUniqueName = (dataArray) ->
    finalArray = []
    _.each dataArray, (obj) ->
      finalArray.push(obj.uniqueName)
    finalArray


  $scope.getAccountsGroupsList()
  
  $scope.formatGraphData = (graphData) ->
    $scope.series = []
    $scope.chartData = []
    $scope.labels = []
    $scope.GroupsAndAccounts = []
    data = graphData
    groups = []
    accounts = []


    if data.groups.length > 0
      _.each data.groups ,(grp) ->
        groups.push(grp)

    if data.accounts.length > 0
      _.each data.accounts, (acc) ->
        accounts.push(acc)

    if groups.length > 0
      _.each groups, (grp) ->
        grpObj = {
          category: ''
          forSeries:{
            dr: ''
            cr: ''
            cb: ''
          }
          forData: {
            dr: []
            cr: []
            cb: []
          }
          forLabels: []
        }
        fgrp = {
          name: ''
          category: ''
          forfilter:{
            cb: {
              type: 'cb'
              val: false
            }
            cr: {
              type: 'cr'
              val: false
            }
            dr: {
              type: 'dr'
              val: false
            }
          }
        }
        grpObj.category = grp.category
        grpObj.forSeries.dr = grp.name + " (DR)"
        grpObj.forSeries.cr = grp.name + " (CR)"
        grpObj.forSeries.cb = grp.name + " (C/B)"
        fgrp.name = grp.name
        fgrp.category = grp.category
        
        if grp.intervalBalances.length > 0
          _.each grp.intervalBalances, (bal) ->
            grpObj.forData.dr.push(bal.debitTotal)
            grpObj.forData.cr.push(bal.creditTotal)
            grpObj.forData.cb.push(bal.closingBalance.amount)
            grpObj.forLabels.push(bal.to)

        switch grpObj.category.toLowerCase()
          when "assets"
            $scope.series.push(grpObj.forSeries.dr)
            $scope.series.push(grpObj.forSeries.cb)
            $scope.chartData.push(grpObj.forData.dr)
            $scope.chartData.push(grpObj.forData.cb)
            fgrp.forfilter.cb.val = true
            fgrp.forfilter.dr.val = true

          when "liabilities"
            $scope.series.push(grpObj.forSeries.cr)
            $scope.series.push(grpObj.forSeries.cb)
            $scope.chartData.push(grpObj.forData.cr)
            $scope.chartData.push(grpObj.forData.cb)
            fgrp.forfilter.cb.val = true
            fgrp.forfilter.cr.val = true
          when "income"
            $scope.series.push(grpObj.forSeries.cr)
            $scope.series.push(grpObj.forSeries.cb)
            $scope.chartData.push(grpObj.forData.cr)
            $scope.chartData.push(grpObj.forData.cb)
            fgrp.forfilter.cb.val = true
            fgrp.forfilter.cr.val = true

          when "expenses"
            $scope.series.push(grpObj.forSeries.dr)
            $scope.series.push(grpObj.forSeries.cb)
            $scope.chartData.push(grpObj.forData.dr)
            $scope.chartData.push(grpObj.forData.cb)
            fgrp.forfilter.cb.val = true
            fgrp.forfilter.dr.val = true

        $scope.labels = grpObj.forLabels
        $scope.GroupsAndAccounts.push(fgrp)

    if accounts.length > 0
      _.each accounts, (acc) ->
        accObj = {
          category: ''
          forSeries:{
            dr: ''
            cr: ''
            cb: ''
          }
          forData: {
            dr: []
            cr: []
            cb: []
          }
          forLabels: []
        }
        facc = {
          name: ''
          category: ''
          forfilter:{
            cb: {
              type: 'cb'
              val: false
            }
            cr: {
              type: 'cr'
              val: false
            }
            dr: {
              type: 'dr'
              val: false
            }
          }
        }
        accObj.category = acc.category
        accObj.forSeries.dr = acc.name + " (DR)"
        accObj.forSeries.cr = acc.name + " (CR)"
        accObj.forSeries.cb = acc.name + " (C/B)"
        facc.name = acc.name
        facc.category = acc.category
        
        if acc.intervalBalances.length > 0
          _.each acc.intervalBalances, (bal) ->
            accObj.forData.dr.push(bal.debitTotal)
            accObj.forData.cr.push(bal.creditTotal)
            accObj.forData.cb.push(bal.closingBalance.amount)
            accObj.forLabels.push(bal.to)

        switch accObj.category.toLowerCase()
          when "assets"
            $scope.series.push(accObj.forSeries.dr)
            $scope.series.push(accObj.forSeries.cb)
            $scope.chartData.push(accObj.forData.dr)
            $scope.chartData.push(accObj.forData.cb)
            facc.forfilter.cb.val = true
            facc.forfilter.dr.val = true

          when "liabilities"
            $scope.series.push(accObj.forSeries.cr)
            $scope.series.push(accObj.forSeries.cb)
            $scope.chartData.push(accObj.forData.cr)
            $scope.chartData.push(accObj.forData.cb)
            facc.forfilter.cb.val = true
            facc.forfilter.cr.val = true

          when "income"
            $scope.series.push(accObj.forSeries.cr)
            $scope.series.push(accObj.forSeries.cb)
            $scope.chartData.push(accObj.forData.cr)
            $scope.chartData.push(accObj.forData.cb)
            facc.forfilter.cb.val = true
            facc.forfilter.cr.val = true

          when "expenses"
            $scope.series.push(accObj.forSeries.dr)
            $scope.series.push(accObj.forSeries.cb)
            $scope.chartData.push(accObj.forData.dr)
            $scope.chartData.push(accObj.forData.cb)
            facc.forfilter.cb.val = true
            facc.forfilter.dr.val = true
        if groups.length < 1    
          $scope.labels = accObj.forLabels
          
        $scope.GroupsAndAccounts.push(facc)

    # set variable to show chart on ui
    $scope.chartDataAvailable = true
    $scope.showFilters = true

  $scope.filterGraph = (arg) ->
    console.log arg
    seriesIdc = []
    series = $scope.series
    idx = 0
    chartData = $scope.chartData
    targetData = {}
    groups = $scope.graphData.groups
    accounts = $scope.graphData.accounts
    grpacc = []
    filteredObj = {}
    selectedValue = $scope.selected.filteredGroupsAndAccounts

    _.each groups, (grp) ->
      grpacc.push(grp)
    _.each accounts, (acc) ->
      grpacc.push(acc)

    if !_.isEmpty(selectedValue)
      while idx < series.length
        if series[idx].indexOf(selectedValue.name) != -1
          seriesIdc.push(idx)
        idx++

      _.each grpacc, (obj) ->
        if obj.name == selectedValue.name
          dataObj = {
            forSeries: {
              dr: obj.name + ' (DR)'
              cr: obj.name + ' (CR)'
              cb: obj.name + ' (C/B)'
            }
            forData: {
              dr: []
              cr: []
              cb: []
            }
          }  
          _.each obj.intervalBalances, (bal) ->
            dataObj.forData.cb.push(bal.closingBalance.amount)
            dataObj.forData.cr.push(bal.creditTotal)
            dataObj.forData.dr.push(bal.debitTotal)

          filteredObj = dataObj

          switch arg.type
            when "cr"
              if arg.val == true && $scope.series.indexOf(filteredObj.forSeries.cr) == -1
                addAtIdx = seriesIdc[seriesIdc.length-1]
                $scope.series.splice(addAtIdx, 0, filteredObj.forSeries.cr)
                $scope.chartData.splice(addAtIdx, 0, filteredObj.forData.cr)
              else if arg.val == false && $scope.series.indexOf(filteredObj.forSeries.cr) != -1
                removeAtIdx = seriesIdc[seriesIdc.length-1] - 1 
                $scope.series.splice(removeAtIdx, 1)
                $scope.chartData.splice(removeAtIdx, 1)
            when "dr"
              if arg.val == true && $scope.series.indexOf(filteredObj.forSeries.dr) == -1             
                addAtIdx = seriesIdc[seriesIdc.length-1]
                $scope.series.splice(addAtIdx, 0, filteredObj.forSeries.dr)
                $scope.chartData.splice(addAtIdx, 0, filteredObj.forData.dr)
              else if arg.val == false && $scope.series.indexOf(filteredObj.forSeries.dr) != -1
                removeAtIdx = $scope.series.indexOf(filteredObj.forSeries.dr) 
                $scope.series.splice(removeAtIdx, 1)
                $scope.chartData.splice(removeAtIdx, 1)
            when "cb"
              if arg.val == true && $scope.series.indexOf(filteredObj.forSeries.cb) == -1             
                addAtIdx = seriesIdc[seriesIdc.length-1]
                $scope.series.splice(addAtIdx, 0, filteredObj.forSeries.cb)
                $scope.chartData.splice(addAtIdx, 0, filteredObj.forData.cb)
              else if arg.val == false && $scope.series.indexOf(filteredObj.forSeries.cb) != -1
                removeAtIdx = $scope.series.indexOf(filteredObj.forSeries.cb) 
                $scope.series.splice(removeAtIdx, 1)
                $scope.chartData.splice(removeAtIdx, 1)                 

  $scope.getGraphData  = (reqParam,graphParam) ->
    reportService.historicData(reqParam, graphParam).then $scope.getGraphDataSuccess, $scope.getGraphDataFailure

  $scope.getGraphDataSuccess = (res) ->
    $scope.graphData = res.body
    $scope.formatGraphData($scope.graphData)

  $scope.getGraphDataFailure = (res) ->
    $scope.chartDataAvailable = true
    toastr.error(res.data.message, res.data.status)

  $scope.generateGraph = () ->
    $scope.chartDataAvailable = false
    $scope.showFilters = false
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': $filter('date')($scope.fromDate.date,'dd-MM-yyyy')
      'toDate': $filter('date')($scope.toDate.date, "dd-MM-yyyy")
      'interval': $scope.selected.interval 
    }
    graphParam = {
      'groups' : $scope.createArrayWithUniqueName($scope.selected.groups)
      'accounts' : $scope.createArrayWithUniqueName($scope.selected.accounts)
    }
    if $scope.selected.groups.length > 0 || $scope.selected.accounts.length > 0
      $scope.getGraphData(reqParam, graphParam)
    else
      toastr.error('Please select atleast one group or account to create graph')
      $scope.chartDataAvailable = true
    
  $scope.$watch('selected.groups', (newVal, oldVal)->
    if newVal != oldVal
      if newVal.length > 3
        $scope.groups = []
        toastr.info('You can only select 4 Groups at a time.')
      else if newVal.length < 4
        $scope.groups = $scope.listBeforeLimit.groups
  ) 

  $scope.$watch('selected.accounts', (newVal, oldVal)->
    if newVal != oldVal
      if newVal.length > 3
        $scope.accounts = []
        toastr.info('You can only select 4 Accounts at a time.')
      else if newVal.length < 4
        $scope.accounts = $scope.listBeforeLimit.accounts
  )

  $scope.$watch('fromDate.date', (newVal,oldVal) ->
    oldDate = new Date(oldVal).getTime()
    newDate = new Date(newVal).getTime()

    toDate = new Date($scope.toDate.date).getTime()

    if newDate > toDate
      $scope.toDate.date =  newDate
  )

  # for profit and loss graphs
  $scope.showHistoryFilters = true
  $scope.showPLGraphFilters = false
  $scope.showNWfilters = false

  $scope.showPLFilter = () ->
    $scope.showPLGraphFilters = true
    $scope.showNWfilters = false
    $scope.showHistoryFilters = false

  $scope.showHistoryFilter = () ->
    $scope.showPLGraphFilters = false
    $scope.showNWfilters = false
    $scope.showHistoryFilters = true

  $scope.showNWfilter = () ->
    $scope.showPLGraphFilters = false
    $scope.showNWfilters = true
    $scope.showHistoryFilters = false
  

  $scope.getPLgraphData = (reqParam) ->
    reportService.plGraphData(reqParam).then $scope.getPLgraphDataSuccess, $scope.getPLgraphDataFailure

  $scope.getPLgraphDataSuccess = (res) ->
    $scope.plGraphData = res.body
    $scope.formatPLgraphData($scope.plGraphData)

  $scope.getPLgraphDataFailure = (res) ->
    $scope.chartDataAvailable = true
    toastr.error(res.data.message)

  $scope.generatePLgraph = () ->
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': $filter('date')($scope.fromPLDate.date,'dd-MM-yyyy')
      'toDate': $filter('date')($scope.toPLDate.date, "dd-MM-yyyy")
      'interval': $scope.selected.interval 
    }
    $scope.getPLgraphData(reqParam) 
    $scope.chartDataAvailable = false

  $scope.formatPLgraphData = (plData) ->
    $scope.plSeries = []
    $scope.plChartData = []
    $scope.plLabels = []

    monthlyBalances = []
    yearlyBalances = []

    _.each plData.periodBalances, (pl) ->
      $scope.plLabels.push(pl.to)
      monthlyBalances.push(pl.monthlyBalance)
      $scope.plSeries.push('Monthly Balances')
      yearlyBalances.push(pl.yearlyBalance)
      $scope.plSeries.push('Yearly Balances')

    $scope.plChartData.push(monthlyBalances, yearlyBalances)
    $scope.chartDataAvailable = true

  $scope.$watch('fromPLDate.date', (newVal,oldVal) ->
    oldDate = new Date(oldVal).getTime()
    newDate = new Date(newVal).getTime()

    toDate = new Date($scope.toDate.date).getTime()

    if newDate > toDate
      $scope.toDate.date =  newDate
  )

  # for networth graph

  $scope.getNWgraphData = (reqParam) ->
    reportService.nwGraphData(reqParam).then $scope.getNWgraphDataSuccess, $scope.getNWgraphDataFailure

  $scope.getNWgraphDataSuccess = (res) ->
    $scope.nwGraphData = res.body
    $scope.formatNWgraphData ($scope.nwGraphData)

  $scope.getNWgraphDataFailure = (res) ->
    $scope.chartDataAvailable = true
    toastr.error(res.data.message)

  $scope.generateNWgraph = () ->
    reqParam = {
      'cUname': $rootScope.selectedCompany.uniqueName
      'fromDate': $filter('date')($scope.fromNWDate.date,'dd-MM-yyyy')
      'toDate': $filter('date')($scope.toNWDate.date, "dd-MM-yyyy")
      'interval': $scope.selected.interval 
    }
    $scope.getNWgraphData(reqParam) 
    $scope.chartDataAvailable = false


  $scope.formatNWgraphData = (nwData) ->
    $scope.nwSeries = []
    $scope.nwChartData = []
    $scope.nwLabels = []

    monthlyBalances = []
    yearlyBalances = []

    _.each nwData.periodBalances, (nw) ->
      $scope.nwLabels.push(nw.to)
      monthlyBalances.push(nw.monthlyBalance)
      $scope.nwSeries.push('Monthly Balances')
      yearlyBalances.push(nw.yearlyBalance)
      $scope.nwSeries.push('Yearly Balances')

    $scope.nwChartData.push(monthlyBalances, yearlyBalances)
    $scope.chartDataAvailable = true

  $scope.$watch('fromNWDate.date', (newVal,oldVal) ->
    oldDate = new Date(oldVal).getTime()
    newDate = new Date(newVal).getTime()

    toDate = new Date($scope.toDate.date).getTime()

    if newDate > toDate
      $scope.toDate.date =  newDate
  )




#init angular app
giddh.webApp.controller 'reportsController', reportsController
