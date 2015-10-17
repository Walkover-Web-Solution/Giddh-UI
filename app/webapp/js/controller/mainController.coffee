"use strict"

mainController = ($scope, $rootScope, $timeout, $http, $modal, localStorageService, toastr, locationService) ->
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
      modalInstance = $modal.open(
        templateUrl: '/public/webapp/views/addManageGroupModal.html'
        size: "liq90"
        backdrop: 'static'
        controller: 'groupController'
      )
  $rootScope.countryCodesList = locationService.getCountryCode()

  $rootScope.$on '$viewContentLoaded', ->
    $rootScope.basicInfo = localStorageService.get("_userDetails")
    

    
    

  

angular.module('giddhWebApp').controller 'mainController', mainController