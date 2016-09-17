"use strict"

adminController = ($scope, $rootScope, $http, $timeout, $auth, localStorageService, toastr, $window) ->
  $scope.loginIsProcessing = false
  $scope.captchaKey = '6LcgBiATAAAAAMhNd_HyerpTvCHXtHG6BG-rtcmi'
  $scope.companies = []
  $scope.query = ""
  $scope.dummyObj = {
    "companySubscription": {
      "subscriptionDate": "28-05-2016",
      "servicePlan": {
        "amount": 0,
        "planName": "trial",
        "servicePeriod": 1
      },
      "remainingPeriod": 1,
      "paymentDue": false,
      "paymentMode":"pre",
      "nextBillDate":"28-06-2016",
      "createdAt":"28-05-2016",
      "expiry": "09-10-2016"
    },
    "contactNo":"91-7828405888",
    "createdBy":{
      "name":"Ravi Soni",
      "email":"ravisoni@walkover.in",
      "uniqueName":"ravisoni@walkover.in"
    },
    "lastActivity":"26-08-2016 17:06:00",
    "name":"ravi soni",
    "sharedWith":[{
      "email": "ravisoni@hostnsoft.com",
      "permission": "super_admin"
    }],
    "apiHits": 104521
  }
  $scope.dummyData = [

  ]
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

  $scope.authenticate = (provider) ->
    $scope.loginIsProcessing = true
    $auth.authenticate(provider).then((response) ->
      if response.data.result.status is "error"
#user is not registerd with us
        toastr.error(response.data.result.message, "Error")
        $timeout (->
          window.location = "/sindhu"
        ),3000
      else
#user is registered and redirect it to app
        localStorageService.set("_adminDetails", response.data.userDetails)
        $window.sessionStorage.setItem("_ak", response.data.result.body.authKey)
        window.location = "/sindhu/panel"
    ).catch (response) ->
      $scope.loginIsProcessing = false
      #user is not registerd with us
      if response.data.result.status is "error"
        toastr.error(response.data.result.message, "Error")
        $timeout (->
          window.location = "/index"
        ), 3000
      else if response.status is 502
        toastr.error("Something went wrong please reload page", "Error")
      else
        toastr.error("Something went wrong please reload page", "Error")

  $scope.getCompanyList = () ->
    #Need to hit api and get list of companies
    #structure to be followed
#    console.log($rootScope.CompanyList)
    $scope.companies = $rootScope.CompanyList
    groupedCompany = _.groupBy($rootScope.CompanyList, 'email')
    i = 0
    while i <= 100
      $scope.dummyObj.apiHits = $scope.dummyObj.apiHits + 1
      $scope.dummyObj.companySubscription.servicePlan.amount = $scope.dummyObj.companySubscription.servicePlan.amount + 1
      addThis = {}
      _.extend(addThis,$scope.dummyObj)
      $scope.dummyData.push(addThis)
      i++
#    console.log(groupedCompany)

  $scope.searchCompanies = (query) ->


  $scope.showSharedWithDetails = (data) ->
    console.log(data)

#  $timeout ( ->
#    $scope.getCompanyList()
#  ),2000



angular.module('giddhApp').controller 'sindhuController', adminController