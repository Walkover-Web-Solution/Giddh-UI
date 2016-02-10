"use strict"
homeController = ($scope, $rootScope, getLedgerState, $state) ->

  $scope.goToLedgerState = () ->
    if getLedgerState.data.shared
      $rootScope.selectedCompany = getLedgerState.data
      $state.go('company.content.ledgerContent')
    else
      $state.go('company.content.manage')
  $scope.goToLedgerState()



#init angular app
giddh.webApp.controller 'homeController', homeController
