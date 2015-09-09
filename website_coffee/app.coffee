# Author themechanic
# 22 August 2015
# Giddh Website App

app = angular.module("giddhApp",["satellizer","LocalStorageModule"])

app.config(["$authProvider"
  ($authProvider) ->
    $authProvider.google({
      clientId: '40342793-h9vu599ed13f54kb673t2ltbc713vad7.apps.googleusercontent.com'  
    })
])

app.config (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix 'giddh'

app.run(($rootScope, $http, $location)->
  console.log "app init"
)

do ->
  angular.module('giddhApp', []).directive 'autoActive', [
    '$location'
    ($location) ->
      {
        restrict: 'A'
        scope: false
        link: (scope, element) ->
          setActive = ->
            fURL = $location.absUrl().split('/')
            pathT = fURL.reverse()
            path = pathT[0]
            if path
              elem = angular.element('.nav li a.' + path)
              elem.addClass 'active'
            else
              elem = angular.element('.nav li a.home')
              elem.addClass 'active'

          setActive()
          scope.$on '$locationChangeSuccess', setActive
          return

      }
  ]
  return