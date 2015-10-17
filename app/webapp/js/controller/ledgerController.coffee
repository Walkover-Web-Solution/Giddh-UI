"use strict"

ledgerController = ($scope, $rootScope, $timeout, $http, $modal, localStorageService, toastr, locationService) ->
  
  $scope.sarfaraz = "My Name"

  $scope.dummyAccntJson = [
    {
        "groupName": "abhishek agnihotri",
        "groupId": "431",
        "accountDetails": [
          {
            "accountName": "(abhiagnihotri)",
            "accountId": "5",
            "email": "",
            "address": "",
            "mobileNo": "0",
            "openingBalance": "",
            "balance": "0",
            "openingBalanceType": "1",
            "uniqueName": "",
            "pan": "",
            "serviceTaxNumber": "",
            "wtCst": "",
            "charId": "1",
            "others": ""
          }
          {
            "accountName": "(ravisoni)",
            "accountId": "18",
            "email": "",
            "address": "",
            "mobileNo": "0",
            "openingBalance": "",
            "balance": "0",
            "openingBalanceType": "1",
            "uniqueName": "",
            "pan": "",
            "serviceTaxNumber": "",
            "wtCst": "",
            "charId": "1",
            "others": ""
          }
        ]
    },
    {
        "groupName": "aishwarya chaturvedi",
        "groupId": "434",
        "accountDetails": [
            {
                "accountName": "(aishwarya)",
                "accountId": "8",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ajay mor",
        "groupId": "435",
        "accountDetails": [
          {
              "accountName": "(ajaytraders)",
              "accountId": "9",
              "email": "",
              "address": "",
              "mobileNo": "0",
              "openingBalance": "",
              "balance": "0",
              "openingBalanceType": "1",
              "uniqueName": "",
              "pan": "",
              "serviceTaxNumber": "",
              "wtCst": "",
              "charId": "1",
              "others": ""
          }
        ]
    },
    {
        "groupName": "ajit ray j",
        "groupId": "436",
        "accountDetails": [
            {
                "accountName": "(ajitray)",
                "accountId": "10",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "akash kotadia j",
        "groupId": "437",
        "accountDetails": [
            {
                "accountName": "(akashkotadia)",
                "accountId": "11",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "66055",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "alok awasthi",
        "groupId": "444",
        "accountDetails": [
            {
                "accountName": "(alok2014)",
                "accountId": "18",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "alok goel a",
        "groupId": "445",
        "accountDetails": [
            {
                "accountName": "(alokgoel)",
                "accountId": "19",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "alok kumar ghosh",
        "groupId": "446",
        "accountDetails": [
            {
                "accountName": "(aloksms2014)",
                "accountId": "20",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "amit yadav",
        "groupId": "451",
        "accountDetails": [
            {
                "accountName": "(amit.spartacus)",
                "accountId": "25",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "anand kumar singh",
        "groupId": "455",
        "accountDetails": [
            {
                "accountName": "(anand_net1)",
                "accountId": "29",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ankit chhuneja j",
        "groupId": "460",
        "accountDetails": [
            {
                "accountName": "(ankit_chhuneja\r\n)",
                "accountId": "34",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ankit gadiya",
        "groupId": "461",
        "accountDetails": [
            {
                "accountName": "(anky0013)",
                "accountId": "35",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "abc acb",
        "groupId": "429",
        "accountDetails": [
            {
                "accountName": "(annmm)",
                "accountId": "3",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "bankim bhagat",
        "groupId": "485",
        "accountDetails": [
            {
                "accountName": "(applify)",
                "accountId": "59",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ardy travels goa a",
        "groupId": "464",
        "accountDetails": [
            {
                "accountName": "(ardytravelsgoa)",
                "accountId": "38",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "arihanth academy",
        "groupId": "465",
        "accountDetails": [
            {
                "accountName": "(arihanth)",
                "accountId": "39",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "gaurav arora",
        "groupId": "528",
        "accountDetails": [
            {
                "accountName": "(arorag)",
                "accountId": "102",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "arpit tuteja",
        "groupId": "467",
        "accountDetails": [
            {
                "accountName": "(arpit@dv)",
                "accountId": "41",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "arun dagaria",
        "groupId": "468",
        "accountDetails": [
            {
                "accountName": "(arun.dagaria@gmail.com)",
                "accountId": "42",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ashish singh",
        "groupId": "475",
        "accountDetails": [
            {
                "accountName": "(asconfab)",
                "accountId": "49",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ashapura infocom",
        "groupId": "472",
        "accountDetails": [
            {
                "accountName": "(ashapura\r\n)",
                "accountId": "46",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ashok kumar",
        "groupId": "476",
        "accountDetails": [
            {
                "accountName": "(ashok.lic)",
                "accountId": "50",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ambiora techfest",
        "groupId": "449",
        "accountDetails": [
            {
                "accountName": "(ashwary)",
                "accountId": "23",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ashwini bagga a",
        "groupId": "477",
        "accountDetails": [
            {
                "accountName": "(ashwinibagga)",
                "accountId": "51",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "jayesh thakkar",
        "groupId": "551",
        "accountDetails": [
            {
                "accountName": "(assetzone10\r\n)",
                "accountId": "124",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "assr computer j",
        "groupId": "478",
        "accountDetails": [
            {
                "accountName": "(assrcomputer)",
                "accountId": "52",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kandasamy asaithambi",
        "groupId": "557",
        "accountDetails": [
            {
                "accountName": "(astgroup)",
                "accountId": "130",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "atul morey a",
        "groupId": "481",
        "accountDetails": [
            {
                "accountName": "(atulmorey)",
                "accountId": "55",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "babu revathi",
        "groupId": "484",
        "accountDetails": [
            {
                "accountName": "(baburaj)",
                "accountId": "58",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kunal jain",
        "groupId": "574",
        "accountDetails": [
            {
                "accountName": "(baid1987)",
                "accountId": "147",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "beyond 360 a",
        "groupId": "487",
        "accountDetails": [
            {
                "accountName": "(beyond360)",
                "accountId": "61",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "bhagyashri patil",
        "groupId": "489",
        "accountDetails": [
            {
                "accountName": "(bhagyashri)",
                "accountId": "63",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "bhargav lakkaraju",
        "groupId": "491",
        "accountDetails": [
            {
                "accountName": "(bhargav@hooplaindia.com)",
                "accountId": "65",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "neeraa bhartiyneer",
        "groupId": "425",
        "accountDetails": [
            {
                "accountName": "(bhartiyneer)",
                "accountId": "2",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "arvind bansal",
        "groupId": "471",
        "accountDetails": [
            {
                "accountName": "(bigdreaminfo)",
                "accountId": "45",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "bineesh n",
        "groupId": "492",
        "accountDetails": [
            {
                "accountName": "(bineeshhd)",
                "accountId": "66",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "binoy sebastian",
        "groupId": "493",
        "accountDetails": [
            {
                "accountName": "(binoy)",
                "accountId": "67",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "bipin shah",
        "groupId": "494",
        "accountDetails": [
            {
                "accountName": "(bipinshah446)",
                "accountId": "68",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "bizzarch software",
        "groupId": "495",
        "accountDetails": [
            {
                "accountName": "(bizzarch)",
                "accountId": "69",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "black dock technologies",
        "groupId": "496",
        "accountDetails": [
            {
                "accountName": "(blackdock)",
                "accountId": "70",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "alekhya nadendla",
        "groupId": "443",
        "accountDetails": [
            {
                "accountName": "(bonsoul)",
                "accountId": "17",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ca arving kumar singh",
        "groupId": "497",
        "accountDetails": [
            {
                "accountName": "(caarvind)",
                "accountId": "71",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "jyostana oza",
        "groupId": "555",
        "accountDetails": [
            {
                "accountName": "(cakashoza)",
                "accountId": "128",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "guru ananth",
        "groupId": "532",
        "accountDetails": [
            {
                "accountName": "(cannysms)",
                "accountId": "106",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ca reetesh agarwal",
        "groupId": "498",
        "accountDetails": [
            {
                "accountName": "(careetesh)",
                "accountId": "72",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "council for green india",
        "groupId": "507",
        "accountDetails": [
            {
                "accountName": "(cgi24)",
                "accountId": "81",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "bhagwan patidar",
        "groupId": "488",
        "accountDetails": [
            {
                "accountName": "(charak)",
                "accountId": "62",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "christking matric",
        "groupId": "505",
        "accountDetails": [
            {
                "accountName": "(christking)",
                "accountId": "79",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "coi indore",
        "groupId": "506",
        "accountDetails": [
            {
                "accountName": "(coindore)",
                "accountId": "80",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "akshay maheshwari",
        "groupId": "440",
        "accountDetails": [
            {
                "accountName": "(cozzent)",
                "accountId": "14",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "devendra koyande",
        "groupId": "511",
        "accountDetails": [
            {
                "accountName": "(devendra44k)",
                "accountId": "85",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "devidas raut a",
        "groupId": "513",
        "accountDetails": [
            {
                "accountName": "(devidasraut)",
                "accountId": "87",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kaushik singh",
        "groupId": "561",
        "accountDetails": [
            {
                "accountName": "(dezify)",
                "accountId": "134",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "divakaran srinivasan",
        "groupId": "516",
        "accountDetails": [
            {
                "accountName": "(dhivee)",
                "accountId": "90",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "dinesh kumar j",
        "groupId": "515",
        "accountDetails": [
            {
                "accountName": "(dinnu)",
                "accountId": "89",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "karan kurani",
        "groupId": "560",
        "accountDetails": [
            {
                "accountName": "(doctorc)",
                "accountId": "133",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "doozie software",
        "groupId": "517",
        "accountDetails": [
            {
                "accountName": "(doozie)",
                "accountId": "91",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "dr r k sachdev j",
        "groupId": "521",
        "accountDetails": [
            {
                "accountName": "(drrksachdev)",
                "accountId": "95",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "d d mahajan",
        "groupId": "508",
        "accountDetails": [
            {
                "accountName": "(dsoujj)",
                "accountId": "82",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "endtoend endtoend",
        "groupId": "522",
        "accountDetails": [
            {
                "accountName": "(endtoend)",
                "accountId": "96",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "logeswaran kumar",
        "groupId": "576",
        "accountDetails": [
            {
                "accountName": "(eswarr)",
                "accountId": "149",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "e world",
        "groupId": "524",
        "accountDetails": [
            {
                "accountName": "(eworld123)",
                "accountId": "98",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "dr atul seth",
        "groupId": "518",
        "accountDetails": [
            {
                "accountName": "(eyemax)",
                "accountId": "92",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "jaswant kumar jaiswal",
        "groupId": "549",
        "accountDetails": [
            {
                "accountName": "(flabiafresh)",
                "accountId": "122",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kunjeswar sharma",
        "groupId": "575",
        "accountDetails": [
            {
                "accountName": "(foundation)",
                "accountId": "148",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "gajendran s",
        "groupId": "525",
        "accountDetails": [
            {
                "accountName": "(gajayandran)",
                "accountId": "99",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "bharat heda",
        "groupId": "490",
        "accountDetails": [
            {
                "accountName": "(galaxyrealty)",
                "accountId": "64",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ganesh naik j",
        "groupId": "527",
        "accountDetails": [
            {
                "accountName": "(ganeshnaik)",
                "accountId": "101",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "christian flintrup",
        "groupId": "504",
        "accountDetails": [
            {
                "accountName": "(gigahost)",
                "accountId": "78",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ganesh kumar",
        "groupId": "526",
        "accountDetails": [
            {
                "accountName": "(gkumar)",
                "accountId": "100",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "alpesh patel",
        "groupId": "447",
        "accountDetails": [
            {
                "accountName": "(global sms solution)",
                "accountId": "21",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "krishna gupta",
        "groupId": "569",
        "accountDetails": [
            {
                "accountName": "(gupta)",
                "accountId": "142",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "gyg borivali j",
        "groupId": "533",
        "accountDetails": [
            {
                "accountName": "(gygborivali)",
                "accountId": "107",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "deepali jaiswal",
        "groupId": "509",
        "accountDetails": [
            {
                "accountName": "(hdfcpbp)",
                "accountId": "83",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "aneesh bhasin",
        "groupId": "457",
        "accountDetails": [
            {
                "accountName": "(hipcask)",
                "accountId": "31",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kiranjeet singh",
        "groupId": "566",
        "accountDetails": [
            {
                "accountName": "(iamjg)",
                "accountId": "139",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kalidas t",
        "groupId": "556",
        "accountDetails": [
            {
                "accountName": "(ibtrng)",
                "accountId": "129",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "icube education",
        "groupId": "539",
        "accountDetails": [
            {
                "accountName": "(icube)",
                "accountId": "113",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "indra kumar",
        "groupId": "542",
        "accountDetails": [
            {
                "accountName": "(inderdss)",
                "accountId": "116",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "himanshu arora",
        "groupId": "536",
        "accountDetails": [
            {
                "accountName": "(info@ayontechnovision.com\r\n)",
                "accountId": "110",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "cenvo corporation",
        "groupId": "499",
        "accountDetails": [
            {
                "accountName": "(inlandsms)",
                "accountId": "73",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "devendra salot",
        "groupId": "512",
        "accountDetails": [
            {
                "accountName": "(investinshare)",
                "accountId": "86",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "adersh dev",
        "groupId": "433",
        "accountDetails": [
            {
                "accountName": "(ishost)",
                "accountId": "7",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "anil suryavanshi",
        "groupId": "458",
        "accountDetails": [
            {
                "accountName": "(ishwaritech)",
                "accountId": "32",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "gaurav lambole",
        "groupId": "529",
        "accountDetails": [
            {
                "accountName": "(itechinfo)",
                "accountId": "103",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "ernesto cohnen",
        "groupId": "523",
        "accountDetails": [
            {
                "accountName": "(ixigo)",
                "accountId": "97",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "anjaiah kottur",
        "groupId": "459",
        "accountDetails": [
            {
                "accountName": "(jagger)",
                "accountId": "33",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "jainis arakkal",
        "groupId": "545",
        "accountDetails": [
            {
                "accountName": "(jainisjose)",
                "accountId": "118",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "jain market",
        "groupId": "546",
        "accountDetails": [
            {
                "accountName": "(jcm123)",
                "accountId": "119",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "jijo jose j",
        "groupId": "554",
        "accountDetails": [
            {
                "accountName": "(jijojose)",
                "accountId": "127",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "iswar lalakia",
        "groupId": "544",
        "accountDetails": [
            {
                "accountName": "(jp.sanitaryware\r\n)",
                "accountId": "117",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "jaishiva infra projects pvt ltd",
        "groupId": "547",
        "accountDetails": [
            {
                "accountName": "(jsipl)",
                "accountId": "120",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kapilesh singh j",
        "groupId": "558",
        "accountDetails": [
            {
                "accountName": "(kapileshsingh)",
                "accountId": "131",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "alagappan karthikeyan",
        "groupId": "442",
        "accountDetails": [
            {
                "accountName": "(karhinksg)",
                "accountId": "16",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "jay p",
        "groupId": "552",
        "accountDetails": [
            {
                "accountName": "(kaush.gchat)",
                "accountId": "125",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kaustubh keshav shimpi",
        "groupId": "562",
        "accountDetails": [
            {
                "accountName": "(kaustubhshimpi\r\n)",
                "accountId": "135",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kavyanjali kavyanjali",
        "groupId": "563",
        "accountDetails": [
            {
                "accountName": "(kavyanjali)",
                "accountId": "136",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "dinesh kawad",
        "groupId": "514",
        "accountDetails": [
            {
                "accountName": "(kawad)",
                "accountId": "88",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
        "groupName": "kewraj khatri",
        "groupId": "565",
        "accountDetails": [
            {
                "accountName": "(khatri)",
                "accountId": "138",
                "email": "",
                "address": "",
                "mobileNo": "0",
                "openingBalance": "",
                "balance": "0",
                "openingBalanceType": "1",
                "uniqueName": "",
                "pan": "",
                "serviceTaxNumber": "",
                "wtCst": "",
                "charId": "1",
                "others": ""
            }
        ]
    },
    {
      "groupName": "kiran panjwani",
      "groupId": "567",
      "accountDetails": [
        {
          "accountName": "(kiirran)",
          "accountId": "140",
          "email": "",
          "address": "",
          "mobileNo": "0",
          "openingBalance": "",
          "balance": "0",
          "openingBalanceType": "1",
          "uniqueName": "",
          "pan": "",
          "serviceTaxNumber": "",
          "wtCst": "",
          "charId": "1",
          "others": ""
        }
      ]
    }
  ]

  $rootScope.$on '$viewContentLoaded', ->
    console.log "ledger rootScope viewContentLoaded"
    $rootScope.isCollapsed = true

    
    

  

angular.module('giddhWebApp').controller 'ledgerController', ledgerController