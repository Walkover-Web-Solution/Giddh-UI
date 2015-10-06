"use strict"

mainController = ($scope, $rootScope, $timeout, $http, $modal, localStorageService, toastr) ->
  $rootScope.basicInfo = {}

  $scope.logout = ->
    try
      $http.post('/logout').then ((response) ->
        localStorageService.remove("_userDetails")
        window.location = "/thanks"
      ), (response) ->
    catch e
      throw new Error(e.message)

  $rootScope.$on '$viewContentLoaded', ->
    $rootScope.basicInfo = localStorageService.get("_userDetails")

  $scope.goToManageGroups = ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalInstance = $modal.open(
        templateUrl: '/public/webapp/views/addManageGroupModal.html'
        size: "liq90"
        #backdrop: 'static'
        controller: 'groupController'
      )

angular.module('giddhWebApp').controller 'mainController', mainController