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
    it 'should call service method to fetch roles', ->
      deferred = @q.defer()
      spyOn(@roleServices, 'getAll').andReturn(deferred.promise)
      @scope.getRoles()
      expect(@roleServices.getAll).toHaveBeenCalled()

  describe '#onGetRolesSuccess', ->
    it 'should call service method to fetch roles', ->
      spyOn(@localStorageService, 'set')
      @scope.onGetRolesSuccess({body: [{name: 'admin'}]})
      expect(@localStorageService.set).toHaveBeenCalledWith('_roles', [{name: 'admin'}])

  describe '#onGetRolesFailure', ->
    xit 'should show toastr with error message', ->
      res =
        data:
          status: "Error"
          message: "some-message"
      spyOn(@toastr, 'error')
      @scope.onGetRolesFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#checkPermissions', ->
    it 'should call permission service hasPermissionOn method and set value true to canUpdate variable', ->
      data = {role: {permissions: [{code: "UPDT"}]}}
      spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
      @scope.checkPermissions(data)
      expect(@scope.canUpdate).toBeTruthy()
      expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "UPDT")

    it 'should call permission service hasPermissionOn method and set value true to canAdd variable', ->
      data = {role: {permissions: [{code: "ADD"}]}}
      spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
      @scope.checkPermissions(data)
      expect(@scope.canAdd).toBeTruthy()
      expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "ADD")

    it 'should call permission service hasPermissionOn method and set value true to canDelete variable', ->
      data = {role: {permissions: [{code: "DLT"}]}}
      spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
      @scope.checkPermissions(data)
      expect(@scope.canDelete).toBeTruthy()
      expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "DLT")

    it 'should call permission service hasPermissionOn method and set value true to canDelete variable', ->
      data = {role: {permissions: [{code: "SHR"}]}}
      spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
      @scope.checkPermissions(data)
      expect(@scope.canShare).toBeTruthy()
      expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "SHR")

    it 'should call permission service hasPermissionOn method and set value true to canDelete variable', ->
      data = {role: {permissions: [{code: "MNG_USR"}]}}
      spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
      @scope.checkPermissions(data)
      expect(@scope.canManageUser).toBeTruthy()
      expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "MNG_USR")
