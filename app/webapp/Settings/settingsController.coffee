'use strict'

settingsController = ($scope,$rootScope) ->
  $rootScope.cmpViewShow = true
  $scope.showSubMenus = false

giddh.webApp.controller 'settingsController', settingsController