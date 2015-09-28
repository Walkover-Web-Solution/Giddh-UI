"use strict"

mainController = ($scope, $rootScope, $timeout, $http, localStorageService) ->

  $rootScope.basicInfo = {}

  $rootScope.getItem = (key) ->
    localStorageService.get(key)

  $scope.logout = ->
    try
      $http.post('/logout').then ((response) ->
        localStorageService.remove("_userDetails")
        window.location = "/thanks"
      ), (response) ->
    catch e
      throw new Error(e.message)

  $rootScope.$on '$viewContentLoaded', ->
    $rootScope.basicInfo = $rootScope.getItem("_userDetails")


angular.module('giddhWebApp').controller 'mainController', mainController