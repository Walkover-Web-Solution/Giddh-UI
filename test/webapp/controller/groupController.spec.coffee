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
      spyOn(@groupService, 'getAllFor').andReturn(deferred.promise)
      @scope.getGroups()
      expect(@groupService.getAllFor).toHaveBeenCalledWith("soniravi")

  describe '#getGroupListSuccess', ->
    it 'should set group list', ->
      result = ["body":{"name":"fixed assets"},{"name":"capital account"}]
      @scope.getGroupListSuccess(result)
      expect(@scope.groupList).toBe(result.body)

  describe '#getGroupListFailure', ->
    it 'should show a toastr for error', ->
      spyOn(@toastr,'error')
      @scope.getGroupListFailure()
      expect(@toastr.error).toHaveBeenCalledWith("Unable to get group details.", "Error")

  describe '#selectGroupToEdit', ->
    it 'should set group as selected and a variable to true to show its detail', ->
      group = {"name":"Fixed Assets"}
      @scope.selectGroupToEdit(group)
      expect(@scope.selectedGroup).toBe(group)
      expect(@scope.showGroupDetails).toBeTruthy()

  describe '#updateGroup', ->
    xit 'should call group service and update group', ->
      spyOn(@groupService,'update')
      @scope.updateGroup()