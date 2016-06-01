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
  $scope.plShowOptions = false
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
  # $scope.filteredExportData = []
  # $scope.addToExportNow = false
  $scope.filteredTotal = {
    exportingFiltered: false
    openingBalance: 0
    creditTotal: 0
    debitTotal: 0
    closingBalance: 0
  }


  $scope.balSheet = {
    liabilities : []
    assets : []
    assetTotal : 0
    liabTotal : 0
  }
  
  $scope.fy = {
    fromYear: ''
    toYear: ''
  }


  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

  $scope.checkFY = (reqParam) ->
    currentYear = moment().get('year')
    currentFY =  $rootScope.activeYear.start
    if currentYear != currentFY
      $scope.fromDate.date = $rootScope.fy.financialYearStarts
      $scope.toDate.date = $rootScope.fy.financialYearEnds
      reqParam.fromDate = $scope.fromDate.date
      reqParam.toDate = $scope.toDate.date


  # p&l functions
  $scope.calCulateTotalIncome = (data) ->
    eTtl = 0
    _.each(data, (item) ->
      if item.closingBalance.type is 'DEBIT'
        eTtl -= Number(item.closingBalance.amount)
      else
        eTtl += Number(item.closingBalance.amount)
    )
    return Number((eTtl).toFixed(2))

  $scope.calCulateTotalExpense = (data) ->
    eTtl = 0
    _.each(data, (item) ->
      if item.closingBalance.type is 'CREDIT'
        eTtl -= Number(item.closingBalance.amount)
      else
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
    $scope.plData.expenseTotal = $scope.calCulateTotalExpense(fData.expArr)
    $scope.plData.incomeTotal = $scope.calCulateTotalIncome(fData.incArr)
    clB = $scope.plData.incomeTotal - $scope.plData.expenseTotal

    $scope.plData.closingBalance = Math.abs(clB)

    if $scope.plData.incomeTotal >= $scope.plData.expenseTotal
      #console.info "Income is Greater"
      $scope.inProfit = true
      $scope.plData.expenseTotal += $scope.plData.closingBalance
    if $scope.plData.incomeTotal < $scope.plData.expenseTotal
      #console.info "expenses is Greater"
      $scope.inProfit = false
      $scope.plData.incomeTotal += $scope.plData.closingBalance
    

  $scope.exportPLdataHorizontal = (e) ->
    plData =  $scope.plData
    zippedData = _.zip($scope.plData.expArr, $scope.plData.incArr)
    csv = ''
    row = ''
    header = ''
    title = 'EXPENSES' + ',' + '' + ',' + '' + ',' + 'INCOME' + '' + '\r\n' + 'Particular' + ',' + 'Amount' + ',' + '' + ',' + 'Particular' + ',' + 'Amount' + '\r\n' + '\r\n'
    $scope.fnProfitLoss = "Profit-and-Loss.csv"

    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'Profit and Loss' + ': ' + $filter('date')($scope.fromDate.date,'dd-MM-yyyy') + ' to ' + $filter('date')($scope.toDate.date,
      "dd-MM-yyyy") + '\r\n'
    csv += header + '\r\n' + title

    
    _.each zippedData, (row) ->
      index = 1
      _.each row, (val) ->
        csv += val.groupName + ',' + val.closingBalance.amount + ',' + '' + ',' 
        if index % 2 == 0
          csv += '\r\n'
        index = index + 1

    if plData.closingBalance > 0
      csv += '\r\n' + 'Profit' + ',' + plData.closingBalance + '\r\n'
    else if plData.closingBalance < 0
      csv += '\r\n' + '' + ',' + '' + ',' + '' + 'Loss' + ',' + plData.closingBalance + '\r\n'

    csv += 'Total' + ',' + plData.expenseTotal + ',' + '' + ',' + 'Total' + ',' +  plData.incomeTotal

    csv += row + '\r\n';
    
    $scope.csvPL = csv

    $scope.profitLoss = 'data:text/csv;charset=utf-8,' + escape(csv)
    $scope.plShowOptions = false
    e.stopPropagation()

  $scope.exportPLdataVertical = (e) ->
    plData =  $scope.plData
    csv = ''
    incRow = ''
    expRow = ''
    incTotal = ''
    expTotal = ''
    header = ''
    total = ''
    expTitle = 'EXPENSES' + '\r\n' + 'Particular' + ',' + 'Amount' +  '\r\n'
    incTitle = 'INCOME' + '\r\n' + 'Particular' + ',' + 'Amount' +  '\r\n'
    $scope.fnProfitLoss = "Profit-and-Loss.csv"

    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'Profit and Loss' + ': ' + $filter('date')($scope.fromDate.date,'dd-MM-yyyy') + ' to ' + $filter('date')($scope.toDate.date,
      "dd-MM-yyyy") + '\r\n'
    
    #add income details
    _.each plData.incArr, (inc) ->
      incRow += inc.groupName + ',' + inc.closingBalance.amount + '\r\n'
      if inc.childGroups.length > 0
        _.each inc.childGroups, (cInc) ->
          incRow += '          ' + cInc.groupName + ',' + cInc.closingBalance.amount + '\r\n'

    incTotal += 'Total' + ',' + plData.incomeTotal + '\r\n'
 

    #add expenses details
    _.each plData.expArr, (exp) ->
      expRow += exp.groupName + ',' + exp.closingBalance.amount + '\r\n'
      if exp.childGroups.length > 0
        _.each exp.childGroups, (cExp) ->
          expRow += '          ' + cExp.groupName + ',' + cExp.closingBalance.amount + '\r\n'

    expTotal += 'Total' + ',' + plData.expenseTotal + '\r\n'
    
    if plData.closingBalance >= 0
      total += 'Profit' + ',' + plData.closingBalance
    else
      total += 'Loss' + ',' + plData.closingBalance

    csv += header + '\r\n' + incTitle + '\r\n' + incRow + incTotal + '\r\n' + '\r\n' + expTitle + '\r\n' + expRow + expTotal + '\r\n' + total
    
    $scope.csvPL = csv

    $scope.profitLoss = 'data:text/csv;charset=utf-8,' + escape(csv)
    $scope.plShowOptions = false
    e.stopPropagation()


  $scope.showPLoptions = (e) ->
    $scope.plShowOptions = !$scope.plShowOptions
    e.stopPropagation()

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
    $scope.checkFY(reqParam)
    trialBalService.getAllFor(reqParam).then $scope.getTrialBalSuccess, $scope.getTrialBalFailure

  $scope.getTrialBalSuccess = (res) ->
    $scope.makeDataForPl(res.body)
    $scope.addUIKey(res.body.groupDetails)
    $scope.data = res.body
    $scope.exportData = []
    $scope.data.groupDetails = $scope.orderGroups(res.body.groupDetails)
    $scope.balSheet.assetTotal = $scope.calCulateTotalAssets($scope.balSheet.assets)
    $scope.balSheet.liabTotal = $scope.calCulateTotalLiab($scope.balSheet.liabilities)
    if $scope.inProfit == false
      $scope.balSheet.assetTotal += $scope.plData.closingBalance
    else if $scope.inProfit == true
      $scope.balSheet.liabTotal += $scope.plData.closingBalance
    $scope.exportData = $scope.data.groupDetails
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
    total = {
      ob: 0
      cb: 0
      cr: 0
      dr: 0
    }
    csv = ''
    row = ''
    header = ''
    title = '' + ',' + 'Opening Balance' + ',' + 'Debit' + ',' + 'Credit' + ',' + 'Closing Balance' + '\n'
    $scope.fnGroupWise = "Trial_Balance.csv"
    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'Trial Balance' + ': ' + $filter('date')($scope.fromDate.date,'dd-MM-yyyy') + ' to ' + $filter('date')($scope.toDate.date,
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
      group.isVisible = obj.isVisible
      groups.push group

    _.each groups, (obj) ->
      if obj.isVisible
        row += obj.name + ',' + obj.openingBalance + ' ' + $filter('recType')(obj.openingBalanceType,obj.openingBalance) + ',' + obj.debit + ',' + obj.credit + ',' + obj.closingBalance + $filter('recType')(obj.closingBalanceType,obj.closingBalance) + '\r\n'
        total.ob += obj.openingBalance
        total.cb += obj.closingBalance
        total.cr += obj.credit
        total.dr += obj.debit

    csv += row + '\r\n';
    # csv += '\r\n' + 'Total' + ',' + $scope.filteredTotal.openingBalance + ',' + $scope.filteredTotal.debitTotal + ',' + $scope.filteredTotal.creditTotal + ',' + $scope.filteredTotal.closingBalance + '\n'
    csv += '\r\n' + 'Total' + ',' + total.ob + ',' + total.dr + ',' + total.cr + ',' + total.cb + '\n'
    $scope.csvGW = csv

    $scope.uriGroupWise = 'data:text/csv;charset=utf-8,' + escape(csv)
    $scope.showOptions = true
    e.stopPropagation()

  $scope.formatDataAccountWise = (e) ->
    groups = []
    accounts = []
    childGroups = []
    rawData = $scope.exportData
    total = {
      ob: 0
      cb: 0
      cr: 0
      dr: 0
    }
    $scope.fnAccountWise = "Trial_Balance_account-wise.csv"
    row = ''
    title = ''
    body = ''
    footer = ''
    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'Trial Balance' + ': ' + $filter('date')($scope.fromDate.date,
        "dd-MM-yyyy") + ' to ' + $filter('date')($scope.toDate.date,
        "dd-MM-yyyy") + '\r\n'

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

    createCsv = (data)->
      _.each data, (obj) ->
        row = row or
          ''
        if obj.isVisible == true
          row += obj.name + ' (' + obj.parent  + ')' + ',' + obj.openingBalance+ ' ' + $filter('recType')(obj.openingBalanceType ,obj.openingBalance) +  ',' + obj.debit + ',' + obj.credit + ',' + obj.closingBalance + ',' + $filter('recType')(obj.closingBalanceType,obj.closingBalance) + '\r\n'
          total.ob += obj.openingBalance
          total.cb += obj.closingBalance
          total.cr += obj.credit
          total.dr += obj.debit

      body += row + '\r\n'

    createCsv(accounts)
    footer += 'Total' + ',' + total.ob + ',' + total.dr + ',' + total.cr + ',' + total.cb + '\n'
    csv = header + '\r\n\r\n' + title + '\r\n' + body + footer

    $scope.csvAW = csv
    $scope.uriAccountWise = 'data:text/csv;charset=utf-8,' + escape(csv)
    $scope.showOptions = true
    e.stopPropagation()

  $scope.formatDataCondensed = (e) ->
    rawData = $scope.exportData
    groupData = []
    total = {
      ob: 0
      cb: 0
      cr: 0
      dr: 0
    }
    csv = ''
    title = ''
    body = ''
    footer = ''
    companyDetails = $rootScope.selectedCompany
    header = companyDetails.name + '\r\n' + '"'+ companyDetails.address+'"' + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'Trial Balance' + ': ' + $filter('date')($scope.fromDate.date,
        "dd-MM-yyyy") + ' to ' + $filter('date')($scope.toDate.date,
        "dd-MM-yyyy") + '\r\n'

    $scope.fnCondensed = "Trial_Balance_condensed.csv"
    sortData = (parent, groups) ->
      _.each parent, (obj) ->
        group = group or
          accounts: []
          childGroups: []
        group.name = obj.groupName
        group.openingBalance = obj.forwardedBalance.amount
        group.openingBalanceType = obj.forwardedBalance.type
        group.credit = obj.creditTotal
        group.debit = obj.debitTotal
        group.closingBalance = obj.closingBalance.amount
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
                childGroup.accounts = childGroup.accounts or
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
                childGroup.accounts.push account

            if grp.childGroups.length > 0
              sortData(grp.childGroups, childGroup.childGroups)
        groups.push group

    sortData(rawData, groupData)

    title += 'Name' + ',' + 'Opening Balance' + ',' + 'Debit' + ',' + 'Credit' + ',' + 'Closing Balance' + '\r\n'
    # footer += 'Total' + ',' + $scope.filteredTotal.openingBalance + ',' + $scope.filteredTotal.debitTotal + ',' + $scope.filteredTotal.creditTotal + ',' + $scope.filteredTotal.closingBalance + '\n'

    createCsv = (csvObj) ->
      #console.log csvObj, 'csvObj'
      index = 0
      bodyGen = (csvObj, index) ->
        bd = ''
        _.each csvObj, (obj) ->
          row = '';
          strIndex = ''
          (strIndex += '   ' for i in [0...index])
          if obj.isVisible == true && obj.closingBalance != 0
            row += strIndex + obj.name.toUpperCase() + ',' + obj.openingBalance + $filter('recType')(obj.openingBalanceType,obj.openingBalance) + ',' + obj.debit + ',' + obj.credit + ',' + obj.closingBalance + $filter('recType')(obj.closingBalanceType,obj.ClosingBalance) + '\r\n'
            if obj.accounts.length > 0
              _.each obj.accounts, (acc) ->
                if acc.isVisible == true
                  row += strIndex + '   ' +$scope.firstCapital(acc.name.toLowerCase()) + ' (' + $scope.firstCapital(obj.name) + ')' + ',' + acc.openingBalance + $filter('recType')(acc.openingBalanceType,acc.openingBalance) + ',' + acc.debit + ',' + acc.credit + ',' + acc.closingBalance + $filter('recType')(acc.closingBalanceType,acc.closingBalance) + '\r\n'
                  total.ob += acc.openingBalance
                  total.cb += acc.closingBalance
                  total.cr += acc.credit
                  total.dr += acc.debit
            if obj.childGroups.length > 0
             row += bodyGen(obj.childGroups, index+1)
          bd += row
        bd
      body = bodyGen(csvObj, 0)
      footer += 'Total' + ',' + total.ob + ',' + total.dr + ',' + total.cr + ',' + total.cb + '\n'
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
      $scope.plShowOptions = false
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
    $scope.balSheet.assets = []
    $scope.balSheet.liabilities = []
    _.each data, (grp) ->
      switch grp.category
        when 'assets'
          assets.push(grp)
          $scope.balSheet.assets.push(grp)
        when 'liabilities'
          liabilities.push(grp)
          $scope.balSheet.liabilities.push(grp)
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
    if newVal != oldVal
      $scope.enableDownload = false
  )

  # for Balance sheet

  $scope.calCulateTotalAssets = (data) ->
    total = 0
    _.each data, (obj) ->
      if obj.closingBalance.type == 'CREDIT'
        total -= obj.closingBalance.amount
      else
        total += obj.closingBalance.amount
    total

  $scope.calCulateTotalLiab = (data) ->
    total = 0
    _.each data, (obj) ->
      if obj.closingBalance.type == 'DEBIT'
        total -= obj.closingBalance.amount
      else
        total += obj.closingBalance.amount
    total

  

giddh.webApp.controller 'tbplController', tbplController