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

  describe '#getOnlyCitySuccess', ->
    it 'should filter data from a object', ->
      data = {"results" : [{
         "address_components" : [{
            "long_name" : "Indore"
          }],
         "types" : [ "locality", "political" ]
      }]} 
      @scope.getOnlyCitySuccess(data)
      expect(data.results[0].types[0]).toBe("locality")
      expect(data.results[0].address_components[0].long_name).toBe("Indore")
  
  describe '#getOnlyCityFailure', ->
    it 'should show a toastr with error message', ->
      response = {"data":{"status":"some-error", "message":"some-message"}}
      spyOn(@toastr,'error')
      @scope.getOnlyCityFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message','Error')


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
  
  describe '#onCreateCompanyFailure', ->
    it 'should show a toastr with error message', ->
      response = {"data":{"status":"some-error", "message":"some-message"}}
      spyOn(@toastr,'error')
      @scope.onCreateCompanyFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message','Error')


  describe '#getCompanyList', ->
    it 'should call get companyList service', ->
      deferred = @q.defer()
      spyOn(@companyServices, "getAll").andReturn(deferred.promise)
      @scope.getCompanyList()
      expect(@companyServices.getAll).toHaveBeenCalled()
    
  describe '#getCompanyListSuccess', ->
    it 'should show error if response have error and call a function to open modal', ->
      spyOn(@scope, "openFirstTimeUserModal")
      response = {"status": "error", "body": {"email":"abc@def","contactNo":"9104120","baseCurrency":"INR"}}
      @scope.getCompanyListSuccess(response)
      expect(@scope.openFirstTimeUserModal).toHaveBeenCalled()

    it 'should set true to a variable and push data in company list', ->
      response = {"status": "success", "body": {"email":"abc@def","contactNo":"9104120","baseCurrency":"INR"}}
      @scope.getCompanyListSuccess(response)
      expect(@scope.mngCompDataFound).toBeTruthy()
      expect(@scope.companyList).toEqual(response.body)
    

  describe '#getCompanyListFailure', ->
    it 'should show a toastr with error message', ->
      response = {"data":{"status":"some-error", "message":"some-message"}}
      spyOn(@toastr,'error')
      @scope.getCompanyListFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message','Error')


  describe '#delCompanySuccess', ->
    it 'should show success message and call get companyList function', ->
      response = {"status":"success","body":"Company 'companyUniqueName' deleted successfully."}
      spyOn(@toastr,'success')
      spyOn(@scope, "getCompanyList")
      @scope.delCompanySuccess(response)
      expect(@toastr.success).toHaveBeenCalledWith('Company deleted successfully','Success')
      expect(@scope.getCompanyList).toHaveBeenCalled()
    
  describe '#delCompanyFailure', ->
    it 'should show error alert with toastr', ->
      response = {"data":{"status":"some-error", "message":"some-message"}}
      @spyOn(@toastr, "error")
      @scope.delCompanyFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message','Error')

  describe '#goToCompany', ->
    it 'should make a call for check permissions, set a variable true, put data in scope variable and set data in localStorage', ->
      data = {}
      spyOn(@scope, "ifHavePermission")
      spyOn(@localStorageService, "set")

      @scope.goToCompany(data)
      expect(@scope.ifHavePermission).toHaveBeenCalledWith(data)
      expect(@scope.cmpViewShow).toBeTruthy()
      expect(@scope.companyBasicInfo).toEqual(data) 
      expect(@localStorageService.set).toHaveBeenCalledWith("_selectedCompany", data)
  
  describe '#updateCompanyInfo', ->
    it 'should update company data if form is valid', ->
      data = {}
      deferred = @q.defer()
      spyOn(@companyServices, "update").andReturn(deferred.promise)
      @scope.updateCompanyInfo(data)
      expect(@companyServices.update).toHaveBeenCalledWith(data)

  describe '#updtCompanySuccess', ->
    it 'should show success alert with toastr and call getCompanyList function', ->
      response = {}
      spyOn(@toastr, "success")
      spyOn(@scope, "getCompanyList")
      
      @scope.updtCompanySuccess(response)
      expect(@toastr.success).toHaveBeenCalledWith('Company updated successfully','Success')
      expect(@scope.getCompanyList).toHaveBeenCalled()

  describe '#updtCompanyFailure', ->
    it 'should show error alert with toastr', ->
      response = {"data":{"status":"some-error", "message":"some-message"}}
      @spyOn(@toastr, "error")
      @scope.updtCompanyFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message','Error')

  describe '#getCountry', ->
    it 'should call search coutry service with value', ->
      val = "India"
      deferred = @q.defer()
      spyOn(@locationService, "searchCountry").andReturn(deferred.promise)
      @scope.getCountry(val)
      expect(@locationService.searchCountry).toHaveBeenCalledWith(val)
  
  describe '#getCountrySuccess', ->
    it 'should filter data from a object', ->
      data = {"results" : [{
         "address_components" : [{
            "long_name" : "India"
          }],
         "types" : [ "country", "political" ]
      }]} 
      @scope.onGetCountrySuccess(data)
      expect(data.results[0].types[0]).toBe("country")
      expect(data.results[0].address_components[0].long_name).toBe("India")
  
  describe '#getState', ->
    it 'should call search state service', ->
      val = "Madhya Pradesh"
      @scope.companyBasicInfo.country = "India"
      deferred = @q.defer()
      spyOn(@locationService, "searchState").andReturn(deferred.promise)
      @scope.getState(val)
      expect(@locationService.searchState).toHaveBeenCalledWith(val, @scope.companyBasicInfo.country)
  
  describe '#onGetStateSuccess', ->
    it 'should filter data from a object', ->
      data = {"results" : [{
         "address_components" : [{
            "long_name" : "Madhya Pradesh"
          }],
         "types" : [ "administrative_area_level_1", "political" ]
      }]} 
      @scope.onGetStateSuccess(data)
      expect(data.results[0].types[0]).toBe("administrative_area_level_1")
      expect(data.results[0].address_components[0].long_name).toBe("Madhya Pradesh")
    
  describe '#getCity', ->
    it 'should call getCity service with city value and state value', ->
      val = "Houston"
      @scope.companyBasicInfo.state = "Texas"
      deferred = @q.defer()
      spyOn(@locationService, "searchCity").andReturn(deferred.promise)
      @scope.getCity(val)
      expect(@locationService.searchCity).toHaveBeenCalledWith(val, @scope.companyBasicInfo.state)

  describe '#onGetCitySuccess', ->
    it 'should filter data from a object', ->
      data = {"results" : [{
         "address_components" : [{
            "long_name" : "Texas"
          }],
         "types" : [ "locality", "political" ]
      }]} 
      @scope.getOnlyCitySuccess(data)
      expect(data.results[0].types[0]).toBe("locality")
      expect(data.results[0].address_components[0].long_name).toBe("Texas")

    

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

  




























