"use strict"

ledgerController = ($scope, $rootScope, $timeout, $http, $modal, localStorageService, toastr, locationService) ->
  
  $scope.sarfaraz = "My name"

  
  $scope.sampleLedger = {
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
            "amount": 4004,
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
            "amount": 501,
            "type": "DEBIT"
          },
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "cake"
            },
            "amount": 501,
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
            "amount": 501,
            "type": "DEBIT"
          },
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "cake"
            },
            "amount": 501,
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
        "entryDate": "12-09-2015",
        "voucherNo": 1004
      },
      {
        "transactions": [
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "temp"
            },
            "amount": 501,
            "type": "DEBIT"
          },
          {
            "particular": {
              "name": "Rahul",
              "uniqueName": "water"
            },
            "amount": 501,
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
    console.log "ledger rootScope viewContentLoaded"
    $rootScope.isCollapsed = true

    
    

  

angular.module('giddhWebApp').controller 'ledgerController', ledgerController