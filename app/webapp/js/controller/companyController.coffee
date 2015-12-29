"use strict"
companyController = ($scope, $rootScope, $timeout, $uibModal, $log, companyServices, currencyService, locationService, modalService, localStorageService, toastr, userServices, Upload, DAServices, $state) ->
  #make sure managecompanylist page not load
  $rootScope.mngCompDataFound = false
  #make sure manage company detail not load
  $rootScope.cmpViewShow = false
  $rootScope.selectedCompany = {}
  $rootScope.nowShowAccounts = false
  $scope.mHideBar = false
  $scope.dHideBar = false
  $scope.showUpdTbl = false

  #contains company list
  $scope.companyList = []
  $scope.companyDetails = {}
  $scope.currencyList = []
  $scope.currencySelected = undefined
  $scope.shareRequest = {role: 'view_only', user: null}

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

  #create company failure
  $scope.onCreateCompanyFailure = (res) ->
    toastr.error(res.data.message, "Error")

  #Get company list
  $scope.getCompanyList = ->
    companyServices.getAll().then($scope.getCompanyListSuccess, $scope.getCompanyListFailure)

  #Get company list
  $scope.getCompanyListSuccess = (res) ->
    $scope.companyList = _.sortBy(res.body, 'shared')
    if _.isEmpty($scope.companyList)
      $scope.openFirstTimeUserModal()
    else
      $rootScope.mngCompDataFound = true
      cdt = localStorageService.get("_selectedCompany")
      if not _.isNull(cdt) && not _.isEmpty(cdt) && not _.isUndefined(cdt)
        cdt = _.findWhere($scope.companyList, {uniqueName: cdt.uniqueName})
        localStorageService.set("_selectedCompany", cdt)
        $scope.goToCompany(cdt, cdt.index)
      else
        $scope.goToCompany($scope.companyList[0], 0)

  #get company list failure
  $scope.getCompanyListFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  $scope.getUserDetails = ->
    if _.isUndefined($rootScope.basicInfo.uniqueName)
      $rootScope.basicInfo = localStorageService.get("_userDetails")
    userServices.get($rootScope.basicInfo.uniqueName).then($scope.getUserDetailSuccess, $scope.getUserDetailFailure)

  #Get user details
  $scope.getUserDetailSuccess = (res) ->
    $rootScope.basicInfo = res.body

  #get company list failure
  $scope.getUserDetailFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  $scope.getCompany = (uniqueName)->
    companyServices.get(uniqueName).then((->), (->))

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
    toastr.success("Company deleted successfully", "Success")
    $scope.getCompanyList()

  #delete company failure
  $scope.delCompanyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.goToCompanyCheck = (data, index) ->
    if data.role.uniqueName is 'shared'
      localStorageService.set("_selectedCompany", data)
      $rootScope.selectedCompany = data
      $state.go('ledger.ledgerContent')
    else
      $scope.goToCompany(data, index)

  #making a detail company view
  $scope.goToCompany = (data, index) ->
    $scope.showUpdTbl = false
    $scope.mFiles = []
    $scope.dFiles = []
    $scope.mErrFiles = []
    $scope.dErrFiles = []
    $scope.canEdit = true
    $scope.canEdit = $rootScope.ifHavePermission(data, "UPDT")
    $scope.canManageUser = $rootScope.ifHavePermission(data, "MNG_USR")
    $rootScope.cmpViewShow = true
    $scope.selectedCmpLi = index
    angular.extend($scope.selectedCompany, data)
    $scope.selectedCompany.index = index
    contactnumber = $scope.selectedCompany.contactNo
    if not _.isNull(contactnumber) and not _.isEmpty(contactnumber) and not _.isUndefined(contactnumber) and contactnumber.match("-")
      SplitNumber = contactnumber.split('-')
      $scope.selectedCompany.mobileNo = SplitNumber[1]
      $scope.selectedCompany.cCode = SplitNumber[0]

    previousCompany = localStorageService.get("_selectedCompany")
    if(_.isEmpty(previousCompany) || previousCompany.uniqueName != data.uniqueName)
      DAServices.LedgerSet(null, null)
      localStorageService.set("_ledgerData", null)
      localStorageService.set("_selectedAccount", null)

    localStorageService.set("_selectedCompany", $scope.selectedCompany)

    if $scope.canManageUser is true
      $scope.getSharedUserList($scope.selectedCompany.uniqueName)
      $scope.getRolesList()

    if not $rootScope.nowShowAccounts
      $rootScope.nowShowAccounts = true
    else
      $rootScope.$broadcast('$reloadAccount')

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

  #get roles and set it in local storage
  $scope.getRolesList = () ->
    cUname = $rootScope.selectedCompany.uniqueName
    companyServices.getRoles(cUname).then($scope.getRolesSuccess, $scope.getRolesFailure)

  $scope.getRolesSuccess = (res) ->
    $scope.rolesList = res.body

  $scope.getRolesFailure = (res) ->
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


  #fire function after page fully loaded
  $scope.$on '$viewContentLoaded', ->
    $scope.getCompanyList()
    $scope.getCurrencyList()
    $scope.getUserDetails()

#init angular app
giddh.webApp.controller 'companyController', companyController
