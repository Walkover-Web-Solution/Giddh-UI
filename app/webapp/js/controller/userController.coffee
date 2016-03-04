"use strict"

userController = ($scope, $rootScope, toastr, userServices, localStorageService, $timeout, $uibModal, modalService) ->
  $scope.userAuthKey = undefined
  $scope.noData = false
  $scope.subListData = []
  $scope.uTransData = {}
  $scope.cSubsData = false
  $rootScope.basicInfo = localStorageService.get("_userDetails")
  $scope.currentPage = 1
  $scope.pagiMaxSize = 5
  
  $scope.getUserAuthKey = () ->
    if !_.isEmpty($rootScope.basicInfo)
      userServices.getKey($rootScope.basicInfo.uniqueName).then($scope.getUserAuthKeySuccess,
          $scope.getUserAuthKeyFailure)

  $scope.getUserAuthKeySuccess = (res) ->
    $scope.userAuthKey = res.body

  $scope.getUserAuthKeyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.regenerateKey = () ->
    userServices.generateKey($rootScope.basicInfo.uniqueName).then($scope.generateKeySuccess,
        $scope.generateKeyFailure)

  $scope.generateKeySuccess = (res) ->
    $scope.userAuthKey = res.body.authKey

  $scope.generateKeyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $timeout(->
    $scope.getUserAuthKey()
  ,200)

  $scope.getSubscriptionList = () ->
    userServices.getsublist($rootScope.basicInfo.uniqueName).then($scope.getSubscriptionListSuccess, $scope.getSubscriptionListFailure)
  
  $scope.getSubscriptionListSuccess = (res) ->
    $scope.subListData = res.body
    if res.body.length > 0
      $scope.cSubsData = true
    else
      $scope.cSubsData = false

  $scope.getSubscriptionListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.changeCallback = () ->
    result =  _.findWhere($scope.subListData, {autoDeduct: false})
    if _.isUndefined(result) || _.isEmpty(result)
      console.info "do nothing"
    else
      obj = {
        uUname: $rootScope.basicInfo.uniqueName
        companyUniqueName: result.companyUniqueName
      }
      userServices.cancelAutoPay(obj).then($scope.autoPayChangeSuccess, $scope.autoPayChangeFailure)
    
  $scope.autoPayChangeSuccess = (res) ->
    $scope.getSubscriptionList()

  $scope.autoPayChangeFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getUserTransaction = () -> 
    modalInstance = $uibModal.open(
      templateUrl: 'prevTransDetail.html'
      size: "liq90"
      backdrop: 'static'
      scope: $scope
    )
    obj = {
      name: $rootScope.basicInfo.uniqueName
      num: 1
    }
    modalInstance.opened.then ->
      userServices.getUserSublist(obj).then($scope.getUserSublistSuccess, $scope.getUserSubListFailure)
    
  $scope.getUserSublistSuccess = (res) ->
    $scope.uTransData = res.body
    $scope.uTransData.startPage = 1
    $scope.nothingToLoadUser = false
    if $scope.uTransData.length is 0
      $scope.noData = true

  $scope.getUserSubListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.pageChanged = (data) ->
    if data.totalPages is data.startPage
      $scope.nothingToLoadUser = true
      toastr.info("Nothing to load, all transactions are loaded", "Info")
      return
    obj = {
      name: $rootScope.basicInfo.uniqueName
      num: data.startPage
    }
    userServices.getUserSublist(obj).then($scope.pageChangedSuccess, $scope.pageChangedFailure)

  $scope.pageChangedSuccess =(res)->
    $scope.uTransData.paymentDetail = $scope.uTransData.paymentDetail.concat(res.body.paymentDetail)
    $scope.uTransData.startPage += 1

  $scope.pageChangedFailure =(res)->
    toastr.error(res.data.message, res.data.status)


  #################### yodlee integration ####################
  $scope.banks = {
    list : undefined
    banksList: []
    components : []
    siteID: ''
    linked: []
    toLink:''
    toLinkObj: {}
  }

  $scope.bankDetails = {}

  $scope.loadYodlee = () ->
    userServices.loginRegister($scope.loginSuccess, $scope.loginFailure)
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)

  $scope.getAccountsSuccess = (res) ->
    $scope.banks.linked = res.body


  $scope.getAccountsFailure = (res) ->
    console.log res


  
  $scope.fetchSiteList = (str) ->
    data = {
      name: str
    }
    if data.name.length > 1
      userServices.searchSite(data).then($scope.searchSiteSuccess, $scope.searchSiteFailure)

  $scope.searchSiteSuccess = (res) ->
    $scope.banks.banksList = res.body

  $scope.searchSiteFailure = (res) ->
    toastr.error(res.message)

  $scope.selectBank = (bank) ->
    console.log bank
    $scope.banks.siteID = bank.siteId
    if bank.yodleeSiteLoginFormDetailList.length > 1
      toastr.error('Something went wrong')
    else
      $scope.banks.components = bank.yodleeSiteLoginFormDetailList[0].componentList


  $scope.submitForm = (bankDetails) ->
    det = bankDetails
    reqBody = {
      siteId : $scope.banks.siteID.toString()
      loginFormDetail : []
    }
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    components = $scope.banks.components
    _.each components, (cmp) ->
      toSend = {}
      dn = cmp.displayName
      for property of det
        if dn == property
          toSend.value = det[property]
      toSend.name = cmp.name
      toSend.displayName = cmp.displayName
      toSend.isEditable = cmp.isEditable
      toSend.enclosedType = cmp.fieldInfoType
      toSend.valueMask = cmp.valueMask
      toSend.valueIdentifier = cmp.valueIdentifier
      toSend.size = cmp.size
      toSend.maxlength = cmp.maxlength
      toSend.helpText = cmp.helpText
      toSend.fieldType = cmp.fieldType.typeName
      reqBody.loginFormDetail.push(toSend)

    userServices.addSiteAccount(reqBody, companyUniqueName).then($scope.addSiteAccountSuccess, $scope.addSiteAccountFailure)

  $scope.addSiteAccountSuccess = (res) ->
    siteData = res.body
    if siteData.isMfa == true
      

  $scope.addSiteAccountFailure = (res) ->
    toastr.error(res.message)

  $scope.showAccountsList = (card) ->
    card.showAccList = true
    $scope.AccountsList = $rootScope.fltAccntList

  $scope.linkGiddhAccount = (card) ->
    card.showAccList = false
    $scope.showAccountsList(card)
    $scope.banks.toLinkObj = {
      itemAccountId: card.itemAccountId
      giddhAccountUniqueName: ''
    }

  $scope.LinkGiddhAccountConfirm = (acc) ->
    $scope.banks.toLinkObj.giddhAccountUniqueName = acc.uniqueName
    modalService.openConfirmModal(
        title: 'Link Account',
        body: 'Are you sure you want to link ' + acc.name + ' ?',
        ok: 'Yes',
        cancel: 'No').then($scope.LinkGiddhAccountConfirmed)

  $scope.LinkGiddhAccountConfirmed = (res) ->
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    userServices.addGiddhAccount(companyUniqueName, $scope.banks.toLinkObj).then($scope.LinkGiddhAccountConfirmSuccess, $scope.LinkGiddhAccountConfirmFailure)

  $scope.LinkGiddhAccountConfirmSuccess = (res) ->
    console.log res

  $scope.LinkGiddhAccountConfirmFailure = (res) ->
    console.log res

#init angular app
giddh.webApp.controller 'userController', userController