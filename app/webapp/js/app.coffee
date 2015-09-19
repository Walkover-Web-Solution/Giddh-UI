# Author themechanic
# 22 August 2015
# Giddh Website App

app = angular.module("giddhWebApp",
	[
		"satellizer"
		"LocalStorageModule"
		"ngRoute"
		"ngResource"
		"perfect_scrollbar"
		"ui.tree"
		"ngSanitize"
	]
)

app.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix 'giddh'

app.config ($locationProvider, $routeProvider) ->
  # $locationProvider.html5Mode({
  # 	enabled: true,
  # 	requireBase: false
  # })
  $routeProvider
	  .when('/home',
	  	controller : 'homeController',
	  	templateUrl: '/public/webapp/views/home.html'
	  )
	  .when('/thankyou',
	  	controller : 'homeController',
	  	templateUrl: '/public/webapp/views/thanks.html'
	  )
	  .otherwise redirectTo: '/home'

app.run(($rootScope, $http, $templateCache)->
  #$rootScope.$on '$viewContentLoaded', ->
  	#$templateCache.removeAll()

  console.log "app init"
)