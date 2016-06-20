"use strict"

userController = ($scope, $rootScope, toastr, userServices, localStorageService, $timeout, $uibModal, modalService, $filter, groupService) ->
  $scope.userAuthKey = undefined
  $scope.noData = false
  $scope.subListData = []
  $scope.uTransData = {}
  $scope.cSubsData = false
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

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
  $scope.transDate = {date: new Date()}
  $scope.transactionDate = $filter('date')($scope.transDate.date, "dd-MM-yyyy")
  $scope.format = "dd-MM-yyyy"
  $scope.newTransDate = {date: new Date()}
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }
  $scope.dateOptionsBanks = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': true
  }
  $scope.today = new Date()
  $scope.beforeThreeMonths =  moment().subtract(3, 'month').utc()
  $scope.fromDatePickerIsOpen = false
  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $scope.loadYodlee = () ->
    #userServices.loginRegister($scope.loginSuccess, $scope.loginFailure)
    $scope.getYodleeAccounts()

  $scope.getYodleeAccounts = () ->
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
      #add transaction date to cards and assign utc format
      _.each $scope.banks.linked, (bank) ->
        _.each bank.accounts, (card) ->
          if _.isNull(card.transactionDate) || _.isUndefined(card.transactionDate)
            card.transactionDate =  new Date()
          else
            card.transactionDate = new Date(card.transactionDate)
           
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

    # $scope.getYodleeAccounts()
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
      itemAccountId: card.accountId
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
    toastr.success('Account linked successfully with ' + linkAccData.linkedAccount.name)
    companyUniqueName =  {
      cUnq: $rootScope.selectedCompany.uniqueName
    }
    userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)

  $scope.LinkGiddhAccountConfirmFailure = (res) ->
    toastr.error(res.data.message)

  $scope.removeGiddhAccount = (card) ->
    $scope.banks.toRemove.linkedAccount = card.linkedAccount.uniqueName
    $scope.banks.toRemove.ItemAccountId = card.accountId.toString()
    modalService.openConfirmModal(
        title: 'Delete Account',
        body: 'Are you sure you want to unlink ' + card.linkedAccount.uniqueName + ' ?',
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
    console.log card
    $scope.banks.toDelete = card.accountId
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
    console.log(res)
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

  $scope.setItemAccountId = (card) ->
    $scope.banks.toLinkObj.itemAccountId = card.accountId

  $scope.updateTransactionDate = (date) ->
    obj =  {
      cUnq: $rootScope.selectedCompany.uniqueName
      itemAccountId: $scope.banks.toLinkObj.itemAccountId
      date: date
    }
    data = {}
    userServices.setTransactionDate(obj, data).then($scope.updateTransactionDateSuccess, $scope.updateTransactionDateFailure)

  $scope.updateTransactionDateSuccess = (res) ->
    toastr.success(res.body)

  $scope.updateTransactionDateFailure = (res) ->
    toastr.error(res.data.code, res.data.message)

  # watch date changed
  $scope.changedate =(date)->
    abc = $filter("date")(date)
    date = $filter('date')(date, "dd-MM-yyyy")
    modalService.openConfirmModal(
      title: 'Update Date',
      body: 'Do you want to get ledger entries for this account from ' + abc + ' ?',
      ok: 'Yes',
      cancel: 'No').then(()->
        $scope.updateTransactionDate(date)
      )

  # manage sub user start
  $scope.cSubUser = {}

  # get subuser list
  $scope.getSubUsers = () ->
    console.time "getSubUsers"
    console.log $rootScope.basicInfo
    console.timeEnd "getSubUsers"

  # create sub user
  $scope.createSubUser =(udata)->
    userServices.createSubUser($rootScope.basicInfo.uniqueName, udata).then($scope.createSubUserSuccess, $scope.createSubUserFailure)

  $scope.createSubUserSuccess = (res) ->
    $scope.cSubUser = {}
    toastr.success("Sub User successfully created", "Success")
    $scope.getUserDetails()

  $scope.createSubUserFailure = (res) ->
    toastr.error(res.data.code, res.data.message)

  # delete sub user
  $scope.deleteSubUser =(data, index)->
    userServices.deleteSubUser(data.uniqueName).then($scope.deleteSubUserSuccess, $scope.deleteSubUserFailure)

  $scope.deleteSubUserSuccess = (res) ->
    toastr.success(res.body, res.status)
    $scope.getUserDetails()

  $scope.deleteSubUserFailure = (res) ->
    toastr.error(res.data.code, res.data.message)

  # login as
  $scope.getSubUserAuthKey = (uniqueName) ->
    userServices.getSubUserAuthKey(uniqueName).then($scope.getSubUserAuthKeySuccess, $scope.getSubUserAuthKeyFailure)

  $scope.getSubUserAuthKeySuccess = (res) ->
    _.filter($rootScope.basicInfo.subUsers, (user) ->
      if user.uniqueName is res.body.uniqueName
        user.authKeyDone = true
        user.authKey = res.body.authKey
    )

  $scope.getSubUserAuthKeyFailure = (res) ->
    toastr.error(res.data.code, res.data.message)

  # add and verify mobile number
  $scope.phoneNumber = ''
  $scope.userNumber = ''
  $scope.mobNum = {
    countryCode: ''
    number: ''
    showVerificationBox : false
    verificationCode: ''
  }

  $scope.addNumber = (number) ->
    if number.indexOf('-') != -1
      numArr = number.split('-')
      $scope.mobNum.countryCode = numArr[0]
      $scope.mobNum.number = numArr[1]
      data = {
        "countryCode":$scope.mobNum.countryCode
        "mobileNumber":$scope.mobNum.number
      }
      userServices.addNumber(data).then($scope.addNumberSuccess, $scope.addNumberFailure)
    else
      toastr.error("Please enter number in format: 91-9998899988")

  $scope.addNumberSuccess = (res) ->
    toastr.success("You will receive a verification code on your mobile shortly.")
    $scope.mobNum.showVerificationBox = true

  $scope.addNumberFailure = (res) ->
    toastr.error(res.data.message)

  $scope.verifyNumber = (code) ->
    data = {
      "countryCode":$scope.mobNum.countryCode
      "mobileNumber":$scope.mobNum.number
      "oneTimePassword":$scope.mobNum.verificationCode
    }
    userServices.verifyNumber(data).then($scope.verifyNumberSuccess, $scope.verifyNumberFailure)

  $scope.verifyNumberSuccess = (res) ->
    toastr.success(res.body)
    $scope.mobNum.showVerificationBox = false
    $scope.getUserDetails()

  $scope.verifyNumberFailure = (res) ->
    toastr.error(res.data.message)

  $scope.getUserDetails = ->
    if _.isUndefined($rootScope.basicInfo.uniqueName)
      $rootScope.basicInfo = localStorageService.get("_userDetails")
    userServices.get($rootScope.basicInfo.uniqueName).then($scope.getUserDetailSuccess, $scope.getUserDetailFailure)

  #Get user details
  $scope.getUserDetailSuccess = (res) ->
    localStorageService.set("_userDetails", res.body)
    $rootScope.basicInfo = res.body
    $scope.userNumber = res.body.contactNo

  #Get user details failure
  $scope.getUserDetailFailure = (res)->
    toastr.error(res.data.message, res.data.status)
  # manage sub user end

  #get flat account list
#  $scope.flatAccList = {
#    page: 1
#    count: 5
#    totalPages: 0
#    currentPage : 1
#  }

  $scope.getFlatAccountList = (compUname) ->
    $rootScope.getFlatAccountList(compUname)
#    reqParam = {
#      companyUniqueName: compUname
#      q: ''
#      page: $scope.flatAccList.page
#      count: $scope.flatAccList.count
#    }
#    groupService.getFlatAccList(reqParam).then($scope.getFlatAccountListListSuccess, $scope.getFlatAccountListFailure)

  $scope.getFlatAccountListListSuccess = (res) ->
    $scope.fltAccntListPaginated = res.body.results

  $scope.getFlatAccountListFailure = (res) ->
    toastr.error(res.data.message)

  $scope.getFlatAccountList($rootScope.selectedCompany.uniqueName)

  # search flat accounts list
  $rootScope.searchAccounts = (str) ->
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    if str.length > 2
      reqParam.q = str
      groupService.getFlatAccList(reqParam).then($scope.getFlatAccountListListSuccess, $scope.getFlatAccountListFailure)
    else
      reqParam.q = ''
      reqParam.count = 5
      groupService.getFlatAccList(reqParam).then($scope.getFlatAccountListListSuccess, $scope.getFlatAccountListFailure)

  # connect bank
  $scope.connectBank = ()->
    userServices.connectBankAc($rootScope.selectedCompany.uniqueName).then($scope.connectBankSuccess, $scope.connectBankFailure)

  $scope.connectBankSuccess = (res) ->
    $scope.cntBnkData = res.body
    url = res.body.token_URL + '?token=' + res.body.token
    $scope.connectUrl = url
    $uibModal.open(
      templateUrl: '/public/webapp/views/connectBankModal.html',
      size: "md",
      backdrop: 'static',
      scope: $scope
    )

  $scope.connectBankFailure = (res) ->
    toastr.error(res.data.message, "Error")

  $scope.refreshToken = (account) ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      accountId: account.accountId
    }
    userServices.refreshAccount(reqParam).then($scope.refreshTokenSuccess, $scope.refreshTokenFailure )

  $scope.refreshTokenSuccess = (res) ->
    console.log res
    url = res.body.connectUrl
    $scope.connectUrl = url
    $uibModal.open(
      templateUrl: '/public/webapp/views/refreshBankAccountsModal.html',
      size: "md",
      backdrop: 'static',
      scope: $scope
    )

  $scope.refreshTokenFailure = (res) ->
    toastr.error(res.data.message, "Error")
  

#init angular app
giddh.webApp.controller 'userController', userController