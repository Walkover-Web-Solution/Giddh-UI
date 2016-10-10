'use strict'

settingsController = ($scope, $rootScope, $timeout, $uibModal, $log, companyServices, currencyService, locationService, modalService, localStorageService, toastr, userServices, Upload, DAServices, $state, permissionService, $stateParams, couponServices, groupService, accountService, $filter, $http, $location) ->
  $rootScope.cmpViewShow = true
  $scope.showSubMenus = false
  $scope.webhooks = [{url:"https://www.giddh.com", days:-2}, {url:"https://www.giddh.com", days:2}, {url:"", days:""}]
  $scope.autoPayOption = [{}]
  $scope.tabs = [
    {title:'Invoice/Proforma', active: true}
    {title:'Taxes', active: false}
    {title:'Email/SMS settings', active: false}
    {title: 'Linked Accounts', active:false}
  ]

  # manage tax variables
  $scope.taxTypes = [
    "MONTHLY"
    "YEARLY"
    "QUATERLY"
    "HALFYEARLY"
  ]
  $scope.monthDays = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
  $scope.createTaxData = {
    duration: "MONTHLY"
    taxFileDate: 1
  }

  $scope.today = new Date()
  $scope.fromTaxDate = {date: new Date()}
  $scope.format = "dd-MM-yyyy"
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }
  #################### linked banks integration ####################
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

  # get taxes
  $scope.getTax=()->
    $scope.taxList = []
    if $rootScope.canUpdate and $rootScope.canDelete
      companyServices.getTax($rootScope.selectedCompany.uniqueName).then($scope.getTaxSuccess, $scope.getTaxFailure)

  $scope.getTaxSuccess = (res) ->
    if res.body.length is 0
      $scope.taxList = []
    else
      _.each res.body, (obj) ->
        obj.isEditable = false
        if obj.account == null
          obj.account = {}
          obj.account.uniqueName = ''
        obj.hasLinkedAcc = _.find($scope.fltAccntListPaginated, (acc)->
          return acc.uniqueName == obj.account.uniqueName
        )
        $scope.taxList.push(obj)

  $scope.getTaxFailure = (res) ->
    $scope.noTaxes = true


  $scope.clearTaxFields = () ->
    $scope.createTaxData = {
      duration: "MONTHLY"
      taxFileDate: 1
    }


  $scope.addNewTax = (newTax) ->
    newTax = {
      updateEntries: false
      taxNumber:newTax.taxNumber,
      name: newTax.name,
      account:
        uniqueName: newTax.account.uniqueName
      duration:newTax.duration,
      taxFileDate:1,
      taxDetail:[
        {
          date : $filter('date')($scope.fromTaxDate.date, 'dd-MM-yyyy'),
          value: newTax.value
        }
      ]
    }
    companyServices.addTax($rootScope.selectedCompany.uniqueName, newTax).then($scope.addNewTaxSuccess, $scope.addNewTaxFailure)

  $scope.addNewTaxSuccess = (res) ->
# reset tax data
    $scope.createTaxData = {
      duration: "MONTHLY"
      taxFileDate: 1
    }
    $scope.fromTaxDate = {date: new Date()}
    $scope.getTax()
    toastr.success("Tax added successfully.", "Success")


  $scope.addNewTaxFailure = (res) ->
    toastr.error(res.data.message)

  #delete tax
  $scope.deleteTaxconfirmation = (data) ->
    modalService.openConfirmModal(
      title: 'Delete Tax'
      body: 'Are you sure you want to delete? ' + data.name + ' ?',
      ok: 'Yes',
      cancel: 'No').then(->
      reqParam = {
        uniqueName: $rootScope.selectedCompany.uniqueName
        taxUniqueName: data.uniqueName
      }
      companyServices.deleteTax(reqParam).then($scope.deleteTaxSuccess, $scope.deleteTaxFailure)
    )

  $scope.deleteTaxSuccess = (res) ->
    $scope.getTax()
    toastr.success(res.status, res.body)

  $scope.deleteTaxFailure = (res) ->
    toastr.error(res.status, res.data.message)

  #edit tax
  $scope.editTax = (item) ->
    item.isEditable = true
    $scope.taxEditData = item
    $scope.taxDetail_1 = angular.copy(item.taxDetail)
    _.each $scope.taxList, (tax) ->
      if tax.uniqueName != item.uniqueName
        tax.isEditable = false

  $scope.updateTax = (item) ->
    newTax = {
      'taxNumber': item.taxNumber,
      'name': item.name,
      'account':{
        'uniqueName': item.account.uniqueName
      },
      'duration':item.duration,
      'taxFileDate': item.taxFileDate,
      'taxDetail': item.taxDetail
    }
    item.hasLinkedAcc = true
    $scope.taxValueUpdated = false

    _.each $scope.taxDetail_1, (tax_1, idx) ->
      _.each item.taxDetail, (tax, index) ->
        if tax.taxValue.toString() != tax_1.taxValue.toString() && idx == index
          $scope.taxValueUpdated = true

    _.each newTax.taxDetail, (detail) ->
      detail.value = detail.taxValue.toString()

    reqParam = {
      uniqueName: $rootScope.selectedCompany.uniqueName
      taxUniqueName: $scope.taxEditData.uniqueName
      updateEntries: false
    }

    if $scope.taxValueUpdated
