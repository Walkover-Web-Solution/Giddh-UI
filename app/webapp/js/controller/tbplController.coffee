"use strict"

tbplController = ($scope, $rootScope, trialBalService, localStorageService, $filter, toastr, $timeout, $window) ->
  tb = this
  $scope.showTbplLoader = true
  $scope.inProfit = true
  $scope.expanded = false
  $scope.today = new Date()
  $scope.fromDate = {date: new Date()}
  $scope.toDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.showOptions = false
  $scope.sendRequest = true
  $scope.showChildren = false
  $scope.showpdf = false
  $scope.showNLevel = false
  $rootScope.cmpViewShow = true
  $scope.showClearSearch = false
  $scope.noData = false
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }
  $scope.plData = {
    closingBalance: 0
    incomeTotal: 0
    expenseTotal: 0
  }
  $scope.format = "dd-MM-yyyy"
  

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

  # p&l functions
  $scope.calCulateTotal = (data) ->
    eTtl = 0
    _.each(data, (item) ->
      eTtl += Number(item.closingBalance.amount)
    )
    return Number((eTtl).toFixed(2))


  $scope.filterPlData = (data) ->
    filterPlData = {}
    filterPlData.incArr = []
    filterPlData.expArr = []
    filterPlData.othArr = []
    income = []
    expenses = []
    others = []
    _.each data, (grp) ->
      switch grp.category
        when 'income'
          income.push(grp)
        when 'expenses'
          expenses.push(grp)
        else
          others.push(grp)
    _.each others, (obj) ->
      filterPlData.othArr.push(obj) 
    _.each income, (inc) ->
      filterPlData.incArr.push(inc)
    _.each expenses, (exp) ->
      filterPlData.expArr.push(exp)
    filterPlData

  $scope.makeDataForPl = (data) ->
    fData = $scope.filterPlData(data.groupDetails)
    $scope.plData = _.omit(fData, "othArr")
    $scope.plData.expenseTotal = $scope.calCulateTotal(fData.expArr)
    $scope.plData.incomeTotal = $scope.calCulateTotal(fData.incArr)
    clB = $scope.plData.incomeTotal - $scope.plData.expenseTotal

    $scope.plData.closingBalance = Math.abs(clB)

    if $scope.plData.incomeTotal >= $scope.plData.expenseTotal
      console.info "Income is Greater"
      $scope.inProfit = true
    if $scope.plData.incomeTotal < $scope.plData.expenseTotal
      console.info "expenses is Greater"
      $scope.inProfit = false

  # P&l functions end

  $scope.getDefaultDate = ->
    date = undefined
    mm = '01'
    dd = '04'
    year = moment().get('year')
    currentMonth = moment().get('month') + 1
    getDate = ->
      if currentMonth >= 4
        dateStr = dd + '-' + mm + '-' + year
        date = Date.parse(dateStr.replace(/-/g,"/"))
      else
        year -= 1
        dateStr = dd + '-' + mm + '-' + year
        date = Date.parse(dateStr.replace(/-/g,"/"))
      date  
    {date: getDate()}

  $scope.fromDate = {
    date: $scope.getDefaultDate().date
  }

  $scope.getTrialBal = (data) ->
    $scope.showTbplLoader = true
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
    $scope.makeDataForPl(res.body)
    $scope.data = res.body
    $scope.data.groupDetails = $scope.orderGroups(res.body.groupDetails)
    if $scope.data.closingBalance.amount is 0 and $scope.data.creditTotal is 0 and $scope.data.debitTotal is 0 and $scope.data.forwardedBalance.amount is 0
      $scope.noData = true
    $scope.showTbplLoader = false

  $scope.getTrialBalFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.filterBydate = () ->
    dateObj =
      'fromDate': $filter('date')($scope.getDefaultDate().date,'dd-MM-yyyy')
      'toDate': $filter('date')($scope.toDate.date, 'dd-MM-yyyy')
    $scope.expanded = false

    # $rootScope.showLedgerBox = false
    dateObj.fromDate = $filter('date')($scope.fromDate.date, 'dd-MM-yyyy')
    dateObj.toDate = $filter('date')($scope.toDate.date, 'dd-MM-yyyy')
    $scope.getTrialBal(dateObj)

  $scope.$on '$viewContentLoaded', ->
    if $scope.sendRequest
      dateObj = {
        'fromDate': $filter('date')($scope.getDefaultDate().date,'dd-MM-yyyy')
        'toDate': $filter('date')($scope.toDate.date, "dd-MM-yyyy")
      }
      $scope.getTrialBal(dateObj)
      $scope.sendRequest = false

  $scope.firstCapital = (input) ->
    s = input.split('')
    first = s[0].toUpperCase()
    rest = s.splice(1)
    i = first + rest.join('')
    input = i
    input

  #format $scope.data to convert into csv
  $scope.formatDataGroupWise = (e) ->
    groups = []
    rawData = $scope.data.groupDetails
    csv = ''
    row = ''
    header = ''
    title = '' + ',' + 'Opening Balance' + ',' + 'Debit' + ',' + 'Credit' + ',' + 'Closing Balance' + '\n'
    $scope.fnGroupWise = "Trial_Balance.csv"
    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'CIN: U72400MP2010PTC023806' + '\r\n' + 'Trial Balance' + ': ' + $filter('date')($scope.fromDate.date,'dd-MM-yyyy') + ' to ' + $filter('date')($scope.toDate.date,
      "dd-MM-yyyy") + '\r\n'
    csv += header + '\r\n' + title


    _.each rawData, (obj) ->
      group = {}
      group.name = obj.groupName
      group.openingBalance = obj.forwardedBalance.amount
      group.openingBalanceType = obj.forwardedBalance.type
      group.credit = obj.creditTotal
      group.debit = obj.debitTotal
      group.closingBalance = obj.closingBalance.amount
      group.closingBalanceType = obj.closingBalance.type
      groups.push group

    _.each groups, (obj) ->
      row += obj.name + ',' + obj.openingBalance + ' ' + $filter('recType')(obj.openingBalanceType,obj.openingBalance) + ',' + obj.debit + ',' + obj.credit + ',' + obj.closingBalance + ',' + $filter('recType')(obj.closingBalanceType,obj.closingBalance) + '\r\n'

    csv += row + '\r\n';
    csv += '\r\n' + 'Total' + ',' + $scope.data.forwardedBalance.amount + ',' + $scope.data.debitTotal + ',' + $scope.data.creditTotal + ',' + $scope.data.closingBalance.amount + '\n'

    $scope.csvGW = csv

    $scope.uriGroupWise = 'data:text/csv;charset=utf-8,' + escape(csv)
    $scope.showOptions = true
    e.stopPropagation()

  $scope.formatDataAccountWise = (e) ->
    groups = []
    accounts = []
    childGroups = []
    rawData = $scope.data.groupDetails
    $scope.fnAccountWise = "Trial_Balance_account-wise.csv"
    row = ''
    title = ''
    body = ''
    footer = ''
    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'CIN: U72400MP2010PTC023806' + '\r\n' + 'Trial Balance' + ': ' + $scope.fromDate.date + ' to ' + $filter('date')($scope.toDate.date,
        "dd-MM-yyyy") + '\r\n'


    _.each rawData, (obj) ->
      group = {}
      group.Name = obj.groupName
      #group.openingBalance = obj.forwardedBalance.amount
      group.Credit = obj.creditTotal
      group.Debit = obj.debitTotal
      group.ClosingBalance = obj.closingBalance.amount
      #group.accounts = obj.accounts
      #group.childGroups = obj.childGroups
      groups.push group


    sortChildren = (parent) ->
      #push account to accounts if accounts.length > 0
      _.each parent, (obj) ->
        if obj.accounts.length > 0
          _.each obj.accounts, (acc) ->
            account = {}
            account.name = acc.name
            account.credit = acc.creditTotal
            account.debit = acc.debitTotal
            account.closingBalance = acc.closingBalance.amount
            account.closingBalanceType = acc.closingBalance.type
            accounts.push account

      #push childgroup to childGroups if childGroups.length > 0
      _.each parent, (obj) ->
        if obj.childGroups.length > 0
          _.each obj.childGroups, (chld) ->
            childGroup = {}
            childGroup.name = chld.groupName
            childGroup.credit = chld.creditTotal
            childGroup.debit = chld.debitTotal
            childGroup.closingBalance = chld.closingBalance.amount
            childGroups.push childGroup

            if chld.accounts.length > 0
              _.each chld.accounts, (acc) ->
                account = {}
                account.name = acc.name
                account.credit = acc.creditTotal
                account.debit = acc.debitTotal
                account.closingBalance = acc.closingBalance.amount
                account.closingBalanceType = acc.closingBalance.type
                accounts.push account

            if chld.childGroups.length > 0
              _.each chld.childGroups, (obj) ->
                group = {}
                group.Name = obj.groupName
                #group.openingBalance = obj.forwardedBalance.amount
                group.Credit = obj.creditTotal
                group.Debit = obj.debitTotal
                group.Closing - Balance = obj.closingBalance.amount
                group.accounts = obj.accounts
                group.childGroups = obj.childGroups
                groups.push group
              sortChildren(chld.childGroups)

    sortChildren(rawData)

    title += 'Name' + ',' + 'Debit' + ',' + 'Credit' + ',' + 'Closing Balance' + '\r\n'
    footer += 'Total' + ',' + $scope.data.debitTotal + ',' + $scope.data.creditTotal + ',' + $scope.data.closingBalance.amount + '\r\n'

    createCsv = (data)->
      _.each data, (obj) ->
        row = row or
          ''
        row += obj.name + ',' + obj.debit + ',' + obj.credit + ',' + obj.closingBalance + ',' + $filter('recType')(obj.closingBalanceType,obj.closingBalance) + '\r\n'
      body += row + '\r\n'

    createCsv(accounts)

    csv = header + '\r\n\r\n' + title + '\r\n' + body + footer

    $scope.csvAW = csv

    $scope.uriAccountWise = 'data:text/csv;charset=utf-8,' + escape(csv)
    $scope.showOptions = true
    e.stopPropagation()

  $scope.formatDataCondensed = (e) ->
    rawData = $scope.data.groupDetails
    groupData = []
    csv = ''
    title = ''
    body = ''
    footer = ''
    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'CIN: U72400MP2010PTC023806' + '\r\n' + 'Trial Balance' + ': ' + $scope.fromDate.date + ' to ' + $filter('date')($scope.toDate.date,
        "dd-MM-yyyy") + '\r\n'

    $scope.fnCondensed = "Trial_Balance_condensed.csv"
    sortData = (parent, groups) ->
      _.each parent, (obj) ->
        group = group or
          accounts: []
          childGroups: []
        group.Name = obj.groupName
        #group.openingBalance = obj.forwardedBalance.amount
        group.Credit = obj.creditTotal
        group.Debit = obj.debitTotal
        group.ClosingBalance = obj.closingBalance.amount
        group.closingBalanceType = obj.closingBalance.type
        if obj.accounts.length > 0
          #group.accounts = obj.accounts
          _.each obj.accounts, (acc) ->
            account = {}
            account.name = acc.name
            account.credit = acc.creditTotal
            account.debit = acc.debitTotal
            account.closingBalance = acc.closingBalance.amount
            account.closingBalanceType = acc.closingBalance.type
            group.accounts.push account
        #console.log group.accounts

        if obj.childGroups.length > 0
          #group.childGroups = obj.childGroups
          _.each obj.childGroups, (grp) ->
            childGroup = childGroup or
              subGroups: []
              subAccounts: []
            childGroup.name = grp.groupName
            childGroup.credit = grp.creditTotal
            childGroup.debit = grp.debitTotal
            childGroup.closingBalance = grp.closingBalance.amount
            childGroup.closingBalanceType = grp.closingBalance.type
            group.childGroups.push childGroup

            if grp.accounts.length > 0
              _.each grp.accounts, (acc) ->
                childGroup.subAccounts = childGroup.subAccounts or
                  []
                account = {}
                account.name = acc.name
                account.credit = acc.creditTotal
                account.debit = acc.debitTotal
                account.closingBalance = acc.closingBalance.amount
                account.closingBalanceType = acc.closingBalance.type
                childGroup.subAccounts.push account

            if grp.childGroups.length > 0
              sortData(grp.childGroups, childGroup.subGroups)

        groups.push group

    sortData(rawData, groupData)

    title += 'Name' + ',' + 'Debit' + ',' + 'Credit' + ',' + 'Closing Balance' + '\r\n'
    footer += 'Total' + ',' + $scope.data.debitTotal + ',' + $scope.data.creditTotal + ',' + $scope.data.closingBalance.amount + '\r\n'

    createCsv = (csvObj) ->
      _.each csvObj, (obj) ->
        row = row or
            ''
        row += obj.Name.toUpperCase() + ',' + obj.Debit + ',' + obj.Credit + ',' + obj.ClosingBalance + ',' + $filter('recType')(obj.closingBalanceType,obj.ClosingBalance) + '\r\n'
        if obj.accounts.length > 0
          _.each obj.accounts, (acc) ->
            row += $scope.firstCapital(acc.name.toLowerCase()) + ' (' + $scope.firstCapital(obj.Name) + ')' + ',' + acc.debit + ',' + acc.credit + ',' + acc.closingBalance + ',' + $filter('recType')(acc.closingBalanceType,acc.closingBalance) + '\r\n'

        if obj.childGroups.length > 0
          _.each obj.childGroups, (grp) ->
            if grp.closingBalance != 0
              row += $scope.firstCapital(grp.name.toLowerCase()) + ' (' + obj.Name.toUpperCase() + ')' + ',' + grp.debit + ',' + grp.credit + ',' + grp.closingBalance + ',' + $filter('recType')(grp.closingBalanceType,grp.closingBalance) + '\r\n'

            if grp.subGroups.length > 0
              _.each grp.subGroups, (subgrp) ->
                if subgrp.name
                  row += subgrp.name.toLowerCase() + ' (' + $scope.firstCapital(grp.name) + ')' + ',' + subgrp.debit + ',' + subgrp.credit + ',' + subgrp.closingBalance + ',' + $filter('recType')(subgrp.closingBalanceType,subgrp.closingBalance) + '\r\n'
                  createCsv(grp.subGroups)

            if grp.subAccounts.length > 0
              _.each grp.subAccounts, (acc) ->
                row += acc.name.toLowerCase() + ' (' + $scope.firstCapital(grp.name) + ')' + ',' + acc.debit + ',' + acc.credit + ',' + acc.closingBalance + ',' + $filter('recType')(acc.closingBalanceType,acc.closingBalance) + '\r\n'

        body += row + '\r\n'

      csv = header + '\r\n\r\n' + title + '\r\n' + body + '\r\n' + footer + '\r\n'
    createCsv(groupData)

    $scope.csvCond = csv

    $scope.uriCondensed = 'data:text/csv;charset=utf-8,' + escape(csv)
    $scope.showOptions = true
    e.stopPropagation()

  $scope.formatData = (e) ->
    $scope.formatDataGroupWise(e)
    $scope.formatDataCondensed(e)
    $scope.formatDataAccountWise(e)

  $scope.hideOptions = (e) ->
    $timeout (->
      $scope.showOptions = false
      $scope.showpdf = false
    ), 100
    e.stopPropagation()
    
  $(document).on 'click', (e) ->
    $timeout (->
      $scope.showOptions = false
      $scope.showpdf = false
    ), 100

  $scope.addData = ->
    if $scope.showChildren
      $scope.showChildren = false
    else
      $scope.showChildren = true

  $scope.showPdfOptions = (e) ->
    $scope.showpdf = true
    e.stopPropagation()

  $scope.showNLevelList = (e) ->
    $scope.showNLevel = true

  $scope.orderGroups = (data) ->
    orderedGroups = []
    assets = []
    liabilities = []
    income = []
    expenses = []
    _.each data, (grp) ->
      switch grp.category
        when 'assets'
          assets.push(grp)
        when 'liabilities'
          liabilities.push(grp)
        when 'income'
          income.push(grp)
        when 'expenses'
          expenses.push(grp)
        else
          assets.push(grp)
    _.each liabilities, (liability) ->
      orderedGroups.push(liability)
    _.each assets, (asset) ->
      orderedGroups.push(asset) 
    _.each income, (inc) ->
      orderedGroups.push(inc)
    _.each expenses, (exp) ->
      orderedGroups.push(exp)
    orderedGroups

  $scope.$watch('fromDate.date', (newVal,oldVal) ->
    oldDate = new Date(oldVal).getTime()
    newDate = new Date(newVal).getTime()
    toDate = new Date($scope.toDate.date).getTime()
    if newDate > toDate
      $scope.toDate.date =  newDate
  )


giddh.webApp.controller 'tbplController', tbplController