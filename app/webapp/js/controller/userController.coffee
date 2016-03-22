"use strict"

userController = ($scope, $rootScope, toastr, userServices, localStorageService, $timeout, $uibModal, modalService) ->
  $scope.userAuthKey = undefined
  $scope.noData = false
  $scope.subListData = []
  $scope.uTransData = {}
  $scope.cSubsData = false
  
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
    if data.startPage > data.totalPages
      $scope.nothingToLoadUser = true
      toastr.info("Nothing to load, all transactions are loaded", "Info")
      return
    if data.startPage is 1
      data.startPage = 2
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
    type: ''
    itemId: ''
    linked: []
    toLink:''
    toLinkObj: {}
    mfaForm: {}
    fieldType: ''
    mfaResponse: {
      imgOrToken: ''
      questions:{}
    }
    requestSent: false
    captcha: ''
    showToken: false
    modalInstance: undefined
    toDelete : ''
    toRemove : {}
  }
  $scope.linkedAccountsExist = false
  $scope.bankDetails = {}

  $scope.loadYodlee = () ->
    #userServices.loginRegister($scope.loginSuccess, $scope.loginFailure)
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)

  $scope.getAccountsSuccess = (res) ->
    $scope.banks.linked = res.body
    if $scope.banks.linked.length < 1
      $scope.linkedAccountsExist = false
    else
      $scope.linkedAccountsExist = true

  $scope.getAccountsFailure = (res) ->
    # companyUniqueName =  {
    #   cUnq: $rootScope.selectedCompany.uniqueName
    # }
    toastr.error(res.data.code, res.data.message)
    # userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)

  
  $scope.fetchSiteList = (str) ->
    data = {
      name: str
    }
    reqParam = {
      pName: str
    }
    if data.name.length > 1
      userServices.searchSite(data, reqParam).then($scope.searchSiteSuccess, $scope.searchSiteFailure)

  $scope.searchSiteSuccess = (res) ->
    $scope.banks.banksList = res.body

  $scope.searchSiteFailure = (res) ->
    toastr.error(res.message)

  $scope.selectBank = (bank) ->
    $scope.banks.siteID = bank.siteId
    $scope.banks.type = bank.type
    if bank.yodleeSiteLoginFormDetailList.length > 1
      toastr.error('Something went wrong')
    else
      $scope.banks.components = bank.yodleeSiteLoginFormDetailList[0].componentList
      _.each $scope.banks.components, (bank) ->

        if bank.fieldType.typeName == 'OPTIONS'
          bank.fieldOptions = []
          mergedOptions = _.zip(bank.displayValidValues, bank.validValues)
          _.each mergedOptions, (opt) ->
            option = {}
            option.name = opt[0]
            option.value = opt[1]
            bank.fieldOptions.push(option)

        if bank.name.toLowerCase().indexOf('password') != -1
          bank.name = "PASSWORD"

  $scope.submitForm = (bankDetails) ->
    det = bankDetails
    reqBody = {
      siteId : $scope.banks.siteID.toString()
      loginFormDetail : []
      type : $scope.banks.type
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

      # for property of cmp
      #   toSend[property] = cmp[property]
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
    $scope.banks.requestSent = true
    

  $scope.addSiteAccountSuccess = (res) ->
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    $scope.banks.itemId = res.body.itemId
    if res.body.mfa
      $scope.banks.fieldType = res.body.yodleeMfaResponse.fieldType
      switch res.body.yodleeMfaResponse.fieldType
        when "TOKEN"
          $scope.banks.mfaForm = res.body.yodleeMfaResponse.fieldInfo.token
          $scope.banks.showToken = true
        when "IMAGE"
          $scope.banks.mfaForm = res.body.yodleeMfaResponse.fieldInfo.image
          $scope.banks.showToken = true
        when "QUESTIONS"
          $scope.banks.mfaForm = res.body.yodleeMfaResponse.fieldInfo.questionAns
          $scope.banks.showToken = false
      $scope.banks.modalInstance = $uibModal.open(
        templateUrl: '/public/webapp/views/yodleeMfaModal.html'
        size: "sm"
        backdrop: 'static'
        scope: $scope
      )
    else
      $scope.banks.list = undefined
      toastr.success('Account added successfully!')

    userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)

    $scope.banks.requestSent = false
    $scope.bankDetails = {}  

  $scope.addSiteAccountFailure = (res) ->
    toastr.error(res.data.message, res.data.code)
    $scope.banks.requestSent = false
    $scope.bankDetails = {}

  $scope.addMfaAccount = (bankData) ->
    mfa = bankData.mfaResponse
    unqObj =  {
      cUnq: $rootScope.selectedCompany.uniqueName
      itemId: $scope.banks.itemId
    }
    newMfa = {}
    newMfa.itemId = $scope.banks.itemId
    newMfa.type = $scope.banks.fieldType
    if newMfa.type == 'IMAGE' || newMfa.type == 'TOKEN'
      newMfa.token = mfa.imgOrToken
      newMfa.questionAnswerses = []
    else if newMfa.type == 'QUESTIONS'
      mfaForm = $scope.banks.mfaForm
      newMfa.token = mfa.imgOrToken
      newMfa.questionAnswerses = []
      _.each mfaForm.questionsAndAns, (pQ) ->
        question = {}
        for property of mfa.questions
          if pQ.metaData == property
            question.answer = mfa.questions[property]
            question.answerFieldType = pQ.responseFieldType
            question.metaData = pQ.metaData
            question.question = pQ.question
            question.questionFieldType = pQ.questionFieldType
            newMfa.questionAnswerses.push(question)

    userServices.verifyMfa(unqObj, newMfa).then($scope.verifyMfaSuccess, $scope.verifyMfaFailure)

  $scope.verifyMfaSuccess = (res) ->
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    toastr.success('Account added successfully!')
    userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)
    $scope.banks.modalInstance.close()
    $scope.banks.list = undefined

  $scope.verifyMfaFailure = (res) ->
    $scope.banks.modalInstance.close()
    toastr.error(res.data.code, res.data.message, 'Please try again.')
    

  $scope.showAccountsList = (card) ->
    card.showAccList = true
    $scope.AccountsList = $rootScope.fltAccntList
    linkedAccounts = []
    _.each $scope.banks.linked, (acc) ->
      _.each acc.yodleeAccounts, (link) ->
        if link.giddhAccount != null
          linked = {
            uniqueName : link.giddhAccount.uniqueName
          }
          $scope.AccountsList = _.without($scope.AccountsList, _.findWhere($scope.AccountsList, linked))
    

  $scope.linkGiddhAccount = (card) ->
    card.showAccList = false
    $scope.showAccountsList(card)
    $scope.banks.toLinkObj = {
      itemAccountId: card.itemAccountId
      uniqueName: ''
    }

  $scope.LinkGiddhAccountConfirm = (acc) ->
    $scope.banks.toLinkObj.uniqueName = acc.uniqueName
    modalService.openConfirmModal(
        title: 'Link Account',
        body: 'Are you sure you want to link ' + acc.name + ' ?',
        ok: 'Yes',
        cancel: 'No').then($scope.LinkGiddhAccountConfirmed)

  $scope.LinkGiddhAccountConfirmed = (res) ->
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
      itemAccountId: $scope.banks.toLinkObj.itemAccountId
    }
    userServices.addGiddhAccount(companyUniqueName, $scope.banks.toLinkObj).then($scope.LinkGiddhAccountConfirmSuccess, $scope.LinkGiddhAccountConfirmFailure)

  $scope.LinkGiddhAccountConfirmSuccess = (res) ->
    linkAccData = res.body
    toastr.success('Account linked successfully with ' + linkAccData.giddhAccount.name)
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)

  $scope.LinkGiddhAccountConfirmFailure = (res) ->
    toastr.error(res.data.message)

  $scope.removeGiddhAccount = (card) ->
    $scope.banks.toRemove.linkedAccount = card.giddhAccount.uniqueName
    $scope.banks.toRemove.ItemAccountId = card.itemAccountId.toString()
    modalService.openConfirmModal(
        title: 'Delete Account',
        body: 'Are you sure you want to unlink ' + card.giddhAccount.uniqueName + ' ?',
        ok: 'Yes',
        cancel: 'No').then($scope.removeGiddhAccountConfirmed)

  $scope.removeGiddhAccountConfirmed = () ->
    reqParam =  {
      cUnq: $rootScope.selectedCompany.uniqueName
      linkedAccount: $scope.banks.toRemove.linkedAccount
      ItemAccountId: $scope.banks.toRemove.ItemAccountId
    }
    userServices.removeAccount(reqParam).then($scope.removeGiddhAccountConfirmedSuccess, $scope.removeGiddhAccountConfirmedFailure)

  $scope.removeGiddhAccountConfirmedSuccess = (res) ->
    toastr.success('Account successFully unlinked' )
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)

  $scope.removeGiddhAccountConfirmedFailure = (res) ->
    toastr.error(res.body)

  $scope.deleteAddedBank = (card) ->
    $scope.banks.toDelete = card.siteAccountId
    modalService.openConfirmModal(
        title: 'Delete Account',
        body: 'Are you sure you want to delete ' + card.accountName + ' ?' + '\n' + 'All accounts linked with the same bank will be deleted.',
        ok: 'Yes',
        cancel: 'No').then($scope.deleteAddedBankAccountConfirmed)


  $scope.deleteAddedBankAccountConfirmed = () ->
    reqParam = {
      cUnq : $rootScope.selectedCompany.uniqueName
      memSiteAccId: $scope.banks.toDelete
    }
    userServices.deleteBankAccount(reqParam).then($scope.deleteAddedBankAccountConfirmedSuccess, $scope.deleteAddedBankAccountConfirmedFailure)

  $scope.deleteAddedBankAccountConfirmedSuccess = (res) ->
    toastr.success(res.body)
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)

  $scope.deleteAddedBankAccountConfirmedFailure = (res) ->
    toastr.error(res.body)

  $scope.refreshAccounts = () ->
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
      refresh: true
    }
    userServices.refreshAll(companyUniqueName).then($scope.refreshAllSuccess, $scope.refreshAllFailure)

  $scope.refreshAllSuccess = (res) ->
    refreshedAccounts = res.body
    $scope.banks.linked = refreshedAccounts
    toastr.success('SuccessFully Refreshed!')

  $scope.refreshAllFailure = (res) ->
    toastr.error(res.data.message, res.data.code)

#init angular app
giddh.webApp.controller 'userController', userController


