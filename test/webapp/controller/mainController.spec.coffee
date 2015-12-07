'use strict'

describe 'mainController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, localStorageService, toastr, groupService, $q, $modal, roleServices) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @roleServices = roleServices
    @localStorageService = localStorageService
    @toastr = toastr
    @modal = $modal
    @q = $q
    @mainController = $controller('mainController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
          roleServices: @roleServices
        })

  describe '#goToManageGroups', ->
    it 'should show a toastr error message if object is blank', ->
      @rootScope.selectedCompany = {}
      spyOn(@toastr, 'error')
      deferred = @q.defer()
      spyOn(@modal, 'open').andReturn({result: deferred.promise})

      @scope.goToManageGroups()
      expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')
      expect(@modal.open).not.toHaveBeenCalled()

    it 'should call modal service', ->
      @rootScope.selectedCompany = {something: "something"}
      modalData = {
        templateUrl: '/public/webapp/views/addManageGroupModal.html'
        size: "liq90"
        backdrop: 'static'
        controller: 'groupController'
      }
      deferred = @q.defer()
      spyOn(@modal, 'open').andReturn({result: deferred.promise})
      @scope.goToManageGroups()
      expect(@modal.open).toHaveBeenCalledWith(modalData)

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