"use strict"
homeController = ($scope, $rootScope, getLedgerState, $state) ->

  $scope.goToLedgerState = () ->
    if getLedgerState.data.shared && getLedgerState.data.firstLogin == false
      $rootScope.selectedCompany = getLedgerState.data
      $state.go('company.content.ledgerContent')
    else
      $state.go('company.content.manage')
  $scope.goToLedgerState()

  #$rootScope.setActiveFinancialYear(getLedgerState.data.activeFinancialYear)


#init angular app
giddh.webApp.controller 'homeController', homeController
