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

app.config ($routeProvider) ->
  $routeProvider
	  .when('/home',
	  	controller : 'homeController',
	  	templateUrl: '/public/webapp/views/home.html')
	  .otherwise redirectTo: '/home'
	  return

app.run(($rootScope, $http, $templateCache)->
  #$rootScope.$on '$viewContentLoaded', ->
  	#$templateCache.removeAll()

  console.log "app init"
)