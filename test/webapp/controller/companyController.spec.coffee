'use strict'

describe 'companyController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, currencyService, toastr, localStorageService, locationService, $q, companyServices, $modal, $confirm, $timeout) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @currencyService = currencyService
    @locationService = locationService
    @modal = $modal
    @confirm = $confirm
    @toastr = toastr
    @companyServices = companyServices
    @q = $q
    @timeout = $timeout
    @localStorageService = localStorageService
    @companyController = $controller('companyController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          currencyService: @currencyService,
          toastr: @toastr,
          localStorageService: @localStorageService,
          locationService: @locationService,
          companyServices: @companyServices,
          $confirm: @confirm,
          $timeout: @timeout
        })

  describe '#ifHavePermission', ->
    it 'should set permission according to company role data', ->
      data = {
        role:
          permissions: [{code: "MNG_USR"}]
      }
      @scope.ifHavePermission(data)
      expect(@scope.canManageUser).toBeTruthy()

    it 'should not set permissions if not have permission', ->
      data = {
        role:
          permissions: [{code: "NOT_USR"}]
      }
      @scope.ifHavePermission(data)
      expect(@scope.canManageUser).toBeFalsy()

  describe '#checkCmpCretedOrNot', ->
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

  describe '#openFirstTimeUserModal', ->
    it 'should open a model to create company', ->
      modalData = {
        templateUrl: '/public/webapp/views/createCompanyModal.html',
        size: "sm",
        backdrop: 'static',
        scope: @scope
      }
      deferred = @q.defer()
      spyOn(@modal, 'open').andReturn({result: deferred.promise})

      @scope.openFirstTimeUserModal()
      expect(@modal.open).toHaveBeenCalledWith(modalData)

  describe '#onCompanyCreateModalCloseSuccess', ->
    it 'should call create with data passed', ->
      company = {name: "foo baar", city: "Indore"}
      @spyOn(@scope, 'createCompany')
      @scope.onCompanyCreateModalCloseSuccess(company)
      expect(@scope.createCompany).toHaveBeenCalledWith(company)

  describe '#onCompanyCreateModalCloseFailure', ->
    it 'should call create with data passed', ->
      @spyOn(@scope, 'checkCmpCretedOrNot')
      @scope.onCompanyCreateModalCloseFailure()
      expect(@scope.checkCmpCretedOrNot).toHaveBeenCalled()

  describe '#getOnlyCity', ->
    it 'should call search only city service', ->
      val = "Indore"
      deferred = @q.defer()
      spyOn(@locationService, "searchOnlyCity").andReturn(deferred.promise)
      @scope.getOnlyCity(val)
      expect(@locationService.searchOnlyCity).toHaveBeenCalledWith(val)

  describe '#getOnlyCitySuccess', ->
    it 'should filter data from a object', ->
      data = {
        "results": [{
          "address_components": [{
            "long_name": "Indore"
          }],
          "types": ["locality", "political"]
        }]
      }
      @scope.getOnlyCitySuccess(data)
      expect(data.results[0].types[0]).toBe("locality")
      expect(data.results[0].address_components[0].long_name).toBe("Indore")

  describe '#getOnlyCityFailure', ->
    it 'should show a toastr with error message', ->
      response = {"data": {"status": "some-error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.getOnlyCityFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#createCompany', ->
    it 'should call service method', ->
      cdata = {"email": null, "contactNo": null}
      deferred = @q.defer()
      spyOn(@companyServices, "create").andReturn(deferred.promise)
      @scope.createCompany(cdata)
      expect(@companyServices.create).toHaveBeenCalledWith(cdata)

  describe '#onCreateCompanySuccess', ->
    it 'should show a alert and set a var to true and push data in a array', ->
      @scope.companyList = []
      response = {body: {"email": null, "contactNo": null}}
      spyOn(@toastr, 'success')

      @scope.onCreateCompanySuccess(response)

      expect(@toastr.success).toHaveBeenCalledWith('Company create successfully', 'Success')
      expect(@scope.mngCompDataFound).toBeTruthy()
      expect(@scope.companyList).toContain(response.body)

  describe '#onCreateCompanyFailure', ->
    it 'should show a toastr with error message', ->
      response = {"data": {"status": "some-error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.onCreateCompanyFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#getCompanyList', ->
    it 'should call get companyList service', ->
      deferred = @q.defer()
      spyOn(@companyServices, "getAll").andReturn(deferred.promise)
      @scope.getCompanyList()
      expect(@companyServices.getAll).toHaveBeenCalled()

  describe '#getCompanyListSuccess', ->
    beforeEach ->
# @timeout = $injector.get('$timeout')
      timerCallback = jasmine.createSpy('timerCallback')
      jasmine.Clock.useMock()
      angular.element('#cmpnyli_0').click().trigger('click')


    it 'should show error if response have error and call a function to open modal', ->
      spyOn(@scope, "openFirstTimeUserModal")
      response = {"status": "error", "body": {"email": "abc@def", "contactNo": "9104120", "baseCurrency": "INR"}}
      @scope.getCompanyListSuccess(response)
      expect(@scope.openFirstTimeUserModal).toHaveBeenCalled()

    it 'should set true to a variable and push data in company list, and by default click on first child to get company details', ->
      response = {"status": "success", "body": {"email": "abc@def", "contactNo": "9104120", "baseCurrency": "INR"}}
      @scope.getCompanyListSuccess(response)
      setTimeout(->
        console.log "sarfaraz"
      , 1000)

      expect(@scope.mngCompDataFound).toBeTruthy()
      expect(@scope.companyList).toEqual(response.body)
      #waits(1500)
      @timeout.flush()
  #expect(angular.element(".companyList li").hasClass('active')).toBeTruthy()


  describe '#getCompanyListFailure', ->
    it 'should show a toastr with error message', ->
      response = {"data": {"status": "some-error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.getCompanyListFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#deleteCompany', ->
    it 'should Open Confirm Popup', ->
      deferred = @q.defer()
      @spyOn(@confirm, 'openModal').andReturn(deferred.promise)
      @scope.deleteCompany("foo", 2, "bar")
      expect(@confirm.openModal).toHaveBeenCalledWith({
        title: 'Are you sure you want to delete? bar',
        ok: 'Yes',
        cancel: 'No'
      })

  describe '#delCompanySuccess', ->
    it 'should show success message and call get companyList function', ->
      response = {"status": "success", "body": "Company 'companyUniqueName' deleted successfully."}
      spyOn(@toastr, 'success')
      spyOn(@scope, "getCompanyList")
      @scope.delCompanySuccess(response)
      expect(@toastr.success).toHaveBeenCalledWith('Company deleted successfully', 'Success')
      expect(@scope.getCompanyList).toHaveBeenCalled()

  describe '#delCompanyFailure', ->
    it 'should show error alert with toastr', ->
      response = {"data": {"status": "some-error", "message": "some-message"}}
      @spyOn(@toastr, "error")
      @scope.delCompanyFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#goToCompany', ->
    it 'should make a call for check permissions, set a variable true, put data in scope variable and set data in localStorage, and add active class in li', ->
      data = {}
      index = 0
      spyOn(@scope, "ifHavePermission")

      @scope.goToCompany(data, index)
      expect(@scope.ifHavePermission).toHaveBeenCalledWith(data)
      expect(@scope.cmpViewShow).toBeTruthy()
      expect(@scope.selectedCmpLi).toEqual(index)
      expect(@rootScope.selectedCompany).toEqual(data)


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
      expect(@toastr.success).toHaveBeenCalledWith('Company updated successfully', 'Success')
      expect(@scope.getCompanyList).toHaveBeenCalled()

  describe '#updtCompanyFailure', ->
    it 'should show error alert with toastr', ->
      response = {"data": {"status": "some-error", "message": "some-message"}}
      @spyOn(@toastr, "error")
      @scope.updtCompanyFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#getCountry', ->
    it 'should call search coutry service with value', ->
      val = "India"
      deferred = @q.defer()
      spyOn(@locationService, "searchCountry").andReturn(deferred.promise)
      @scope.getCountry(val)
      expect(@locationService.searchCountry).toHaveBeenCalledWith(val)

  describe '#getCountrySuccess', ->
    it 'should filter data from a object', ->
      data = {
        "results": [{
          "address_components": [{
            "long_name": "India"
          }],
          "types": ["country", "political"]
        }]
      }
      @scope.onGetCountrySuccess(data)
      expect(data.results[0].types[0]).toBe("country")
      expect(data.results[0].address_components[0].long_name).toBe("India")

  describe '#getState', ->
    it 'should call search state service', ->
      val = "Madhya Pradesh"
      @rootScope.selectedCompany.country = "India"
      deferred = @q.defer()
      spyOn(@locationService, "searchState").andReturn(deferred.promise)
      @scope.getState(val)
      expect(@locationService.searchState).toHaveBeenCalledWith(val, @rootScope.selectedCompany.country)

  describe '#onGetStateSuccess', ->
    it 'should filter data from a object', ->
      data = {
        "results": [{
          "address_components": [{
            "long_name": "Madhya Pradesh"
          }],
          "types": ["administrative_area_level_1", "political"]
        }]
      }
      @scope.onGetStateSuccess(data)
      expect(data.results[0].types[0]).toBe("administrative_area_level_1")
      expect(data.results[0].address_components[0].long_name).toBe("Madhya Pradesh")

  describe '#getCity', ->
    it 'should call getCity service with city value and state value', ->
      val = "Houston"
      @rootScope.selectedCompany.state = "Texas"
      deferred = @q.defer()
      spyOn(@locationService, "searchCity").andReturn(deferred.promise)
      @scope.getCity(val)
      expect(@locationService.searchCity).toHaveBeenCalledWith(val, @rootScope.selectedCompany.state)

  describe '#onGetCitySuccess', ->
    it 'should filter data from a object', ->
      data = {
        "results": [{
          "address_components": [{
            "long_name": "Texas"
          }],
          "types": ["locality", "political"]
        }]
      }
      @scope.getOnlyCitySuccess(data)
      expect(data.results[0].types[0]).toBe("locality")
      expect(data.results[0].address_components[0].long_name).toBe("Texas")

  describe '#getCurrencyList', ->
    it 'should call not service method and return success', ->
      data = {'code': 'USD'}
      spyOn(@localStorageService, "keys").andReturn(['_currencyList'])
      spyOn(@localStorageService, "get").andReturn(data)
      spyOn(@currencyService, "getList")

      @scope.getCurrencyList()

      expect(@scope.currencyList).toBe(data)
      expect(@currencyService.getList).not.toHaveBeenCalled()

    it 'should call service method and return success', ->
      data = {'code': 'USD'}
      spyOn(@localStorageService, "keys").andReturn([])
      spyOn(@localStorageService, "get")
      spyOn(@currencyService, "getList").andReturn(data)

      @scope.getCurrencyList()

      expect(@currencyService.getList).toHaveBeenCalledWith(@scope.getCurrencyListSuccess,
          @scope.getCurrencyListFailure)
      expect(@localStorageService.get).not.toHaveBeenCalled()

  describe '#getCurrencyListSuccess', ->
    it 'should save currency details to scope.currencyList', ->
      data = {"status": "success", "body": [{'code': 'USD'}, {'code': 'CAD'}, {'code': 'EUR'}]}
      @scope.getCurrencyListSuccess(data)
      expect(@scope.currencyList.length).toBe(3)
      expect(@scope.currencyList).toContain('USD')
      expect(@scope.currencyList).toContain('CAD')
      expect(@scope.currencyList).toContain('EUR')

  describe '#getCurrencyListFailure', ->
    it 'should show a toastr with error as heading', ->
      response = {"data": {"status": "some-error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.getCurrencyListFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')