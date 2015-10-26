"use strict"

mainController = ($scope, $rootScope, $timeout, $http, $modal, localStorageService, toastr, locationService, modalService) ->
  $rootScope.basicInfo = {}
  $rootScope.isCollapsed = true
  $scope.logout = ->
    $http.post('/logout').then ((response) ->
      localStorageService.remove("_userDetails")
      window.location = "/thanks"
    ), (response) ->

  $scope.goToManageGroups = ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalService.openManageGroupsModal()


  # for ledger
  $rootScope.makeAccountFlatten = (data) ->
    console.log "in makeAccountFlatten"
    $rootScope.fltAccntList = data
    # $scope.fltAccntList = []
    # _.filter(data, (obj) ->
    #   $scope.fltAccntList.push(obj.name)
    # )

  $rootScope.countryCodesList = locationService.getCountryCode()

  $rootScope.$on '$viewContentLoaded', ->
    $rootScope.basicInfo = localStorageService.get("_userDetails")


  
  


angular.module('giddhWebApp').controller 'mainController', mainController