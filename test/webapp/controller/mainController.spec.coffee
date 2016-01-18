'use strict'

describe 'mainController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, localStorageService, toastr, groupService, $q, $uibModal, roleServices, permissionService) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @roleServices = roleServices
    @localStorageService = localStorageService
    @toastr = toastr
    @uibModal = $uibModal
    @permissionService = permissionService
    @q = $q
    @mainController = $controller('mainController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
          permissionService: @permissionService
          roleServices: @roleServices
        })

  describe '#getRoles', ->
    it 'should call service method to fetch roles if roles is undefined', ->
      deferred = @q.defer()
      spyOn(@roleServices, 'getAll').andReturn(deferred.promise)
      spyOn(@localStorageService, 'get').andReturn(undefined)
      @scope.getRoles()
      expect(@roleServices.getAll).toHaveBeenCalled()

    it 'should call service method to fetch roles if roles is empty', ->
      deferred = @q.defer()
      spyOn(@roleServices, 'getAll').andReturn(deferred.promise)
      spyOn(@localStorageService, 'get').andReturn([])
      @scope.getRoles()
      expect(@roleServices.getAll).toHaveBeenCalled()

    it 'should not call service method to fetch roles if roles defined', ->
      deferred = @q.defer()
      spyOn(@roleServices, 'getAll').andReturn(deferred.promise)
      spyOn(@localStorageService, 'get').andReturn([{name: 'admin'}])
      @scope.getRoles()
      expect(@roleServices.getAll).not.toHaveBeenCalled()

  describe '#onGetRolesSuccess', ->
    it 'should call service method to fetch roles', ->
      spyOn(@localStorageService, 'set')
      @scope.onGetRolesSuccess({body: [{name: 'admin'}]})
      expect(@localStorageService.set).toHaveBeenCalledWith('_roles', [{name: 'admin'}])