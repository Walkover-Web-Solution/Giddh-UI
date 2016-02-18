"use strict"

mainController = ($scope, $rootScope, $timeout, $http, $uibModal, localStorageService, toastr, locationService, modalService, roleServices, permissionService) ->
  $rootScope.showLedgerBox = true
  $rootScope.showLedgerLoader = false
  $rootScope.basicInfo = {}
  $rootScope.flatAccntListWithParents = []
  $rootScope.canManageComp = true
  $rootScope.canViewSpecificItems = false
  $rootScope.canUpdate = false
  $rootScope.canDelete = false
  $rootScope.canAdd = false
  $rootScope.canShare = false
  $rootScope.canManageUser = false
  
  $scope.logout = ->
    $http.post('/logout').then ((res) ->
      # don't need to clear below
      # _userDetails, _currencyList
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

  $scope.checkPermissions = (entity) ->
    $rootScope.canUpdate = permissionService.hasPermissionOn(entity, "UPDT")
    $rootScope.canDelete = permissionService.hasPermissionOn(entity, "DLT")
    $rootScope.canAdd = permissionService.hasPermissionOn(entity, "ADD")
    $rootScope.canShare = permissionService.hasPermissionOn(entity, "SHR")
    $rootScope.canManageUser = permissionService.hasPermissionOn(entity, "MNG_USR")

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

  $rootScope.$on 'callCheckPermissions', (event, data)->
    $scope.checkPermissions(data)
    # $rootScope.$emit('callCheckPermissions', data)

giddh.webApp.controller 'mainController', mainController
