"use strict"
homeController = ($scope, $rootScope, getLedgerState, $state, localStorageService) ->

  $scope.goToLedgerState = () ->
    console.log "in goToLedgerState"
    localStorageService.set("_selectedCompany", getLedgerState.data)
    if getLedgerState.type is'shared'
      $rootScope.selectedCompany = getLedgerState.data
      $state.go('company.ledgerContent')
    else
      $state.go('company.manage')
  
  $scope.goToLedgerState()


#init angular app
giddh.webApp.controller 'homeController', homeController
