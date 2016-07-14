"use strict"
companyController = ($scope, $rootScope, $timeout, $uibModal, $log, companyServices, currencyService, locationService, modalService, localStorageService, toastr, userServices, Upload, DAServices, $state, permissionService, $stateParams, couponServices, groupService, accountService, $filter, $http) ->
  #make sure managecompanylist page not load
  $rootScope.mngCompDataFound = false
  #make sure manage company detail not load
  $rootScope.cmpViewShow = false
  $rootScope.selectedCompany = {}
  $scope.mHideBar = false
  $scope.dHideBar = false
  $scope.showUpdTbl = false
  $scope.compSetBtn = true
  $scope.compDataFound = false
  $scope.compTransData = {}
  $scope.showPayOptns = false
  $scope.isHaveCoupon = false
  $scope.afterConnectSuccess = false
  #contains company list
  $scope.companyList = []
  $scope.companyDetails = {}
  $scope.currencyList = []
  $scope.currencySelected = undefined
  $scope.shareRequest = {role: 'view_only', user: null}
  # userController methods
  $scope.payAlert = []
  $scope.wlt = {}
  $scope.coupRes = {}
  $scope.coupon = {}
  $scope.payStep2 = false
  $scope.payStep3 = false
  $scope.directPay = false
  $scope.wlt.status = false
  $scope.disableRazorPay = false
  $scope.discount = 0
  $scope.amount = 0
  $scope.noTaxes = false
  $scope.AccountsListToLink = []
  $scope.tabs = [
    {title:'Basic information', active: true}
    {title:'Permission', active: false}
    {title:'Tally XML upload', active: false}
    {title:'Payment details', active: false}
    {title:'Taxes', active: false}
    {title:'Email/SMS settings', active: false}
    {title:'Financial Year', active: false}
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

  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true
  

  #dialog for first time user
  $scope.openFirstTimeUserModal = () ->
    modalInstance = $uibModal.open(
      templateUrl: '/public/webapp/views/createCompanyModal.html',
      size: "sm",
      backdrop: 'static',
      scope: $scope
    )
    modalInstance.result.then($scope.onCompanyCreateModalCloseSuccess, $scope.onCompanyCreateModalCloseFailure)

  $scope.onCompanyCreateModalCloseSuccess = (data) ->
    cData = {}
    cData.name = data.name
    cData.city = data.city
    $scope.createCompany(cData)

  $scope.onCompanyCreateModalCloseFailure = () ->
    $scope.checkCmpCretedOrNot()
    modalService.openConfirmModal(
        title: 'LogOut',
        body: 'In order to be able to use Giddh, you must create a company. Are you sure you want to cancel and logout?',
        ok: 'Yes',
        cancel: 'No').then($scope.firstLogout)

  $scope.firstLogout = () ->
    $http.post('/logout').then ((res) ->
      # don't need to clear below
      # _userDetails, _currencyList
      localStorageService.clearAll()
      window.location = "/thanks"
    ), (res) ->


  #for make sure
  $scope.checkCmpCretedOrNot = ->
    if $scope.companyList.length <= 0
      $scope.openFirstTimeUserModal()

  #get only city for create company
  $scope.getOnlyCity = (val) ->
    locationService.searchOnlyCity(val).then($scope.getOnlyCitySuccess, $scope.getOnlyCityFailure)

  #get only city success
  $scope.getOnlyCitySuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "locality"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  #get only city failure
  $scope.getOnlyCityFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #creating company
  $scope.createCompany = (cdata) ->
    companyServices.create(cdata).then($scope.onCreateCompanySuccess, $scope.onCreateCompanyFailure)

  #create company success
  $scope.onCreateCompanySuccess = (res) ->
    toastr.success("Company create successfully", "Success")
    $rootScope.mngCompDataFound = true
    $scope.companyList.push(res.body)
    $state.reload()

  #create company failure
  $scope.onCreateCompanyFailure = (res) ->
    toastr.error(res.data.message, "Error")

  #Get company list
  $scope.getCompanyList = ()->
#    $rootScope.getCompanyList()
#    if _.isEmpty($rootScope.CompanyList)
#      $scope.openFirstTimeUserModal()
#    else
#      $scope.goToCompany($rootScope.selectedCompany,$rootScope.companyIndex,"")
   companyServices.getAll().then($scope.getCompanyListSuccess, $scope.getCompanyListFailure)

  #Get company list
  $scope.getCompanyListSuccess = (res) ->
    $scope.companyList = _.sortBy(res.body, 'shared')
    $rootScope.CompanyList = $scope.companyList
    if _.isEmpty($scope.companyList)
      $scope.openFirstTimeUserModal()
    else
      $rootScope.mngCompDataFound = true
      cdt = localStorageService.get("_selectedCompany")
      if not _.isNull(cdt) && not _.isEmpty(cdt) && not _.isUndefined(cdt)
        cdt = _.findWhere($scope.companyList, {uniqueName: cdt.uniqueName})
        if _.isUndefined(cdt)
          $rootScope.setCompany($scope.companyList[0])
          $scope.goToCompany($scope.companyList[0], 0, "CHANGED")
        else
          $rootScope.setCompany(cdt)
          $scope.goToCompany(cdt, cdt.index, "NOCHANGED")
      else
        $rootScope.setCompany($scope.companyList[0])
        $scope.goToCompany($scope.companyList[0], 0, "CHANGED")
      $rootScope.$emit('companyLoaded')

  #get company list failure
  $scope.getCompanyListFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  $scope.getUserDetails = ->
    if _.isUndefined($rootScope.basicInfo.uniqueName)
      $rootScope.basicInfo = localStorageService.get("_userDetails")
    userServices.get($rootScope.basicInfo.uniqueName).then($scope.getUserDetailSuccess, $scope.getUserDetailFailure)

  #Get user details
  $scope.getUserDetailSuccess = (res) ->
    localStorageService.set("_userDetails", res.body)
    $rootScope.basicInfo = res.body

  #get company list failure
  $scope.getUserDetailFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  #delete company
  $scope.deleteCompany = (uniqueName, index, name) ->
    modalService.openConfirmModal(
      title: 'Are you sure you want to delete? ' + name,
      ok: 'Yes',
      cancel: 'No'
    ).then ->
      companyServices.delete(uniqueName).then($scope.delCompanySuccess, $scope.delCompanyFailure)

  #delete company success
  $scope.delCompanySuccess = (res) ->
    $rootScope.selectedCompany = {}
    localStorageService.remove("_selectedCompany")
    toastr.success("Company deleted successfully", "Success")
    $scope.getCompanyList()    

  #delete company failure
  $scope.delCompanyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.goToCompanyCheck = (data, index) ->
    # set financial year
    localStorageService.set('activeFY', data.activeFinancialYear)
    $rootScope.setActiveFinancialYear(data.activeFinancialYear)
    activeYear = {} 
    activeYear.start = moment(data.activeFinancialYear.financialYearStarts,"DD/MM/YYYY").year()
    activeYear.ends = moment(data.activeFinancialYear.financialYearEnds,"DD/MM/YYYY").year()
    if activeYear.start == activeYear.ends then (activeYear.year = activeYear.start) else (activeYear.year = activeYear.start + '-' + activeYear.ends)
    $rootScope.currentFinancialYear = activeYear.year
    ########
    
    $rootScope.$emit('callCheckPermissions', data)
    $rootScope.canViewSpecificItems = false
    if data.role.uniqueName is 'shared'
      $rootScope.canManageComp = false
      if data.sharedEntity is 'groups'
        $rootScope.canViewSpecificItems = true
      localStorageService.set("_selectedCompany", data)
      $rootScope.selectedCompany = data
      $rootScope.$emit('companyChanged')
      $state.go('company.content.ledgerContent')
    else
      $rootScope.canManageComp = true
      $scope.goToCompany(data, index, "CHANGED")
    $rootScope.$emit('reloadAccounts')
    $scope.tabs[0].active = true

  #making a detail company view
  $scope.goToCompany = (data, index, type) ->
    $rootScope.$emit('callCheckPermissions', data)
    $scope.compDataFound = false
    $scope.showUpdTbl = false
    $scope.mFiles = []
    $scope.dFiles = []
    $scope.mErrFiles = []
    $scope.dErrFiles = []
    $rootScope.cmpViewShow = true
    $scope.selectedCmpLi = index
    $rootScope.setCompany(data)
    #angular.extend($rootScope.selectedCompany, data)
    $rootScope.selectedCompany.index = index
    contactnumber = $rootScope.selectedCompany.contactNo
    if not _.isNull(contactnumber) and not _.isEmpty(contactnumber) and not _.isUndefined(contactnumber) and contactnumber.match("-")
      SplitNumber = contactnumber.split('-')
      $rootScope.selectedCompany.mobileNo = SplitNumber[1]
      $rootScope.selectedCompany.cCode = SplitNumber[0]

    #localStorageService.set("_selectedCompany", $rootScope.selectedCompany)

    if $rootScope.canManageCompany
      $scope.getSharedUserList($rootScope.selectedCompany.uniqueName)
    if type is 'CHANGED'
      $rootScope.$emit('companyChanged')
    else
      console.info "Same Company loaded"

  #update company details
  $scope.updateCompanyInfo = (data) ->
    if _.isObject(data.cCode)
      data.contactNo = data.cCode.value + "-" + data.mobileNo
    else
      data.contactNo = data.cCode + "-" + data.mobileNo
    abc = _.omit(data, "financialYears")
    companyServices.update(abc).then($scope.updtCompanySuccess, $scope.updtCompanyFailure)

  #update company success
  $scope.updtCompanySuccess = (res)->
    localStorageService.set("_selectedCompany", res.body)
    toastr.success("Company updated successfully", "Success")
    $scope.getCompanyList()

  #update company failure
  $scope.updtCompanyFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  #to inject form again on scope do not remove very imp function
  $scope.setFormScope = (scope) ->
    @formScope = scope

  $scope.getCountry = (val) ->
    locationService.searchCountry(val).then($scope.onGetCountrySuccess, $scope.onGetCountryFailure)

  $scope.onGetCountrySuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "country"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  $scope.onGetCountryFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getState = (val) ->
    locationService.searchState(val, $rootScope.selectedCompany.country).then($scope.onGetStateSuccess,
      $scope.onGetStateFailure)

  $scope.onGetStateSuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "administrative_area_level_1"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  $scope.onGetStateFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getCity = (val) ->
    locationService.searchCity(val, $rootScope.selectedCompany.state).then($scope.onGetCitySuccess,
      $scope.onGetCityFailure)

  $scope.onGetCitySuccess = (data) ->
    filterThis = data.results.filter (i) -> i.types[0] is "locality"
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  $scope.onGetCityFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getCurrencyList = ->
    currencyListt = localStorageService.get("_currencyList")
    if not _.isNull(currencyListt) && not _.isEmpty(currencyListt) && not _.isUndefined(currencyListt)
      $scope.currencyList = currencyListt
    else
      currencyService.getList($scope.getCurrencyListSuccess, $scope.getCurrencyListFailure)

  $scope.getCurrencyListFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  #Get company list
  $scope.getCurrencyListSuccess = (res) ->
    $scope.currencyList = _.map(res.body, (item) ->
      item.code
    )
    localStorageService.set("_currencyList", $scope.currencyList)

  #update user role
  $scope.updateUserRole = (role, userEmail) ->
    sData = {role: role, user: userEmail}
    companyServices.share($rootScope.selectedCompany.uniqueName, sData).then($scope.onShareCompanySuccess,
      $scope.onShareCompanyFailure)

  #share and manage permission in manage company
  $scope.shareCompanyWithUser = () ->
    if _.isEqual($scope.shareRequest.user, $rootScope.basicInfo.email)
      toastr.error("You cannot add yourself.", "Error")
      return
    companyServices.share($rootScope.selectedCompany.uniqueName, $scope.shareRequest).then($scope.onShareCompanySuccess,
      $scope.onShareCompanyFailure)

  $scope.onShareCompanySuccess = (res) ->
    $scope.shareRequest = {role: 'view_only', user: null}
    toastr.success(res.body, res.status)
    $scope.getSharedUserList($rootScope.selectedCompany.uniqueName)


  $scope.onShareCompanyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #get shared user list
  $scope.getSharedUserList = (uniqueName) ->
    companyServices.shredList(uniqueName).then($scope.getSharedUserListSuccess, $scope.getSharedUserListFailure)

  $scope.getSharedUserListSuccess = (res) ->
    $scope.sharedUsersList = res.body

  $scope.getSharedUserListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #delete shared user
  $scope.unSharedUser = (uNqame, id) ->
    data = {user: uNqame}
    companyServices.unSharedComp($rootScope.selectedCompany.uniqueName, data).then($scope.unSharedCompSuccess,
      $scope.unSharedCompFailure)

  $scope.unSharedCompSuccess = (res) ->
    toastr.success("Company unshared successfully", "Success")
    $scope.getSharedUserList($rootScope.selectedCompany.uniqueName)

  $scope.unSharedCompFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.exceptOwnEmail = (email) ->
    $rootScope.basicInfo.email isnt email.userEmail

  $scope.getUploadsList = ->
    companyServices.getUploadsList($rootScope.selectedCompany.uniqueName).then($scope.getUploadsListSuccess, $scope.getUploadsListFailure)

  $scope.getUploadsListSuccess = (res) ->
    if res.body.length > 0
      $scope.showUpdTbl = true
      $scope.updlist = res.body
    else
      toastr.info("No records found", "Info")

  $scope.getUploadsListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  # upload by progressbar
  $scope.uploadMasterFiles = (files, errFiles) ->
    $scope.mHideBar = false
    $scope.mFiles = files
    $scope.mErrFiles = errFiles
    angular.forEach files, (file) ->
      file.upload = Upload.upload(
        url: '/upload/' + $rootScope.selectedCompany.uniqueName + '/master'
        file: file
      )
      file.upload.then ((res) ->
        $timeout ->
          $scope.mHideBar = true
          file.result = res.data
          toastr.success(res.data.body.message, res.data.status)
      ), ((res) ->
        console.log res, "error"
      ), (evt) ->
        file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))

  # upload by progressbar
  $scope.uploadDaybookFiles = (files, errFiles) ->
    $scope.dHideBar = false
    $scope.dFiles = files
    $scope.dErrFiles = errFiles
    angular.forEach files, (file) ->
    angular.forEach files, (file) ->
      file.upload = Upload.upload(
        url: '/upload/' + $rootScope.selectedCompany.uniqueName + '/daybook'
        file: file
      )
      file.upload.then ((res) ->
        $timeout ->
          $scope.dHideBar = true
          file.result = res.data
          toastr.success(res.data.body.message, res.data.status)
      ), ((res) ->
        console.log res, "error"
      ), (evt) ->
        file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))

  # payment details related func
  $scope.primPayeeChange = (a, b) ->
    $scope.compSetBtn = false

  $scope.$watch('selectedCompany.companySubscription.autoDeduct', (newVal,oldVal) ->
    if !_.isUndefined(oldVal)
      if newVal isnt oldVal
        $scope.compSetBtn = false
  )
  $scope.pageChangedComp = (data) ->
    if data.startPage > data.totalPages
      $scope.nothingToLoadComp = true
      toastr.info("Nothing to load, all transactions are loaded", "Info")
      return
    if data.startPage is 1
      data.startPage = 2
    obj = {
      name: $rootScope.selectedCompany.uniqueName
      num: data.startPage
    }
    companyServices.getCompTrans(obj).then($scope.pageChangedCompSuccess, $scope.pageChangedCompFailure)

  $scope.pageChangedCompSuccess =(res)->
    $scope.compTransData.paymentDetail = $scope.compTransData.paymentDetail.concat(res.body.paymentDetail)
    $scope.compTransData.startPage += 1 

  $scope.pageChangedCompFailure =(res)->
    toastr.error(res.data.message, res.data.status)

  $scope.getCompanyTransactions = ()->
    obj = {
      name: $rootScope.selectedCompany.uniqueName
      num: 1
    }
    companyServices.getCompTrans(obj).then($scope.getCompanyTransactionsSuccess, $scope.getCompanyTransactionsFailure)

  $scope.getCompanyTransactionsSuccess = (res) ->
    angular.copy(res.body, $scope.compTransData)
    $scope.compTransData.startPage = 1
    $scope.nothingToLoadComp = false
    if res.body.paymentDetail.length > 0
      $scope.compDataFound = true
    else
      $scope.compDataFound = false
      toastr.info("Don\'t have any transactions yet.", "Info")

  $scope.getCompanyTransactionsFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.updateCompSubs = (resObj) ->
    data = {
      uniqueName: $rootScope.selectedCompany.uniqueName
      autoDeduct: resObj.autoDeduct
      primaryBiller: resObj.primaryBiller
    }
    companyServices.updtCompSubs(data).then($scope.updateCompSubsSuccess, $scope.updateCompSubsFailure)

  $scope.updateCompSubsSuccess = (res) ->
    $scope.selectedCompany.companySubscription = res.body
    toastr.success("Updates successfully", res.status)

  $scope.updateCompSubsFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getWltBal=()->
    userServices.getWltBal($rootScope.basicInfo.uniqueName).then($scope.getWltBalSuccess, $scope.getWltBalFailure)

  $scope.getWltBalSuccess = (res) ->
    $scope.disableRazorPay = false
    avlB = Number(res.body.availableCredit)
    invB = Number($rootScope.selectedCompany.companySubscription.billAmount)
    if avlB >= invB
      $scope.showPayOptns = false
      $scope.deductSubsViaWallet(invB)
    else if avlB > 0 and avlB < invB
      $scope.wlt.Amnt = Math.abs(invB - avlB)
      $scope.showPayOptns = true
    else
      $scope.showPayOptns = true
      $scope.wlt.Amnt = invB

  $scope.getWltBalFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.deductSubsViaWallet = (num) ->
    obj = {
      uniqueName: $rootScope.selectedCompany.uniqueName
      billAmount: num
    }
    companyServices.payBillViaWallet(obj).then($scope.subsViaWltSuccess, $scope.subsWltFailure)

  $scope.subsViaWltSuccess = (res) ->
    $rootScope.basicInfo.availableCredit -= res.body.amountPayed
    $rootScope.selectedCompany.companySubscription.paymentDue = false
    $rootScope.selectedCompany.companySubscription.billAmount = 0
    $scope.showPayOptns = false
    toastr.success("Payment completed", "Success")
    $scope.resetSteps()

  $scope.subsWltFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.addBalViaDirectCoupon = () ->
    obj = {
      uUname: $rootScope.basicInfo.uniqueName
      paymentId: null
      amount: Number($scope.wlt.Amnt)
      discount: Number($scope.discount)
      couponCode: $scope.coupRes.couponCode
    }
    userServices.addBalInWallet(obj).then($scope.addBalRzrSuccess, $scope.addBalRzrFailure)

  $scope.addBalViaRazor = (razorObj) ->
    obj = {
      uUname: $rootScope.basicInfo.uniqueName
      paymentId: razorObj.razorpay_payment_id
      amount: Number($scope.wlt.Amnt)
      discount: Number($scope.discount)
    }
    if _.isEmpty($scope.coupRes)
      obj.couponCode = null
    else
      if $scope.coupRes.type is 'balance_add'
        obj.couponCode = null
        obj.amount= Number($scope.amount)
        $scope.coupRes.extra = true
      else  
        obj.couponCode = $scope.coupRes.couponCode

    userServices.addBalInWallet(obj).then($scope.addBalRzrSuccess, $scope.addBalRzrFailure)

  $scope.addBalRzrSuccess = (res) ->
    if $scope.isHaveCoupon and !_.isEmpty($scope.coupRes)
      if $scope.coupRes.type is 'balance_add' and $scope.coupRes.extra
        $rootScope.basicInfo.availableCredit += Number($scope.amount)
      else if $scope.coupRes.type is 'balance_add'
        $rootScope.basicInfo.availableCredit += Number($scope.coupRes.maxAmount)
      else
        $rootScope.basicInfo.availableCredit += Number($scope.amount)
    else
      $rootScope.basicInfo.availableCredit += Number($scope.wlt.Amnt)
    # end
    if $scope.wlt.status
      $scope.directPay = false
      $scope.disableRazorPay = false
      $scope.showPayOptns = false
      $scope.resetSteps()
      toastr.success(res.body, res.status)
    else
      if $rootScope.basicInfo.availableCredit >= $rootScope.selectedCompany.companySubscription.billAmount
        $scope.deductSubsViaWallet(Number($rootScope.selectedCompany.companySubscription.billAmount))
      else
        $scope.amount -= Number($scope.coupRes.maxAmount)
        $scope.directPay = false
        $scope.disableRazorPay = false
        $scope.payAlert.push({msg: "Coupon is redeemed. But for complete subscription, you have to add Rs. "+$scope.amount+ " more in your wallet."})
    
  $scope.addBalRzrFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
    $scope.directPay = true
    $scope.showPayOptns = false
    $scope.resetSteps()

  # child functions here for userController
  # add money in wallet
  $scope.addMoneyInWallet = () ->
    if Number($scope.wlt.Amnt) < 100
      $scope.wlt = angular.copy({})
      toastr.warning("You cannot make payment", "Warning")
    else
      $scope.payStep2 = true
      $scope.wlt.status = true

  # redeem coupon
  $scope.redeemCoupon = (code) ->
    couponServices.couponDetail(code).then($scope.redeemCouponSuccess, $scope.redeemCouponFailure)

  $scope.removeDotFromString = (str) ->
    return Math.floor(Number(str))
