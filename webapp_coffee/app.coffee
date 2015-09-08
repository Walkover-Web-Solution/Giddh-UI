# Author themechanic
# 22 August 2015
# Giddh Website App

app = angular.module("giddhWebApp",["satellizer","LocalStorageModule", "ngRoute"])

app.config ($routeProvider) ->
  $routeProvider.when('/home', templateUrl: '/public/view/home.html').otherwise redirectTo: '/home'
  return

app.run(($rootScope, $http)->
  console.log "app init"
)