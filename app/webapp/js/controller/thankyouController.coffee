"use strict"
thankyouController = ($scope, $rootScope, localStorageService, toastr) ->



  #fire function after page fully loaded
  $scope.$on '$viewContentLoaded', ->
    console.log "thankyouController loaded"

#init angular app
angular.module('giddhWebApp').controller 'thankyouController', thankyouController
