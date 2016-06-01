# 'use strict'

# describe 'userController', ->
#   beforeEach module('giddhWebApp')

#   describe 'local variables', ->
#     beforeEach inject ($rootScope, $controller) ->
#       @scope = $rootScope.$new()
#       @rootScope = $rootScope
#       @userController = $controller('userController',
#         {
#           $scope: @scope, 
#           $rootScope: @rootScope
#         }
#       )

#     it 'should check scope variables set by default', ->
#       expect(@scope.userAuthKey).toBeUndefined()
#       expect(@scope.noData).toBeFalsy()
#       expect(@scope.subListData).toEqual([])
#       expect(@scope.uTransData).toEqual({})
#       expect(@scope.cSubsData).toBeFalsy()
#       expect(@scope.banks).toBeDefined()
#       expect(@scope.linkedAccountsExist).toBeFalsy()
#       expect(@scope.bankDetails).toBeDefined()
#       spyOn(@scope, "getUserAuthKey")
#       runs ->
#         expect(@scope.getUserAuthKey).not.toHaveBeenCalled()
#       # waitsFor (->
#       #   @scope.getUserAuthKey()
#       # ), 200
#       # runs ->
#       #   expect(@scope.getUserAuthKey).toHaveBeenCalled()

#   beforeEach inject ($controller, $rootScope, toastr, userServices, $q, localStorageService, $uibModal) ->
#     @scope = $rootScope.$new()
#     @rootScope = $rootScope
#     @toastr = toastr
#     @q = $q
#     @userServices = userServices
#     @localStorageService = localStorageService
#     @uibModal = $uibModal
#     @userController = $controller('userController',
#         {
#           $scope: @scope,
#           $rootScope: @rootScope,
#           userServices: @userServices
#           localStorageService: @localStorageService
#           $uibModal: @uibModal
#         })

#   describe '#getUserAuthKey', ->
#     it 'should not call service if basicinfo is undefined', ->
#       @rootScope.basicInfo = undefined
#       deferred = @q.defer()
#       spyOn(@userServices, 'getKey').andReturn(deferred.promise)
#       @scope.getUserAuthKey()
#       expect(@userServices.getKey).not.toHaveBeenCalled()

#     it 'should call service', ->
#       @rootScope.basicInfo = {"userUniqueName": "ravisoni"}
#       deferred = @q.defer()
#       spyOn(@userServices, 'getKey').andReturn(deferred.promise)
#       @scope.getUserAuthKey()
#       expect(@userServices.getKey).toHaveBeenCalled()

#   describe '#getUserAuthKeySuccess', ->
#     it 'should set userAuthKey value', ->
#       res = {"body": "userUniqueId"}
#       @scope.getUserAuthKeySuccess(res)
#       expect(@scope.userAuthKey).toEqual(res.body)

#   describe '#getUserAuthKeyFailure', ->
#     it 'should show toastr with error message', ->
#       res = 
#         data: 
#           message: "Unable to generate auth key"
#           status: "Error"
#       spyOn(@toastr, 'error')
#       @scope.getUserAuthKeyFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#regenerateKey', ->
#     it 'should regenerate key for user by calling service', ->
#       @rootScope.basicInfo = {"userUniqueName": "ravisoni"}
#       deferred = @q.defer()
#       spyOn(@userServices, 'generateKey').andReturn(deferred.promise)
#       @scope.regenerateKey()
#       expect(@userServices.generateKey).toHaveBeenCalled()

#   describe '#generateKeySuccess', ->
#     it 'should set userAuthKey value', ->
#       res = {"body": "userUniqueId"}
#       @scope.getUserAuthKeySuccess(res)
#       expect(@scope.userAuthKey).toEqual(res.body)

#   describe '#generateKeyFailure', ->
#     it 'should show toastr with error message', ->
#       res = 
#         data: 
#           message: "some message"
#           status: "Error"
#       spyOn(@toastr, 'error')
#       @scope.getUserAuthKeyFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#getSubscriptionList', ->
#     it 'should call service userServices getsublist method with rootScope variable', ->
#       @rootScope.basicInfo = {"userUniqueName": "ravisoni"}
#       deferred = @q.defer()
#       spyOn(@userServices, 'getsublist').andReturn(deferred.promise)
#       @scope.getSubscriptionList()
#       expect(@userServices.getsublist).toHaveBeenCalled()
    

#   describe '#getSubscriptionListSuccess', ->
#     it 'should set subListData data and set variable to true', ->
#       res = {
#         body: [
#           {some: "userUniqueId"}
#         ]
#       }
#       @scope.getSubscriptionListSuccess(res)
#       expect(@scope.subListData).toEqual(res.body)
#       expect(@scope.cSubsData).toBeTruthy()

