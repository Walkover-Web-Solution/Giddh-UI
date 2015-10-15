'use strict'

describe 'mainController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, localStorageService, toastr, groupService, $q, $modal) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @localStorageService = localStorageService
    @toastr = toastr
    @modal = $modal
    @q = $q
    @mainController = $controller('mainController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
#$modal: @modal
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
      

    