"use strict"

userController = ($scope, $rootScope, toastr, userServices, localStorageService, $timeout, $uibModal) ->
  $scope.userAuthKey = undefined
  $scope.noData = false
  $scope.subListData = []
  $scope.uTransData = {}
  $scope.cSubsData = false
  $scope.currentPage = 1
  $scope.pagiMaxSize = 5
  
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
      console.info "do nothing"
    else
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
    obj = {
      name: $rootScope.basicInfo.uniqueName
      num: 1
    }
    modalInstance.opened.then ->
      userServices.getUserSublist(obj).then($scope.getUserSublistSuccess, $scope.getUserSubListFailure)
    
  $scope.getUserSublistSuccess = (res) ->
    $scope.uTransData = res.body
    $scope.uTransData.startPage = 1
    $scope.nothingToLoadUser = false
    if $scope.uTransData.length is 0
      $scope.noData = true

  $scope.getUserSubListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.pageChanged = (data) ->
    if data.totalPages is data.startPage
      $scope.nothingToLoadUser = true
      toastr.info("Nothing to load, all transactions are loaded", "Info")
      return
    obj = {
      name: $rootScope.basicInfo.uniqueName
      num: data.startPage
    }
    userServices.getUserSublist(obj).then($scope.pageChangedSuccess, $scope.pageChangedFailure)

  $scope.pageChangedSuccess =(res)->
    $scope.uTransData.paymentDetail = $scope.uTransData.paymentDetail.concat(res.body.paymentDetail)
    $scope.uTransData.startPage += 1

  $scope.pageChangedFailure =(res)->
    toastr.error(res.data.message, res.data.status)

#init angular app
giddh.webApp.controller 'userController', userController