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

app.run(($rootScope, $http)->
  console.log "app init"
)