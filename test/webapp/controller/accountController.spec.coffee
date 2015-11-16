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
    it 'should show a toastr informing user to select company first when no company selected', ->
      spyOn(@toastr, 'error')
      spyOn(@localStorageService, 'get').andReturn({})
      @scope.getAccountsGroups()
      expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')
      expect(@scope.showAccountList).toBeFalsy()

    it 'should call groups from route after getting company unique name', ->
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
      spyOn(@toastr, 'error')
      @scope.getGroupListFailure()
      expect(@toastr.error).toHaveBeenCalledWith("Unable to get group details.", "Error")

  describe '#test for reload account event', ->
    it 'should call a getAccountGroups', ->
      spyOn(@scope, 'getAccountsGroups')
      @rootScope.$broadcast('$reloadAccount')
      expect(@scope.getAccountsGroups).toHaveBeenCalled()

  describe '#test to check for viewContentLoaded event', ->
    it 'should call a getAccountsGroups method', ->
      spyOn(@scope, 'getAccountsGroups')
      @rootScope.$broadcast('$viewContentLoaded')
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

  describe '#collapseAllSubMenus', ->
    it 'should collapseAllSubMenus and set a variable value to true', ->
      @scope.collapseAllSubMenus()
      expect(@rootScope.showSubMenus).toBeTruthy()

  describe '#expandAllSubMenus', ->
    it 'should expandAllSubMenus and set a variable value to false', ->
      @scope.expandAllSubMenus()
      expect(@rootScope.showSubMenus).toBeFalsy()