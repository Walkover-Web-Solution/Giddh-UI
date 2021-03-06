"use strict"

tbplController = ($scope, $rootScope, trialBalService, localStorageService, $filter, toastr, $timeout, $window, companyServices, $state, FileSaver) ->
  tb = this
  $scope.showTbplLoader = true
  $scope.showBSLoader = true
  $scope.showPLLoader = true
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
  $scope.showTbXls = false
  $scope.showNLevel = false
  $rootScope.cmpViewShow = true
  $scope.showClearSearch = false
  $scope.noData = false
  $scope.enableDownload = true
  $scope.keyWord = {
    query: ''
  }
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

  $scope.hardRefresh = false
  $scope.bsHardRefresh = false
  $scope.plHardRefresh = false

  $scope.fyChecked = false

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  $scope.activeFinancialYear = localStorageService.get("activeFY")

  tb.getActiveFinancialYearIndex = (activeFY, financialYears) ->
    $scope.tempFYIndex = 0
    _.each financialYears, (fy, index) ->
      if fy.uniqueName == activeFY.uniqueName
        if(index == 0)
          $scope.tempFYIndex = index
        else
          $scope.tempFYIndex = index * -1
    return $scope.tempFYIndex 

  $scope.getFYs = (companyUniqueName) ->
    @fySuccess = (res) ->
      $scope.financialYears = res.body.financialYears
      $scope.activeBSFYIndex = tb.getActiveFinancialYearIndex($scope.activeFinancialYear, $scope.financialYears)
      $scope.activePLFYIndex = tb.getActiveFinancialYearIndex($scope.activeFinancialYear, $scope.financialYears)
    @fyFailure = (res) ->
      toastr.error(res.data.message)
    companyServices.getFY(companyUniqueName).then @fySuccess, @fyFailure    

  $scope.activeBSFYIndex = 0
  $scope.activePLFYIndex = 0
  $scope.financialYears = []
  $scope.getFYs($rootScope.selectedCompany.uniqueName)

  # financial year functions
  $rootScope.setActiveFinancialYear($scope.activeFinancialYear)

  $scope.getDateObj = (date) ->
    dateArray = date.split('-')
    date = new Date(dateArray[2], dateArray[1] - 1, dateArray[0])
    date 

  $scope.checkFY = (reqParam) ->
    currentYear = moment().get('year')
    currentFY =  $rootScope.activeYear.start
    $scope.fromDate.date = $scope.getDateObj($rootScope.fy.financialYearStarts)
    $scope.toDate.date = $scope.getDateObj($rootScope.fy.financialYearEnds)
    reqParam.fromDate = $filter('date')($scope.fromDate.date, 'dd-MM-yyyy')
    reqParam.toDate = $filter('date')($scope.toDate.date, 'dd-MM-yyyy')

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


  $scope.filterBSData = (data) ->
    $scope.balSheet.assets = []
    $scope.balSheet.liabilities = []
    _.each data, (grp) ->
      switch grp.category
        when 'assets'
          $scope.balSheet.assets.push(grp)
        when 'liabilities'
          $scope.balSheet.liabilities.push(grp)

  $scope.makeDataForBS = (data) ->
    $scope.filterBSData(data.groupDetails)
    $scope.balSheet.assetTotal = $scope.calCulateTotalAssets($scope.balSheet.assets)
    $scope.balSheet.liabTotal = $scope.calCulateTotalLiab($scope.balSheet.liabilities)
    # if $scope.inProfit == false
    #   $scope.balSheet.assetTotal += $scope.plData.closingBalance
    # else if $scope.inProfit == true
    #   $scope.balSheet.liabTotal += $scope.plData.closingBalance

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

  # $scope.fromDate = {
  #   date: $scope.getDefaultDate().date
  # }

  $scope.setRefresh = () ->
    $scope.hardRefresh = true

  $scope.setRefreshForBalanceSheet = () ->
    $scope.bsHardRefresh = true

  $scope.setRefreshForProfitLoss = () ->
    $scope.plHardRefresh = true

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
#    console.log($scope.hardRefresh)
    if $scope.hardRefresh == true
      reqParam = {
        'companyUniqueName': $rootScope.selectedCompany.uniqueName
        'fromDate': data.fromDate
        'toDate': data.toDate
        'refresh': true
      }
    #$scope.checkFY(reqParam)
    trialBalService.getAllFor(reqParam).then $scope.getTrialBalSuccess, $scope.getTrialBalFailure

  $scope.count = 0
  $scope.detailedGroups = []
  $scope.getTrialBalSuccess = (res) ->
    # $scope.makeDataForPl(res.body)
    $scope.exportData = []
    $scope.addUIKey(res.body.groupDetails)
    $scope.count = 0
    $scope.detailedGroups = $scope.removeZeroAmountAccount(res.body.groupDetails)
    $scope.removeZeroAmountGroup($scope.detailedGroups)
    angular.copy($scope.detailedGroups,$scope.exportData)
    $scope.removeSd($scope.detailedGroups)
    $scope.data = res.body
    $scope.data.groupDetails = $scope.orderGroups($scope.detailedGroups)
    # $scope.balSheet.assetTotal = $scope.calCulateTotalAssets($scope.balSheet.assets)
    # $scope.balSheet.liabTotal = $scope.calCulateTotalLiab($scope.balSheet.liabilities)
    # if $scope.inProfit == false
    #   $scope.balSheet.assetTotal += $scope.plData.closingBalance
    # else if $scope.inProfit == true
    #   $scope.balSheet.liabTotal += $scope.plData.closingBalance
    if $scope.data.closingBalance.amount is 0 and $scope.data.creditTotal is 0 and $scope.data.debitTotal is 0 and $scope.data.forwardedBalance.amount is 0
      $scope.noData = true
    else
      $scope.noData = false
    $scope.showTbplLoader = false
    $scope.hardRefresh = false

  $scope.removeZeroAmountAccount = (grpList) ->
    _.each grpList, (grp) ->
      tempAcc = []
      count = 0
      if grp.closingBalance.amount > 0 || grp.forwardedBalance.amount > 0 || grp.creditTotal > 0 || grp.debitTotal > 0
        _.each(grp.accounts, (account) ->
          if account.closingBalance.amount > 0 || account.openingBalance.amount > 0 || account.creditTotal > 0 || account.debitTotal > 0
            tempAcc.push(account)
          else
            count = count + 1
        )
