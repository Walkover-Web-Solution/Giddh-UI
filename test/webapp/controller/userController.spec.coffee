'use strict'

describe 'userController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($controller, $rootScope, toastr, userServices, $q, localStorageService, $uibModal) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @toastr = toastr
    @q = $q
    @userServices = userServices
    @localStorageService = localStorageService
    @uibModal = $uibModal
    @userController = $controller('userController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          userServices: @userServices
          localStorageService: @localStorageService
          $uibModal: @uibModal
        })

  describe '#getUserAuthKey', ->
    it 'should not call service if basicinfo is undefined', ->
      @rootScope.basicInfo = undefined
      deferred = @q.defer()
      spyOn(@userServices, 'getKey').andReturn(deferred.promise)
      @scope.getUserAuthKey()
      expect(@userServices.getKey).not.toHaveBeenCalled()

    it 'should call service', ->
      @rootScope.basicInfo = {"userUniqueName": "ravisoni"}
      deferred = @q.defer()
      spyOn(@userServices, 'getKey').andReturn(deferred.promise)
      @scope.getUserAuthKey()
      expect(@userServices.getKey).toHaveBeenCalled()

  describe '#getUserAuthKeySuccess', ->
    it 'should set userAuthKey value', ->
      res = {"body": "userUniqueId"}
      @scope.getUserAuthKeySuccess(res)
      expect(@scope.userAuthKey).toEqual(res.body)

  describe '#getUserAuthKeyFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "Unable to generate auth key"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.getUserAuthKeyFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#regenerateKey', ->
    it 'should regenerate key for user by calling service', ->
      @rootScope.basicInfo = {"userUniqueName": "ravisoni"}
      deferred = @q.defer()
      spyOn(@userServices, 'generateKey').andReturn(deferred.promise)
      @scope.regenerateKey()
      expect(@userServices.generateKey).toHaveBeenCalled()

  describe '#generateKeySuccess', ->
    it 'should set userAuthKey value', ->
      res = {"body": "userUniqueId"}
      @scope.getUserAuthKeySuccess(res)
      expect(@scope.userAuthKey).toEqual(res.body)

  describe '#generateKeyFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "Unable to generate auth key"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.getUserAuthKeyFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#getUserTransaction', ->
    xit 'should call modal service', ->
      @rootScope.selectedCompany = {something: "something"}
      modalData = {
        templateUrl: 'prevTransDetail.html',
        size: "liq90",
        backdrop: 'static',
        scope: @scope
      }
      deferred = @q.defer()
      spyOn(@uibModal, 'open').andReturn({result: deferred.opened})
      @scope.getUserTransaction()
      expect(@uibModal.open).toHaveBeenCalledWith(modalData)

  describe '#getUserSublistSuccess', ->
    it 'should set uTransData data and set noData variable to false', ->
      res = {
        body: [
          {name: "somename", userUniqueName: "somename"}
        ]
      }
      @scope.getUserSublistSuccess(res)
      expect(@scope.uTransData).toEqual(res.body)
      expect(@scope.noData).toBeFalsy()

    it 'should set uTransData data and set noData variable to true', ->
      res = {
        body: []
      }
      @scope.getUserSublistSuccess(res)
      expect(@scope.uTransData).toEqual(res.body)
      expect(@scope.noData).toBeTruthy()

  describe '#getUserSubListFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "Unable to generate auth key"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.getUserSubListFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  