#     it 'should set subListData data and set variable to false', ->
#       res = {
#         body: []
#       }
#       @scope.getSubscriptionListSuccess(res)
#       expect(@scope.subListData).toEqual(res.body)
#       expect(@scope.cSubsData).toBeFalsy()

#   describe '#getSubscriptionListFailure', ->
#     it 'should show toastr with error message', ->
#       res = 
#         data: 
#           message: "Unable to generate auth key"
#           status: "Error"
#       spyOn(@toastr, 'error')
#       @scope.getSubscriptionListFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#changeCallback', ->
#     it 'should match obj from list and not call userServices due to mismatch', ->
#       @scope.subListData = [
#         {autoDeduct: true, companyUniqueName: "abc"}
#         {autoDeduct: true, companyUniqueName: "deb"}
#       ]
#       @rootScope.basicInfo = {}
#       @rootScope.basicInfo.uniqueName = "somename"
#       obj = {
#         uUname: @rootScope.basicInfo.uniqueName
#         companyUniqueName: "deb"
#       }
#       deferred = @q.defer()
#       spyOn(@userServices, 'cancelAutoPay').andReturn(deferred.promise)
#       @scope.changeCallback()
#       expect(@userServices.cancelAutoPay).not.toHaveBeenCalledWith(obj)
      
#     it 'should check and match obj from list and call userServices cancelAutoPay method with obj', ->
#       @scope.subListData = [
#         {autoDeduct: true, companyUniqueName: "abc"}
#         {autoDeduct: false, companyUniqueName: "deb"}
#       ]
#       @rootScope.basicInfo = {}
#       @rootScope.basicInfo.uniqueName = "somename"
#       obj = {
#         uUname: @rootScope.basicInfo.uniqueName
#         companyUniqueName: "deb"
#       }
#       deferred = @q.defer()
#       spyOn(@userServices, 'cancelAutoPay').andReturn(deferred.promise)
#       @scope.changeCallback()
#       expect(@userServices.cancelAutoPay).toHaveBeenCalledWith(obj)

#   describe '#autoPayChangeSuccess', ->
#     it 'should call getSubscriptionList function', ->
#       spyOn(@scope, "getSubscriptionList")
#       res = {}
#       @scope.autoPayChangeSuccess(res)
#       expect(@scope.getSubscriptionList).toHaveBeenCalled()

#   describe '#autoPayChangeFailure', ->
#     it 'should show toastr with error message', ->
#       res = 
#         data: 
#           message: "Some message"
#           status: "Error"
#       spyOn(@toastr, 'error')
#       @scope.autoPayChangeFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#getUserTransaction', ->
#     xit 'should call modal service', ->
#       @rootScope.basicInfo = {}
#       @rootScope.basicInfo.uniqueName= "something"
#       modalInstance = {}
#       modalInstance.opened = true
#       modalInstance = {
#         templateUrl: 'prevTransDetail.html',
#         size: "liq90",
#         backdrop: 'static',
#         scope: @scope
#       }
#       deferred = @q.defer()
#       spyOn(@uibModal, 'open').andReturn({result: deferred.promise})
#       @scope.getUserTransaction()
#       expect(@uibModal.open).toHaveBeenCalledWith(modalInstance)

#   describe '#getUserSublistSuccess', ->
#     it 'should set uTransData data and set noData variable to false', ->
#       res = {
#         body: [
#           {name: "somename", userUniqueName: "somename"}
#         ]
#       }
#       @scope.getUserSublistSuccess(res)
#       expect(@scope.uTransData).toEqual(res.body)
#       expect(@scope.noData).toBeFalsy()

#     it 'should set uTransData data and set noData variable to true', ->
#       res = {
#         body: []
#       }
#       @scope.getUserSublistSuccess(res)
#       expect(@scope.uTransData).toEqual(res.body)
#       expect(@scope.noData).toBeTruthy()

#   describe '#getUserSubListFailure', ->
#     it 'should show toastr with error message', ->
#       res = 
#         data: 
#           message: "some message"
#           status: "Error"
#       spyOn(@toastr, 'error')
#       @scope.getUserSubListFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)
      
#   describe '#pageChanged', ->
#     it 'should not call userServices getUserSublist method and set variable to nothingToLoadUser', ->
#       data = {
#         totalPages: 1
#         startPage: 2
#       }
#       spyOn(@toastr, "info")
#       @scope.pageChanged(data)
#       expect(@scope.nothingToLoadUser).toBeTruthy()
#       expect(@toastr.info).toHaveBeenCalledWith("Nothing to load, all transactions are loaded", "Info")

#     it 'should call userServices getUserSublist method', ->
#       @rootScope.basicInfo = {}
#       @rootScope.basicInfo.uniqueName= "something"
#       data = {
#         totalPages: 1
#         startPage: 1
#       }
#       obj = {
#         name: @rootScope.basicInfo.uniqueName
#         num: 2
#       }
#       deferred = @q.defer()
#       spyOn(@userServices, 'getUserSublist').andReturn(deferred.promise)
#       @scope.pageChanged(data)
#       expect(@userServices.getUserSublist).toHaveBeenCalledWith(obj)
      
