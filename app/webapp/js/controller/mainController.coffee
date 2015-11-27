"use strict"

mainController = ($scope, $rootScope, $timeout, $http, $modal, localStorageService, toastr, locationService, modalService) ->
  $rootScope.showLedgerBox = false
  $rootScope.basicInfo = {}
  $scope.logout = ->
    $http.post('/logout').then ((res) ->
      localStorageService.remove("_userDetails")
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

  $rootScope.$on '$viewContentLoaded', ->
    $rootScope.basicInfo = localStorageService.get("_userDetails")

angular.module('giddhWebApp').controller 'mainController', mainController