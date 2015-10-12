'use strict'

describe 'groupController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, localStorageService, toastr, groupService, $q) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @localStorageService = localStorageService
    @toastr = toastr
    @groupService = groupService
    @q = $q
    @groupController = $controller('groupController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService})

  describe '#getGroups', ->
    it 'should show a toastr informing user to select company first when no company selected', ->
      @rootScope.selectedCompany = {}
      spyOn(@toastr, 'error')
      @scope.getGroups()
      expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')

    it 'should call groups from route after getting company unique name', ->
      @rootScope.selectedCompany = {"data": "Got it", "uniqueName": "soniravi"}
      deferred = @q.defer()
      spyOn(@groupService, 'getAllWithAccountsFor').andReturn(deferred.promise)
      @scope.getGroups()
      expect(@groupService.getAllWithAccountsFor).toHaveBeenCalledWith("soniravi")

  describe '#getGroupListSuccess', ->
    it 'should set group list', ->
      result = ["body": {"name": "fixed assets"}, {"name": "capital account"}]
      @scope.getGroupListSuccess(result)
      expect(@scope.groupList).toBe(result.body)

  describe '#getGroupListFailure', ->
    it 'should show a toastr for error', ->
      spyOn(@toastr, 'error')
      @scope.getGroupListFailure()
      expect(@toastr.error).toHaveBeenCalledWith("Unable to get group details.", "Error")

  describe '#selectGroupToEdit', ->
    it 'should set group as selected and a variable to true to show its detail', ->
      group = {"name": "Fixed Assets"}
      @scope.selectGroupToEdit(group)
      expect(@scope.selectedGroup).toBe(group)
      expect(@scope.showGroupDetails).toBeTruthy()

  describe '#updateGroup', ->
    it 'should call group service and update group', ->
      @scope.selectedGroup = {"uniqueName": "1"}
      @rootScope.selectedCompany = {"uniqueName": "2"}
      deferred = @q.defer()
      spyOn(@groupService, 'update').andReturn(deferred.promise)
      @scope.updateGroup()
      expect(@groupService.update).toHaveBeenCalledWith("2", {'uniqueName': '1'})

  describe '#addNewSubGroup', ->
    it 'should call group service and add new subgroup to selected group', ->
      @scope.selectedSubGroup = {"name": "subgroup1", "desc": "description","uniqueName":"suniqueName"}
      @rootScope.selectedCompany = {"uniqueName": "CmpUniqueName"}
      @scope.selectedGroup = {"uniqueName": "grpUName"}
      body = {
        "name": @scope.selectedSubGroup.name,
        "uniqueName": "suniquename",
        "parentGroupUniqueName": @scope.selectedGroup.uniqueName
        "description": "description"
      }
      deferred = @q.defer()
      spyOn(@groupService, 'create').andReturn(deferred.promise)
      @scope.addNewSubGroup()
      expect(@groupService.create).toHaveBeenCalledWith("CmpUniqueName", body)

  describe '#deleteGroup', ->
    it 'should call group service and delete and call group list', ->
      deferred = @q.defer()
      @rootScope.selectedCompany = {"uniqueName": "CmpUniqueName","isFixed":"false"}
      spyOn(@groupService, 'delete').andReturn(deferred.promise)
      @scope.deleteGroup()
      expect(@rootScope.selectedCompany.isFixed).toBeTruthy()
      expect(@groupService.delete)
