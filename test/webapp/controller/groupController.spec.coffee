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
    it 'should check for selected company from local storage and set a local variable', ->
      spyOn(@localStorageService, 'keys').andReturn({"_selectedCompany"})
      result = {"data": "Got it"}
      spyOn(@localStorageService, 'get').andReturn(result)
      @scope.getGroups()
      expect(@scope.companyBasicInfo).toBe(result)

    it 'should show a toastr informing user to select company first when no company selected', ->
      spyOn(@localStorageService, 'keys').andReturn({})
      spyOn(@toastr, 'error')
      @scope.getGroups()
      expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')

    it 'should call groups from route after getting company unique name', ->
      result = {"data": "Got it", "uniqueName": "soniravi"}
      deferred = @q.defer()
      spyOn(@localStorageService, 'keys').andReturn({"_selectedCompany"})
      spyOn(@localStorageService, 'get').andReturn(result)
      spyOn(@groupService, 'getAllFor').andReturn(deferred.promise)
      @scope.getGroups()
      expect(@groupService.getAllFor).toHaveBeenCalledWith("soniravi")