# test cases done insomuch
  $scope.redeemCouponSuccess = (res) ->
    $scope.payAlert = []
    $scope.discount = 0
    $scope.coupRes = res.body
    toastr.success("Hurray your coupon code is redeemed", res.status)
    $scope.payAlert.push({type: 'success', msg: "Coupon code is redeemed. You can get a max discount of Rs. "+$scope.coupRes.maxAmount})
    $scope.amount = $scope.removeDotFromString($scope.wlt.Amnt)
    switch res.body.type
      when 'balance_add'
        $scope.directPay = true
        $scope.disableRazorPay = true
        $scope.addBalViaDirectCoupon()
      when 'cashback'
        $scope.checkDiffAndAlert('cashback')
      when 'cashback_discount'
        $scope.discount = 0
        $scope.cbDiscount = $scope.calCulateDiscount()
        $scope.checkDiffAndAlert('cashback_discount')
      when 'discount'
        $scope.discount = $scope.calCulateDiscount()
        $scope.checkDiffAndAlert('discount')
      when 'discount_amount'
        $scope.discount =  $scope.coupRes.maxAmount
        $scope.checkDiffAndAlert('discount_amount')
      else
        toastr.warning("Something went wrong", "Warning")
    
  
  $scope.calCulateDiscount = () ->
    val = Math.floor($scope.coupRes.value * $scope.amount/100)
    if val > $scope.coupRes.maxAmount
      return Number(Math.floor($scope.coupRes.maxAmount))
    else
      return Number(val)

      
  $scope.checkDiffAndAlert = (type)->
    $scope.directPay = false
    switch type
      when 'cashback_discount'
        $scope.disableRazorPay = false
        $scope.payAlert.push({msg: "Your cashback amount will be credited in your account withing 48 hours after payment has been done. Your will get a refund of Rs. "+$scope.cbDiscount})
      when 'cashback'
        if $scope.amount < $scope.coupRes.value
          $scope.disableRazorPay = true
          $scope.payAlert.push({msg: "Your coupon is redeemed but to avail coupon, You need to make a payment of Rs. "+$scope.coupRes.value})
        else
          $scope.disableRazorPay = false
          $scope.payAlert.push({type: 'success', msg: "Your cashback amount will be credited in your account withing 48 hours after payment has been done. Your will get a refund of Rs. "+$scope.coupRes.value})
      
      when 'discount'
        diff = $scope.amount-$scope.discount
        if diff < 100
          $scope.disableRazorPay = true
          $scope.payAlert.push({msg: "After discount amount cannot be less than 100 Rs. To avail coupon you have to add more money. Currently payable amount is Rs. "+diff})
        else
          $scope.disableRazorPay = false
          $scope.payAlert.push({type: 'success', msg: "Hurray you have availed a discount of Rs. "+$scope.discount+ ". Now payable amount is Rs. "+diff})
      when 'discount_amount'
        diff = $scope.amount-$scope.discount
        if diff < 100
          $scope.disableRazorPay = true
          $scope.payAlert.push({msg: "After discount amount cannot be less than 100 Rs. To avail coupon you have to add more money. Currently payable amount is Rs. "+diff})
        else if $scope.amount < $scope.coupRes.value
          $scope.disableRazorPay = true
          $scope.payAlert.push({msg: "Your coupon is redeemed but to avail coupon, You need to make a payment of Rs. "+$scope.coupRes.value})
        else
          $scope.disableRazorPay = false
          $scope.payAlert.push({type: 'success', msg: "Hurray you have availed a discount of Rs. "+$scope.discount+ ". Now payable amount is Rs. "+diff})
      
      

  $scope.redeemCouponFailure = (res) ->
    $scope.disableRazorPay = false
    $scope.payAlert = []
    $scope.discount = 0
    $scope.amount = $scope.removeDotFromString($scope.wlt.Amnt)
    $scope.coupRes = {}
    toastr.error(res.data.message, res.data.status)
    $scope.payAlert.push({msg: res.data.message})

  # remove alert
  $scope.closeAlert = (index) ->
    $scope.payAlert.splice(index, 1)

  # reset steps
  $scope.resetSteps = () ->
    $scope.showPayOptns = false
    $scope.isHaveCoupon = false
    $scope.payAlert = []
    $scope.wlt = angular.copy({})
    $scope.coupon = angular.copy({})
    $scope.wlt.status = false
    $scope.coupRes = {}
    $scope.payStep2 = false
    $scope.payStep3 = false
    $scope.disableRazorPay = false

  $scope.resetDiscount = (status) ->
    $scope.isHaveCoupon = status
    if !$scope.isHaveCoupon
      $scope.payAlert = []
      $scope.coupon = angular.copy({})
      $scope.disableRazorPay = false

  # upload issue fix
  $scope.openFixUploadIssues = (data) ->
    $scope.fixUploadData = {}
    $scope.fixUploadData = angular.copy(data)
    if data.isGroupConflict
      $scope.fixUploadData.groupConflicts = _.reject($scope.fixUploadData.groupConflicts, (grpC) ->
          _.some($scope.flattenGroupList, (grp) ->
            grp.uniqueName is grpC.uniqueName)
      )
    if data.isAccountConflict
      $scope.fixUploadData.accountConflicts = _.reject($scope.fixUploadData.accountConflicts, (acObj) ->
          _.some($scope.fltAccntList, (ac) ->
            ac.uniqueName is acObj.uniqueName || ac.mergedAccounts.indexOf(acObj.uniqueName) isnt -1
          ) 
      )
    $scope.modal = {}
    $scope.modal.modalInstance = $uibModal.open(
      templateUrl: '/public/webapp/views/fixUploadIssueModal.html',
      size: "lg",
      backdrop: 'static',
      scope: $scope
    )
    

  # omit if group already exist
  $scope.ifGroupAlreadyExist =(group) ->
    _.some($scope.flattenGroupList, (grp) ->
      grp.uniqueName == group.uniqueName)

  # move fix group
  $scope.fixMoveGroup = (group, togroup) ->
    if _.isObject(togroup)
      body = {
        "name": group.name,
        "uniqueName": group.uniqueName.toLowerCase(),
        "parentGroupUniqueName": togroup.uniqueName,
        "description": undefined
      }
      groupService.create($rootScope.selectedCompany.uniqueName, body).then($scope.fixMoveGroupSuccess, $scope.fixMoveGroupFailure)
    else
      toastr.warning("You can only select group from list", "Warning")

  $scope.fixMoveGroupSuccess = (res) ->
    toastr.success("Sub group added successfully", "Success")
    $scope.fixUploadData.groupConflicts = _.reject($scope.fixUploadData.groupConflicts, (grp) ->
      grp.uniqueName is res.body.uniqueName
    )
    $scope.getGroups()

  $scope.fixMoveGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  # account fix
  $scope.fixMoveAc = (ac, group) ->
    if _.isObject(group)
      unqNamesObj = {
        compUname: $rootScope.selectedCompany.uniqueName
        acntUname : ac.uniqueName
        selGrpUname: group.uniqueName
      }
      accountService.createAc(unqNamesObj, ac).then($scope.fixMoveAcSuccess, $scope.fixMoveAcFailure)
    else
      toastr.warning("You can only select account from list", "Warning")

  $scope.fixMoveAcSuccess = (res) ->
    toastr.success("Account created successfully", res.status)
    $scope.fixUploadData.accountConflicts = _.reject($scope.fixUploadData.accountConflicts, (acObj) ->
      acObj.uniqueName is res.body.uniqueName
    )
    $scope.getGroups()

  $scope.fixMoveAcFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.retryUpload = (data) ->
    $scope.waitXmlUpload = true
    companyServices.retryXml($rootScope.selectedCompany.uniqueName, data).then($scope.retryUploadSuccess, $scope.retryUploadFailure)

  $scope.retryUploadSuccess = (res) ->
    $scope.waitXmlUpload = false
    toastr.success(res.body.message, res.status)
    $scope.modal.modalInstance.close()
    $scope.getUploadsList()

  $scope.retryUploadFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
    $scope.modal.modalInstance.close()

  # manage taxes
  $scope.addNewAccountBytaxes = () ->
    $rootScope.$emit('callManageGroups')

  # get taxes
  $scope.getTax=()->
    $scope.taxList = []
    if $rootScope.canUpdate and $rootScope.canDelete
      companyServices.getTax($rootScope.selectedCompany.uniqueName).then($scope.getTaxSuccess, $scope.getTaxFailure)

  $scope.getTaxSuccess = (res) ->
    if res.body.length is 0
      $scope.taxList = []
      console.log "isEmpty array"
    else
      _.each res.body, (obj) ->
        obj.isEditable = false
        if obj.account == null
          obj.account = {}
          obj.account.uniqueName = ''
        obj.hasLinkedAcc = _.find($scope.fltAccntList, (acc)->
          return acc.uniqueName == obj.account.uniqueName
        ) 
        $scope.taxList.push(obj)

  $scope.getTaxFailure = (res) ->
    $scope.noTaxes = true

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
      modalService.openConfirmModal(
        title: 'Update Tax Value',
        body: 'One or more tax values have changed, would you like to update tax amount as per new value(s) ?',
        ok: 'Yes',
        cancel: 'No'
      ).then(->
        reqParam.updateEntries = true
        companyServices.editTax(reqParam, newTax).then($scope.updateTaxSuccess, $scope.updateTaxFailure)
      )
    else
      companyServices.editTax(reqParam, newTax).then($scope.updateTaxSuccess, $scope.updateTaxFailure)
      item.isEditable = false
      
  $scope.updateTaxSuccess = (res) ->
    $scope.taxEditData.isEditable = false
    $scope.getTax()
    toastr.success(res.status, "Tax updated successfully.")
    
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

  # # ---------------- Financial Year----------------#
  $scope.fy = {
    company: ''
    companyUniqueName: ''
    years: []
    selectedYear: ''
    periods: ['Jan-Dec', 'Apr-Mar']
    selectedPeriod: ''
    newFY: ''
    addedFYears: []
    currentFY: {}
  }
  $scope.months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  $scope.fyYears = []
  $scope.sFY = {}

  $scope.addfyYears = () ->
    $scope.fyYears = []
    year = moment().get('year') - 1
    while year >= 1970
      $scope.fyYears.push(year)
      year -= 1
    $scope.fyYears = _.difference($scope.fyYears, $scope.fy.addedFYears)

  $scope.setFYname = (years) ->
    _.each years, (yr) ->
      name = yr.uniqueName.split("-")
      yr.name = name[1] + '-' + name[2]

  $scope.getFY = () ->
    companyServices.getFY($rootScope.selectedCompany.uniqueName).then($scope.getFYSuccess, $scope.getFYFailure)

  $scope.getFYSuccess = (res) ->
    $scope.fy.company = res.body.companyName
    $scope.fy.companyUniqueName = res.body.companyUniqueName
    $scope.fy.years = res.body.financialYears
    _.each $scope.fy.years, (yr) ->
      addedYear = yr.financialYearStarts
      addedYearSplit = addedYear.split('-')
      cYear = addedYearSplit[2]
      $scope.fy.addedFYears.push(Number(cYear))
    $scope.setFYname($scope.fy.years)
    $scope.addfyYears()

  $scope.getFYFailure = (res) ->
    toastr.error(res.data.message)

  $scope.changeFyPeriod = (period) ->
    reqParam = {
      companyUniqueName:  $rootScope.selectedCompany.uniqueName
    }
    data = {
      "financialYearPeriod": period.toString()
    }
    companyServices.updateFY(reqParam, data).then($scope.changeFyPeriodSuccess, $scope.changeFyPeriodFailure)

  $scope.changeFyPeriodSuccess = (res) ->
    toastr.success('Period Updated Successfully')
    $scope.fy.years = res.body.financialYears
    $scope.setFYname($scope.fy.years)
    $scope.getcurrentFYfromResponse($rootScope.currentFinancialYear, $scope.fy.years)

  $scope.changeFyPeriodFailure = (res) ->
    toastr.error(res.data.message)

  $scope.getCurrentPeriod = () ->
    cmp = localStorageService.get('_selectedCompany')
    if !_.isNull(cmp)
      fromMonth = moment(cmp.activeFinancialYear.financialYearStarts,"DD/MM/YYYY").month()
      toMonth = moment(cmp.activeFinancialYear.financialYearEnds,"DD/MM/YYYY").month()
      selectedPeriod = $scope.months[fromMonth] + '-' + $scope.months[toMonth]
      if selectedPeriod == 'Apr-Mar'
        $scope.fy.selectedPeriod = $scope.fy.periods[1]
      else if selectedPeriod == 'Jan-Dec'
        $scope.fy.selectedPeriod = $scope.fy.periods[0]

  $scope.switchFY = (year) ->
    data = {
      "uniqueName":year.uniqueName
    }
    reqParam = {
      companyUniqueName:  $rootScope.selectedCompany.uniqueName
    }
    companyServices.switchFY(reqParam, data).then($scope.switchFYSuccess, $scope.switchFYFailure)

  $scope.switchFYSuccess = (res) ->
    toastr.success(res.status, 'Financial Year switched successfully.')
    $rootScope.setActiveFinancialYear(res.body)
    localStorageService.set('activeFY', res.body)

  $scope.switchFYFailure = (res) ->
    toastr.error(res.data.message)

  $scope.lockFY = (year) ->
    $scope.sFY = year
    data = {
      "uniqueName":year.uniqueName
      "lockAll":"true"
    }
    reqParam = {
      companyUniqueName:  $rootScope.selectedCompany.uniqueName
    }
    if year.isLocked
      companyServices.lockFY(reqParam, data).then($scope.lockFYSuccess, $scope.lockFYFailure)
    else
      companyServices.unlockFY(reqParam, data).then($scope.unlockFYSuccess, $scope.unlockFYFailure)

  $scope.lockFYSuccess = (res) ->
    toastr.success('Financial Year Locked Successfully.')
    $scope.fy.years = res.body.financialYears
    $scope.setFYname($scope.fy.years)

  $scope.lockFYFailure = (res) ->
    $scope.sFY.isLocked = false
    toastr.error(res.data.message)

  $scope.unlockFYSuccess = (res) ->
    toastr.success('Financial Year Unlocked Successfully.')
    $scope.fy.years = res.body.financialYears
    $scope.setFYname($scope.fy.years)

  $scope.unlockFYFailure = (res) ->
    $scope.sFY.isLocked = true
    toastr.error(res.data.message)

  $scope.addFY = (newFy) ->
    data = {
      "fromYear": newFy
    }
    reqParam = {
      companyUniqueName:  $rootScope.selectedCompany.uniqueName
    }
    companyServices.addFY(reqParam, data).then($scope.addFYSuccess, $scope.addFYFailure)

  $scope.addFYSuccess = (res) ->
    toastr.success('Financial Year created successfully.')
    $scope.getFY()
    $scope.fy.newFY = ''

  $scope.addFYFailure = (res) ->
    toastr.error(res.data.message)

  $scope.getcurrentFYfromResponse = (currentFinancialYear, response) ->
    cYear = {}
    cFY = ''
    if currentFinancialYear.length > 4
      f = currentFinancialYear.split('-')
      cFY = f[0]
    else
      cFY = currentFinancialYear
      
    _.each response,(yr) ->
      if yr.financialYearStarts.indexOf(cFY) != -1
        cYear = yr
    $rootScope.setActiveFinancialYear(cYear)
    localStorageService.set('activeFY', cYear)


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
      # _.each acc.yodleeAccounts, (link) ->
      #   if link.giddhAccount != null
      #     linked = {
      #       uniqueName : link.giddhAccount.uniqueName
      #     }
      #     $scope.AccountsListToLink = _.without($scope.AccountsList, _.findWhere($scope.AccountsList, linked))

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
    $scope.banks.toDelete = card.accountId
    modalService.openConfirmModal(
      title: 'Delete Account',
      body: 'Are you sure you want to delete ' + card.name + ' ?' + '\n' + 'All accounts linked with the same bank will be deleted.',
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
      templateUrl: '/public/webapp/views/connectBankModal.html',
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
      templateUrl: '/public/webapp/views/refreshBankAccountsModal.html',
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
      templateUrl: '/public/webapp/views/refreshBankAccountsModal.html',
      size: "md",
      backdrop: 'static',
      scope: $scope
    )

  $scope.refreshTokenFailure = (res) ->
    toastr.error(res.data.message, "Error")

  $scope.setActiveTab = () ->
    $scope.afterConnectSuccess  = true
    $scope.loadYodlee()
  #  Linked methods end here


  $timeout( ->
    $rootScope.selAcntUname = undefined
    $scope.getCompanyList()
    $scope.getCurrencyList()
    $scope.getUserDetails()
    # $scope.getCurrentPeriod()
  ,200)

  #fire function after page fully loaded
  $scope.$on '$viewContentLoaded', ->
    $timeout( ->
      $scope.selectedAccountUniqueName = undefined
      $scope.rolesList = localStorageService.get("_roles")
    ,2000)

  $scope.$on('$stateChangeStart', (event, toState, toParams, fromState, fromParams)->
    $scope.resetSteps()
  )

#init angular app
giddh.webApp.controller 'companyController', companyController
