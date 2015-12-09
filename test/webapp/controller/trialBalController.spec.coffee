'use strict'

describe 'trialBalanceController', ->
  beforeEach module('giddhWebApp')

  describe 'local variables', ->
    beforeEach inject ($rootScope, $controller, localStorageService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      spyOn(@localStorageService, 'get').andReturn({name: "walkover"})

      @trialBalanceController = $controller('trialBalanceController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService})

    it 'should check scope variables set by default', ->
      spyOn(@scope, "getDefaultDate")
      expect(@scope.today).toBeDefined()
      expect(@scope.fromDate.date).toBeDefined()
      expect(@scope.toDate.date).toBeDefined()
      expect(@scope.fromDatePickerIsOpen).toBeFalsy()
      expect(@scope.fromDatePickerIsOpen).toBeFalsy
      expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")

  describe 'controller methods', ->
    beforeEach inject ($rootScope, $controller, localStorageService, toastr, $timeout, $filter, trialBalService, $q) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      @toastr = toastr
      @timeout = $timeout
      @filter = $filter
      @trialBalService = trialBalService
      @q = $q
      @trialBalanceController = $controller('trialBalanceController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
          toastr: @toastr
          $timeout: @timeout
          $filter: @filter
        })
    describe '#getTrialBal', ->
      it 'should show alert with toastr error if date is null ', ->
        spyOn(@toastr, "error")
        deferred = @q.defer()
        spyOn(@trialBalService, "getAllFor").andReturn(deferred.promise)
        data = {
          fromDate: null
          toDate: null
        }
        @scope.getTrialBal(data)
        expect(@toastr.error).toHaveBeenCalledWith("Date should be in proper format", "Error")
        expect(@trialBalService.getAllFor).not.toHaveBeenCalled()

      it 'should call trialBalService getAllFor method with reqparam obj', ->
        spyOn(@toastr, "error")
        deferred = @q.defer()
        spyOn(@trialBalService, "getAllFor").andReturn(deferred.promise)
        @rootScope.selectedCompany = {
          uniqueName: "somename"
        }
        data = {
          fromDate: "01-04-2015"
          toDate: "30-11-2015"
        }
        reqParam = {
          companyUniqueName: @rootScope.selectedCompany.uniqueName
          fromDate: data.fromDate
          toDate: data.toDate
        }
        @scope.getTrialBal(data)
        expect(@toastr.error).not.toHaveBeenCalledWith("Date should be in proper format", "Error")
        expect(@trialBalService.getAllFor).toHaveBeenCalledWith(reqParam)

    describe '#getTrialBalSuccess', ->
      it 'should set value of showLedgerContent to true', ->
       res = {
          body: {}
       }
       @scope.getTrialBalSuccess(res)
       expect(@scope.data).toEqual(res.body)
       expect(@rootScope.showLedgerBox).toBeTruthy()

    describe '#getTrialBalFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.getTrialBalFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)   

    describe '#filterByDate', ->
      it 'should call getTrialBal with filtered dates', ->
        dateObj = {
            fromDate: '15/01/2015'
            toDate: '08/12/2015'
          }
        expect(@scope.expanded).toBeFalsy()
        expect(@rootScope.showLedgerBox).toBeFalsy()
        spyOn(@scope, "getTrialBal")
        @scope.getTrialBal(dateObj)
        expect(@scope.getTrialBal).toHaveBeenCalledWith(dateObj)

    describe '#typeFilter', ->
      it 'should be called with input', ->
        input = ''
        spyOn(@scope, "typeFilter")
        @scope.typeFilter(input)
        expect(@scope.typeFilter).toHaveBeenCalledWith(input)

    describe '#formatData', ->
      it 'should call formatDataGroupWise , formatDataAccountWise and formatDataCondensed', ->
        spyOn(@scope, "formatData").andCallThrough()
        spyOn(@scope, "formatDataCondensed")
        spyOn(@scope, "formatDataAccountWise")
        spyOn(@scope, "formatDataGroupWise")
        @scope.formatData()
        expect(@scope.formatDataCondensed).toHaveBeenCalled()
        expect(@scope.formatDataAccountWise).toHaveBeenCalled()
        expect(@scope.formatDataGroupWise).toHaveBeenCalled()  












