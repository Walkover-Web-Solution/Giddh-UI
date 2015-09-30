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
    it 'should return success if status is success', ->
      @scope.getCurrencyListSuccess(data)
      expect()
    it 'should return false and show toaster if status is error', ->

  describe '#getCurrencyList', ->
    it 'should call service method and return success', ->
      spyOn(@currencyService,'getList')
      @scope.getCurrencyList()
      expect(@currencyService.getList).toHaveBeenCalledWith(@scope.getCurrencyListSuccess, @scope.getCurrencyListFail)