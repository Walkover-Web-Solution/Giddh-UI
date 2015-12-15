"use strict"

trialBalanceController = ($scope, $rootScope, trialBalService, localStorageService, $filter, toastr, $timeout, $window) ->
  $scope.expanded = false
  #date time picker code starts here
  $scope.today = new Date()
  $scope.fromDate = {date: new Date()}
  $scope.toDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.showOptions = false
  $scope.showChildren = false
  $scope.sendRequest = true
  $rootScope.cmpViewShow = true
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }

  $scope.format = "dd-MM-yyyy"

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

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
    dateObj =
      'fromDate': $filter('date')($scope.getDefaultDate().date,'dd-MM-yyyy')
      'toDate': $filter('date')($scope.toDate.date, 'dd-MM-yyyy')
    $scope.expanded = false

    $rootScope.showLedgerBox = false
    dateObj.fromDate = $filter('date')($scope.fromDate.date, 'dd-MM-yyyy')
    dateObj.toDate = $filter('date')($scope.toDate.date, 'dd-MM-yyyy')
    $scope.getTrialBal dateObj

  #expand accordion on search
  $scope.expandAccordion = (e) ->
    $timeout (->
      l = e.currentTarget.value.length
      if l > 0
        $scope.expanded = true
      else
        $scope.expanded = false
    ), 100
    console.log trialBalanceController.accordion 

  $scope.$on '$viewContentLoaded', ->
    if $scope.sendRequest
      dateObj = {
        'fromDate': $filter('date')($scope.getDefaultDate().date,'dd-MM-yyyy')
        'toDate': $filter('date')($scope.toDate.date, "dd-MM-yyyy")
      }
      $scope.getTrialBal(dateObj)
      $scope.sendRequest = false

  $scope.typeFilter = (input) ->
    switch input
      when 'DEBIT'
        input = "Dr."
      when 'CREDIT'
        input = "Cr."
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
      row += obj.name + ',' + obj.openingBalance + ' ' + $scope.typeFilter(obj.openingBalanceType) + ',' + obj.debit + ',' + obj.credit + ',' + obj.closingBalance + ',' + $scope.typeFilter(obj.closingBalanceType) + '\r\n'

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
    header = companyDetails.name + '\r\n' + companyDetails.address + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'CIN: U72400MP2010PTC023806' + '\r\n' + 'Trial Balance' + ': ' + $scope.fromDate.date + ' to ' + $filter('date')($scope.toDate.date,
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
        row += obj.name + ',' + obj.debit + ',' + obj.credit + ',' + obj.closingBalance + ',' + $scope.typeFilter(obj.closingBalanceType) + '\r\n'
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
    header = companyDetails.name + '\r\n' + companyDetails.address + '\r\n' + companyDetails.city + '-' + companyDetails.pincode + '\r\n' + 'CIN: U72400MP2010PTC023806' + '\r\n' + 'Trial Balance' + ': ' + $scope.fromDate.date + ' to ' + $filter('date')($scope.toDate.date,
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
        row += obj.Name + ',' + obj.Debit + ',' + obj.Credit + ',' + obj.ClosingBalance + ',' + $scope.typeFilter(obj.closingBalanceType) + '\r\n'

        if obj.accounts.length > 0
          _.each obj.accounts, (acc) ->
            row += acc.name + ' (' + obj.Name + ')' + ',' + acc.debit + ',' + acc.credit + ',' + acc.closingBalance + ',' + $scope.typeFilter(acc.closingBalanceType) +'\r\n'

        if obj.childGroups.length > 0
          _.each obj.childGroups, (grp) ->
            if grp.closingBalance != 0
              row += grp.name + ' (' + obj.Name + ')' + ',' + grp.debit + ',' + grp.credit + ',' + grp.closingBalance + ',' + $scope.typeFilter(grp.closingBalanceType) + '\r\n'

            if grp.subGroups.length > 0
              _.each grp.subGroups, (subgrp) ->
                if subgrp.name
                  row += subgrp.name + ' (' + grp.name + ')' + ',' + subgrp.debit + ',' + subgrp.credit + ',' + subgrp.closingBalance + ',' + $scope.typeFilter(subgrp.closingBalanceType) +'\r\n'
                  createCsv(grp.subGroups)

            if grp.subAccounts.length > 0
              _.each grp.subAccounts, (acc) ->
                row += acc.name + ' (' + grp.name + ')' + ',' + acc.debit + ',' + acc.credit + ',' + acc.closingBalance + ',' + $scope.typeFilter(acc.closingBalanceType) + '\r\n'

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
    ), 100
    e.stopPropagation()
    
  $(document).on 'click', (e) ->
    $timeout (->
      $scope.showOptions = false
    ), 100

  $scope.addData = ->
    if $scope.showChildren == false
      $scope.showChildren = true

angular.module('giddhWebApp').controller 'trialBalanceController', trialBalanceController