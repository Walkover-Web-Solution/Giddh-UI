# 'use strict'

# describe 'homeController', ->
#   beforeEach module('giddhWebApp')

#   describe "#goToLedgerState data exist", ->
#     beforeEach inject ($rootScope, $controller, $state) ->
#       @scope = $rootScope.$new()
#       @rootScope = $rootScope
#       @getLedgerState = {data: {shared: "data found"}}
#       @state = $state
#       spyOn(@state, "go")
#       @homeController = $controller('homeController',
#         {
#           $scope: @scope,
#           $rootScope: @rootScope,
#           getLedgerState: @getLedgerState
#           $state: @state
#         })

#     xit 'should call go method with given params', ->
#       expect(@rootScope.selectedCompany).toBe(@getLedgerState.data)
#       expect(@state.go).toHaveBeenCalledWith('company.content.ledgerContent')
#       expect(@state.go).not.toHaveBeenCalledWith('company.content.manage')

#   describe "#goToLedgerState data does not exist", ->
#     beforeEach inject ($rootScope, $controller, $state) ->
#       @scope = $rootScope.$new()
#       @rootScope = $rootScope
#       @getLedgerState = {data: {}}
#       @state = $state
#       spyOn(@state, "go")
#       @homeController = $controller('homeController',
#         {
#           $scope: @scope,
#           $rootScope: @rootScope,
#           getLedgerState: @getLedgerState
#           $state: @state
#         })

#     xit 'should call go method with given params', ->
#       expect(@rootScope.selectedCompany).toBeUndefined()
#       expect(@state.go).toHaveBeenCalledWith('company.content.manage')
#       expect(@state.go).not.toHaveBeenCalledWith('company.content.ledgerContent')

