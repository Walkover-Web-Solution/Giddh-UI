'use strict'

describe 'companyController', ->
  beforeEach module('giddhWebApp')

  describe 'local variables', ->
    beforeEach inject ($rootScope, $controller, localStorageService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @companyController = $controller('companyController',
        {
          $scope: @scope, 
          $rootScope: @rootScope
        }
      )

    it 'should check scope variables set by default', ->
      expect(@rootScope.mngCompDataFound).toBeFalsy()
      expect(@rootScope.cmpViewShow).toBeFalsy()
      expect(@rootScope.selectedCompany).toEqual({})
      expect(@scope.mHideBar).toBeFalsy()
      expect(@scope.dHideBar).toBeFalsy()
      expect(@scope.showUpdTbl).toBeFalsy()
      expect(@scope.compSetBtn).toBeTruthy()
      expect(@scope.compDataFound).toBeFalsy()
      expect(@scope.compTransData).toEqual({})
      expect(@scope.showPayOptns).toBeFalsy()
      expect(@scope.isHaveCoupon).toBeFalsy()
      # contains company list
      expect(@scope.companyList).toEqual([])
      expect(@scope.companyDetails).toEqual({})
      expect(@scope.currencyList).toEqual([])
      expect(@scope.currencySelected).toBeUndefined()
      expect(@scope.shareRequest).toEqual({role: 'view_only', user: null})
      # userController methods
      expect(@scope.payAlert).toEqual([])
      expect(@scope.coupRes).toEqual({})
      expect(@scope.coupon).toEqual({})
      expect(@scope.payStep2).toBeFalsy()
      expect(@scope.payStep3).toBeFalsy()
      expect(@scope.directPay).toBeFalsy()
      expect(@scope.wlt.status).toBeFalsy()
      expect(@scope.disableRazorPay).toBeFalsy()
      expect(@scope.discount).toBe(0)
      expect(@scope.amount).toBe(0)

  beforeEach inject ($rootScope, $controller, currencyService, toastr, localStorageService, locationService, $q, companyServices, $uibModal, modalService, $timeout, permissionService, DAServices, Upload, userServices, $state) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @currencyService = currencyService
    @permissionService = permissionService
    @locationService = locationService
    @uibModal = $uibModal
    @state = $state
    @modalService = modalService
    @toastr = toastr
    @companyServices = companyServices
    @userServices = userServices
    @q = $q
    @timeout = $timeout
    @localStorageService = localStorageService
    @DAServices = DAServices
    @Upload = Upload
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
          permissionService: @permissionService
          userServices: @userServices
          $timeout: @timeout
          $uibModal: @uibModal
          $state: @state
          DAServices: @DAServices
          Upload: @Upload
        })

  describe '#openFirstTimeUserModal', ->
    it 'should open a model to create company', ->
      modalData = {
        templateUrl: '/public/webapp/views/createCompanyModal.html',
        size: "sm",
        backdrop: 'static',
        scope: @scope
      }
      deferred = @q.defer()
      spyOn(@uibModal, 'open').andReturn({result: deferred.promise})
      @scope.openFirstTimeUserModal()
      expect(@uibModal.open).toHaveBeenCalledWith(modalData)

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

  describe '#checkCmpCretedOrNot', ->
    xit 'should check if user created company or not after company modal open', ->
      @scope.companyList = []
      spyOn(@scope, 'openFirstTimeUserModal')
      @scope.checkCmpCretedOrNot()
      expect(@scope.openFirstTimeUserModal).toHaveBeenCalled()

    it 'should not open company create modal', ->
      @scope.companyList = ["1", "2"]
      spyOn(@scope, 'openFirstTimeUserModal')
      @scope.checkCmpCretedOrNot()
      expect(@scope.openFirstTimeUserModal).not.toHaveBeenCalledWith()

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
      res = 
        data: 
          status: "Error"
          message: "some-message"
      spyOn(@toastr, 'error')
      @scope.getOnlyCityFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

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
      res = {body: {"email": null, "contactNo": null}}
      spyOn(@toastr, 'success')

      @scope.onCreateCompanySuccess(res)

      expect(@toastr.success).toHaveBeenCalledWith('Company create successfully', 'Success')
      expect(@scope.mngCompDataFound).toBeTruthy()
      expect(@scope.companyList).toContain(res.body)

  describe '#onCreateCompanyFailure', ->
    it 'should show a toastr with error message', ->
      res = {"data": {"status": "some-error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.onCreateCompanyFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#getCompanyList', ->
    it 'should call get companyList service', ->
      deferred = @q.defer()
      spyOn(@companyServices, "getAll").andReturn(deferred.promise)
      @scope.getCompanyList()
      expect(@companyServices.getAll).toHaveBeenCalled()

  describe '#getCompanyListSuccess', ->
    xit 'should call a function to open modal', ->
      spyOn(@scope, "openFirstTimeUserModal")
      res = {"body": []}
      @scope.getCompanyListSuccess(res)
      expect(@scope.openFirstTimeUserModal).toHaveBeenCalled()

    res = {
      body: [
        {
          baseCurrency: "INR"
          city: "Indore"
          name: "dude's"
          uniqueName: "dudesindore14543150802480qgzih"
          updatedAt: "01-02-2016 13:53:42"
          index: 0
        }
        {
          baseCurrency: "INR"
          city: "Mumbai"
          name: "Hey dude"
          uniqueName: "dudesindore"
          index: 1
        }
      ]
    }
    it 'should set true to a variable and push data in company list, and call goToCompany function with matched company with the help of localStorageService', ->
      locRes = {
        baseCurrency: "INR"
        city: "Indore"
        name: "dude's"
        uniqueName: "dudesindore14543150802480qgzih"
        updatedAt: "01-02-2016 13:53:42"
        index: 0
      }
      spyOn(@scope, "goToCompany")
      spyOn(@localStorageService, "get").andReturn(locRes)
      spyOn(@localStorageService, "set")
      @scope.getCompanyListSuccess(res)
      expect(@rootScope.mngCompDataFound).toBeTruthy()
      expect(@scope.companyList).toContain(locRes)
      expect(@scope.goToCompany).toHaveBeenCalledWith(locRes, 0, "NOCHANGED")
      expect(@localStorageService.set).toHaveBeenCalledWith("_selectedCompany", locRes)

    it 'should set true to a variable and push data in company list, and call goToCompany function with companyList first company, due to mismatch of uniqueName', ->
      locRes = {
        baseCurrency: "INR"
        city: "Indore"
        name: "dude's"
        uniqueName: "dudduuudududu"
        index: 0
      }
      spyOn(@scope, "goToCompany")
      spyOn(@localStorageService, "get").andReturn(locRes)
      spyOn(@localStorageService, "set")
      @scope.getCompanyListSuccess(res)
      expect(@rootScope.mngCompDataFound).toBeTruthy()
      expect(@scope.goToCompany).toHaveBeenCalledWith(@scope.companyList[0], 0, "CHANGED")
      expect(@localStorageService.set).toHaveBeenCalledWith("_selectedCompany", @scope.companyList[0])

    xit 'should set true to a variable and push data in company list, and call goToCompany function with companyList first company, due to nothing in localStorage', ->
      spyOn(@scope, "goToCompany")
      spyOn(@localStorageService, "get").andReturn(undefined)
      spyOn(@localStorageService, "set")
      @scope.getCompanyListSuccess(res)
      expect(@rootScope.mngCompDataFound).toBeTruthy()
      expect(@scope.goToCompany).toHaveBeenCalledWith(@scope.companyList[0], 0, "CHANGED")
      expect(@localStorageService.set).toHaveBeenCalledWith("_selectedCompany", @scope.companyList[0], "CHANGED")


  describe '#getCompanyListFailure', ->
    it 'should show a toastr with error message', ->
      res = 
        data: 
          status: "Error"
          message: "some-message"
      spyOn(@toastr, 'error')
      @scope.getCompanyListFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#getUserDetails', ->
    it 'should call user service get method with basicInfo variable', ->
      @rootScope.basicInfo = {
        uniqueName: "somename"
      }
      deferred = @q.defer()
      spyOn(@userServices, "get").andReturn(deferred.promise)
      @scope.getUserDetails()
      expect(@userServices.get).toHaveBeenCalledWith(@rootScope.basicInfo.uniqueName)
    it 'should call user service get method with basicInfo variable after fetching it from localStorageService', ->
      @rootScope.basicInfo = {}
      deferred = @q.defer()
      spyOn(@userServices, "get").andReturn(deferred.promise)
      spyOn(@localStorageService, "get").andReturn({uniqueName: "somename"})
      @scope.getUserDetails()
      expect(@localStorageService.get).toHaveBeenCalledWith("_userDetails")
      expect(@userServices.get).toHaveBeenCalledWith(@rootScope.basicInfo.uniqueName)
  
  describe '#getUserDetailSuccess', ->
    it 'should set data in basicInfo variable', ->
      res = {
        body: "somename"
      }
      spyOn(@localStorageService, "set")
      @scope.getUserDetailSuccess(res)
      expect(@rootScope.basicInfo).toBe(res.body)
      expect(@localStorageService.set).toHaveBeenCalledWith("_userDetails", res.body)

  describe '#getUserDetailFailure', ->
    it 'should show alert with toastr', ->
      res ={
        data:
          message: "hey dude"
          status: "Error"
      }
      spyOn(@toastr,"error")
      @scope.getUserDetailFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

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
      res = 
        data: 
          status: "Success"
          message: "Company 'companyUniqueName' deleted successfully."
      spyOn(@toastr, 'success')
      spyOn(@scope, "getCompanyList")
      @scope.delCompanySuccess(res)
      expect(@toastr.success).toHaveBeenCalledWith('Company deleted successfully', 'Success')
      expect(@scope.getCompanyList).toHaveBeenCalled()

  describe '#delCompanyFailure', ->
    it 'should show error alert with toastr', ->
      res = 
        data: 
          status: "Error"
          message: "some-message"
      @spyOn(@toastr, "error")
      @scope.delCompanyFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#goToCompanyCheck', ->
    it 'should check if user have shared permissions, and sharedEntity is groups then make a variable truthy then call localStorageService set method and call state service go method for change page and set rootScope variable', ->
      data =
        sharedEntity: "groups"
        uniqueName: "afafafafaf1443520197325007bgo"
        name: "dude"
        role: 
          uniqueName: "shared"
          name: "shared"
      index = 0
      spyOn(@state, "go")
      spyOn(@localStorageService, "set")
      spyOn(@rootScope, "$emit")
      @scope.goToCompanyCheck(data, index)
      expect(@rootScope.$emit).toHaveBeenCalledWith('callCheckPermissions', data)
      expect(@rootScope.canManageComp).toBeFalsy()
      expect(@rootScope.canViewSpecificItems).toBeTruthy()
      expect(@localStorageService.set).toHaveBeenCalledWith("_selectedCompany", data)
      expect(@rootScope.selectedCompany).toEqual(data)
      expect(@state.go).toHaveBeenCalledWith('company.content.ledgerContent')
      expect(@rootScope.$emit).toHaveBeenCalledWith('companyChanged')
    it 'should call goToCompany function', ->
      data = 
        uniqueName: "afafafafaf1443520197325007bgo"
        name: "dude"
        role: 
          uniqueName: "admin"
          name: "admin"
      index = 0
      spyOn(@rootScope, "$emit")
      spyOn(@scope, "goToCompany")
      @scope.goToCompanyCheck(data, index)
      expect(@rootScope.canViewSpecificItems).toBeFalsy()
      expect(@rootScope.canManageComp).toBeTruthy()
      expect(@scope.goToCompany).toHaveBeenCalledWith(data, index, "CHANGED")
      expect(@rootScope.$emit).not.toHaveBeenCalledWith('companyChanged')
      
  describe '#goToCompany', ->
    it 'should make a call for check permissions, set a variable true, put data in scope variable and set data in localStorage, and add active class in li', ->
      data = 
        uniqueName: "afafafafaf1443520197325007bgo"
        name: "dude"
        contactNo: "91-1234567890"
        role: 
          uniqueName: "Super Admin"
          name: "super_admin"
      index = 0
      dbd = data
      dbd.index = index
      dbd.cCode = "91"
      dbd.mobileNo = "1234567890"
      deferred = @q.defer()
      @rootScope.canManageUser = true
      spyOn(@localStorageService, "get").andReturn({uniqueName: "some"})
      spyOn(@scope, "getSharedUserList")
      spyOn(@localStorageService, "set")
      spyOn(@rootScope, "$emit")
      @scope.goToCompany(data, index, "CHANGED")
      expect(@rootScope.$emit).toHaveBeenCalledWith('callCheckPermissions', data)
      expect(@scope.showUpdTbl).toBeFalsy()
      expect(@scope.cmpViewShow).toBeTruthy()
      expect(@scope.selectedCmpLi).toEqual(index)
      expect(@scope.selectedCompany).toEqual(dbd)
      expect(@localStorageService.set).toHaveBeenCalledWith("_selectedCompany", dbd)
      expect(@scope.getSharedUserList).toHaveBeenCalledWith("afafafafaf1443520197325007bgo")
      expect(@rootScope.$emit).toHaveBeenCalledWith('companyChanged')
      
    it 'should not call getSharedUserList and DAService', ->
      data = 
        uniqueName: "afafafafaf1443520197325007bgo"
        index: 0
        cCode: ""
      index = 0
      @rootScope.canManageUser = false
      spyOn(@permissionService, "hasPermissionOn").andReturn(false)
      spyOn(@scope, "getSharedUserList")
      spyOn(@localStorageService, "set")
      spyOn(@DAServices, "LedgerSet")
      spyOn(@localStorageService, "get").andReturn({uniqueName: "afafafafaf1443520197325007bgo"})
      @scope.goToCompany(data, index)
      expect(@scope.getSharedUserList).not.toHaveBeenCalledWith("afafafafaf1443520197325007bgo")
      expect(@DAServices.LedgerSet).not.toHaveBeenCalledWith(null, null)

  describe '#updateCompanyInfo', ->
    it 'should update company data if form is valid', ->
      data = {}
      deferred = @q.defer()
      spyOn(@companyServices, "update").andReturn(deferred.promise)
      @scope.updateCompanyInfo(data)
      expect(@companyServices.update).toHaveBeenCalledWith(data)

  describe '#updtCompanySuccess', ->
    it 'should show success alert with toastr and call getCompanyList function', ->
      res = {}
      spyOn(@toastr, "success")
      spyOn(@scope, "getCompanyList")

      @scope.updtCompanySuccess(res)
      expect(@toastr.success).toHaveBeenCalledWith('Company updated successfully', 'Success')
      expect(@scope.getCompanyList).toHaveBeenCalled()

  describe '#updtCompanyFailure', ->
    it 'should show error alert with toastr', ->
      res =
        data:
          status: "Error"
          message: "some-message"
      @spyOn(@toastr, "error")
      @scope.updtCompanyFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#getCountry', ->
    it 'should call search coutry service with value', ->
      val = "India"
      deferred = @q.defer()
      spyOn(@locationService, "searchCountry").andReturn(deferred.promise)
      @scope.getCountry(val)
      expect(@locationService.searchCountry).toHaveBeenCalledWith(val)

  describe '#onGetCountrySuccess', ->
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

  describe '#onGetCountryFailure', ->
    it 'should show error alert with toastr', ->
      res =
        data:
          status: "Error"
          message: "some-message"
      @spyOn(@toastr, "error")
      @scope.onGetCountryFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

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

  describe '#onGetStateFailure', ->
    it 'should show error alert with toastr', ->
      res =
        data:
          status: "Error"
          message: "some-message"
      @spyOn(@toastr, "error")
      @scope.onGetStateFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

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

  describe '#onGetCityFailure', ->
    it 'should show error alert with toastr', ->
      res =
        data:
          status: "Error"
          message: "some-message"
      @spyOn(@toastr, "error")
      @scope.onGetCityFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#getCurrencyList', ->
    it 'should not call service method and return success', ->
      data = {'code': 'USD'}
      spyOn(@localStorageService, "get").andReturn(data)
      spyOn(@currencyService, "getList")

      @scope.getCurrencyList()
      expect(@localStorageService.get).toHaveBeenCalled()
      expect(@scope.currencyList).toBe(data)
      expect(@currencyService.getList).not.toHaveBeenCalled()

    it 'should call service method and return success', ->
      data = {'code': 'USD'}
      spyOn(@localStorageService, "get").andReturn({})
      spyOn(@currencyService, "getList").andReturn(data)

      @scope.getCurrencyList()

      expect(@currencyService.getList).toHaveBeenCalledWith(@scope.getCurrencyListSuccess,
          @scope.getCurrencyListFailure)
      expect(@localStorageService.get).toHaveBeenCalled()

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
      res =
        data:
          status: "Error"
          message: "some-message"
      spyOn(@toastr, 'error')
      @scope.getCurrencyListFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#updateUserRole', ->
    it 'should call companyServices.share service with role or json object contains email', ->
      role = "view_only"
      userEmail = "s@g.com"
      sData = {role: role, user: userEmail}
      @rootScope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      deferred = @q.defer()
      spyOn(@companyServices, "share").andReturn(deferred.promise)
      @scope.updateUserRole(role, userEmail)
      expect(@companyServices.share).toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName, sData)

  describe '#shareCompanyWithUser', ->
    it 'should call companyServices.share service with role or json object contains email', ->
      @rootScope.basicInfo = {email: "s@f.com"}
      @scope.shareRequest = {role: "view_only", user: "s@g.com"}
      @rootScope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      deferred = @q.defer()
      spyOn(@companyServices, "share").andReturn(deferred.promise)
      @scope.shareCompanyWithUser()
      expect(@companyServices.share).toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName, @scope.shareRequest)

    it 'should not call service if email matched and show a toastr', ->
      @rootScope.basicInfo = {email: "s@g.com"}
      @scope.shareRequest = {role: "view_only", user: "s@g.com"}
      @rootScope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      deferred = @q.defer()
      spyOn(@toastr, 'error')
      spyOn(@companyServices, "share").andReturn(deferred.promise)
      @scope.shareCompanyWithUser()
      expect(@companyServices.share).not.toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName, @scope.shareRequest)
      expect(@toastr.error).toHaveBeenCalledWith('You cannot add yourself.', 'Error')

  describe '#onShareCompanySuccess', ->
    it 'should make a blank object, show success message and call getSharedUserList function', ->
      @rootScope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      data = {role: 'view_only', user: null}
      res = {"status": "success", "body": "Company 'companyUniqueName' shared successfully with 'name'"}
      spyOn(@toastr, 'success')
      spyOn(@scope, "getSharedUserList")

      @scope.onShareCompanySuccess(res)
      expect(@scope.shareRequest).toEqual(data)
      expect(@toastr.success).toHaveBeenCalledWith("Company 'companyUniqueName' shared successfully with 'name'",
          "success")
      expect(@scope.getSharedUserList).toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName)

  describe '#onShareCompanyFailure', ->
    it 'should show toastr with error message', ->
      res =
        data:
          status: "Error"
          message: "some-message"
      spyOn(@toastr, 'error')
      @scope.onShareCompanyFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#getSharedUserList', ->
    it 'should call companyService with shredList method', ->
      uniqueName = "afafafafaf1443520197325007bgo"
      deferred = @q.defer()
      spyOn(@companyServices, "shredList").andReturn(deferred.promise)
      @scope.getSharedUserList(uniqueName)
      expect(@companyServices.shredList).toHaveBeenCalledWith(uniqueName)

  describe '#getSharedUserListSuccess', ->
    it 'should set data in scope variable sharedUsersList', ->
      res = {
        "status": "success",
        "body": [{"userName": "ravi", "userEmail": "ravisoni@hostnsoft.com", "userUniqueName": "ravisoni"}]
      }
      @scope.getSharedUserListSuccess(res)
      expect(@scope.sharedUsersList).toEqual(res.body)

  describe '#getSharedUserListFailure', ->
    it 'should show toastr with error message', ->
      res =
        data:
          status: "Error"
          message: "some-message"
      spyOn(@toastr, 'error')
      @scope.getSharedUserListFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#unSharedUser', ->
    it 'should call companyService with unSharedComp method', ->
      id = 0
      data = {user: "uNqame"}
      @rootScope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}

      deferred = @q.defer()
      spyOn(@companyServices, "unSharedComp").andReturn(deferred.promise)
      @scope.unSharedUser(data.user, id)
      expect(@companyServices.unSharedComp).toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName, data)

  describe '#unSharedCompSuccess', ->
    it 'should show success toastr and call getSharedUserList function', ->
      @rootScope.selectedCompany = {uniqueName: "afafafafaf1443520197325007bgo"}
      res = {"status": "success", "body": "Company unshared successfully"}
      spyOn(@toastr, 'success')
      spyOn(@scope, "getSharedUserList")
      @scope.unSharedCompSuccess(res)
      expect(@toastr.success).toHaveBeenCalledWith("Company unshared successfully", "Success")
      expect(@scope.getSharedUserList).toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName)

  describe '#unSharedCompFailure', ->
    it 'should show toastr with error message', ->
      res =
        data:
          status: "Error"
          message: "some-message"
      spyOn(@toastr, 'error')
      @scope.unSharedCompFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#exceptOwnEmail', ->
    it 'should check if basicInfo email is same like email.userEmail and return true', ->
      @rootScope.basicInfo = {"email": "some@some.some"}
      email =
        userEmail: "some@some.some"
      @scope.exceptOwnEmail(email)
      expect(@rootScope.basicInfo.email).toEqual(email.userEmail)

  describe '#getUploadsList', ->
    it 'should call get companyList service method getUploadsList', ->
      deferred = @q.defer()
      spyOn(@companyServices, "getUploadsList").andReturn(deferred.promise)
      @scope.getUploadsList()
      expect(@companyServices.getUploadsList).toHaveBeenCalled()

  describe '#getUploadsListSuccess', ->
    it 'should set a variable true and copy response in a scope variable', ->
      res = {"body": ["something"]}
      @scope.getUploadsListSuccess(res)
      expect(@scope.showUpdTbl).toBeTruthy()
      expect(@scope.updlist).toBe(res.body)
    it 'should show toastr alert', ->
      res = {"body": []}
      spyOn(@toastr, "info")
      @scope.getUploadsListSuccess(res)
      expect(@toastr.info).toHaveBeenCalledWith("No records found", "Info")

  describe '#getUploadsListFailure', ->
    it 'should show a toastr with error message', ->
      res = {"data": {"status": "some-error", "message": "some-message"}}
      spyOn(@toastr, 'error')
      @scope.getUploadsListFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#uploadMasterFiles', ->
    it 'should make variable false set values in a scope variable, then call upload service with upload method', ->
      result = ''
      files = [{ 
        fieldname: 'file',
        originalname: 'master-small.xml',
        encoding: '7bit',
        mimetype: 'text/xml',
        destination: './uploads/',
        filename: '1449894122205.xml',
        path: 'uploads/1449894122205.xml',
        size: 1288072 
      }]
      errFiles = []
      deferred = @q.defer()
      spyOn(@Upload, "upload").andReturn(deferred.promise)
      # spyOn(@Upload, 'upload').and.returnValue(deferred.promise)
      @scope.uploadMasterFiles(files, errFiles)
      expect(@Upload.upload).toHaveBeenCalled()
      expect(@scope.mHideBar).toBeFalsy()
      expect(@scope.mFiles).toBe(files)
      expect(@scope.mErrFiles).toBe(errFiles)
      expect(angular.forEach).toBeDefined()
  
  describe '#uploadDaybookFiles', ->
    it 'should make variable false set values in a scope variable, then call upload service with upload method', ->
      result = ''
      files = [{ 
        fieldname: 'file',
        originalname: 'Daybook-small.xml',
        encoding: '7bit',
        mimetype: 'text/xml',
        destination: './uploads/',
        filename: '1449894122205.xml',
        path: 'uploads/1449894122205.xml',
        size: 1288072 
      }]
      errFiles = []
      deferred = @q.defer()
      spyOn(@Upload, "upload").andReturn(deferred.promise)
      @scope.uploadDaybookFiles(files, errFiles)
      expect(@Upload.upload).toHaveBeenCalled()
      expect(@scope.dHideBar).toBeFalsy()
      expect(@scope.dFiles).toBe(files)
      expect(@scope.dErrFiles).toBe(errFiles)
      expect(angular.forEach).toBeDefined()

  describe '#test to check for viewContentLoaded event', ->
    xit 'should call a getAccountsGroups method', ->
      spyOn(@scope, 'getCompanyList')
      spyOn(@scope, 'getCurrencyList')
      spyOn(@scope, 'getUserDetails')
      @rootScope.$broadcast('$viewContentLoaded')
      expect(@scope.getCompanyList).toHaveBeenCalled()
      expect(@scope.getCurrencyList).toHaveBeenCalled()
      expect(@scope.getUserDetails).toHaveBeenCalled()

  # payment details related func cases
  describe '#primPayeeChange', ->
    it 'should set a compSetBtn variable to false', ->
      @scope.primPayeeChange("a", "b")
      expect(@scope.compSetBtn).toBeFalsy()
  
  describe '#pageChangedComp', ->
    it 'should check if startPage is greater than totalPages then set variable to true and show message with toastr', ->
      data = {
        startPage: 2
        totalPages: 1
      }
      spyOn(@toastr, "info")
      @scope.pageChangedComp(data)
      expect(@scope.nothingToLoadComp).toBeTruthy() 
      expect(@toastr.info).toHaveBeenCalledWith("Nothing to load, all transactions are loaded", "Info")

    it 'should exaggerate startPage var and call companyServices getCompTrans method', ->
      deferred = @q.defer()
      spyOn(@companyServices, "getCompTrans").andReturn(deferred.promise)
      data = {
        startPage: 1
        totalPages: 1
      }
      @rootScope.selectedCompany = {
        uniqueName: "hey"
      }
      obj = {
        name: @rootScope.selectedCompany.uniqueName
        num: data.startPage+1
      }
      @scope.pageChangedComp(data)
      expect(@companyServices.getCompTrans).toHaveBeenCalledWith(obj)

  describe '#pageChangedCompSuccess', ->
    it 'should concatinate two arrays and create plus one count to variable', ->
      res = 
        body: 
          paymentDetail: [
            {some: "thing"}
          ]
      @scope.compTransData = 
        startPage: 1
        paymentDetail: []
      @scope.pageChangedCompSuccess(res)
      expect(@scope.compTransData.startPage).toBe(2)
      expect(@scope.compTransData.paymentDetail).toEqual(res.body.paymentDetail)

  describe '#pageChangedCompFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "Some message"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.pageChangedCompFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)
      
  describe '#getCompanyTransactions', ->
    it 'should call companyServices getCompTrans method', ->
      deferred = @q.defer()
      spyOn(@companyServices, "getCompTrans").andReturn(deferred.promise)
      @rootScope.selectedCompany = {
        uniqueName: "hey"
      }
      obj = {
        name: @rootScope.selectedCompany.uniqueName
        num: 1
      }
      @scope.getCompanyTransactions()
      expect(@companyServices.getCompTrans).toHaveBeenCalledWith(obj)
  
  describe '#getCompanyTransactionsSuccess', ->
    it 'should set value in compTransData variable, and set nothingToLoadComp to toBeFalsy  and set compDataFound variable to truthy', ->
      res = 
        body: 
          paymentDetail: [
            {some: "thing"}
          ]
      @scope.compTransData = 
        startPage: 1
        paymentDetail: []
      @scope.getCompanyTransactionsSuccess(res)
      expect(@scope.compTransData.startPage).toBe(1)
      expect(@scope.compTransData.paymentDetail).toEqual(res.body.paymentDetail)
      expect(@scope.nothingToLoadComp).toBeFalsy()
      expect(@scope.compDataFound).toBeTruthy()

    it 'should set value in compTransData variable, and set nothingToLoadComp to toBeFalsy  and set compDataFound variable to toBeFalsy and show message with toastr', ->
      res = 
        body: 
          paymentDetail: []
      @scope.compTransData = 
        startPage: 1
        paymentDetail: []
      spyOn(@toastr, "info")
      @scope.getCompanyTransactionsSuccess(res)
      expect(@scope.compTransData.startPage).toBe(1)
      expect(@scope.compTransData.paymentDetail).toEqual(res.body.paymentDetail)
      expect(@scope.nothingToLoadComp).toBeFalsy()
      expect(@scope.compDataFound).toBeFalsy()
      expect(@toastr.info).toHaveBeenCalledWith("Don\'t have any transactions yet.", "Info")

  describe '#getCompanyTransactionsFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "Some message"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.getCompanyTransactionsFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)


  describe '#updateCompSubs', ->
    it 'should call companyServices updtCompSubs method', ->
      deferred = @q.defer()
      spyOn(@companyServices, "updtCompSubs").andReturn(deferred.promise)
      @rootScope.selectedCompany = {
        uniqueName: "hey"
      }
      resObj = {
        autoDeduct: true
        primaryBiller:
          userEmail: "someemail"
          userName: "Some"
          userUniqueName: "user"
      }
      data = {
        uniqueName: @rootScope.selectedCompany.uniqueName
        autoDeduct: resObj.autoDeduct
        primaryBiller: resObj.primaryBiller
      }
      @scope.updateCompSubs(resObj)
      expect(@companyServices.updtCompSubs).toHaveBeenCalledWith(data)

  describe '#updateCompSubsSuccess', ->
    it 'should set value in companySubscription variable, and show message with toastr', ->
      res = 
        status: "Success"
        body: {
          some: "some"
        }
      @scope.selectedCompany = 
        companySubscription: {}
      spyOn(@toastr, "success")
      @scope.updateCompSubsSuccess(res)
      expect(@scope.selectedCompany.companySubscription).toEqual(res.body)
      expect(@toastr.success).toHaveBeenCalledWith("Updates successfully", res.status)
      

  describe '#updateCompSubsFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "Some message"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.updateCompSubsFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#getWltBal', ->
    it 'should call userServices getWltBal method', ->
      deferred = @q.defer()
      spyOn(@userServices, "getWltBal").andReturn(deferred.promise)
      @rootScope.basicInfo = {
        uniqueName: "hey"
      }
      @scope.getWltBal()
      expect(@userServices.getWltBal).toHaveBeenCalledWith('hey')

  describe '#getWltBalSuccess', ->
    it 'should check if available balance is greater or equal to companySubscription they set showPayOptns var to false and call deductSubsViaWallet function and default false a variable', ->
      @rootScope.selectedCompany = {
        companySubscription:
          billAmount: 40
      }
      res = 
        body: 
          availableCredit: 100
      spyOn(@scope, "deductSubsViaWallet")
      @scope.getWltBalSuccess(res)
      expect(@scope.disableRazorPay).toBeFalsy()
      expect(@scope.showPayOptns).toBeFalsy()
      expect(@scope.deductSubsViaWallet).toHaveBeenCalledWith(40)

      
    

  describe '#getWltBalFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "Some message"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.getWltBalFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

    

