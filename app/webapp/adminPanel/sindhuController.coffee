"use strict"

adminController = ($scope, $rootScope, sindhuServices, $timeout) ->
  $rootScope.cmpViewShow = true
  $scope.companies = []

#  {
#  "activeFinancialYear":{
#    "isLocked":false,
#    "uniqueName":"FY-APR2016-MAR2017",
#    "financialYearStarts":"01-04-2016",
#    "financialYearEnds":"31-03-2017"
#  },
#  "sharedEntity":null,
#  "city":"Indore",
#  "country":null,
#  "pincode":null,
#  "email":null,
#  "baseCurrency":"INR",
#  "companyIdentity":[
#  ],
#  "uniqueName":"ravisoindore14644276127130av8t1",
#  "contactNo":null,
#  "companySubscription":{
#    "subscriptionDate":"28-05-2016",
#    "servicePlan":{
#      "amount":0,
#      "planName":"trial",
#      "servicePeriod":1
#    },
#    "remainingPeriod":1,
#    "paymentDue":false,
#    "primaryBillerConfirmed":false,
#    "billAmount":0,
#    "discount":0,
#    "autoDeduct":false,
#    "primaryBiller":null,
#    "createdBy":{
#      "name":"Ravi Soni",
#      "email":"ravisoni@hostnsoft.com",
#      "uniqueName":"ravisoni@hostnsoft.com"
#    },
#    "paymentMode":"pre",
#    "nextBillDate":"28-06-2016",
#    "createdAt":"28-05-2016"
#  },
#  "createdBy":{
#    "name":"Ravi Soni",
#    "email":"ravisoni@walkover.in",
#    "uniqueName":"ravisoni@walkover.in"
#  },
#  "updatedAt":"26-08-2016 17:06:00",
#  "financialYears":[
#    {
#      "isLocked":false,
#      "uniqueName":"FY-APR2016-MAR2017",
#      "financialYearStarts":"01-04-2016",
#      "financialYearEnds":"31-03-2017"
#    },
#    {
#      "isLocked":false,
#      "uniqueName":"FY-APR2015-MAR2016",
#      "financialYearStarts":"01-04-2015",
#      "financialYearEnds":"31-03-2016"
#    }
#  ],
#  "updatedBy":{
#    "name":"Ravi Soni",
#    "email":"ravisoni@hostnsoft.com",
#    "uniqueName":"ravisoni@hostnsoft.com"
#  },
#  "createdAt":"28-05-2016 14:56:52",
#  "canUserSwitch":false,
#  "state":null,
#  "shared":true,
#  "alias":"Giddh4",
#  "address":null,
#  "role":{
#    "uniqueName":"super_admin",
#    "name":"Super Admin"
#  },
#  "name":"ravi soni"
#  }
  $scope.getCompanyList = () ->
    #Need to hit api and get list of companies
    #structure to be followed
    console.log($rootScope.CompanyList)
    $scope.companies = $rootScope.CompanyList

  $timeout ( ->
    $scope.getCompanyList()
  ),2000



giddh.webApp.controller 'adminController', adminController