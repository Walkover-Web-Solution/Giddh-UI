"use strict"

ledgerController = ($scope, $rootScope, localStorageService, toastr, groupService, modalService, accountService, ledgerService, $filter, locationService) ->
  $scope.accntTitle = undefined
  $scope.showLedgerBox = false
  $scope.selectedAccountUname = undefined
  $scope.selectedGroupUname = undefined

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
  $scope.ftypeAdd = "add"
  $scope.ftypeUpdate = "update"
  $scope.dummyValueDebit = 
  {
    "transactions": [
      {
        "particular": {
          "name": "",
          "uniqueName": ""
        },
        "amount": "",
        "type": "DEBIT"
      }
    ],
    "description": "",
    "tag": "test",
    "uniqueName": undefined,
    "voucher": {
      "name": "sales"
      "shortCode": "sal"
    },
    "entryDate": ""
  }
  $scope.dummyValueCredit = 
  {
    "transactions": [
      {
        "particular": {
          "name": "",
          "uniqueName": ""
        },
        "amount": "",
        "type": "CREDIT"
      }
    ],
    "description": "",
    "tag": "",
    "uniqueName": undefined,
    "voucher": {
      "name": "sales"
      "shortCode": "sal"
    },
    "entryDate": ""
  }
  

  # ledger
  # load ledger start
  $scope.loadLedger = (data, acData) ->

    $scope.accntTitle = acData.name
    $scope.selectedAccountUname = acData.uniqueName 
    $scope.selectedGroupUname = data.groupUniqueName

    # console.log $scope.selectedAccountUname, $scope.selectedGroupUname

    unqNamesObj = {
      compUname: $scope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUname
      fromDate: $filter('date')($scope.fromDate.date,"dd-MM-yyyy")
      toDate: $filter('date')($scope.toDate.date,"dd-MM-yyyy")
    }
    ledgerService.getLedger(unqNamesObj).then($scope.loadLedgerSuccess, $scope.loadLedgerFailure)

  $scope.loadLedgerSuccess = (response) ->
    console.log response, "loadLedgerSuccess"
    response.body.ledgers.push($scope.dummyValueDebit)
    response.body.ledgers.push($scope.dummyValueCredit)
    $scope.ledgerData = response.body
    $scope.showLedgerBox = true
    
  $scope.debitOnly = (ledger) ->
    'DEBIT' == ledger.transactions[0].type
  
  $scope.creditOnly = (ledger) ->
    'CREDIT' == ledger.transactions[0].type  

  $scope.loadLedgerFailure = (response) ->
    console.log response


  $scope.addNewAccount = () ->
    console.log "addNewAccount"
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalService.openManageGroupsModal()

  $scope.discardEntry = () ->
    console.log "discardEntry"

  
  $scope.addNewEntry = (data) ->
    console.log "addNewEntry"
    # $scope.edata = undefined
    edata = {}
    angular.copy(data, edata)
    
    if angular.isUndefined(data.voucher)
      console.log "true"
    else
      edata.voucherType = data.voucher.shortCode

    if angular.isObject(data.transactions[0].particular)
      unk = data.transactions[0].particular.uniqueName
      edata.transactions[0].particular = unk

    console.log "hurray", edata

    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUname
    }
    ledgerService.createEntry(unqNamesObj, edata).then($scope.addEntrySuccess, $scope.addEntryFailure)

  $scope.addEntrySuccess = (response) ->
    console.log response, "addEntrySuccess"
    
    console.log $scope.ledgerData, "before"
    # $scope.addNewRow('debit')
    # $scope.ledgerData.ledgers.unshift(dummyresponse)


  $scope.addEntryFailure = (response) ->
    console.log response, "addEntryFailure"


  $scope.updateEntry = (edata) ->
    console.log "updateEntry"
    edata.voucherType = edata.voucher.shortCode
    
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroupUname
      acntUname: $scope.selectedAccountUname
      entUname: edata.uniqueName
    }

    console.log edata, "actdata", unqNamesObj

    ledgerService.updateEntry(unqNamesObj, edata).then($scope.updateEntrySuccess, $scope.updateEntryFailure)

  $scope.updateEntrySuccess = (response) ->
    console.log response, "updateEntrySuccess"

  $scope.updateEntryFailure = (response) ->
    console.log response, "updateEntryFailure"


  $scope.addNewRow = (type) ->
    console.log type, "add new row"


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


  $scope.ledgerDataata = {
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
        "tag": "HELLO",
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
              "name": "frnd",
              "uniqueName": "frndafafaf14453422453110l26ow"
            },
            "amount": 2001,
            "type": "CREDIT"
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
              "name": "Priyanka",
              "uniqueName": "bank"
            },
            "amount":4001,
            "type": "DEBIT"
          },
          {
            "particular": {
              "name": "sonu",
              "uniqueName": "sonu_gates"
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
              "name": "Ravi",
              "uniqueName": "temp"
            },
            "amount": 6001,
            "type": "CREDIT"
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