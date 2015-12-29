"use strict"
thankyouController = ($scope, $rootScope, localStorageService, toastr) ->



  #fire function after page fully loaded
  $scope.$on '$viewContentLoaded', ->
    console.log "thankyouController loaded"

#init angular app
giddh.webApp.controller 'thankyouController', thankyouController
