"use strict"
homeController = ($scope, $rootScope, getLedgerState, $state, localStorageService) ->

  $scope.goToLedgerState = () ->
    console.log "in goToLedgerState"
    localStorageService.set("_selectedCompany", getLedgerState.data)
    if getLedgerState.type is'shared'
      $rootScope.selectedCompany = getLedgerState.data
      $state.go('ledger.ledgerContent')
    else
      $state.go('manage-company')
  
  $scope.goToLedgerState()


#init angular app
giddh.webApp.controller 'homeController', homeController