#      console.log("= 0 ", grp.groupName + " are " + count)
#      console.log("> 0 ", grp.groupName + " are " + tempAcc.length)
      if tempAcc.length > 0
        grp.accounts = tempAcc
      if grp.childGroups.length > 0
        $scope.removeZeroAmountAccount(grp.childGroups)
    grpList

  $scope.removeZeroAmountGroup = (grpList) ->
    _.each grpList, (grp) ->
      if grp.childGroups.length > 0
        $scope.removeZeroAmountGroup(grp.childGroups)
      _.reject(grp.childGroups, (cGrp) ->
        return if cGrp.closingBalance.amount == 0 && cGrp.forwardedBalance.amount == 0 && cGrp.creditTotal == 0 && cGrp.debitTotal == 0
      )

  $scope.removeSd = (data) ->
    count = 0
    _.each data, (grp) ->
      if grp.childGroups.length > 0
        _.each grp.childGroups, (ch) ->
          count = $scope.countAccounts(ch)
          if ch.uniqueName == $rootScope.groupName.sundryDebtors
            if count > 50
              ch.accounts = []
              if ch.childGroups.length > 0
                $scope.removeAcc(ch)


  $scope.countAccounts = (group) ->
    count = 0
    if group.childGroups.length > 0
      _.each(group.childGroups, (grp) ->
        count = count + grp.accounts.length
        if grp.childGroups.length > 0
          count = count + $scope.countAccounts(grp)
      )
    count

  $scope.removeAcc = (grp) ->
    grp.accounts = []
    if grp.childGroups.length > 0
      _.each grp.childGroups, (ch) ->
        $scope.removeAcc(ch)

  $scope.getTrialBalFailure = (res) ->
    $scope.hardRefresh = false
    toastr.error(res.data.message, res.data.status)
    $scope.showTbplLoader = false

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


  if $scope.sendRequest
    dateObj = {
      'fromDate': $filter('date')($scope.getDefaultDate().date,'dd-MM-yyyy')
      'toDate': $filter('date')($scope.toDate.date, "dd-MM-yyyy")
    }
    $scope.checkFY(dateObj)
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
        if obj.openingBalanceType == "DEBIT"
          total.ob = total.ob + obj.openingBalance
        else
          total.ob = total.ob - obj.openingBalance
        if obj.closingBalanceType == "DEBIT"
          total.cb = total.cb + obj.closingBalance
        else
          total.cb = total.cb - obj.closingBalance