#   describe '#pageChangedSuccess', ->
#     it 'should concatinate two arrays and create plus one count to variable', ->
#       res = 
#         body: 
#           paymentDetail: [
#             {some: "thing"}
#           ]
#       @scope.uTransData = 
#         startPage: 1
#         paymentDetail: []
#       @scope.pageChangedSuccess(res)
#       expect(@scope.uTransData.startPage).toBe(2)
#       expect(@scope.uTransData.paymentDetail).toEqual(res.body.paymentDetail)

#   describe '#pageChangedFailure', ->
#     it 'should show toastr with error message', ->
#       res = 
#         data: 
#           message: "Some message"
#           status: "Error"
#       spyOn(@toastr, 'error')
#       @scope.pageChangedFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#loadYodlee', ->
#     it 'should call getAccounts method of userServices with companyUniqueName', ->
#       @rootScope.selectedCompany = {}
#       @rootScope.selectedCompany.uniqueName = 'something'
#       companyUniqueName =  {
#         cUnq: @rootScope.selectedCompany.uniqueName
#       }
#       deferred = @q.defer()
#       spyOn(@userServices, 'getAccounts').andReturn(deferred.promise)
#       @scope.loadYodlee()
#       expect(@userServices.getAccounts).toHaveBeenCalledWith(companyUniqueName)

#   describe '#getAccountsSuccess' , ->
#     it 'should assign cody of response to variable', ->
#       @scope.banks = {}
#       @scope.banks.linked = {}
#       @scope.banks.linked.length = 1
#       res = {
#         body : []
#       }
#       @scope.getAccountsSuccess(res)
#       expect(@scope.banks.linked ).toEqual(res.body)
#       expect(@scope.linkedAccountsExist).toBeFalsy()


#   describe '#getAccountsFailure', ->
#     it 'should show toastr with error message', ->
#       res = 
#         data: 
#           code: "Some message"
#           message: "Error"
#       spyOn(@toastr, 'error')
#       @scope.getAccountsFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.code, res.data.message)

#   describe '#fetchSiteList', ->
#     it 'should call searchSite method of userServices with reqParam and data', ->
#       str = 'name'
#       data = {
#         name: str
#       }
#       reqParam = {
#         pName : str
#       }
#       deferred = @q.defer()
#       spyOn(@userServices, 'searchSite').andReturn(deferred.promise)
#       @scope.fetchSiteList(str)
#       expect(@userServices.searchSite).toHaveBeenCalledWith(data, reqParam)
      
#   describe '#searchSiteSuccess', ->
#     it 'should set body of response to variable', ->
#       res = {
#         body: []
#       }
#       @scope.banks = {}
#       @scope.searchSiteSuccess(res)
#       expect(@scope.banks.banksList).toEqual(res.body)

#   describe '#searchSiteFailure', ->
#     it 'should show toastr with error message', ->
#       res = 
#         message: "Error"
#       spyOn(@toastr, 'error')
#       @scope.searchSiteFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.message)

#   describe '#selectBank', ->
#     it 'should assign values to bank object variable', ->
#       bank = {
#         siteID: ''
#         type: ''
#         yodleeSiteLoginFormDetailList :[
#           {
#             componentList: []
#           }
#           {
#             componentList: []
#           }
#         ]
#       }
#       @scope.banks = {
#         siteID: bank.siteID
#         type: bank.type
#         components: [
#           bank: {
#             name: ''
#           }
#         ]
#       }
#       @scope.selectBank(bank)
#       #expect(@scope.banks.siteID).toEqual(bank.siteID)
#       expect(@scope.banks.type).toEqual(bank.type)

#   describe '#submitForm', ->
#     xit 'should call addSiteAccount method of userServices', ->
#       @rootScope.selectedCompany = {}
#       @rootScope.selectedCompany.uniqueName = 'something'
#       bankDetails = {}
#       @scope.banks = {
#         siteID: ''
#         type: ''
#         components: [
#           bank: {
#             name: ''
#             fieldType: {
#               typeName: ''
#             }
#           }
#         ]
#       }
#       reqBody = {
#         siteId : ''
#         loginFormDetail : []
#         type : ''
#       }
#       companyUniqueName =  {
#         cUnq: ''
#       }
#       components = @scope.banks.components
#       deferred = @q.defer()
#       spyOn(@userServices, 'addSiteAccount').andReturn(deferred.promise)
#       @scope.submitForm(bankDetails)
#       expect(@userServices.addSiteAccount).toHaveBeenCalledWith(reqBody, companyUniqueName)