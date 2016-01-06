'use strict'

describe 'profitLossController', ->
  beforeEach module('giddhWebApp')

  describe 'local variables', ->
    beforeEach inject ($rootScope, $controller, localStorageService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      spyOn(@localStorageService, 'get').andReturn({name: "walkover"})

      @trialBalanceController = $controller('profitLossController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService})

    it 'should check scope variables set by default', ->
      expect(@scope.today).toBeDefined()
      expect(@scope.sendRequest).toBeTruthy()
      expect(@scope.noData).toBeFalsy
      expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")

  describe 'controller methods', ->
    beforeEach inject ($rootScope, $controller, companyServices, localStorageService, $filter, toastr, $timeout, $q) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      @toastr = toastr
      @filter = $filter
      @companyServices = companyServices
      @timeout = $timeout
      @q = $q
      @profitLossController = $controller('profitLossController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
          toastr: @toastr
          $filter: @filter
          $timeout: @timeout
        })
    describe '#getPl', ->
      it 'should call companyServices getPL method with reqparam obj', ->
        deferred = @q.defer()
        spyOn(@companyServices, "getPL").andReturn(deferred.promise)
        @rootScope.selectedCompany = {}
        reqParam = {
          companyUniqueName: "uniqueName"
          fromDate: ''
          toDate: ''
        }
        @rootScope.selectedCompany.uniqueName = reqParam.companyUniqueName
        @scope.getPl(reqParam)
        expect(@companyServices.getPL).toHaveBeenCalledWith(reqParam)

    