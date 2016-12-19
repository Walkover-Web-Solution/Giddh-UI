"use strict"
homeController = ($scope, $rootScope, getLedgerState, $state, $location, localStorageService) ->

  $scope.goToLedgerState = () ->
    if getLedgerState.data.shared && getLedgerState.data.firstLogin == false
      $rootScope.selectedCompany = getLedgerState.data
      if getLedgerState.data.role.uniqueName == 'super_admin' || getLedgerState.data.role.uniqueName == 'view_only' || getLedgerState.data.role.uniqueName == 'super_admin_off_the_record'
        $state.go('dashboard')
      else
        $state.go('company.content.ledgerContent')
    else
      if (getLedgerState.data.role.uniqueName == 'super_admin' || getLedgerState.data.role.uniqueName == 'super_admin_off_the_record' || getLedgerState.data.role.uniqueName == 'view_only')
        $state.go('dashboard')
      else
        $state.go('company.content.manage')

  $scope.goToLedgerState()

  $rootScope.setActiveFinancialYear(getLedgerState.data.activeFinancialYear)


#init angular app
giddh.webApp.controller 'homeController', homeController
