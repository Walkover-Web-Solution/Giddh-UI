"use strict"

userController = ($scope, $rootScope, toastr, userServices, localStorageService, $timeout, $uibModal) ->
  $scope.userAuthKey = undefined
  $scope.noData = false
  $scope.subListData = []
  $scope.uTransData = []
  $scope.cSubsData = false
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
    if res.body.length > 0
      $scope.cSubsData = true
    else
      $scope.cSubsData = false

  $scope.getSubscriptionListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.changeCallback = () ->
    result =  _.findWhere($scope.subListData, {autoDeduct: false})
    if _.isUndefined(result) || _.isEmpty(result)
      console.log "do nothing"
    else
      console.log result
      obj = {
        uUname: $rootScope.basicInfo.uniqueName
        companyUniqueName: result.companyUniqueName
      }
      userServices.cancelAutoPay(obj).then($scope.autoPayChangeSuccess, $scope.autoPayChangeFailure)
    
  $scope.autoPayChangeSuccess = (res) ->
    $scope.getSubscriptionList()

  $scope.autoPayChangeFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

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
    if $scope.uTransData.length is 0
      $scope.noData = true

  $scope.getUserSubListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  

#init angular app
giddh.webApp.controller 'userController', userController