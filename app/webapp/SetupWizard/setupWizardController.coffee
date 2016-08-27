"use strict"

setWizardController = ($scope, $state, $rootScope, $timeout, $http, $uibModal, localStorageService, userServices ,toastr, locationService, modalService, roleServices, permissionService, companyServices, $window,groupService, $location, WizardHandler) ->

# add and verify mobile number
  $scope.numberVerified = false
  $scope.phoneNumber = ''
  $scope.userNumber = ''
  $scope.mobNum = {
    countryCode: ''
    number: ''
    showVerificationBox : false
    verificationCode: ''
  }

  $scope.addNumber = (number) ->
    if number.indexOf('-') != -1
      numArr = number.split('-')
      $scope.mobNum.countryCode = numArr[0]
      $scope.mobNum.number = numArr[1]
      data = {
        "countryCode":$scope.mobNum.countryCode
        "mobileNumber":$scope.mobNum.number
      }
      userServices.addNumber(data).then($scope.addNumberSuccess, $scope.addNumberFailure)
    else
      toastr.error("Please enter number in format: 91-9998899988")

  $scope.addNumberSuccess = (res) ->
    toastr.success("You will receive a verification code on your mobile shortly.")
    $scope.mobNum.showVerificationBox = true

  $scope.addNumberFailure = (res) ->
    toastr.error(res.data.message)

  $scope.verifyNumber = (code) ->
    data = {
      "countryCode":$scope.mobNum.countryCode
      "mobileNumber":$scope.mobNum.number
      "oneTimePassword":$scope.mobNum.verificationCode
    }
    userServices.verifyNumber(data).then($scope.verifyNumberSuccess, $scope.verifyNumberFailure)

  $scope.verifyNumberSuccess = (res) ->
    toastr.success(res.body)
    $scope.mobNum.showVerificationBox = false
    $scope.numberVerified = true
    WizardHandler.wizard().next()

  $scope.verifyNumberFailure = (res) ->
    toastr.error(res.data.message)

  #create company
  $scope.createCompany = (cdata) ->
    companyServices.create(cdata).then($scope.onCreateCompanySuccess, $scope.onCreateCompanyFailure)

  #create company success
  $scope.onCreateCompanySuccess = (res) ->
    toastr.success("Company created successfully", "Success")
    $rootScope.mngCompDataFound = true
    $scope.companyList.push(res.body)
    $rootScope.getCompanyList()
    WizardHandler.wizard().next()

  #create company failure
  $scope.onCreateCompanyFailure = (res) ->
    toastr.error(res.data.message, "Error")

  $scope.triggerAddManage = () ->
    $timeout ( ->
      $rootScope.$emit('openAddManage')
    ), 100
  

giddh.webApp.controller 'setWizardController', setWizardController