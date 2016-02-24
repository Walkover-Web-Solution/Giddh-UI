"use strict"
companyController = ($scope, $rootScope, $timeout, $uibModal, $log, companyServices, currencyService, locationService, modalService, localStorageService, toastr, userServices, Upload, DAServices, $state, permissionService, $stateParams, couponServices) ->
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
  $scope.compTransData = []
  $scope.compDiffAmount = 0
  $scope.showPayOptns = false
  #contains company list
  $scope.companyList = []
  $scope.companyDetails = {}
  $scope.currencyList = []
  $scope.currencySelected = undefined
  $scope.shareRequest = {role: 'view_only', user: null}

  # userController methods
  $scope.payStep2 = false
  $scope.payStep3 = false
  $scope.directPay = false
  $scope.disableRazorPay = false
  $scope.payAlert = []
  $scope.wlt = {}
  $scope.wlt.status = false
  $scope.coupRes = {}
  $scope.coupon = {}
  $scope.discount = 0
  $scope.amount = 0
  $scope.calCulatedDiscount = 0

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

  #for make sure
  $scope.checkCmpCretedOrNot = ->
    if $scope.companyList.length <= 0
      # $scope.openFirstTimeUserModal()
      console.info "do nothing"

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

  #create company failure
  $scope.onCreateCompanyFailure = (res) ->
    toastr.error(res.data.message, "Error")

  #Get company list
  $scope.getCompanyList = ()->
    companyServices.getAll().then($scope.getCompanyListSuccess, $scope.getCompanyListFailure)

  #Get company list
  $scope.getCompanyListSuccess = (res) ->
    $scope.companyList = _.sortBy(res.body, 'shared')
    if _.isEmpty($scope.companyList)
      # $scope.openFirstTimeUserModal()
      console.info "do nothing"
    else
      $rootScope.mngCompDataFound = true
      cdt = localStorageService.get("_selectedCompany")
      if not _.isNull(cdt) && not _.isEmpty(cdt) && not _.isUndefined(cdt)
        cdt = _.findWhere($scope.companyList, {uniqueName: cdt.uniqueName})
        if _.isUndefined(cdt)
          localStorageService.set("_selectedCompany", $scope.companyList[0])
          $scope.goToCompany($scope.companyList[0], 0, "CHANGED")
        else
          localStorageService.set("_selectedCompany", cdt)
          $scope.goToCompany(cdt, cdt.index, "NOCHANGED")
      else
        localStorageService.set("_selectedCompany", $scope.companyList[0])
        $scope.goToCompany($scope.companyList[0], 0, "CHANGED")

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
    # modalInstance = $uibModal.open(
    #   templateUrl: '/public/webapp/views/confirmModal.html'
    #   title: 'Are you sure you want to delete? ' + name
    #   ok: 'Yes'
    #   cancel: 'No'
    #   scope: $scope
    # )
    # modalInstance.result.then ->
    #   companyServices.delete(uniqueName).then($scope.delCompanySuccess, $scope.delCompanyFailure)

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
    angular.extend($rootScope.selectedCompany, data)
    $rootScope.selectedCompany.index = index
    contactnumber = $rootScope.selectedCompany.contactNo
    if not _.isNull(contactnumber) and not _.isEmpty(contactnumber) and not _.isUndefined(contactnumber) and contactnumber.match("-")
      SplitNumber = contactnumber.split('-')
      $rootScope.selectedCompany.mobileNo = SplitNumber[1]
      $rootScope.selectedCompany.cCode = SplitNumber[0]

    localStorageService.set("_selectedCompany", $rootScope.selectedCompany)

    if $rootScope.canManageUser
      $scope.getSharedUserList($rootScope.selectedCompany.uniqueName)
    if type is 'CHANGED'
      $rootScope.$emit('companyChanged')
    else
      console.info "Same Company loaded"

  #update company details
  $scope.updateCompanyInfo = (data) ->
    if not _.isEmpty(data.contactNo)
      if _.isObject(data.cCode)
        data.contactNo = data.cCode.value + "-" + data.mobileNo
      else
        data.contactNo = data.cCode + "-" + data.mobileNo

    companyServices.update(data).then($scope.updtCompanySuccess, $scope.updtCompanyFailure)

  #update company success
  $scope.updtCompanySuccess = (res)->
    toastr.success("Company updated successfully", "Success")
    $scope.getCompanyList()
    localStorageService.set("_selectedCompany", res.body)

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
  $scope.getCompanyTransactions = ()->
    companyServices.getCompTrans($rootScope.selectedCompany.uniqueName).then($scope.getCompanyTransactionsSuccess, $scope.getCompanyTransactionsFailure)

  $scope.getCompanyTransactionsSuccess = (res) ->
    angular.copy(res.body, $scope.compTransData)
    if res.body.length > 0
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
    console.log res, "updateCompSubsSuccess"

  $scope.updateCompSubsFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getWltBal=()->
    userServices.getWltBal($rootScope.basicInfo.uniqueName).then($scope.getWltBalSuccess, $scope.getWltBalFailure)

  $scope.getWltBalSuccess = (res) ->
    $scope.disableRazorPay = false
    avlB = Number(res.body.availableCredit)
    invB = Number($rootScope.selectedCompany.companySubscription.servicePlan.amount)
    if avlB >= invB
      $scope.showPayOptns = false
      $scope.deductSubsViaWallet(invB)
    else if avlB > 0 and avlB < invB
      # hit api with avlB and go through wallet with compDiffAmount
      $scope.wlt.Amnt = Math.abs(invB - avlB)
      $scope.showPayOptns = true
    else
      console.log "no bal found or bal is zero"

  $scope.getWltBalFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.deductSubsViaWallet = (num) ->
    obj = {
      uniqueName: $rootScope.selectedCompany.uniqueName
      billAmount: num
    }
    companyServices.payBillViaWallet(obj).then($scope.subsViaWltSuccess, $scope.subsWltFailure)

  $scope.subsViaWltSuccess = (res) ->
    console.log "subsViaWltSuccess", res

  $scope.subsWltFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  $scope.deductSubsViaRazor = (razorObj) ->
    console.log $scope.wlt.Amnt, razorObj
    if _.isEmpty($scope.coupRes)
      obj = {
        uniqueName: $rootScope.basicInfo.uniqueName
        paymentId: razorObj.razorpay_payment_id
        amount: $scope.wlt.Amnt
        coupanCode: null
      }
    else
      obj = {
        uniqueName: $rootScope.basicInfo.uniqueName
        paymentId: razorObj.razorpay_payment_id
        amount: $scope.wlt.Amnt
        coupanCode: $scope.wlt.Amnt
      }
    # companyServices.payBillViaRazor(obj).then($scope.subsViaRzrSuccess, $scope.subsRzrFailure)

  $scope.subsViaRzrSuccess = (res) ->
    console.log "subsViaRzrSuccess", res

  $scope.subsRzrFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  # child functions here for userController
  # add money in wallet
  $scope.addMoneyInWallet = () ->
    if Number($scope.wlt.Amnt) < 100
      $scope.wlt = angular.copy({})
      toastr.warning("You cannot make payment")
    else
      $scope.payStep2 = true
      $scope.wlt.status = true

  # redeem coupon
  $scope.redeemCoupon = (code) ->
    couponServices.couponDetail(code).then($scope.redeemCouponSuccess, $scope.redeemCouponFailure)

  $scope.removeDotFromString = (str) ->
    return Math.floor(Number(str))

  $scope.redeemCouponSuccess = (res) ->
    $scope.payAlert = []
    $scope.calCulatedDiscount = 0
    $scope.coupRes = res.body
    toastr.success("Hurray your coupon code is redeemed", res.status)
    
    if res.body.type is "balance_add"
      $scope.directPay = true
      $scope.disableRazorPay = true
      console.info "we will hit api"
      # hit api from here

    else if $scope.coupRes.type is "cashback"
      $scope.directPay = false
      $scope.disableRazorPay = false
      $scope.amount = $scope.removeDotFromString($scope.wlt.Amnt)
      $scope.discount = 0
      console.info "we will give cashback"
      $scope.payAlert.push({msg: "Your cashback amount will be credited in your account withing 48 hours after payment has been done."})

    else if $scope.coupRes.type is "discount"
      console.info "calculating discount"
      $scope.directPay = false

      $scope.amount = $scope.removeDotFromString($scope.wlt.Amnt)

      $scope.calCulatedDiscount = Number($scope.coupRes.value * $scope.amount/100)

      if $scope.calCulatedDiscount > $scope.coupRes.maxAmount
        $scope.discount = Number($scope.coupRes.maxAmount)
        diff = $scope.amount-$scope.discount
        if diff < 100
          $scope.disableRazorPay = true
          $scope.payAlert.push({msg: "After discount amount cannot be less than 100 Rs. you have to add more money"})
        else
          $scope.disableRazorPay = false
          $scope.payAlert.push({msg: "You can only avail max discount of Rs. "+$scope.coupRes.maxAmount+ ". After discount, you have to pay Rs. "+ diff})
      else
        $scope.disableRazorPay = false
        $scope.discount = $scope.calCulatedDiscount
        $scope.payAlert.push({msg: "Hurray you have availed a discount of Rs. "+ $scope.discount})
      

  $scope.redeemCouponFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  # remove alert
  $scope.closeAlert = (index) ->
    $scope.payAlert.splice(index, 1)

  # reset steps
  $scope.resetSteps = () ->
    $scope.isHaveCoupon = false
    $scope.payAlert = []
    $scope.wlt = angular.copy({})
    $scope.coupon = angular.copy({})
    $scope.wlt.status = false
    $scope.coupRes = {}
    $scope.payStep2 = false
    $scope.payStep3 = false

  $scope.resetDiscount = () ->
    if !$scope.isHaveCoupon
      $scope.payAlert = []
      $scope.coupon = angular.copy({})

  $timeout( ->
    $rootScope.selAcntUname = undefined
    $scope.getCompanyList()
    $scope.getCurrencyList()
    $scope.getUserDetails()
  ,200)
  #fire function after page fully loaded
  $scope.$on '$viewContentLoaded', ->
    $timeout( ->
      $scope.selectedAccountUniqueName = undefined
      $scope.rolesList = localStorageService.get("_roles")
    ,2000)

  $rootScope.$on('$stateChangeStart', (event, toState, toParams, fromState, fromParams)->
    if _.isEmpty(toParams)
      $rootScope.selAcntUname = undefined
  )

#init angular app
giddh.webApp.controller 'companyController', companyController
