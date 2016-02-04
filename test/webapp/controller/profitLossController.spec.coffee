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
    
    describe '#getPlSuccess', ->
      it 'should set showLedgerBox to true and assign data in scope variable and call calCulateTotal function', ->
        res = {
          body:
            closingBalance:10
            expenseGroups: [
              {closingBalance: 100}
              {closingBalance: 400}
            ]
            incomeGroups: [
              {closingBalance: 500}
              {closingBalance: 600}
            ]
        }
        spyOn(@scope, "calCulateTotal")
        @scope.getPlSuccess(res)
        expect(@scope.calCulateTotal).toHaveBeenCalledWith(res.body.expenseGroups)
        expect(@scope.calCulateTotal).toHaveBeenCalledWith(res.body.incomeGroups)
        expect(@scope.data).toEqual(res.body)
        expect(@rootScope.showLedgerBox).toBeTruthy()
    
      it 'should set noData to falsy, and not call calCulateTotal function and assign data', ->
        res = {
          body:
            closingBalance: 0
            expenseGroups: []
            incomeGroups: []
        }
        spyOn(@scope, "calCulateTotal")
        @scope.getPlSuccess(res)
        expect(@scope.calCulateTotal).not.toHaveBeenCalledWith(res.body.expenseGroups)
        expect(@scope.calCulateTotal).not.toHaveBeenCalledWith(res.body.incomeGroups)
        expect(@scope.data).toEqual(res.body)
        expect(@rootScope.showLedgerBox).toBeTruthy()
        expect(@scope.noData).toBeTruthy()
        expect(@scope.expenseTotal).toBe(0)
        expect(@scope.incomeTotal).toBe(0) 
        

    describe '#getPlFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.getPlFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status) 

    describe '#calCulateTotal', ->
      it 'should calCulate Total and andReturn total amount', ->
        data = [
          {closingBalance: 100}
          {closingBalance: 400}
        ]
        d = 0
        d = @scope.calCulateTotal(data)
        expect(d).toBe("500.00") 

              
    