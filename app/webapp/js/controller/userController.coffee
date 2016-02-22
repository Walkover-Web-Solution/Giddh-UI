"use strict"

userController = ($scope, $rootScope, toastr, userServices, localStorageService, $timeout, $uibModal, couponServices) ->
  $scope.userAuthKey = undefined
  $scope.payAlert = []
  $scope.wlt = {}
  $scope.coupon = {}
  $scope.noData = false
  $scope.payStep2 = false
  $scope.payStep3 = false
  $scope.directPay = false
  $scope.disableRazorPay = false
  $scope.wlt.status = false
  $scope.coupRes = {}
  $scope.subListData = []
  $scope.uTransData = []
  $rootScope.basicInfo = localStorageService.get("_userDetails")
  $scope.discount = 0
  $scope.amount = 0
  $scope.calCulatedDiscount = 0

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

  # add money in wallet
  $scope.addMoneyInWallet = () ->
    if Number($scope.wlt.Amnt) < 100
      $scope.wlt = angular.copy({})
      toastr.warning("You cannot make payment")
    else
      $scope.payStep2 = true
      $scope.wlt.status = true

  # redeem coupon
  $scope.redeemCoupon = (code) ->
    couponServices.couponDetail(code).then($scope.redeemCouponSuccess, $scope.redeemCouponFailure)

  $scope.removeDotFromString = (str) ->
    if str.indexOf('.') is -1
      return Number(str)
    else
      numStr = str.split(".")
      return Number(numStr[0])

  $scope.redeemCouponSuccess = (res) ->
    $scope.payAlert = []
    $scope.calCulatedDiscount = 0
    $scope.coupRes = res.body
    toastr.success("Hurray your coupon code is redeemed", res.status)
    
    if res.body.type is "balance_add"
      $scope.directPay = true
      $scope.disableRazorPay = true
      # hit api from here

    else if $scope.coupRes.type is "cashback"
      $scope.directPay = false
      $scope.disableRazorPay = false
      $scope.amount = $scope.removeDotFromString($scope.wlt.Amnt)
      $scope.discount = 0
      $scope.payAlert.push({msg: "Your cashback amount will be credited in your account withing 48 hours after payment has been done."})

    else if $scope.coupRes.type is "discount"
      $scope.directPay = false

      $scope.amount = $scope.removeDotFromString($scope.wlt.Amnt)

      $scope.calCulatedDiscount = Number($scope.coupRes.value * $scope.amount/100)

      if $scope.calCulatedDiscount > $scope.coupRes.maxAmount
        $scope.discount = Number($scope.coupRes.maxAmount)
        diff = $scope.amount-$scope.discount
        if diff < 100
          $scope.disableRazorPay = true
          $scope.payAlert.push({msg: "After discount amount cannot be less than 100 Rs. you have to add more money"})
        else
          $scope.disableRazorPay = false
          $scope.payAlert.push({msg: "You can only avail max discount of Rs. "+$scope.coupRes.maxAmount+ ". After discount, you have to pay Rs. "+ diff})
      else
        $scope.disableRazorPay = false
        $scope.discount = $scope.calCulatedDiscount
        $scope.payAlert.push({msg: "Hurray you have availed a discount of Rs. "+ $scope.discount})
      

  $scope.redeemCouponFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  # reset steps
  $scope.resetSteps = () ->
    $scope.isHaveCoupon = false
    $scope.payAlert = []
    $scope.wlt = angular.copy({})
    $scope.coupon = angular.copy({})
    $scope.wlt.status = false
    $scope.coupRes = {}
    $scope.payStep2 = false
    $scope.payStep3 = false

#init angular app
giddh.webApp.controller 'userController', userController