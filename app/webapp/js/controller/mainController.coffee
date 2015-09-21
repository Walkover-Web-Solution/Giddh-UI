"use strict"

mainController = ($scope, $rootScope, $timeout, $http, localStorageService, $location, createCompanyService) ->

	$scope.dynamicTooltip = 'Hello, World!';

	#this var contains all basic info of user
	$rootScope.basicInfo = {}

	




	#for get localStorage items by key
	$rootScope.getItem =(key) ->
		localStorageService.get(key)

	$rootScope.getCompanyList = ->
		try
			$http.get('/getCompanyList').then ((response) ->
				console.log "in getCompanyList"
				console.log response
				if response.data.status is "error"
					#taking user to create company dialog
					$rootScope.openFirstTimeUserModal()
				else
					#doing something
					$rootScope.mngCompDataFound = true
					

			), (response) ->
		catch e
			throw new Error(e.message);
		

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
		$rootScope.getCompanyList()
		$rootScope.basicInfo = $rootScope.getItem("_userDetails")


angular.module('giddhWebApp').controller 'mainController', mainController