"use strict"

ConfirmModalController = ($scope, $modalInstance, data) ->
  $scope.data = angular.copy(data)
  
  $scope.closePop = ()->
    console.log "closePop"
    $modalInstance.close()

  $scope.cancelPop = () ->
    console.log "cancelPop"
    $modalInstance.dismiss('cancel')

angular.module('giddhWebApp').controller 'ConfirmModalController', ConfirmModalController



