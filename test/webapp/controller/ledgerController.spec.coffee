'use strict'

describe 'ledgerController', ->
  beforeEach module('giddhWebApp')

  describe 'local variables', ->
    beforeEach inject ($rootScope, $controller, localStorageService) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      spyOn(@localStorageService, 'keys').andReturn(["_selectedCompany"])
      spyOn(@localStorageService, 'get').andReturn({name: "walkover"})

      @ledgerController = $controller('ledgerController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService})

    it 'should check scope variables set by default', ->
      expect(@scope.selectedCompany).toEqual({name: "walkover"})
      expect(@scope.accntTitle).toBeUndefined()
      expect(@scope.showLedgerBox).toBeFalsy()
      expect(@scope.selectedAccountUname).toBeUndefined()
      expect(@scope.selectedGroupUname).toBeUndefined()
      expect(@scope.selectedLedgerAccount).toBeUndefined()
      expect(@scope.creditTotal).toBeUndefined()
      expect(@scope.debitTotal).toBeUndefined()
      expect(@scope.creditBalanceAmount).toBeUndefined()
      expect(@scope.debitBalanceAmount).toBeUndefined()
      expect(@scope.quantity).toBe(50)
      expect(@scope.today).toBeDefined()
      expect(@scope.fromDate.date).toBeDefined()
      expect(@scope.toDate.date).toBeDefined()
      expect(@scope.fromDatePickerIsOpen).toBeFalsy()
      expect(@scope.fromDatePickerIsOpen).toBeFalsy
      expect(@scope.dateOptions).toEqual({ 'year-format': "'yy'", 'starting-day': 1, 'showWeeks': false, 'show-button-bar': false, 'year-range': 1, 'todayBtn': false})
      expect(@scope.format).toBe("dd-MM-yyyy")
      expect(@scope.ftypeAdd).toBe("add")
      expect(@scope.ftypeUpdate).toBe("update")
      expect(@localStorageService.keys).toHaveBeenCalled()
      expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")

  describe 'controller methods', ->
    beforeEach inject ($rootScope, $controller, localStorageService, toastr, groupService, $q, $modal) ->
      @scope = $rootScope.$new()
      @rootScope = $rootScope
      @localStorageService = localStorageService
      @toastr = toastr
      @modal = $modal
      @q = $q
      @ledgerController = $controller('ledgerController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
        })