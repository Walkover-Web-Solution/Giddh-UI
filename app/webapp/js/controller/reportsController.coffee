"use strict"
reportsController = ($scope, $rootScope, localStorageService, toastr, groupService, $filter) ->

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
    data = graphData.body
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

    #method to get grpah data here
    $scope.formatGraphData($scope.graphData)



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





    


  $scope.graphData = {
    "status": "success",
    "body": {
      "groups": [
        {
          "name": "group2",
          "uniqueName": "group2",
          "intervalBalances": [
            {
              "to": "2015-12-08",
              "from": "2015-12-06",
              "openingBalance": {
                "amount":0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 2000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-11",
              "from": "2015-12-09",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 3000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-14",
              "from": "2015-12-12",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 1000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-17",
              "from": "2015-12-15",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 500,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-20",
              "from": "2015-12-18",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 4000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-23",
              "from": "2015-12-21",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 6000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-26",
              "from": "2015-12-24",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 2000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-29",
              "from": "2015-12-27",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 2500,
                "type": "DEBIT"
              }
            },
            {
              "to": "2016-01-01",
              "from": "2015-12-30",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 7000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2016-01-04",
              "from": "2016-01-02",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 0,
                "type": "DEBIT"
              }
            },
            {
              "to": "2016-01-06",
              "from": "2016-01-05",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 8000,
              "debitTotal": 15000,
              "closingBalance": {
                "amount": 7000,
                "type": "CREDIT"
              }
            }
          ]
        },
        {
          "name": "group1",
          "uniqueName": "group1",
          "intervalBalances": [
            {
              "to": "2015-12-08",
              "from": "2015-12-06",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 3000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-11",
              "from": "2015-12-09",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 2000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-14",
              "from": "2015-12-12",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 6000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-17",
              "from": "2015-12-15",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 9000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-20",
              "from": "2015-12-18",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 2500,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-23",
              "from": "2015-12-21",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 2200,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-26",
              "from": "2015-12-24",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 1000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-29",
              "from": "2015-12-27",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 5500,
                "type": "DEBIT"
              }
            },
            {
              "to": "2016-01-01",
              "from": "2015-12-30",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 6500,
                "type": "DEBIT"
              }
            },
            {
              "to": "2016-01-04",
              "from": "2016-01-02",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 0,
                "type": "DEBIT"
              }
            },
            {
              "to": "2016-01-06",
              "from": "2016-01-05",
              "openingBalance": {
                "amount": 3000,
                "type": "CREDIT"
              },
              "creditTotal": 16000,
              "debitTotal": 18000,
              "closingBalance": {
                "amount": 2000,
                "type": "CREDIT"
              }
            }
          ]
        },
        {
          "name": "group",
          "uniqueName": "group",
          "intervalBalances": [
            {
              "to": "2015-12-08",
              "from": "2015-12-06",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 1000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-11",
              "from": "2015-12-09",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 2000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-14",
              "from": "2015-12-12",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 3000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-17",
              "from": "2015-12-15",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 1500,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-20",
              "from": "2015-12-18",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 12000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-23",
              "from": "2015-12-21",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 2000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-26",
              "from": "2015-12-24",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 0,
                "type": "DEBIT"
              }
            },
            {
              "to": "2015-12-29",
              "from": "2015-12-27",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 3000,
                "type": "DEBIT"
              }
            },
            {
              "to": "2016-01-01",
              "from": "2015-12-30",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 1500,
                "type": "DEBIT"
              }
            },
            {
              "to": "2016-01-04",
              "from": "2016-01-02",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 0,
              "debitTotal": 0,
              "closingBalance": {
                "amount": 2400,
                "type": "DEBIT"
              }
            },
            {
              "to": "2016-01-06",
              "from": "2016-01-05",
              "openingBalance": {
                "amount": 0,
                "type": "CREDIT"
              },
              "creditTotal": 24000,
              "debitTotal": 15000,
              "closingBalance": {
                "amount": 9000,
                "type": "DEBIT"
              }
            }
          ]
        }
      ],
      "accounts": []
    }
  }














#init angular app
giddh.webApp.controller 'reportsController', reportsController