#        total.ob += obj.openingBalance
#        total.cb += obj.closingBalance
        total.cr += obj.credit
        total.dr += obj.debit

    if total.ob < 0
      total.ob = total.ob * -1
      total.ob = total.ob + " Cr"
    else
      total.ob = total.ob + " Dr"
    if total.cb < 0
      total.cb = total.cb * -1
      total.cb = total.cb + " Cr"
    else
      total.cb = total.cb + " Dr"
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
          if obj.openingBalanceType == "DEBIT"
            total.ob = total.ob + obj.openingBalance
          else
            total.ob = total.ob - obj.openingBalance
          if obj.closingBalanceType == "DEBIT"
            total.cb = total.cb + obj.closingBalance
          else
            total.cb = total.cb - obj.closingBalance
          #        total.ob += obj.openingBalance
          #        total.cb += obj.closingBalance
          total.cr += obj.credit
          total.dr += obj.debit

      if total.ob < 0
        total.ob = total.ob * -1
        total.ob = total.ob + " Cr"
      else
        total.ob = total.ob + " Dr"
      if total.cb < 0
        total.cb = total.cb * -1
        total.cb = total.cb + " Cr"
      else
        total.cb = total.cb + " Dr"
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
              accounts: []
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
            if obj.accounts == undefined
              console.log obj
            if obj.accounts.length > 0
              _.each obj.accounts, (acc) ->
                if acc.isVisible == true
                  row += strIndex + '   ' +$scope.firstCapital(acc.name.toLowerCase()) + ' (' + $scope.firstCapital(obj.name) + ')' + ',' + acc.openingBalance + $filter('recType')(acc.openingBalanceType,acc.openingBalance) + ',' + acc.debit + ',' + acc.credit + ',' + acc.closingBalance + $filter('recType')(acc.closingBalanceType,acc.closingBalance) + '\r\n'
                  if acc.openingBalanceType == "DEBIT"
                    total.ob = total.ob + acc.openingBalance
                  else
                    total.ob = total.ob - acc.openingBalance
                  if acc.closingBalanceType == "DEBIT"
                    total.cb = total.cb + acc.closingBalance
                  else
                    total.cb = total.cb - acc.closingBalance
