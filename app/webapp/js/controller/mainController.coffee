"use strict"

mainController = ($scope, $rootScope, $timeout, $http, $uibModal, localStorageService, toastr, locationService, modalService, roleServices, permissionService) ->
  $rootScope.showLedgerBox = true
  $rootScope.showLedgerLoader = false
  $rootScope.basicInfo = {}

  if _.isEmpty($scope.selectedCompany)
    console.log "hey", $scope.selectedCompany
    lsKeys = localStorageService.get("_selectedCompany")
    if not _.isNull(lsKeys) && not _.isEmpty(lsKeys) && not _.isUndefined(lsKeys)
      $scope.selectedCompany = lsKeys
      console.log "after", $scope.selectedCompany
  else
    console.log "else", $scope.selectedCompany

  #check if user is admin
  $rootScope.ifHavePermission = (data, chkr) ->
    return permissionService.hasPermissionOn(data, chkr)

  $scope.logout = ->
    $http.post('/logout').then ((res) ->
      localStorageService.clearAll()
      window.location = "/thanks"
    ), (res) ->

  $scope.goToManageGroups = ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalService.openManageGroupsModal()

  # for ledger
  $rootScope.makeAccountFlatten = (data) ->
    obj = _.map(data, (item) ->
      obj = {}
      obj.name = item.name
      obj.uniqueName = item.uniqueName
      obj
    )
    $rootScope.fltAccntList = obj

  $rootScope.countryCodesList = locationService.getCountryCode()

  $scope.getRoles = () ->
    roles = localStorageService.get("_roles")
    if(_.isUndefined(roles) or _.isEmpty(roles))
      roleServices.getAll().then($scope.onGetRolesSuccess, $scope.onGetRolesFailure)

  $scope.onGetRolesSuccess = (response) ->
    localStorageService.set("_roles", response.body)

  $scope.onGetRolesFailure = (response) ->
    console.log "Something went wrong while fetching role"

  $rootScope.setScrollToTop = (val, elem)->
    if val.length > 0
      cntBox = document.getElementById(elem)
      cntBox.scrollTop = 0

  $rootScope.$on '$viewContentLoaded', ->
    $scope.getRoles()
    $rootScope.basicInfo = localStorageService.get("_userDetails")

angular.module('giddhWebApp').controller 'mainController', mainController
