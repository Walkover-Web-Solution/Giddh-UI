'use strict'

describe 'tbplController', ->
  beforeEach module('giddhWebApp')

  describe 'local variables', ->
    beforeEach inject ($rootScope, $controller, localStorageService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      spyOn(@localStorageService, 'get').andReturn({name: "walkover"})

      @tbplController = $controller('tbplController',
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
      @tbplController = $controller('tbplController',
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

      xit 'should call trialBalService getAllFor method with reqparam obj', ->
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
      it 'should set value of showLedgerContent to true and set nodata var to Falsy', ->
        res = {
          body:
            closingBalance:
              amount: 10
            forwardedBalance:
              amount: 10
            debitTotal: 10
            creditTotal: 10
        }
        @scope.getTrialBalSuccess(res)
        expect(@scope.data).toEqual(res.body)
        expect(@scope.noData).toBeFalsy()
        expect(@scope.showTbplLoader).toBeFalsy()
      it 'should set value of showTbplLoader to false and set nodata var to truthy', ->
        res = {
          body:
            closingBalance:
              amount: 0
            forwardedBalance:
              amount: 0
            debitTotal: 0
            creditTotal: 0
        }
        @scope.getTrialBalSuccess(res)
        expect(@scope.data).toEqual(res.body)
        expect(@scope.noData).toBeTruthy()
        expect(@scope.showTbplLoader).toBeFalsy()

    describe '#getTrialBalFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "Error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.getTrialBalFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)   

    describe '#filterBydate', ->
      it 'should call getTrialBal with filtered dates', ->
        dateObj = {
            fromDate: '15/01/2015'
            toDate: '08/12/2015'
          }
        expect(@scope.expanded).toBeFalsy()
        spyOn(@scope, "getTrialBal")
        @scope.getTrialBal(dateObj)
        expect(@scope.getTrialBal).toHaveBeenCalledWith(dateObj)

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
