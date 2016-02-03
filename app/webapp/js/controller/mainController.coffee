"use strict"

mainController = ($scope, $rootScope, $timeout, $http, $uibModal, localStorageService, toastr, locationService, modalService, roleServices) ->
  $rootScope.showLedgerBox = true
  $rootScope.showLedgerLoader = false
  $rootScope.basicInfo = {}
  $rootScope.flatAccntListWithParents = []
  $rootScope.canManageComp = true
  $rootScope.canViewSpecificItems = false
  
  $scope.logout = ->
    $http.post('/logout').then ((res) ->
      localStorageService.clearAll()
      window.location = "/thanks"
    ), (res) ->

  # for ledger
  $rootScope.makeAccountFlatten = (data) ->
    angular.copy(data, $rootScope.flatAccntListWithParents)
    obj = _.map(data, (item) ->
      obj = {}
      obj.name = item.name
      obj.uniqueName = item.uniqueName
      obj.mergedAccounts = item.mergedAccounts
      obj
    )
    $rootScope.fltAccntList = obj

  $rootScope.countryCodesList = locationService.getCountryCode()

  $scope.getRoles = () ->
    roleServices.getAll().then($scope.onGetRolesSuccess, $scope.onGetRolesFailure)

  $scope.onGetRolesSuccess = (res) ->
    localStorageService.set("_roles", res.body)

  $scope.onGetRolesFailure = (res) ->
    toastr.error("Something went wrong while fetching role", "Error")

  $rootScope.setScrollToTop = (val, elem)->
    if val is '' || _.isUndefined(val)
      return false
    if val.length > 0
      cntBox = document.getElementById(elem)
      cntBox.scrollTop = 0
  
  $scope.getRoles()
  $timeout(->
    $rootScope.basicInfo = localStorageService.get("_userDetails")
    if !_.isEmpty($rootScope.selectedCompany)
      $rootScope.cmpViewShow = true
  ,1000)

giddh.webApp.controller 'mainController', mainController
