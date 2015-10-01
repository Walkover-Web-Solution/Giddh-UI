'use strict'

describe 'companyController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, currencyService, toastr, localStorageService, locationService, $q, companyServices) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @currencyService = currencyService
    @locationService = locationService
    @toastr = toastr
    @companyServices = companyServices
    @q = $q
    @localStorageService = localStorageService
    @companyController = $controller('companyController',
        {$scope: @scope, $rootScope: @rootScope, currencyService: @currencyService, toastr: @toastr, localStorageService: @localStorageService, locationService: @locationService, companyServices: @companyServices})

  describe '#ifHavePermission', ->
    it 'should set permission according to company role data', ->
      data = {role: permissions:[{code:"MNG_USR"}]}
      @scope.ifHavePermission(data)
      expect(@scope.canManageUser).toBeTruthy()

    it 'should not set permissions if not have permission', ->
      data = {role: permissions:[{code:"NOT_USR"}]}
      @scope.ifHavePermission(data)
      expect(@scope.canManageUser).toBeFalsy()

  
  describe '#checkCmpCretedOrNot check company created or not', ->
    it 'should check if user created company or not after company modal open', ->
      @scope.companyList = []
      spyOn(@scope, 'openFirstTimeUserModal')
      @scope.checkCmpCretedOrNot()
      expect(@scope.openFirstTimeUserModal).toHaveBeenCalled()

    it 'should not open company create modal', ->
      @scope.companyList = ["1", "2"]
      spyOn(@scope, 'openFirstTimeUserModal')
      @scope.checkCmpCretedOrNot()
      expect(@scope.openFirstTimeUserModal).not.toHaveBeenCalledWith()

  describe '#getOnlyCity Get only city for create company modal', ->
    it 'should call search only city service', ->
      val = "Indore"
      deferred = @q.defer()
      spyOn(@locationService, "searchOnlyCity").andReturn(deferred.promise)
      @scope.getOnlyCity(val)
      expect(@locationService.searchOnlyCity).toHaveBeenCalledWith(val)


  describe '#createCompany', ->
    it 'should call service method', ->
      cdata = {"email":null,"contactNo":null}
      deferred = @q.defer()
      spyOn(@companyServices, "create").andReturn(deferred.promise)
      
      @scope.createCompany(cdata)
      expect(@companyServices.create).toHaveBeenCalledWith(cdata)


  describe '#onCreateCompanySuccess', ->
    it 'should show a alert and set a var to true and push data in a array', ->
      @scope.companyList = []
      response = {body: {"email":null,"contactNo":null}}
      spyOn(@toastr,'success')
      
      @scope.onCreateCompanySuccess(response)
      
      expect(@toastr.success).toHaveBeenCalledWith('Company create successfully','Success')
      expect(@scope.mngCompDataFound).toBeTruthy()
      expect(@scope.companyList).toContain(response.body)
    



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




























