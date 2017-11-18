"use strict"
homeController = ($scope, $rootScope, getLedgerState, $state, $location, localStorageService, $http, $timeout) ->

    NG4_STATES = ['/home', 'Reports', 'audit-logs', 'search', 'invoice', 'invoice.accounts', 'invoice.accounts.invoiceId', 'company', 'company.content', 'company.content.manage', 'company.content.user', 'company.content.ledgerContent', 'tbpl', 'dashboard', 'inventory', 'inventory.custom-stock', 'inventory.add-group', 'inventory.add-group.stock-report', 'inventory.add-group.add-stock', 'recurring-entry', '/thankyou', 'proforma', 'proforma.accounts', 'settings', 'invoice2', 'manufacturing', 'refresh-completed', 'success'];
  
    $scope.goToLedgerState = () ->
        # $rootScope.firstLogin =  getLedgerState.data.firstLogin
        $http.get('/state-details').then(
            (res) ->
                $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
                if $rootScope.selectedCompany && $rootScope.selectedCompany.uniqueName is res.data.body.companyUniqueName and NG4_STATES.indexOf(res.data.body.lastState) isnt -1
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
    if getLedgerState.data
        $rootScope.setActiveFinancialYear(getLedgerState.data.activeFinancialYear)

#init angular app
giddh.webApp.controller 'homeController', homeController
