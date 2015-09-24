"use strict"

mainController = ($scope, $rootScope, $timeout, $http, localStorageService) ->

	$scope.dynamicTooltip = 'Hello, World!';

	$rootScope.basicInfo = {}

	$rootScope.getItem =(key) ->
		localStorageService.get(key)

	$scope.logout = ->
		try
			$http.post('/logout').then ((response) ->
				console.log "in logout response"
				console.log response
				localStorageService.remove("_userDetails")
				window.location = "/thanks"
			), (response) ->
		catch e
			throw new Error(e.message);

	$rootScope.$on '$viewContentLoaded', ->
		console.log "view ready"
		$rootScope.basicInfo = $rootScope.getItem("_userDetails")


angular.module('giddhWebApp').controller 'mainController', mainController