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

    # it 'should check scope variables set by default', ->
    #   expect(@scope.today).toBeDefined()
    #   expect(@scope.fromDate.date).toBeDefined()
    #   expect(@scope.toDate.date).toBeDefined()
    #   expect(@scope.fromDatePickerIsOpen).toBeFalsy()
    #   expect(@scope.fromDatePickerIsOpen).toBeFalsy
    #   expect(@dateOptions).fromDate.toBeDefined()
    #   expect(@dateOptions).toDate.toBeDefined()
    #   expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")


  describe 'controller methods', ->
    beforeEach inject ($rootScope, $controller, localStorageService, toastr, $timeout, $filter) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      @toastr = toastr
      @timeout = $timeout
      @filter = $filter
      @trialBalanceController = $controller('trialBalanceController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
          toastr: @toastr
          $timeout: @timeout
          $filter: @filter
        })
    describe 'getTrialBal', ->
      it 'should show alert if date format is wrong', ->
        @scope.toDate = {
          date: null
        }
        @scope.fromDate = {
          date: null
        }
        defaultDate = {
        'fromDate':"01-04-2015"
        'toDate': "30-11-2015"
        }
        spyOn(@toastr, 'error')
        @scope.getTrialBal(defaultDate)
        expect(@toastr.error).toHaveBeenCalledWith('Date should be in proper format', 'Error')


