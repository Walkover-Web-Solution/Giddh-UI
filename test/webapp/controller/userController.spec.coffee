'use strict'

describe 'userController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($controller, $rootScope, toastr, userServices, $q) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @toastr = toastr
    @q = $q
    @userServices = userServices
    @userController = $controller('userController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          userServices: @userServices
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

  describe '#test to check for viewContentLoaded event', ->
    it 'should call a getAccountsGroups method', ->
      spyOn(@scope, 'getUserAuthKey')
      @rootScope.$broadcast('$viewContentLoaded')
      expect(@scope.getUserAuthKey).toHaveBeenCalled()

  describe '#test to check variable set to undefined or not', ->
    it 'should check whether variable declared is undefined or not', ->
      expect(@scope.userAuthKey).toBe(undefined)