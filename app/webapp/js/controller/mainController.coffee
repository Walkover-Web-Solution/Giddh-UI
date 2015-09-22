"use strict"

mainController = ($scope, $rootScope, $timeout, $http, localStorageService, $location, homeControllerServices) ->

	$scope.dynamicTooltip = 'Hello, World!';

	#this var contains all basic info of user
	$rootScope.basicInfo = {}

	




	#for get localStorage items by key
	$rootScope.getItem =(key) ->
		localStorageService.get(key)

	
		

	#to get localstorage key
	#lsKeys = localStorageService.keys()
				
	##logout calling
	$scope.logout = ->
		try
			$http.post('/logout').then ((response) ->
				console.log "in logout response"
				console.log response
				localStorageService.remove("_userDetails")
				window.location = "/thanks"
			), (response) ->
				#console.log response
		catch e
			throw new Error(e.message);
	
	

	$rootScope.$on '$viewContentLoaded', ->
		console.log "view ready"
		$rootScope.basicInfo = $rootScope.getItem("_userDetails")


angular.module('giddhWebApp').controller 'mainController', mainController