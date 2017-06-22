"use strict"
homeController = ($scope, $rootScope, getLedgerState, $state, $location, localStorageService, $http, $timeout) ->
  $scope.goToLedgerState = () ->
    $rootScope.firstLogin = getLedgerState.data.firstLogin
    # if getLedgerState.data.shared && getLedgerState.data.firstLogin == false
    #   $rootScope.selectedCompany = getLedgerState.data
    # if getLedgerState.data.role.uniqueName == 'super_admin' || getLedgerState.data.role.uniqueName == 'view_only' || getLedgerState.data.role.uniqueName == 'super_admin_off_the_record'
    #   $state.go('dashboard')
    # else
    $http.get('/state-details').then(
        (res) ->
            $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
            if $rootScope.selectedCompany.uniqueName == res.data.body.companyUniqueName
                if res.data.body.lastState.indexOf('ledger') isnt -1
                    state = res.data.body.lastState.split('@')
                    $state.go(state[0], {unqName:state[1]})
                else if res.data.body.lastState != '/home'
                    $state.go(res.data.body.lastState)
                else
                    $state.go('company.content.ledgerContent')
            else
                lastStateData =  res.data.body
                $rootScope.$emit('different-company', lastStateData)
        (res) ->
            $state.go('company.content.ledgerContent')
    )
    #$state.go('company.content.ledgerContent')

    # else
    #   if (getLedgerState.data.role.uniqueName == 'super_admin' || getLedgerState.data.role.uniqueName == 'super_admin_off_the_record' || getLedgerState.data.role.uniqueName == 'view_only')
    #     $state.go('dashboard')
    #   else
    #     $state.go('company.content.manage')

    $timeout (->
        $scope.goToLedgerState()
    ), 500

    $rootScope.setActiveFinancialYear(getLedgerState.data.activeFinancialYear)

#init angular app
giddh.webApp.controller 'homeController', homeController