#                  total.ob += acc.openingBalance
#                  total.cb += acc.closingBalance
                  total.cr += acc.credit
                  total.dr += acc.debit
              if total.ob < 0
                total.ob = total.ob * -1
                total.ob = total.ob + " Cr"
              else
                total.ob = total.ob + " Dr"
              if total.cb < 0
                total.cb = total.cb * -1
                total.cb = total.cb + " Cr"
              else
                total.cb = total.cb + " Dr"
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

  $scope.showTbXlsOptions = (e) ->
    $scope.showTbXls = true
    e.stopPropagation()

  $scope.downloadTbXls = (exportType) ->
    $timeout ( ->
      $scope.showOptions = false
      $scope.showTbXls = false
    ), 100
    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'fromDate': $filter('date')($scope.fromDate.date,'dd-MM-yyyy')
      'toDate': $filter('date')($scope.toDate.date, 'dd-MM-yyyy')
      'exportType': exportType
      'query':$scope.keyWord.query
    }
    trialBalService.downloadTBExcel(reqParam).then $scope.downloadTBExcelSuccess, $scope.downloadTBExcelFailure

  $scope.downloadTBExcelSuccess = (res) ->
    data = tb.b64toBlob(res.body, "application/xml", 512)
    FileSaver.saveAs(data, "trialbalance.xlsx")

  $scope.downloadTBExcelFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
    
    
  $(document).on 'click', (e) ->
    $timeout (->
      $scope.showOptions = false
      $scope.plShowOptions = false
      $scope.showpdf = false
      $scope.showTbXls = false
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
          # $scope.balSheet.assets.push(grp)
        when 'liabilities'
          liabilities.push(grp)
          # $scope.balSheet.liabilities.push(grp)
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

  $scope.getBalanceSheetData = () ->
    $scope.showBSLoader = true
    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'refresh': $scope.bsHardRefresh
      'fy': $scope.activeBSFYIndex
    }
    trialBalService.getBalSheet(reqParam).then $scope.getBalanceSheetDataSuccess, $scope.getBalanceSheetDataFailure

  $scope.getProfitLossData = () ->
    $scope.showPLLoader = true
    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'refresh': $scope.plHardRefresh
      'fy': $scope.activePLFYIndex
    }
    trialBalService.getPL(reqParam).then $scope.getPLSuccess, $scope.getPLFailure

  $scope.getBalanceSheetDataSuccess = (res) ->
    $scope.makeDataForBS(res.body)
    $scope.bsHardRefresh = false
    $scope.showBSLoader = false

  $scope.getPLSuccess = (res) ->
    $scope.makeDataForPl(res.body)
    $scope.plHardRefresh = false
    $scope.showPLLoader = false

  $scope.getBalanceSheetDataFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
    $scope.bsHardRefresh = false
    $scope.showBSLoader = false

  $scope.getPLFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
    $scope.plHardRefresh = false
    $scope.showPLLoader = false

  $timeout (->
    $scope.getBalanceSheetData()
  ), 1000

  $timeout (->
    $scope.getProfitLossData()
  ), 1000
  
  $scope.changeBSFYIdx = (item) ->
    _.each $scope.financialYears, (fy, index) ->
      if(fy.uniqueName == item.uniqueName)
        if index == 0
          $scope.activeBSFYIndex = index
        else
          $scope.activeBSFYIndex = index * -1

  $scope.changePLFYIdx = (item) ->
    _.each $scope.financialYears, (fy, index) ->
      if(fy.uniqueName == item.uniqueName)
        if index == 0
          $scope.activePLFYIndex = index
        else
          $scope.activePLFYIndex = index * -1

  $scope.downloadBSExcel = () ->
    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'fy': $scope.activeBSFYIndex
    }
    trialBalService.downloadBSExcel(reqParam).then $scope.downloadBSExcelSuccess, $scope.downloadBSExcelFailure

  $scope.downloadPLExcel = () ->
    reqParam = {
      'companyUniqueName': $rootScope.selectedCompany.uniqueName
      'fy': $scope.activePLFYIndex
    }
    trialBalService.downloadPLExcel(reqParam).then $scope.downloadPLExcelSuccess, $scope.downloadPLExcelFailure

  $scope.downloadBSExcelSuccess = (res) ->
    data = tb.b64toBlob(res.body, "application/xml", 512)
    FileSaver.saveAs(data, "balancesheet.xlsx")

  $scope.downloadPLExcelSuccess = (res) ->
    data = tb.b64toBlob(res.body, "application/xml", 512)
    FileSaver.saveAs(data, "profitloss.xlsx")

  $scope.downloadBSExcelFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.downloadPLExcelFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  tb.b64toBlob = (b64Data, contentType, sliceSize) ->
    contentType = contentType or ''
    sliceSize = sliceSize or 512
    byteCharacters = atob(b64Data)
    byteArrays = []
    offset = 0
    while offset < byteCharacters.length
      slice = byteCharacters.slice(offset, offset + sliceSize)
      byteNumbers = new Array(slice.length)
      i = 0
      while i < slice.length
        byteNumbers[i] = slice.charCodeAt(i)
        i++
      byteArray = new Uint8Array(byteNumbers)
      byteArrays.push byteArray
      offset += sliceSize
    blob = new Blob(byteArrays, type: contentType)
    blob  

  $rootScope.$on 'company-changed' , (event, data) ->
    if data.type == 'CHANGE'
      $state.reload()
 

giddh.webApp.controller 'tbplController', tbplController