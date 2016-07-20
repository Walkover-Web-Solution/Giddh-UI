"use strict"

ConfirmModalController = ($scope, $uibModalInstance, data) ->
  $scope.data = angular.copy(data)
  
  $scope.closePop = ()->
    $uibModalInstance.close()

  $scope.cancelPop = () ->
    $uibModalInstance.dismiss('cancel')

giddh.webApp.controller 'ConfirmModalController', ConfirmModalController