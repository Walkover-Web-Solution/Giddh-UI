'use strict'

describe 'searchController', ->
  beforeEach module('giddhWebApp')

  describe 'local variables', ->
    beforeEach inject ($rootScope, $controller, localStorageService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      spyOn(@localStorageService, 'get').andReturn({})
      @searchController = $controller('searchController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService} )
    it 'should check scope variables set by default', ->
      # spyOn(@scope, "getGrpsforSearch")
      dateObj=
        'year-format': "'yy'",
        'starting-day': 1,
        'showWeeks': false,
        'show-button-bar': false,
        'year-range': 1,
        'todayBtn': false,
        'container': "body"
        'minViewMode': 0

      queryObj= [
        {name:"Closing", uniqueName: "closingBalance"}
        {name:"Opening", uniqueName: "openingBalance"}
        {name:"Cr. total", uniqueName: "creditTotal"}
        {name:"Dr. total", uniqueName: "debitTotal"}
      ]
      queryType= [
        "Less"
        "Greater"
        "Equals"
      ]
      balType=[
        {name:"CR", uniqueName: "CREDIT"}
        {name:"DR", uniqueName: "DEBIT"}
      ]
      order=    [
        "name"
        "closingBalance"
        "closeBalType"
        "openingBalance"
        "openBalType"
        "creditTotal"
        "debitTotal"
        "uniqueName"
      ]

      expect(@scope.today).toBeDefined()
      expect(@scope.dateOptions).toEqual(dateObj)
      expect(@scope.format).toBe("dd-MM-yyyy")

      expect(@scope.searchFormData.fromDate).toBeDefined()
      expect(@scope.searchFormData.toDate).toBeDefined()
      expect(@scope.fromDatePickerIsOpen).toBeFalsy()
      expect(@scope.toDatePickerIsOpen).toBeFalsy()
      expect(@rootScope.selectedCompany).toEqual({})
      expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")
      expect(@scope.noData).toBeFalsy()
      expect(@scope.searchLoader).toBeFalsy()
      expect(@scope.searchResData).toEqual({})
      expect(@scope.searchResDataOrig).toEqual({})
      expect(@scope.queryType).toEqual(queryObj)
      expect(@scope.queryDiffer).toEqual(queryType)
      expect(@scope.balType).toEqual(balType)
      expect(@scope.srchDataSet).toBeDefined()
      expect(@scope.sortType).toEqual("name")
      expect(@scope.sortReverse).toBeFalsy()
      expect(@scope.order).toEqual(order)
      # expect(@scope.getGrpsforSearch).toHaveBeenCalled()
      

      

  describe 'controller methods', ->
    beforeEach inject ($rootScope, $controller, localStorageService, toastr, ledgerService, $q, modalService, DAServices, permissionService, accountService, Upload, groupService, reportService, $uibModal) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      @ledgerService = ledgerService
      @DAServices = DAServices
      @toastr = toastr
      @reportService = reportService
      @accountService = accountService
      @permissionService = permissionService
      @modalService = modalService
      @groupService = groupService
      @Upload = Upload
      @q = $q
      @uibModal = $uibModal
      @searchController = $controller('searchController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
          ledgerService: @ledgerService
          accountService: @accountService
          DAServices: @DAServices
          modalService: @modalService
          Upload: @Upload
          permissionService: @permissionService
          groupService: @groupService
          reportService: @reportService
          $uibModal: @uibModal
        }
      )

    describe '#getGrpsforSearch', ->
      it 'should show error message with toastr', ->
        @rootScope.selectedCompany = {}
        spyOn(@localStorageService, "get").andReturn({})
        spyOn(@toastr, "error")
        @scope.getGrpsforSearch()
        expect(@toastr.error).toHaveBeenCalledWith("Select company first.", "Error")
        expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")

      it 'should call groupService getGroupsWithAccountsInDetail method with uniqueName', ->
        @rootScope.selectedCompany = {
          uniqueName: "12345"
        }
        spyOn(@localStorageService, "get").andReturn({name: "abc"})
        deferred = @q.defer()
        spyOn(@groupService, 'getGroupsWithAccountsInDetail').andReturn(deferred.promise)
        @scope.getGrpsforSearch()
        expect(@groupService.getGroupsWithAccountsInDetail).toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName)
        expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")

    describe '#getGrpsforSearchSuccess', ->
      it 'should call groupService flattenGroup method and make a variable truthy', ->
        res=
          status: "success"
          body: [
            {
              name: "Capital",
              uniqueName: "capital",
              synonyms: null,
              accounts: [],
              groups: [],
              category: "liabilities"
            }
          ]
        spyOn(@groupService, "flattenGroup").andReturn([])
        @scope.getGrpsforSearchSuccess(res)
        expect(@groupService.flattenGroup).toHaveBeenCalledWith(res.body, [])
        expect(@scope.groupList).toEqual(res.body)
        expect(@scope.flattenGroupList).toEqual([])
        expect(@scope.searchLoader).toBeTruthy()

    describe '#getGrpsforSearchFailure', ->
      it 'should show error message with toastr', ->
        res =
          data:
            status: "error"
            message: "message"
        spyOn(@toastr, "error")
        @scope.getGrpsforSearchFailure(res)
        expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

    describe '#getClosingBalance', ->
      it 'should call groupService getClosingBal method with obj', ->
        @rootScope.selectedCompany=
          uniqueName: "12345"

        data=
          fromDate: "01-02-2016"
          toDate: "01-04-2016"
          group: 
            uniqueName: "def"

        obj = {
          compUname: @rootScope.selectedCompany.uniqueName
          selGrpUname: data.group.uniqueName
          fromDate: data.fromDate
          toDate: data.toDate
        }

        deferred = @q.defer()
        spyOn(@groupService, 'getClosingBal').andReturn(deferred.promise)
        spyOn(@scope, "resetQuery")

        @scope.getClosingBalance(data)
        expect(@groupService.getClosingBal).toHaveBeenCalledWith(obj)
        expect(@scope.resetQuery).toHaveBeenCalled()
        expect(@scope.searchDtCntLdr).toBeTruthy()

    describe '#addSearchRow', ->
      it 'should check array length and go in if condition', ->
        @scope.srchDataSet=[]
        @scope.addSearchRow()
        expect(@scope.srchDataSet).toEqual([{ queryType : '', balType : 'CREDIT', queryDiffer : '', amount : '' }])

      it 'should check array length and go in else condition and call toastr warning method', ->
        @scope.srchDataSet= [1,2,3,4,5]
        spyOn(@toastr, "warning")
        @scope.addSearchRow()
        expect(@toastr.warning).toHaveBeenCalledWith("Cannot add more parameters", "Warning")

    describe '#removeSearchRow', ->
      xit 'should ', ->

    describe '#searchQuery', ->
      xit 'should ', ->

    describe '#resetQuery', ->
      it 'should reset variables', ->
        @scope.searchResDataOrig = {name: "123"}
        @scope.resetQuery()
        expect(@scope.searchResData).toEqual(@scope.searchResDataOrig)
        expect(@scope.srchDataSet).toEqual([{ queryType : '', balType : 'CREDIT', queryDiffer : '', amount : '' }])
        expect(@scope.inSrchmode).toBeFalsy()

    describe '#getCSVHeader', ->
      it 'should return an array', ->
        csvres =[
          "Name"
          "Opening Bal."
          "Opening Bal. Type"
          "Closing Bal."
          "Closing Bal. Type"
          "CR Total"
          "DR Total"
          "UniqueName"
        ]
        result = @scope.getCSVHeader()
        expect(result).toEqual(csvres)

    describe '#', ->
      xit 'should ', ->

    describe '#', ->
      xit 'should ', ->

    describe '#', ->
      xit 'should ', ->
        

    


















