'use strict'

describe 'companyController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, currencyService, toastr, localStorageService, locationService, $q, companyServices, $modal, modalService, $timeout) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @currencyService = currencyService
    @locationService = locationService
    @modal = $modal
    @modalService = modalService
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
          modalService: @modalService,
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
    it 'should show error if response have error and call a function to open modal', ->
      spyOn(@scope, "openFirstTimeUserModal")
      response = {"body": []}
      @scope.getCompanyListSuccess(response)
      expect(@scope.openFirstTimeUserModal).toHaveBeenCalled()

    it 'should set true to a variable and push data in company list, and by default click on first child to get company details', ->
      response = {"body": [{"email": "abc@def", "contactNo": "9104120", "baseCurrency": "INR", "index": 0}]}
      spyOn(@scope, "goToCompany")
      spyOn(@localStorageService, "get").andReturn(response.body[0])

      @scope.getCompanyListSuccess(response)

      expect(@scope.mngCompDataFound).toBeTruthy()
      expect(@scope.companyList).toEqual(response.body)
      expect(@scope.goToCompany).toHaveBeenCalledWith(response.body[0], 0)

  describe '#getCompanyListFailure', ->
    it 'should show a toastr with error message', ->
      response = {"data": {"status": "some-error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.getCompanyListFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#deleteCompany', ->
    it 'should Open Confirm Popup', ->
      deferred = @q.defer()
      @spyOn(@modalService, 'openConfirmModal').andReturn(deferred.promise)
      @scope.deleteCompany("foo", 2, "bar")
      expect(@modalService.openConfirmModal).toHaveBeenCalledWith({
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
      data = {uniqueName: "afafafafaf1443520197325007bgo", "index": 0, "cCode": ""}
      index = 0
      @scope.canManageUser = true

      spyOn(@scope, "ifHavePermission")
      spyOn(@scope, "getSharedUserList")

      @scope.goToCompany(data, index)
      expect(@scope.ifHavePermission).toHaveBeenCalledWith(data)
      expect(@scope.cmpViewShow).toBeTruthy()
      expect(@scope.selectedCmpLi).toEqual(index)
      expect(@scope.selectedCompany).toEqual(data)
      expect(@scope.getSharedUserList).toHaveBeenCalledWith("afafafafaf1443520197325007bgo")

    it 'should not call getSharedUserList', ->
      @scope.canManageUser = false
      data = {uniqueName: "afafafafaf1443520197325007bgo", "index": 0, "cCode": ""}
      index = 0

      spyOn(@scope, "ifHavePermission")
      spyOn(@scope, "getSharedUserList")
      @scope.goToCompany(data, index)
      expect(@scope.ifHavePermission).toHaveBeenCalledWith(data)
      expect(@scope.cmpViewShow).toBeTruthy()
      expect(@scope.selectedCmpLi).toEqual(index)
      expect(@scope.selectedCompany).toEqual(data)
      expect(@scope.getSharedUserList).not.toHaveBeenCalledWith("afafafafaf1443520197325007bgo")


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

  describe '#updateUserRole', ->
    it 'should call companyServices.share service with role or json object contains email', ->
      role = "view_only"
      userEmail = "s@g.com"
      sData = {role: role, user: userEmail}
      @scope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      deferred = @q.defer()
      spyOn(@companyServices, "share").andReturn(deferred.promise)
      @scope.updateUserRole(role, userEmail)
      expect(@companyServices.share).toHaveBeenCalledWith(@scope.selectedCompany.uniqueName, sData)

  describe '#shareCompanyWithUser', ->
    it 'should call companyServices.share service with role or json object contains email', ->
      @scope.shareRequest = {role: "view_only", user: "s@g.com"}
      @scope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      deferred = @q.defer()
      spyOn(@companyServices, "share").andReturn(deferred.promise)
      @scope.shareCompanyWithUser()
      expect(@companyServices.share).toHaveBeenCalledWith(@scope.selectedCompany.uniqueName, @scope.shareRequest)

  describe '#onShareCompanySuccess', ->
    it 'should make a blank object, show success message and call getSharedUserList function', ->
      @scope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      data = {}
      response = {"status": "success", "body": "Company 'companyUniqueName' shared successfully with 'name'"}
      spyOn(@toastr, 'success')
      spyOn(@scope, "getSharedUserList")

      @scope.onShareCompanySuccess(response)
      expect(@scope.shareRequest).toEqual(data)
      expect(@toastr.success).toHaveBeenCalledWith("Company 'companyUniqueName' shared successfully with 'name'",
          "success")
      expect(@scope.getSharedUserList).toHaveBeenCalledWith(@scope.selectedCompany.uniqueName)

  describe '#onShareCompanyFailure', ->
    it 'should show toastr with error message', ->
      response = {"data": {"status": "Error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.onShareCompanyFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#getRolesList', ->
    it 'should call companyService with getRoles method', ->
      @scope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      deferred = @q.defer()
      spyOn(@companyServices, "getRoles").andReturn(deferred.promise)
      @scope.getRolesList()
      expect(@companyServices.getRoles).toHaveBeenCalledWith(@scope.selectedCompany.uniqueName)

  describe '#getRolesSuccess', ->
    it 'should set data in scope variable rolesList', ->
      response = {
        "status": "success"
        "body": [{
          "name": "Some Name"
          "uniqueName": "some_name"
        }]
      }
      @scope.getRolesSuccess(response)
      expect(@scope.rolesList).toEqual(response.body)

  describe '#getRolesFailure', ->
    it 'should show toastr with error message', ->
      response = {"data": {"status": "Error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.getRolesFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#getSharedUserList', ->
    it 'should call companyService with shredList method', ->
      uniqueName = "afafafafaf1443520197325007bgo"
      deferred = @q.defer()
      spyOn(@companyServices, "shredList").andReturn(deferred.promise)
      @scope.getSharedUserList(uniqueName)
      expect(@companyServices.shredList).toHaveBeenCalledWith(uniqueName)


  describe '#getSharedUserListSuccess', ->
    it 'should set data in scope variable sharedUsersList', ->
      response = {
        "status": "success",
        "body": [{"userName": "ravi", "userEmail": "ravisoni@hostnsoft.com", "userUniqueName": "ravisoni"}]
      }
      @scope.getSharedUserListSuccess(response)
      expect(@scope.sharedUsersList).toEqual(response.body)

  describe '#getSharedUserListFailure', ->
    it 'should show toastr with error message', ->
      response = {"data": {"status": "Error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.getSharedUserListFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#unSharedUser', ->
    it 'should call companyService with unSharedComp method', ->
      id = 0
      data = {user: "uNqame"}
      @scope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}

      deferred = @q.defer()
      spyOn(@companyServices, "unSharedComp").andReturn(deferred.promise)
      @scope.unSharedUser(data.user, id)
      expect(@companyServices.unSharedComp).toHaveBeenCalledWith(@scope.selectedCompany.uniqueName, data)

  describe '#unSharedCompSuccess', ->
    it 'should show success toastr and call getSharedUserList function', ->
      @scope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      response = {"status": "success", "body": "Company unshared successfully"}
      spyOn(@toastr, 'success')
      spyOn(@scope, "getSharedUserList")
      @scope.unSharedCompSuccess(response)
      expect(@toastr.success).toHaveBeenCalledWith("Company unshared successfully", "Success")
      expect(@scope.getSharedUserList).toHaveBeenCalledWith(@scope.selectedCompany.uniqueName)

  describe '#unSharedCompFailure', ->
    it 'should show toastr with error message', ->
      response = {"data": {"status": "Error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.unSharedCompFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')