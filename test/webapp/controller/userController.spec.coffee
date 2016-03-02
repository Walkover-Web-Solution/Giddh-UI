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

  describe '#getUserAuthKeySuccess', ->
    it 'should set userAuthKey value', ->
      res = {"body": "userUniqueId"}
      @scope.getUserAuthKeySuccess(res)
      expect(@scope.userAuthKey).toEqual(res.body)

  describe '#getUserAuthKeyFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "some message"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.getUserAuthKeyFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#getSubscriptionList', ->
    it 'should call service userServices getsublist method with rootScope variable', ->
      @rootScope.basicInfo = {"userUniqueName": "ravisoni"}
      deferred = @q.defer()
      spyOn(@userServices, 'getsublist').andReturn(deferred.promise)
      @scope.getSubscriptionList()
      expect(@userServices.getsublist).toHaveBeenCalled()
    

  describe '#getSubscriptionListSuccess', ->
    it 'should set subListData data and set variable to true', ->
      res = {
        body: [
          {some: "userUniqueId"}
        ]
      }
      @scope.getSubscriptionListSuccess(res)
      expect(@scope.subListData).toEqual(res.body)
      expect(@scope.cSubsData).toBeTruthy()

    it 'should set subListData data and set variable to false', ->
      res = {
        body: []
      }
      @scope.getSubscriptionListSuccess(res)
      expect(@scope.subListData).toEqual(res.body)
      expect(@scope.cSubsData).toBeFalsy()

  describe '#getSubscriptionListFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "Unable to generate auth key"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.getSubscriptionListFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#changeCallback', ->
    it 'should match obj from list and not call userServices due to mismatch', ->
      @scope.subListData = [
        {autoDeduct: true, companyUniqueName: "abc"}
        {autoDeduct: true, companyUniqueName: "deb"}
      ]
      @rootScope.basicInfo = {}
      @rootScope.basicInfo.uniqueName = "somename"
      obj = {
        uUname: @rootScope.basicInfo.uniqueName
        companyUniqueName: "deb"
      }
      deferred = @q.defer()
      spyOn(@userServices, 'cancelAutoPay').andReturn(deferred.promise)
      @scope.changeCallback()
      expect(@userServices.cancelAutoPay).not.toHaveBeenCalledWith(obj)
      
    it 'should check and match obj from list and call userServices cancelAutoPay method with obj', ->
      @scope.subListData = [
        {autoDeduct: true, companyUniqueName: "abc"}
        {autoDeduct: false, companyUniqueName: "deb"}
      ]
      @rootScope.basicInfo = {}
      @rootScope.basicInfo.uniqueName = "somename"
      obj = {
        uUname: @rootScope.basicInfo.uniqueName
        companyUniqueName: "deb"
      }
      deferred = @q.defer()
      spyOn(@userServices, 'cancelAutoPay').andReturn(deferred.promise)
      @scope.changeCallback()
      expect(@userServices.cancelAutoPay).toHaveBeenCalledWith(obj)

  describe '#autoPayChangeSuccess', ->
    it 'should call getSubscriptionList function', ->
      spyOn(@scope, "getSubscriptionList")
      res = {}
      @scope.autoPayChangeSuccess(res)
      expect(@scope.getSubscriptionList).toHaveBeenCalled()

  describe '#autoPayChangeFailure', ->
    it 'should show toastr with error message', ->
      res = 
        data: 
          message: "Some message"
          status: "Error"
      spyOn(@toastr, 'error')
      @scope.autoPayChangeFailure(res)
      expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

  describe '#getUserTransaction', ->
    xit 'should call modal service', ->
      @rootScope.basicInfo = {}
      @rootScope.basicInfo.uniqueName= "something"
      modalInstance = {}
      modalInstance.opened = true
      modalInstance = {
        templateUrl: 'prevTransDetail.html',
        size: "liq90",
        backdrop: 'static',
        scope: @scope
      }
      deferred = @q.defer()
      spyOn(@uibModal, 'open').andReturn({result: deferred.promise})
      @scope.getUserTransaction()
      expect(@uibModal.open).toHaveBeenCalledWith(modalInstance)

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
      
  describe '#pageChanged', ->
    it 'should not call userServices getUserSublist method and set variable to nothingToLoadUser', ->
      data = {
        totalPages: 1
        startPage: 1
      }
      spyOn(@toastr, "info")
      @scope.pageChanged(data)
      expect(@scope.nothingToLoadUser).toBeTruthy()
      expect(@toastr.info).toHaveBeenCalledWith("Nothing to load, all transactions are loaded", "Info")
      
    
    








      
    

  