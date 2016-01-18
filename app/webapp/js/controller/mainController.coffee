"use strict"

mainController = ($scope, $rootScope, $timeout, $http, $uibModal, localStorageService, toastr, locationService, modalService, roleServices) ->
  $rootScope.showLedgerBox = true
  $rootScope.showLedgerLoader = false
  $rootScope.nowShowAccounts = false
  $rootScope.basicInfo = {}
  
  $scope.logout = ->
    $http.post('/logout').then ((res) ->
      localStorageService.clearAll()
      window.location = "/thanks"
    ), (res) ->

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
    if val is '' || _.isUndefined(val)
      return false
    if val.length > 0
      cntBox = document.getElementById(elem)
      cntBox.scrollTop = 0

  $rootScope.$on '$viewContentLoaded', ->
    $scope.getRoles()
    $rootScope.basicInfo = localStorageService.get("_userDetails")

giddh.webApp.controller 'mainController', mainController
