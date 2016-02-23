"use strict"

userController = ($scope, $rootScope, toastr, userServices, localStorageService, $timeout, $uibModal, couponServices) ->
  $scope.userAuthKey = undefined
  $scope.noData = false
  $scope.subListData = []
  $scope.uTransData = []
  $rootScope.basicInfo = localStorageService.get("_userDetails")
  




  $scope.getUserAuthKey = () ->
    if !_.isEmpty($rootScope.basicInfo)
      userServices.getKey($rootScope.basicInfo.uniqueName).then($scope.getUserAuthKeySuccess,
          $scope.getUserAuthKeyFailure)

  $scope.getUserAuthKeySuccess = (res) ->
    $scope.userAuthKey = res.body

  $scope.getUserAuthKeyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.regenerateKey = () ->
    userServices.generateKey($rootScope.basicInfo.uniqueName).then($scope.generateKeySuccess,
        $scope.generateKeyFailure)

  $scope.generateKeySuccess = (res) ->
    $scope.userAuthKey = res.body.authKey

  $scope.generateKeyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $timeout(->
    $scope.getUserAuthKey()
  ,200)

  $scope.getSubscriptionList = () ->
    userServices.getsublist($rootScope.basicInfo.uniqueName).then($scope.getSubscriptionListSuccess, $scope.getSubscriptionListFailure)
  
  $scope.getSubscriptionListSuccess = (res) ->
    $scope.subListData = res.body

  $scope.getSubscriptionListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.autoPayChange = (data) ->
    console.log data.autoDeduct, "autoPayChange", data

  $scope.getUserTransaction = () -> 
    modalInstance = $uibModal.open(
      templateUrl: 'prevTransDetail.html'
      size: "liq90"
      backdrop: 'static'
      scope: $scope
    )
    modalInstance.opened.then ->
      userServices.getUserSublist($rootScope.basicInfo.uniqueName).then($scope.getUserSublistSuccess, $scope.getUserSubListFailure)
    
  $scope.getUserSublistSuccess = (res) ->
    $scope.uTransData = res.body
    if $scope.uTransData.length >= 0
      $scope.noData = true

  $scope.getUserSubListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  

#init angular app
giddh.webApp.controller 'userController', userController