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
  $scope.enableDownload = true
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
  $scope.exportData = []
  $scope.filteredExportData = []
  $scope.addToExportNow = false
  $scope.filteredTotal = {
    exportingFiltered: false
    openingBalance: 0
    creditTotal: 0
    debitTotal: 0
    closingBalance: 0
  }
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
      $scope.plData.expenseTotal += $scope.plData.closingBalance
    if $scope.plData.incomeTotal < $scope.plData.expenseTotal
      console.info "expenses is Greater"
      $scope.inProfit = false
      $scope.plData.incomeTotal += $scope.plData.closingBalance

  # P&l functions end

  $scope.addUIKey = (data) ->
    _.each data, (grp) ->
      grp.isVisible = true
      _.each grp.accounts, (acc) ->
        acc.isVisible = true
      _.each grp.childGroups, (chld) ->
        if chld.accounts.length > 0
          _.each chld.accounts, (acc) ->
            acc.isVisible = true
        chld.isVisible = true
        if chld.childGroups.length > 0
          $scope.addUIKey(chld.childGroups)

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
    $scope.addUIKey(res.body.groupDetails)
    $scope.data = res.body
    $scope.exportData = []
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
    $scope.enableDownload = true

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
    rawData = $scope.exportData
    csv = ''
    row = ''
    header = ''
    title = '' + ',' + 'Opening Balance' + ',' + 'Debit' + ',' + 'Credit' + ',' + 'Closing Balance' + '\n'
    $scope.fnGroupWise = "Trial_Balance.csv"
    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'Trial Balance' + ': ' + $filter('date')($scope.fromDate.date,'dd-MM-yyyy') + ' to ' + $filter('date')($scope.toDate.date,
      "dd-MM-yyyy") + '\r\n'
    csv += header + '\r\n' + title
    $scope.calculateFilteredExportTotal(rawData)

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
      row += obj.name + ',' + obj.openingBalance + ' ' + $filter('recType')(obj.openingBalanceType,obj.openingBalance) + ',' + obj.debit + ',' + obj.credit + ',' + obj.closingBalance + $filter('recType')(obj.closingBalanceType,obj.closingBalance) + '\r\n'

    csv += row + '\r\n';
    csv += '\r\n' + 'Total' + ',' + $scope.filteredTotal.openingBalance + ',' + $scope.filteredTotal.debitTotal + ',' + $scope.filteredTotal.creditTotal + ',' + $scope.filteredTotal.closingBalance + '\n'

    $scope.csvGW = csv

    $scope.uriGroupWise = 'data:text/csv;charset=utf-8,' + escape(csv)
    $scope.showOptions = true
    e.stopPropagation()

  $scope.formatDataAccountWise = (e) ->
    groups = []
    accounts = []
    childGroups = []
    rawData = $scope.exportData
    $scope.fnAccountWise = "Trial_Balance_account-wise.csv"
    row = ''
    title = ''
    body = ''
    footer = ''
    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'Trial Balance' + ': ' + $filter('date')($scope.fromDate.date,
        "dd-MM-yyyy") + ' to ' + $filter('date')($scope.toDate.date,
        "dd-MM-yyyy") + '\r\n'
    $scope.calculateFilteredExportTotal(rawData)

    _.each rawData, (obj) ->
      group = {}
      group.Name = obj.groupName
      group.openingBalance = obj.forwardedBalance.amount
      group.Credit = obj.creditTotal
      group.Debit = obj.debitTotal
      group.ClosingBalance = obj.closingBalance.amount
      group.accounts = obj.accounts
      group.childGroups = obj.childGroups
      group.isVisible = obj.isVisible
      groups.push group


    sortChildren = (parent) ->
      #push account to accounts if accounts.length > 0
      _.each parent, (obj) ->
        parentGroup = obj.groupName
        if obj.accounts.length > 0
          _.each obj.accounts, (acc) ->
            account = {}
            account.name = acc.name
            account.openingBalance = acc.openingBalance.amount
            account.openingBalanceType = acc.openingBalance.type
            account.credit = acc.creditTotal
            account.debit = acc.debitTotal
            account.closingBalance = acc.closingBalance.amount
            account.closingBalanceType = acc.closingBalance.type
            account.parent = parentGroup
            account.isVisible = acc.isVisible
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
            childGroup.isVisible = chld.isVisible
            childGroups.push childGroup

            if chld.accounts.length > 0
              _.each chld.accounts, (acc) ->
                account = {}
                account.name = acc.name
                account.openingBalance = acc.openingBalance.amount
                account.openingBalanceType = acc.openingBalance.type
                account.credit = acc.creditTotal
                account.debit = acc.debitTotal
                account.closingBalance = acc.closingBalance.amount
                account.closingBalanceType = acc.closingBalance.type
                account.parent = childGroup.name
                account.isVisible = acc.isVisible
                accounts.push account

            if chld.childGroups.length > 0
              _.each chld.childGroups, (obj) ->
                group = {}
                group.Name = obj.groupName
                group.openingBalance = obj.forwardedBalance.amount
                group.openingBalanceType = obj.forwardedBalance.type
                group.Credit = obj.creditTotal
                group.Debit = obj.debitTotal
                group.Closing - Balance = obj.closingBalance.amount
                group.accounts = obj.accounts
                group.childGroups = obj.childGroups
                group.isVisible = obj.isVisible
                groups.push group
              sortChildren(chld.childGroups)

    sortChildren(rawData)

    title += 'Name' + ',' + 'Opening Balance' + ',' + 'Debit' + ',' + 'Credit' + ',' + 'Closing Balance' + '\r\n'
    footer += 'Total' + ',' + $scope.filteredTotal.openingBalance + ',' + $scope.filteredTotal.debitTotal + ',' + $scope.filteredTotal.creditTotal + ',' + $scope.filteredTotal.closingBalance + '\n'

    createCsv = (data)->
      _.each data, (obj) ->
        row = row or
          ''
        if obj.isVisible == true
          row += obj.name + ' (' + obj.parent  + ')' + ',' + obj.openingBalance + $filter('recType')(obj.openingBalanceType ,obj.openingBalance) +  ',' + obj.debit + ',' + obj.credit + ',' + obj.closingBalance + $filter('recType')(obj.closingBalanceType,obj.closingBalance) + '\r\n'
      body += row + '\r\n'

    createCsv(accounts)

    csv = header + '\r\n\r\n' + title + '\r\n' + body + footer

    $scope.csvAW = csv
    $scope.uriAccountWise = 'data:text/csv;charset=utf-8,' + escape(csv)
    $scope.showOptions = true
    e.stopPropagation()

  $scope.formatDataCondensed = (e) ->
    rawData = $scope.exportData
    groupData = []
    csv = ''
    title = ''
    body = ''
    footer = ''
    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+ companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'Trial Balance' + ': ' + $filter('date')($scope.fromDate.date,
        "dd-MM-yyyy") + ' to ' + $filter('date')($scope.toDate.date,
        "dd-MM-yyyy") + '\r\n'
    $scope.calculateFilteredExportTotal(rawData)
    $scope.fnCondensed = "Trial_Balance_condensed.csv"
    sortData = (parent, groups) ->
      _.each parent, (obj) ->
        group = group or
          accounts: []
          childGroups: []
        group.Name = obj.groupName
        group.openingBalance = obj.forwardedBalance.amount
        group.openingBalanceType = obj.forwardedBalance.type
        group.Credit = obj.creditTotal
        group.Debit = obj.debitTotal
        group.ClosingBalance = obj.closingBalance.amount
        group.closingBalanceType = obj.closingBalance.type
        group.isVisible = obj.isVisible
        if obj.accounts.length > 0
          #group.accounts = obj.accounts
          _.each obj.accounts, (acc) ->
            account = {}
            account.name = acc.name
            account.openingBalance = acc.openingBalance.amount
            account.openingBalanceType = acc.openingBalance.type
            account.credit = acc.creditTotal
            account.debit = acc.debitTotal
            account.closingBalance = acc.closingBalance.amount
            account.closingBalanceType = acc.closingBalance.type
            account.isVisible = acc.isVisible
            group.accounts.push account

        if obj.childGroups.length > 0
          #group.childGroups = obj.childGroups
          
          _.each obj.childGroups, (grp) ->
            childGroup = childGroup or
              childGroups: []
              subAccounts: []
            childGroup.name = grp.groupName
            childGroup.parent = obj.groupName
            childGroup.openingBalance = grp.forwardedBalance.amount
            childGroup.openingBalanceType = grp.forwardedBalance.type
            childGroup.credit = grp.creditTotal
            childGroup.debit = grp.debitTotal
            childGroup.closingBalance = grp.closingBalance.amount
            childGroup.closingBalanceType = grp.closingBalance.type
            childGroup.isVisible = grp.isVisible
            group.childGroups.push childGroup

            if grp.accounts.length > 0
              _.each grp.accounts, (acc) ->
                childGroup.subAccounts = childGroup.subAccounts or
                  []
                account = {}
                account.name = acc.name
                account.openingBalance = acc.openingBalance.amount
                account.openingBalanceType = acc.openingBalance.type
                account.credit = acc.creditTotal
                account.debit = acc.debitTotal
                account.closingBalance = acc.closingBalance.amount
                account.closingBalanceType = acc.closingBalance.type
                account.isVisible = acc.isVisible
                childGroup.subAccounts.push account

            if grp.childGroups.length > 0
              sortData(grp.childGroups, childGroup.childGroups)
        groups.push group

    sortData(rawData, groupData)

    title += 'Name' + ',' + 'Opening Balance' + ',' + 'Debit' + ',' + 'Credit' + ',' + 'Closing Balance' + '\r\n'
    footer += 'Total' + ',' + $scope.filteredTotal.openingBalance + ',' + $scope.filteredTotal.debitTotal + ',' + $scope.filteredTotal.creditTotal + ',' + $scope.filteredTotal.closingBalance + '\n'

    createCsv = (csvObj) ->
      #console.log csvObj, 'csvObj'
      _.each csvObj, (obj) ->
        row = row or
            ''
        row += obj.Name.toUpperCase() + ',' + obj.openingBalance + $filter('recType')(obj.openingBalanceType,obj.openingBalance) + ',' + obj.Debit + ',' + obj.Credit + ',' + obj.ClosingBalance + $filter('recType')(obj.closingBalanceType,obj.ClosingBalance) + '\r\n'
        if obj.accounts.length > 0
          _.each obj.accounts, (acc) ->
            if acc.isVisible == true
              row += $scope.firstCapital(acc.name.toLowerCase()) + ' (' + $scope.firstCapital(obj.Name) + ')' + ',' + acc.openingBalance + $filter('recType')(acc.openingBalanceType,acc.openingBalance) + ',' + acc.debit + ',' + acc.credit + ',' + acc.closingBalance + $filter('recType')(acc.closingBalanceType,acc.closingBalance) + '\r\n'

        if obj.childGroups.length > 0
          _.each obj.childGroups, (grp) ->
            if grp.isVisible == true && grp.closingBalance != 0
              row += $scope.firstCapital(grp.name.toLowerCase()) + ' (' + obj.Name.toUpperCase() + ')' + ',' + grp.openingBalance + $filter('recType')(grp.openingBalanceType,grp.openingBalance) + ',' + grp.debit + ',' + grp.credit + ',' + grp.closingBalance + $filter('recType')(grp.closingBalanceType,grp.closingBalance) + '\r\n'

            if grp.childGroups.length > 0
              _.each grp.childGroups, (subgrp) ->
                if subgrp.isVisible == true
                  row += subgrp.Name.toLowerCase() + ' (' + $scope.firstCapital(grp.name) + ')' + ',' + subgrp.openingBalance + $filter('recType')(subgrp.openingBalanceType,subgrp.openingBalance) + ',' + subgrp.debit + ',' + subgrp.credit + ',' + subgrp.closingBalance + $filter('recType')(subgrp.closingBalanceType,subgrp.closingBalance) + '\r\n'
                  createCsv(grp.childGroups)

            if grp.subAccounts.length > 0
              _.each grp.subAccounts, (acc) ->
                if acc.isVisible == true
                  row += acc.name.toLowerCase() + ' (' + $scope.firstCapital(grp.name) + ')' + ',' + acc.openingBalance + $filter('recType')(acc.openingBalanceType,acc.openingBalance) + ',' + acc.debit + ',' + acc.credit + ',' + acc.closingBalance + $filter('recType')(acc.closingBalanceType,acc.closingBalance) + '\r\n'

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

  $scope.logInputLength = (input) ->
    if input.length > 0
      $timeout (->
        $scope.addToExportNow = true
      ), 2000
    else 
      $scope.addToExportNow = false

  $scope.filterTBSearch = (grp) ->
    isGroupPresentUnq = _.findWhere($scope.filteredExportData, {uniqueName:grp.uniqueName})
    isGroupPresentName = _.findWhere($scope.filteredExportData, {groupName:grp.groupName})
    if $scope.addToExportNow && _.isUndefined(isGroupPresentUnq) && _.isUndefined(isGroupPresentName)
      $scope.filteredExportData.push(grp)
      $scope.exportData = $scope.filteredExportData
    else if $scope.addToExportNow == false
      $scope.filteredExportData = []
      $scope.exportData = $scope.data.groupDetails
    grp


  $scope.calculateFilteredExportTotal = (data) ->
    $scope.filteredTotal = {
      exportingFiltered: false
      openingBalance: 0
      creditTotal: 0
      debitTotal: 0
      closingBalance: 0
    }
    _.each data, (grp) ->
      #opening balance
      if grp.forwardedBalance.type == "DEBIT"
        $scope.filteredTotal.openingBalance -= grp.forwardedBalance.amount
      else if grp.forwardedBalance.type == "CREDIT"
        $scope.filteredTotal.openingBalance += grp.forwardedBalance.amount
      #closing balance
      if grp.closingBalance.type == "DEBIT"
        $scope.filteredTotal.closingBalance -= grp.closingBalance.amount
      else if grp.forwardedBalance.type == "CREDIT"
        $scope.filteredTotal.closingBalance += grp.closingBalance.amount
      #debit total
      $scope.filteredTotal.debitTotal += grp.debitTotal
      #credit total
      $scope.filteredTotal.creditTotal += grp.creditTotal

      # apply number filters
      # $scope.filteredTotal.openingBalance = $filter('number')($scope.filteredTotal.openingBalance, 2)
      # $scope.filteredTotal.closingBalance = $filter('number')($scope.filteredTotal.closingBalance, 2)
      # $scope.filteredTotal.debitTotal = $filter('number')($scope.filteredTotal.debitTotal, 2)
      # $scope.filteredTotal.creditTotal = $filter('number')($scope.filteredTotal.creditTotal, 2)
  
  $scope.$watch('fromDate.date', (newVal,oldVal) ->
    oldDate = new Date(oldVal).getTime()
    newDate = new Date(newVal).getTime()
    toDate = new Date($scope.toDate.date).getTime()
    if newDate > toDate
      $scope.toDate.date =  newDate
    if newVal != oldVal
      $scope.enableDownload = false
  )

giddh.webApp.controller 'tbplController', tbplController