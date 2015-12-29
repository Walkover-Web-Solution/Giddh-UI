'use strict'

describe 'accountController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, toastr, accountService, groupService, $q, modalService, localStorageService, DAServices) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @toastr = toastr
    @accountService = accountService
    @groupService = groupService
    @q = $q
    @modalService = modalService
    @localStorageService = localStorageService
    @DAServices = DAServices
    @accountController = $controller('accountController',
      {
        $scope: @scope,
        groupService: @groupService,
        DAServices: @DAServices
      })

  describe '#getAccountsGroups', ->
    xit 'should show a toastr informing user to select company first when no company selected', ->
      spyOn(@toastr, 'error')
      spyOn(@localStorageService, 'get').andReturn({})
      @scope.getAccountsGroups()
      expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')
      expect(@scope.showAccountList).toBeFalsy()

    xit 'should call groups from route after getting company unique name', ->
      spyOn(@localStorageService, 'get').andReturn({"data": "Got it", "uniqueName": "soniravi"})
      deferred = @q.defer()
      spyOn(@groupService, 'getAllWithAccountsFor').andReturn(deferred.promise)
      @scope.getAccountsGroups()
      expect(@groupService.getAllWithAccountsFor).toHaveBeenCalledWith("soniravi")
      expect(@scope.showAccountList).toBeFalsy()

  describe '#getGroupListSuccess', ->
    it 'should set group list', ->
      @rootScope.makeAccountFlatten = (data) ->

      result = ["body": [{
        "name": "group1",
        "uniqueName": "g1",
        "accounts": [{"name": "a1"}]
      },
        {"name": "group2", "uniqueName": "g2", "accounts": []},
        {"name": "group3", "uniqueName": "g3", "accounts": []}]]
      spyOn(@groupService, 'flattenGroup').andReturn({"name": "group2", "uniqueName": "g2", "groups": []})
      spyOn(@groupService, 'flattenGroupsWithAccounts').andReturn([{
        "groupName": "group1",
        "groupUniqueName": "g1",
        "accountDetails": [{"name": "a1"}]
      }])
      spyOn(@rootScope, 'makeAccountFlatten')
      @scope.getGroupListSuccess(result)
      expect(@groupService.flattenGroup).toHaveBeenCalledWith(result.body, [])
      expect(@groupService.flattenGroupsWithAccounts).toHaveBeenCalledWith(@scope.flattenGroupList)
      expect(@scope.groupList).toBe(result.body)
      expect(@scope.flattenGroupList).toEqual({"name": "group2", "uniqueName": "g2", "groups": []})
      expect(@scope.flatAccntWGroupsList).toEqual([{
        "groupName": "group1",
        "groupUniqueName": "g1",
        "accountDetails": [{"name": "a1"}]
      }])
      expect(@scope.showAccountList).toBeTruthy()

  describe '#getGroupListFailure', ->
    it 'should show a toastr for error', ->
      res =
        data:
          status: "Error"
          message: "Unable to get group details."
      spyOn(@toastr, "error")
      @scope.getGroupListFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#test for reload account event', ->
    it 'should call a getAccountGroups', ->
      spyOn(@scope, 'getAccountsGroups')
      @rootScope.$broadcast('$reloadAccount')
      expect(@scope.getAccountsGroups).toHaveBeenCalled()

  describe '#showManageGroups', ->
    it 'should call modal service to show manage group pop up', ->
      spyOn(@modalService, 'openManageGroupsModal')
      @modalService.openManageGroupsModal()
      expect(@modalService.openManageGroupsModal).toHaveBeenCalled()

  describe '#setLedgerData', ->
    it 'should set value in a variable and call da service ledgerset method', ->
      data = {}
      acData = {uniqueName: "name"}
      spyOn(@DAServices, "LedgerSet")
      @scope.setLedgerData(data, acData)
      expect(@scope.selectedAccountUniqueName).toEqual(acData.uniqueName)
      expect(@DAServices.LedgerSet).toHaveBeenCalledWith(data, acData)

  describe '#toggleAcMenus', ->
    varx = [{
        open: false,
        name: "group1"
        uniqueName: "g1"
        accounts: []
      }
      {
        open: false,
        name: "group1"
        uniqueName: "g1"
        accounts: []
    }]
    it 'should expand menus', ->
      @scope.flatAccntWGroupsList = varx
      @scope.toggleAcMenus(true)
      expect(angular.forEach).toBeDefined()
      expect(@scope.showSubMenus).toBeTruthy()
    it 'should collapse all menus', ->
      @scope.flatAccntWGroupsList = varx
      @scope.toggleAcMenus(false)
      expect(angular.forEach).toBeDefined()
      expect(@scope.showSubMenus).toBeFalsy()


