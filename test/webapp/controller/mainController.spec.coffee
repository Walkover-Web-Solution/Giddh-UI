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
    it 'should show toastr with error message', ->
      res =
        data:
          status: "Error"
          message: "some-message"
      spyOn(@toastr, 'error')
      @scope.onGetRolesFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)