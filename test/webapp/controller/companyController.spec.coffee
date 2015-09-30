'use strict'

describe 'companyController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, currencyService, toastr, localStorageService) ->
    @scope = $rootScope.$new()
    @currencyService = currencyService
    @toastr = toastr
    @localStorageService = localStorageService
    @companyController = $controller('companyController',
        {$scope: @scope, currencyService: @currencyService, toastr: @toastr, localStorageService: @localStorageService})

  describe '#getCurrencyListSuccess', ->
    it 'should save currency details to scope.currencyList', ->
      data = {"status":"success","body":[{'code':'USD'},{'code': 'CAD'},{'code': 'EUR'}]}
      @scope.getCurrencyListSuccess(data)
      expect(@scope.currencyList.length).toBe(3)
      expect(@scope.currencyList).toContain('USD')
      expect(@scope.currencyList).toContain('CAD')
      expect(@scope.currencyList).toContain('EUR')

  describe '#getCurrencyListFailure', ->
    it 'should show a toastr with error as heading', ->
      response = {"data":{"status":"some-error", "message":"some-message"}}
      spyOn(@toastr,'error')
      @scope.getCurrencyListFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message','Error')

  describe '#getCurrencyList', ->
    it 'should call service method and return success', ->
      spyOn(@currencyService,'getList')
      spyOn(@localStorageService,'keys').andReturn({'_currencyList': ["USD"]})
      @scope.getCurrencyList()
      expect(@currencyService.getList).toHaveBeenCalledWith(@scope.getCurrencyListSuccess, @scope.getCurrencyListFailure)