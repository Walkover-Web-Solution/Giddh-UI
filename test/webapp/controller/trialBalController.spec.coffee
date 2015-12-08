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


















