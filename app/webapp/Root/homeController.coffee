"use strict"
homeController = ($scope, $rootScope, getLedgerState, $state, $location, localStorageService, $http, $timeout) ->
  
    $scope.goToLedgerState = () ->
        $rootScope.firstLogin = getLedgerState.data.firstLogin
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

    
    $scope.goToLedgerState()
    $rootScope.setActiveFinancialYear(getLedgerState.data.activeFinancialYear)

#init angular app
giddh.webApp.controller 'homeController', homeController
