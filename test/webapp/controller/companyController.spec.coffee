'use strict'

describe 'companyController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, currencyService, toastr, localStorageService) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @currencyService = currencyService
    @toastr = toastr
    @localStorageService = localStorageService
    @companyController = $controller('companyController',
        {$scope: @scope, $rootScope: @rootScope, currencyService: @currencyService, toastr: @toastr, localStorageService: @localStorageService})

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
    it 'should call not service method and return success', ->
      data = {'code':'USD'}
      spyOn(@localStorageService, "keys").andReturn(['_currencyList'])
      spyOn(@localStorageService, "get").andReturn(data)
      spyOn(@currencyService, "getList")

      @scope.getCurrencyList()

      expect(@scope.currencyList).toBe(data)
      expect(@currencyService.getList).not.toHaveBeenCalled()

    it 'should call service method and return success', ->
      data = {'code':'USD'}
      spyOn(@localStorageService, "keys").andReturn([])
      spyOn(@localStorageService, "get")
      spyOn(@currencyService, "getList").andReturn(data)

      @scope.getCurrencyList()

      expect(@currencyService.getList).toHaveBeenCalledWith(@scope.getCurrencyListSuccess, @scope.getCurrencyListFailure)
      expect(@localStorageService.get).not.toHaveBeenCalled()
