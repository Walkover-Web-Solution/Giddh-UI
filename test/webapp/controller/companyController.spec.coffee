'use strict'

describe 'companyController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, currencyService, toastr) ->
    @scope = $rootScope.$new()
    @currencyService = currencyService
    @toastr = toastr
    @companyController = $controller('companyController',
        {$scope: @scope, currencyService: @currencyService, toastr: @toastr})

  describe '#getCurrencyListSuccess', ->
    it 'should show toastr if status is error', ->
      data = {"status":"error","message":"some-message"}
      spyOn(@toastr,'error')
      spyOn(@toastr,'success')
      @scope.getCurrencyListSuccess(data)
      expect(@toastr.error).toHaveBeenCalledWith('some-message','Error')
      expect(@toastr.success).not.toHaveBeenCalled()

    it 'should save currency details to scope.currencyList', ->
      data = {"status":"success","body":[{'code':'USD'},{'code': 'CAD'},{'code': 'EUR'}]}
      @scope.getCurrencyListSuccess(data)
      expect(@scope.currencyList.length).toBe(3)
      expect(@scope.currencyList).toContain('USD')
      expect(@scope.currencyList).toContain('CAD')
      expect(@scope.currencyList).toContain('EUR')

  describe '#getCurrencyListFail', ->
    it 'should show a toastr with error as heading', ->
      data = {"status":"some-error", "message":"some-message"}
      spyOn(@toastr,'error')
      @scope.getCurrencyListFail(data)
      expect(@toastr.error).toHaveBeenCalledWith('some-message','Error')

  describe '#getCurrencyList', ->
    it 'should call service method and return success', ->
      spyOn(@currencyService,'getList')
      @scope.getCurrencyList()
      expect(@currencyService.getList).toHaveBeenCalledWith(@scope.getCurrencyListSuccess, @scope.getCurrencyListFail)