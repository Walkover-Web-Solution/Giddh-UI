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
#      @rootScope.basicInfo = {"userUniqueName": "ravisoni"}
      @rootScope.basicInfo = undefined
      deferred = @q.defer()
      spyOn(@userServices, 'getKey').andReturn(deferred.promise)
      @scope.getUserAuthKey()
      expect(@userServices.getKey).not.toHaveBeenCalled()

    it 'should call service', ->
      @rootScope.basicInfo = {"userUniqueName": "ravisoni"}
      #      @rootScope.basicInfo = undefined
      deferred = @q.defer()
      spyOn(@userServices, 'getKey').andReturn(deferred.promise)
      @scope.getUserAuthKey()
      expect(@userServices.getKey).toHaveBeenCalled()

  describe '#getUserAuthKeySuccess', ->
    it 'should set userAuthKey value', ->
      result = {"body": "userUniqueId"}
      @scope.getUserAuthKeySuccess(result)
      expect(@scope.userAuthKey).toEqual(result.body)

  describe '#getUserAuthKeyFailure', ->
    it 'should show toastr with error message', ->
      result = {"body": {"message": "Unable to generate auth key"}}
      spyOn(@toastr, 'error')
      @scope.getUserAuthKeyFailure(result)
      expect(@toastr.error).toHaveBeenCalledWith("Unable to generate auth key", "Error")

  describe '#regenerateKey', ->
    it ''
