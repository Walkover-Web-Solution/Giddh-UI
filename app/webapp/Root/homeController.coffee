"use strict"
homeController = ($scope, $rootScope, getLedgerState, $state, $location, localStorageService, $http) ->

  $scope.goToLedgerState = () ->
    $rootScope.firstLogin = getLedgerState.data.firstLogin
    # if getLedgerState.data.shared && getLedgerState.data.firstLogin == false
    #   $rootScope.selectedCompany = getLedgerState.data
    # if getLedgerState.data.role.uniqueName == 'super_admin' || getLedgerState.data.role.uniqueName == 'view_only' || getLedgerState.data.role.uniqueName == 'super_admin_off_the_record'
    #   $state.go('dashboard')
    # else
    $http.get('/state-details').then(
        (res) ->
            if res.data.body.isAvailable
                if res.data.body.companyUniqueName == $rootScope.selectedCompany.uniqueName
                    if res.data.body.lastState.indexOf('ledger') != -1
                        state = res.data.body.lastState.split('@')
                        $state.go(state[0], {unqName:state[1]})
                    else if res.data.body.lastState != '/home'
                        $state.go(res.data.body.lastState)
                    else
                        $state.go('company.content.ledgerContent')
                else
                    lastState = {}
                    lastState.companyUniqueName = res.data.body.companyUniqueName
                    lastState.state = res.data.body.lastState
                    $rootScope.$emit('different-company' ,lastState)
        (res) ->
            $state.go('company.content.ledgerContent')
    )


    # else
    #   if (getLedgerState.data.role.uniqueName == 'super_admin' || getLedgerState.data.role.uniqueName == 'super_admin_off_the_record' || getLedgerState.data.role.uniqueName == 'view_only')
    #     $state.go('dashboard')
    #   else
    #     $state.go('company.content.manage')

  $scope.goToLedgerState()

  $rootScope.setActiveFinancialYear(getLedgerState.data.activeFinancialYear)

#init angular app
giddh.webApp.controller 'homeController', homeController
