"use strict"

ConfirmModalController = ($scope, $modalInstance, data) ->
  $scope.data = angular.copy(data)
  
  $scope.closePop = ()->
    $modalInstance.close()

  $scope.cancelPop = () ->
    $modalInstance.dismiss('cancel')

giddh.webApp.controller 'ConfirmModalController', ConfirmModalController



