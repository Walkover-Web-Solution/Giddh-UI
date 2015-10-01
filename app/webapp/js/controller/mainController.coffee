"use strict"

mainController = ($scope, $rootScope, $timeout, $http, localStorageService) ->
  $rootScope.basicInfo = {}

  $scope.logout = ->
    try
      $http.post('/logout').then ((response) ->
        localStorageService.remove("_userDetails")
        window.location = "/thanks"
      ), (response) ->
    catch e
      throw new Error(e.message)

  $rootScope.closePop = ()->
    console.log "closePop"
    #$modalInstance.close()

  $scope.cancelPop = () ->
    console.log "cancelPop"
    #$modalInstance.dismiss('cancel')

  $rootScope.$on '$viewContentLoaded', ->
    $rootScope.basicInfo = localStorageService.get("_userDetails")

  $scope.goToManageGroups = ->
    lsKeys = localStorageService.keys()
    if _.contains(lsKeys, "_selectedCompany")
      window.location = "/manageGroup"
    else
      toastr.error("Select company first.", "Error")

angular.module('giddhWebApp').controller 'mainController', mainController