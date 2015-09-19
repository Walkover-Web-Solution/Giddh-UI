"use strict"

mainController = ($scope, $rootScope, $timeout, $http, localStorageService, $location) ->

	$rootScope.getBasicDetails = ->
		try
			$http.get('/getBasicDetails').then ((response) ->
				console.log "in getBasicDetails"
				console.log response
			), (response) ->
		catch e
			throw new Error(e.message);
		

	#to get localstorage key
	#lsKeys = localStorageService.keys()
				
	##logout calling
	$scope.logout = ->
		console.log "vipin farzi"
		try
			$http.post('/logout').then ((response) ->
				console.log "in logout response"
				console.log response
				localStorageService.remove("_userDetails")
				#$location.path('/thankyou')
				window.location = "/thanks"
			), (response) ->
				#console.log response
		catch e
			throw new Error(e.message);
	

	$rootScope.$on '$viewContentLoaded', ->
		console.log "view ready"
		$rootScope.getBasicDetails()


angular.module('giddhWebApp').controller 'mainController', mainController