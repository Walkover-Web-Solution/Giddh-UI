"use strict"

ledgerController = ($scope, $rootScope, localStorageService, toastr, groupService, modalService, accountService, ledgerService, $filter, locationService) ->
  $scope.accntTitle = undefined
  $scope.showLedgerBox = true

  #date time picker code starts here
  $scope.today = new Date()
  $scope.fromDate = {date: new Date()}
  $scope.toDate = {date: new Date()}
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }

  $scope.format = "dd-MM-yyyy"

  # ledger
  # load ledger start
  $scope.loadLedger = (data, acData) ->
    $scope.accntTitle = acData.name
    $scope.showLedgerBox = true

    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: data.groupUniqueName
      acntUname: acData.uniqueName
      fromDate: $filter('date')($scope.fromDate.date,"dd-MM-yyyy")
      toDate: $filter('date')($scope.toDate.date,"dd-MM-yyyy")
    }
    ledgerService.getLedger(unqNamesObj).then($scope.loadLedgerSuccess, $scope.loadLedgerFailure)

  $scope.loadLedgerSuccess = (response) ->
    console.log response, "loadLedgerSuccess"
    # $scope.ledgerData = response.body

  $scope.loadLedgerFailure = (response) ->
    console.log response

  $scope.addCrossFormField = (i, d, c) ->
    console.log i, d, c, 'addCrossFormField'

  $scope.addNewAccount = () ->
    console.log "addNewAccount"
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalService.openManageGroupsModal()

  $scope.discardEntry = () ->
    console.log "discardEntry"

  $scope.updateEntry = (data) ->
    console.log "updateEntry", data

  $scope.voucherTypeList = [
    {
      name: "sales"
      shortCode: "sal"
    }
    {
      name: "Purchases"
      shortCode: "pur"
    }
    {
      name: "Receipt"
      shortCode: "rcpt"
    }
    {
      name: "Payment"
      shortCode: "pay"
    }
    {
      name: "Journal"
      shortCode: "jr"
    }
  ]

  $scope.dynamicPopover = {
    content: 'Hello, World!',
    templateUrl: 'myPopoverTemplate.html',
    title: 'Title'
  }

  $scope.ledgerData = {
    "broughtForwardBalance": {
      "amount": 0,
      "type": "CREDIT"
    },
    "creditTotal": 4008,
    "debitTotal": 4008,
    "balance": {
      "amount": 4008,
      "type": "CREDIT"
    },
    "ledgers": [
      {
        "transactions": [
          {
            "particular": {
              "name": "Sarfaraz",
              "uniqueName": "temp"
            },
            "amount": 1001,
            "type": "DEBIT"
          }
        ],
        "description": "testing",
        "tag": "testing",
        "uniqueName": "khb1445237230952",
        "voucher": {
          "name": "sales",
          "shortCode": "sal"
        },
        "entryDate": "02-06-2015",
        "voucherNo": 1007
      },
      {
        "transactions": [
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "bank"
            },
            "amount": 2001,
            "type": "DEBIT"
          },
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "cake"
            },
            "amount": 3001,
            "type": "DEBIT"
          }
        ],
        "description": "testing",
        "tag": "testing",
        "uniqueName": "tdq1445237034341",
        "voucher": {
          "name": "sales",
          "shortCode": "sal"
        },
        "entryDate": "12-09-2015",
        "voucherNo": 1003
      },
      {
        "transactions": [
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "bank"
            },
            "amount":4001,
            "type": "DEBIT"
          },
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "cake"
            },
            "amount": 5001,
            "type": "DEBIT"
          }
        ],
        "description": "testing",
        "tag": "testing",
        "uniqueName": "ycc1445237041390",
        "voucher": {
          "name": "sales",
          "shortCode": "sal"
        },
        "entryDate": "13-09-2015",
        "voucherNo": 1004
      },
      {
        "transactions": [
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "temp"
            },
            "amount": 6001,
            "type": "DEBIT"
          },
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "water"
            },
            "amount": 7001,
            "type": "DEBIT"
          }
        ],
        "description": "testing",
        "tag": "testing",
        "uniqueName": "l471445237226558",
        "voucher": {
          "name": "sales",
          "shortCode": "sal"
        },
        "entryDate": "12-09-2015",
        "voucherNo": 1006
      }
    ]
  }

  $rootScope.$on '$viewContentLoaded', ->
    $scope.fromDate.date.setDate(1)
    

angular.module('giddhWebApp').controller 'ledgerController', ledgerController