# modalService.openConfirmModal(
#   title: 'Update Tax Value',
#   body: 'One or more tax values have changed, would you like to update tax amount in all entries as per new value(s) ?',
#   showConfirmBox: true,
#   ok: 'Yes',
#   cancel: 'No'
# ).then(->
#   console.log this
#   reqParam.updateEntries = true
#   companyServices.editTax(reqParam, newTax).then($scope.updateTaxSuccess, $scope.updateTaxFailure)
# )
      $scope.updateEntriesWithChangedTaxValue = false
      $scope.taxObj = {
        reqParam : reqParam
        newTax : newTax
      }
      $scope.updateTax.modalInstance = $uibModal.open(
        templateUrl: $rootScope.prefixThis+'/public/webapp/Globals/modals/update-tax.html'
        size: "md"
        backdrop: 'static'
        scope: $scope
      )
    else
      companyServices.editTax(reqParam, newTax).then($scope.updateTaxSuccess, $scope.updateTaxFailure)
      item.isEditable = false

  $scope.updateTaxAndEntries = (val) ->
    reqParam = $scope.taxObj.reqParam
    newTax = $scope.taxObj.newTax
    reqParam.updateEntries = val
    companyServices.editTax(reqParam, newTax).then($scope.updateTaxSuccess, $scope.updateTaxFailure)


  $scope.updateTaxSuccess = (res) ->
    $scope.taxEditData.isEditable = false
    $scope.getTax()
    toastr.success(res.status, "Tax updated successfully.")
    $scope.updateTax.modalInstance.close()

  $scope.updateTaxFailure = (res) ->
    $scope.getTax()
    toastr.error(res.data.message)

  # edit tax slab
  $scope.addNewSlabBefore = (tax, index)->
    tax.taxValue = parseInt(tax.taxValue)
    newTax = {
      taxValue: tax.taxValue
      date: $filter('date')($scope.today, 'dd-MM-yyyy')
    }
    $scope.taxEditData.taxDetail.splice(index, 0, newTax)

  $scope.addNewSlabAfter = (tax, index) ->
    tax.taxValue = parseInt(tax.taxValue)
    newTax = {
      taxValue: tax.taxValue
      date: $filter('date')($scope.today, 'dd-MM-yyyy')
    }
    $scope.taxEditData.taxDetail.splice(index+1, 0, newTax)

  # remove slab
  $scope.removeSlab = (tax, index) ->
    modalService.openConfirmModal(
      title: 'Remove Tax',
      body: 'Are you sure you want to delete?',
      ok: 'Yes',
      cancel: 'No'
    ).then(->
      $scope.taxEditData.taxDetail.splice(index, 1)
    )

  $scope.cancelUpdateTax = () ->
    $scope.taxEditData.taxDetail = $scope.preSpliceTaxDetail
    $scope.modalInstance.close()

  #------------bulk sms and email---------#
  $scope.msg91 = {
    authKey: ''
    senderId: ''
  }
  $scope.sGrid = {
    authKey: ''
    subject: ''
  }

  $scope.getKeys = () ->
    companyServices.getSmsKey($rootScope.selectedCompany.uniqueName).then($scope.getSmsKeySuccess, $scope.getSmsKeyFailure)
    companyServices.getEmailKey($rootScope.selectedCompany.uniqueName).then($scope.getEmailKeySuccess, $scope.getEmailKeyFailure)

  $scope.getSmsKeySuccess = (res) ->
    $scope.msg91.authKey = res.body.authKey
    $scope.msg91.senderId = res.body.senderId

  $scope.getSmsKeyFailure = (res) ->
    $scope.msg91.authKey = ''
    $scope.msg91.senderId = ''

  $scope.getEmailKeySuccess = (res) ->
    $scope.sGrid.authKey = res.body.authKey
    $scope.sGrid.subject = res.body.subject

  $scope.getEmailKeyFailure = (res) ->
    $scope.sGrid.authKey = ''
    $scope.sGrid.subject = ''

  $scope.saveMsg91 = () ->
    data = {
      "authKey":$scope.msg91.authKey
      "senderId": $scope.msg91.senderId
    }
    companyUniqueName = $rootScope.selectedCompany.uniqueName
    if $scope.msg91.authKey.length > 0 && $scope.msg91.senderId.length > 0
      companyServices.saveSmsKey(companyUniqueName, data).then($scope.saveMsg91Success, $scope.saveMsg91Failure)

  $scope.saveMsg91Success = (res) ->
    toastr.success(res.body)

  $scope.saveMsg91Failure = (res) ->
    toastr.error(res.data.message)

  $scope.saveSendGrid = () ->
    data = {
      "authKey":$scope.sGrid.authKey
      "subject": $scope.sGrid.subject
    }
    companyUniqueName = $rootScope.selectedCompany.uniqueName
    if $scope.sGrid.authKey.length > 0 && $scope.sGrid.subject.length > 0
      companyServices.saveEmailKey(companyUniqueName, data).then($scope.saveSendGridSuccess, $scope.saveSendGridFailure)

  $scope.saveSendGridSuccess = (res) ->
    toastr.success(res.body)

  $scope.saveSendGridFailure = (res) ->
    toastr.error(res.data.message)

  #  Linked bank methods
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
        templateUrl: $rootScope.prefixThis+'/public/webapp/Globals/modals/yodleeMfaModal.html'
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
    $scope.AccountsListToLink = $rootScope.fltAccntListPaginated
    linkedAccounts = []
    _.each $scope.banks.linked, (bank) ->
      if bank.accounts.length > 0
        _.each bank.accounts, (acc) ->
          linkedAccounts.push(acc)
      _.each linkedAccounts, (lAcc) ->
        if lAcc.linkedAccount != null
          linked = {}
          linked.uniqueName = lAcc.linkedAccount.uniqueName
          $scope.AccountsListToLink = _.without($scope.AccountsListToLink, _.findWhere($scope.AccountsListToLink, linked))

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
    $timeout ( ->
      $scope.banks.toLink = ''
    ) ,500


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
    $scope.banks.toDelete = card.loginId
    modalService.openConfirmModal(
      title: 'Delete Account',
      body: 'Are you sure you want to delete ' + card.name + ' ?' + '\n' + 'All accounts linked with the same bank will be deleted.',
      ok: 'Yes',
      cancel: 'No').then($scope.deleteAddedBankAccountConfirmed)


  $scope.deleteAddedBankAccountConfirmed = () ->
    reqParam = {
      cUnq : $rootScope.selectedCompany.uniqueName
      loginId: $scope.banks.toDelete
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
    #    companyUniqueName =  {
    #      cUnq: $rootScope.selectedCompany.uniqueName
    #    }
    #    userServices.getAccounts(companyUniqueName).then($scope.getAccountsSuccess, $scope.getAccountsFailure)
    toastr.success('SuccessFully refreshed!')

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

  # connect bank
  $scope.connectBank = ()->
    userServices.connectBankAc($rootScope.selectedCompany.uniqueName).then($scope.connectBankSuccess, $scope.connectBankFailure)


  $scope.connectBankSuccess = (res) ->
    $scope.cntBnkData = res.body
    url = res.body.token_URL + '?token=' + res.body.token
    $scope.connectUrl = url
    modalInstance = $uibModal.open(
      templateUrl: $rootScope.prefixThis+'/public/webapp/Globals/modals/connectBankModal.html',
      size: "md",
      backdrop: 'static',
      scope: $scope,
      controller:'companyController'
    )

  $scope.connectBankFailure = (res) ->
    toastr.error(res.data.message, "Error")

  $scope.reconnectAccount = (account) ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      loginId: account.loginId
    }
    userServices.reconnectAccount(reqParam).then($scope.reconnectAccountSuccess,$scope.reconnectAccountFailure)

  $scope.reconnectAccountSuccess= (res) ->
    url = res.body.connectUrl
    $scope.connectUrl = url
    modalInstance = $uibModal.open(
      templateUrl: $rootScope.prefixThis+'/public/webapp/Globals/modals/refreshBankAccountsModal.html',
      size: "md",
      backdrop: 'static',
      scope: $scope
    )
    modalInstance.result.then ((selectedItem) ->
      $scope.refreshAccounts()
      return
    ), ->
      $scope.refreshAccounts()
      return

  $scope.reconnectAccountFailure = (res) ->
    toastr.error(res.data.message, "Error")

  $scope.refreshToken = (account) ->
    if account.reconnect
      return
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      loginId: account.loginId
    }
    userServices.refreshAccount(reqParam).then($scope.refreshTokenSuccess, $scope.refreshTokenFailure )

  $scope.refreshTokenSuccess = (res) ->
    url = res.body.connectUrl
    $scope.connectUrl = url
    $uibModal.open(
      templateUrl: $rootScope.prefixThis+'/public/webapp/Globals/modals/refreshBankAccountsModal.html',
      size: "md",
      backdrop: 'static',
      scope: $scope
    )

  $scope.refreshTokenFailure = (res) ->
    toastr.error(res.data.message, "Error")

giddh.webApp.controller 'settingsController', settingsController