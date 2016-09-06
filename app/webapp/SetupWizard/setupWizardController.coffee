"use strict"

setWizardController = ($scope, $state, $rootScope, $timeout, $http, $uibModal, localStorageService, userServices ,toastr, locationService, modalService, roleServices, permissionService, companyServices, $window,groupService, $location, WizardHandler) ->

# add and verify mobile number
  $scope.numberVerified = false
  $scope.isNotVerified = true
  $scope.phoneNumber = ''
  $scope.userNumber = ''
  $scope.showSuccessMsg = false
  $scope.mobNum = {
    countryCode: ''
    number: ''
    showVerificationBox : false
    verificationCode: ''
  }
  $scope.userDetails = localStorageService.get('_userDetails')
  if $scope.userDetails.contactNo != null
    $scope.isNotVerified = false

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
    userServices.get($rootScope.basicInfo.uniqueName).then($scope.getUserDetailSuccess, $scope.getUserDetailFailure)
    WizardHandler.wizard().next()

  $scope.verifyNumberFailure = (res) ->
    toastr.error(res.data.message)

  $scope.getUserDetailSuccess = (res) ->
    localStorageService.set("_userDetails", res.body)
    $rootScope.basicInfo = res.body

  #get company list failure
  $scope.getUserDetailFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  #create company
  $scope.createCompany = (cdata) ->
    companyServices.create(cdata).then($scope.onCreateCompanySuccess, $scope.onCreateCompanyFailure)

  #create company success
  $scope.onCreateCompanySuccess = (res) ->
    toastr.success("Company created successfully", "Success")
    $rootScope.mngCompDataFound = true
    $scope.companyList.push(res.body)
    $rootScope.setCompany(res.body)
    $rootScope.getCompanyList()
    changeData = {}
    changeData.data = res.body
    changeData.type = 'CHANGE'
    $scope.$broadcast('company-changed', changeData)
    $scope.showSuccessMsg = true
    WizardHandler.wizard().next()
    $state.go('company.content.manage')

  #create company failure
  $scope.onCreateCompanyFailure = (res) ->
    toastr.error(res.data.message, "Error")

  $scope.promptBeforeClose = () ->
    if $scope.companyList.length < 1
      modalService.openConfirmModal(
       title: 'Log Out',
       body: 'In order to be able to use Giddh, you must create a company. Are you sure you want to cancel and logout?',
       ok: 'Yes',
       cancel: 'No').then($scope.firstLogout)
    else
      $rootScope.setupModalInstance.close()

  $scope.firstLogout = () ->
    $http.post('/logout').then ((res) ->
     # don't need to clear below
     # _userDetails, _currencyList
     localStorageService.clearAll()
     window.location = "/thanks"
    ), (res) ->

  $scope.triggerAddManage = () ->
    $timeout ( ->
      $rootScope.$emit('openAddManage')
    ), 100

  $scope.setupComplete = () ->
    $scope.showSuccessMsg = true


giddh.webApp.controller 'setWizardController', setWizardController