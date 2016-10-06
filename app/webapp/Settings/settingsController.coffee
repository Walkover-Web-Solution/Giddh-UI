'use strict'

settingsController = ($scope,$rootScope) ->
  $rootScope.cmpViewShow = true
  $scope.showSubMenus = false
  $scope.webhooks = [{url:"https://www.giddh.com", days:-2}, {url:"https://www.giddh.com", days:2}, {url:"", days:""}]
  $scope.autoPayOption = [{}]

giddh.webApp.controller 'settingsController', settingsController