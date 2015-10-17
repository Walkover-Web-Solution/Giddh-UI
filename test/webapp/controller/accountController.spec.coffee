'use strict'

describe 'accountController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, toastr, accountService, groupService, $q, modalService) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @toastr = toastr
    @accountService = accountService
    @groupService = groupService
    @q = $q
    @modalService = modalService
    @accountController = $controller('accountController',
        {$scope: @scope, groupService: @groupService})

  describe '#getAccountsGroups', ->
    it 'should show a toastr informing user to select company first when no company selected', ->
      @rootScope.selectedCompany = {}
      spyOn(@toastr, 'error')
      @scope.getAccountsGroups()
      expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')
      expect(@scope.showAccountList).toBeFalsy()

    it 'should call groups from route after getting company unique name', ->
      @rootScope.selectedCompany = {"data": "Got it", "uniqueName": "soniravi"}
      deferred = @q.defer()
      spyOn(@groupService, 'getAllWithAccountsFor').andReturn(deferred.promise)
      @scope.getAccountsGroups()
      expect(@groupService.getAllWithAccountsFor).toHaveBeenCalledWith("soniravi")
      expect(@scope.showAccountList).toBeFalsy()

  describe '#getGroupListSuccess', ->
    it 'should set group list', ->
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
      @scope.getGroupListSuccess(result)
      expect(@groupService.flattenGroup).toHaveBeenCalledWith(result.body)
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