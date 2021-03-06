"use strict"

mainController = ($scope, $state, $rootScope, $timeout, $http, $uibModal, localStorageService, toastr, locationService, modalService, roleServices, permissionService, companyServices, $window,groupService, $location, DAServices) ->

  $rootScope.scriptArrayHead = [
    "/public/webapp/newRelic.js"
    "/public/webapp/core_bower.min.js"
    "/public/webapp/_extras.js"
    "/public/webapp/app.js"
    "/public/webapp/app.min.js"
  ]
  $rootScope.scriptArrayBody = [
    "/node_modules/rxjs/bundles/Rx.umd.js"
    "/node_modules/es6-shim/es6-shim.js"
    "/node_modules/angular2/bundles/angular2-polyfills.js"
    "/node_modules/angular2/bundles/angular2-all.umd.min.js"
    "/public/webapp/ng2.js"
  ]
  $rootScope.groupName = {
    sundryDebtors : "sundrydebtors"
    revenueFromOperations : "revenuefromoperations"
    indirectExpenses : "indirectexpenses"
    operatingCost: "operatingcost"
    otherIncome: "otherincome"
    purchase: "purchases"
    sales:"sales"
  }


  $rootScope.flyAccounts = false
  $rootScope.$stateParams = {}
#  $rootScope.prefixThis = ""
  $rootScope.cmpViewShow = true
  $rootScope.showLedgerBox = true
  $rootScope.showLedgerLoader = false
  $rootScope.basicInfo = {}
  #$rootScope.flatAccntListWithParents = []
  $rootScope.canManageComp = true
  $rootScope.canViewSpecificItems = false
  $rootScope.canUpdate = false
  $rootScope.canDelete = false
  $rootScope.canAdd = false
  $rootScope.canShare = false
  $rootScope.canManageCompany = false
  $rootScope.canVWDLT = false
  $rootScope.companyLoaded = true
  $rootScope.superLoader = false
  $rootScope.hideHeader = false
  $rootScope.phoneVerified = false
  $rootScope.stateParams = null
  $rootScope.search = {}
  $rootScope.search.acnt = ''
  $rootScope.flatAccList = {
    page: 1
    count: 20000
    totalPages: 0
    currentPage : 1
    limit: 5
  }
  $rootScope.queryFltAccnt = []
  $rootScope.fltAccntListPaginated = []
  $rootScope.fltAccountListFixed = []
  $rootScope.CompanyList = []
  $rootScope.companyIndex = 0
  $rootScope.selectedAccount = {}
  $rootScope.hasOwnCompany = false
  $rootScope.sharedEntity = ""
  $rootScope.croppedAcntList = []
  $rootScope.gstDetail = []
  $rootScope.stateList = []
  $rootScope.setDefaultGst = false;
  $rootScope.defaultChecked = {}


  ##Date range picker###
  # $scope.fixedDate = {
  #   startDate: moment().subtract(30, 'days')._d,
  #   endDate: moment()._d
  # };


  # $scope.singleDate = moment()
  # $scope.fixedDateOptions = {
  #     locale:
  #       applyClass: 'btn-green'
  #       applyLabel: 'Apply'
  #       fromLabel: 'From'
  #       format: 'D-MMM-YY'
  #       toLabel: 'To'
  #       opens: 'center'
  #       cancelLabel: 'Cancel'
  #       customRangeLabel: 'Custom range'
  #     ranges:
  #       'Last 1 Day': [
  #         moment().subtract(1, 'days')
  #         moment()
  #       ]
  #       'Last 7 Days': [
  #         moment().subtract(6, 'days')
  #         moment()
  #       ]
  #       'Last 30 Days': [
  #         moment().subtract(29, 'days')
  #         moment()
  #       ]
  #       'Last 6 Months': [
  #         moment().subtract(6, 'months')
  #         moment()
  #       ]
  #       'Last 1 Year': [
  #         moment().subtract(12, 'months')
  #         moment()
  #       ]
  #     eventHandlers : {
  #       'apply.daterangepicker' : (e, picker) ->
  #         $scope.fixedDate.startDate = e.model.startDate._d
  #         $scope.fixedDate.endDate = e.model.endDate._d
  #     }
  # }
  # $scope.setStartDate = ->
  #   $scope.fixedDate.startDate = moment().subtract(4, 'days').toDate()

  # $scope.setRange = ->
  #   $scope.fixedDate =
  #       startDate: moment().subtract(5, 'days')
  #       endDate: moment()
  ###date range picker end###

  #get user details
  getUserSuccess = (res) ->
    localStorageService.set('_userDetails', res.data.body)
    $rootScope.basicInfo = res.data.body
    if $rootScope.basicInfo.name.indexOf(" ") != -1
     $scope.userName = $rootScope.basicInfo.name.split(" ")
     $scope.userName = $scope.userName[0][0]+$scope.userName[1][0]
    else if $rootScope.basicInfo.name.indexOf("@") != -1
     $scope.userName = $rootScope.basicInfo.name.split("@")
     $scope.userName = $scope.userName[0][0]
    $rootScope.getCompanyList()
    if !_.isEmpty($rootScope.selectedCompany)
      $rootScope.cmpViewShow = true
      
  getUserFailure = (res) ->
    toastr.error('unable to fetch user')
  getUserDetail = () ->
    $http.get('/fetch-user').then(getUserSuccess, getUserFailure)
  getUserDetail()

  $scope.addScript = () ->
    _.each($rootScope.scriptArrayHead, (script) ->
      sc = document.createElement("script")
      sc.src = $scope.prefixUrl(script)
      sc.type = "text/javascript"
      document.head.appendChild(sc)
    )
    _.each($rootScope.scriptArrayBody, (script) ->
      sc = document.createElement("script")
      sc.src = $scope.prefixUrl(script)
      sc.type = "text/javascript"
      document.body.appendChild(sc)
    )

  $scope.prefixUrl = (path) ->
    str = "http://1." + location.host + path
    console.log(str)
    return str

  $scope.runSetupWizard = () ->
    $rootScope.setupModalInstance = $uibModal.open(
      templateUrl: '/public/webapp/SetupWizard/setup-wizard.html',
      size: "lg",
      backdrop: 'static',
      scope: $scope
    )

  #get account details for ledger
  $rootScope.getSelectedAccountDetail = (acc) ->
    console.log acc

  # check IE browser version
  $rootScope.GetIEVersion = () ->
    ua = window.navigator.userAgent
    msie = ua.indexOf('MSIE ')
    trident = ua.indexOf('Trident/')
    edge = ua.indexOf('Edge/')
    if (msie > 0)
      toastr.error('For Best User Expreince, upgrade to IE 11+')

  $rootScope.GetIEVersion()

  # check browser
  $rootScope.msieBrowser = ()->
    ua = window.navigator.userAgent
    msie = ua.indexOf('MSIE')
    if msie > 0 or !!navigator.userAgent.match(/Trident.*rv\:11\./)
      return true
    else
      console.info window.navigator.userAgent, 'otherbrowser', msie
      return false

  # open window for IE
  $rootScope.openWindow = (url) ->
    win = window.open()
    win.document.write('sep=,\r\n', url)
    win.document.close()
    win.document.execCommand('SaveAs', true, 'abc' + ".xls")
    win.close()

  $scope.logout = ->
    $http.post('/logout').then ((res) ->
      # don't need to clear below
      # _userDetails, _currencyList
      localStorageService.remove('_userDetails')
      localStorageService.remove('_roles')
      localStorageService.remove('_currencyList')
      localStorageService.remove('_selectedAccount')
      localStorageService.remove('_ledgerData')
      window.sessionStorage.clear()
      window.location = "https://giddh.com"
    ), (res) ->

  # for ledger
  $rootScope.makeAccountFlatten = (data) ->
    # $rootScope.flatAccntListWithParents = data
    # obj = _.map(data, (item) ->
    #   obj = {}
    #   obj.name = item.name
    #   obj.uniqueName = item.uniqueName
    #   obj.mergedAccounts = item.mergedAccounts
    #   obj
    # )
    #$rootScope.fltAccntList = obj

  $rootScope.countryCodesList = locationService.getCountryCode()

  $scope.getRoles = (company) ->
    roleServices.getAll(company.uniqueName).then($scope.onGetRolesSuccess, $scope.onGetRolesFailure)

  $scope.onGetRolesSuccess = (res) ->
    localStorageService.set("_roles", res.body)

  $scope.onGetRolesFailure = (res) ->
    toastr.error("Something went wrong while fetching role", "Error")

  $scope.getCdnUrl = ->
    roleServices.getEnvVars().then($scope.onGetEnvSuccess, $scope.onGetEnvFailure)

  $scope.onGetEnvSuccess = (res) ->
    $rootScope.prefixThis = res.envUrl

  $scope.onGetEnvFailure = (res) ->

  # switch user
  $scope.ucActive = false

  $scope.switchUser =() ->
    companyServices.switchUser($rootScope.selectedCompany.uniqueName).then($scope.switchUserSuccess, $scope.switchUserFailure)

  $scope.switchUserSuccess = (res) ->
    $scope.ucActive = res.body.active
    $state.reload()

  $scope.switchUserFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.checkPermissions = (entity) ->
    $rootScope.canUpdate = true
    $rootScope.canDelete = true
    $rootScope.canAdd = true
    $rootScope.canShare = true
    $rootScope.canManageCompany = true
    $rootScope.canVWDLT = true
    # commented by sarfaraz on 8 nov. 2017
    # $rootScope.canUpdate = permissionService.hasPermissionOn(entity, "UPDT")
    # $rootScope.canDelete = permissionService.hasPermissionOn(entity, "DLT")
    # $rootScope.canAdd = permissionService.hasPermissionOn(entity, "ADD")
    # $rootScope.canShare = permissionService.hasPermissionOn(entity, "SHR")
    # $rootScope.canManageCompany = permissionService.hasPermissionOn(entity, "MNG_CMPNY")
    # $rootScope.canVWDLT = permissionService.hasPermissionOn(entity, "VWDLT")

  $rootScope.setScrollToTop = (val, elem)->
    if val is '' || _.isUndefined(val)
      return false
    if val.length > 0
      cntBox = document.getElementById(elem)
      cntBox.scrollTop = 0

  $rootScope.validateEmail = (emailStr)->
    pattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return pattern.test(emailStr)
  
  

  $timeout (->
    cdt = localStorageService.get("_selectedCompany")
    if !_.isNull(cdt)
      $rootScope.setActiveFinancialYear(cdt.activeFinancialYear)
      $scope.getRoles(cdt)
      $scope.getCdnUrl()
  ), 500


  $scope.beforeDeleteCompany = {}

  #delete company
  $scope.deleteCompany = (company, index, name, event) ->
    event.stopPropagation()
    $scope.beforeDeleteCompany.company = company
    $scope.beforeDeleteCompany.index = index
    modalService.openConfirmModal(
      title: 'Delete Company'
      body: 'Are you sure you want to delete ' + name + ' ?',
      ok: 'Yes',
      cancel: 'No'
    ).then ->
      companyServices.delete(company.uniqueName).then($scope.delCompanySuccess, $scope.delCompanyFailure)

  #delete company success
  $scope.delCompanySuccess = (res) ->
#    $rootScope.selectedCompany = {}
#    localStorageService.remove("_selectedCompany")
    if $rootScope.selectedCompany.uniqueName == $scope.beforeDeleteCompany.company.uniqueName
      localStorageService.remove("_selectedCompany")
    else
      $scope.companyList = _.without($scope.companyList, $scope.beforeDeleteCompany.company)
    $rootScope.getCompanyList()
    $scope.beforeDeleteCompany = {}
    if !$rootScope.CompanyList
      localStorageService.set("_selectedCompany", null)
      localStorageService.set("_selectedAccount", null)
    toastr.success("Company deleted successfully", "Success")

#    $scope.getCompanyList()

# refresh company list 
  $scope.refreshcompanyList = (e) ->
    companyServices.getAll().then($scope.refreshcompanyListSuccess, $scope.getCompanyListFailure)
    e.stopPropagation()

  $scope.refreshcompanyListSuccess = (res) ->
    $scope.companyList = _.sortBy(res.body, 'shared')
    # $scope.findCompanyInList()

  #delete company failure
  $scope.delCompanyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #creating company
  $scope.createCompany = (cdata) ->
    companyServices.create(cdata).then($scope.onCreateCompanySuccess, $scope.onCreateCompanyFailure)

  #create company success
  $scope.onCreateCompanySuccess = (res) ->
    toastr.success("Company created successfully", "Success")
    $rootScope.mngCompDataFound = true
    try
      $scope.companyList.push(res.body)
    catch e
      $scope.companyList = []
      $scope.companyList.push(res.body)

  #create company failure
  $scope.onCreateCompanyFailure = (res) ->
    toastr.error(res.data.message, "Error")

  #Create ne company
  $scope.createNewCompany = () ->
    $scope.runSetupWizard()
    
  $scope.onCompanyCreateModalCloseSuccess = (data) ->
    cData = {}
    cData.name = data.name
    cData.city = data.city
    $scope.createCompany(cData)

  $scope.onCompanyCreateModalCloseFailure = () ->
    if $scope.companyList.length <= 0
      modalService.openConfirmModal(
        title: 'LogOut',
        body: 'In order to be able to use Giddh, you must create a company. Are you sure you want to cancel and logout?',
        ok: 'Yes',
        cancel: 'No').then($scope.firstLogout, $scope.logoutCancel)

  $scope.logoutCancel = () ->
    $scope.createNewCompany()

  $scope.firstLogout = () ->
    $http.post('/logout').then ((res) ->
      localStorageService.clearAll()
      window.location = "/thanks"
    ), (res) ->


  #get only city for create company
  $scope.getOnlyCity = (val) ->
    locationService.searchOnlyCity(val).then($scope.getOnlyCitySuccess, $scope.getOnlyCityFailure)

  #get only city success
  $scope.getOnlyCitySuccess = (data) ->
    filterThis = data.results.filter (i) -> _.contains(i.types, "locality")
    filterThis.map((item) ->
      item.address_components[0].long_name
    )

  #get only city failure
  $scope.getOnlyCityFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.setCompanyCountryDefault=()->
    $timeout (->
      $rootScope.selectedCompany.country = if $rootScope.selectedCompany.country then $rootScope.selectedCompany.country else 'India'
      $rootScope.breakCompanyContactDetails()
    ), 1500

  #Get company list
  $rootScope.getCompanyList = ()->
    companyServices.getAll().then($scope.getCompanyListSuccess, $scope.getCompanyListFailure)

  #Get company list success
  $scope.getCompanyListSuccess = (res) ->    
    $scope.companyList = _.sortBy(res.body, 'shared')
    $scope.companyList = $scope.companyList.reverse()
    $rootScope.CompanyList = $scope.companyList
    if _.isEmpty($scope.companyList)
      #When no company is there
      $scope.companyList.count
      #$scope.runSetupWizard()
      $scope.createNewCompany()
    else
      # When there are companies
      $scope.checkUserCompanyStatus(res.body)
      $rootScope.mngCompDataFound = true
      $scope.findCompanyInList()
      # $rootScope.checkWalkoverCompanies()

  $scope.checkUserCompanyStatus = (compList) ->
    _.each compList, (cmp) ->
      if cmp.shared
        $rootScope.hasOwnCompany = true

  # get index of a company from company list array
  $scope.getcompanyIndex = (company) ->
    idx = 0
    if $scope.companyList.length > 0
      _.each $scope.companyList, (cmp, index) ->
        if cmp.uniqueName == company.uniqueName
          idx = index
    return idx

  # get last selected company from localstorage and match from new list
  $scope.findCompanyInList = () ->
    cdt = localStorageService.get("_selectedCompany")
    # if we get a company from localstorage
    if not _.isNull(cdt) && not _.isEmpty(cdt) && not _.isUndefined(cdt)
      cdt = _.findWhere($scope.companyList, {uniqueName: cdt.uniqueName})
      if _.isUndefined(cdt)
        $scope.changeCompany($scope.companyList[0],0,'SELECT')
        $rootScope.setCompany($scope.companyList[0])
        $rootScope.companyIndex = 0
      else
        $rootScope.companyIndex = $scope.getcompanyIndex(cdt)
        $scope.changeCompany(cdt,$rootScope.companyIndex,'SELECT')
        $rootScope.setCompany(cdt)
    #if we dont get a company from localstorage, set company at 0 index as selected company
    else
      $scope.changeCompany($scope.companyList[0],0,'CHANGE')
      $rootScope.setCompany($scope.companyList[0])
      $rootScope.companyIndex = 0

  #get company list failure
  $scope.getCompanyListFailure = (res)->
    $scope.createNewCompany()
    $rootScope.CompanyList = []
    if !$scope.companyList
      $scope.companyList = []
    localStorageService.set("_selectedCompany", null)
    localStorageService.set("_selectedCompany", null)
    toastr.error(res.data.message, res.data.status)
    return false

  $rootScope.setCompany = (company) ->
    $rootScope.selectedCompany = company
    $rootScope.fltAccntListPaginated = []
    $rootScope.breakCompanyContactDetails()
    $scope.checkPermissions($rootScope.selectedCompany)
    localStorageService.set("_selectedCompany", $rootScope.selectedCompany)
    $rootScope.getFlatAccountList(company.uniqueName)
    $rootScope.getGstDetail()
    $scope.getGroupsList()

  $rootScope.breakCompanyContactDetails = () ->
    if $rootScope.selectedCompany.contactNo
      result = $rootScope.selectedCompany.contactNo.split("-")
      $rootScope.selectedCompany.cCode = result[0]
      $rootScope.selectedCompany.mobileNo = result[1]
    else
      $rootScope.selectedCompany.cCode = 91
      $rootScope.selectedCompany.mobileNo = null

  $rootScope.getParticularAccount = (searchThis) ->
    accountList = []
    _.filter($rootScope.fltAccntListPaginated,(account) ->
      if(account.name.toLowerCase().match(searchThis.toLowerCase()) != null || account.uniqueName.match(searchThis) != null)
        accountList.push(account)
    )
    accountList

  $rootScope.removeAccountFromPaginatedList = (account) ->
    $rootScope.fltAccntListPaginated = _.without($rootScope.fltAccntListPaginated,account)

  $scope.gettingCroppedAccount = false
  $rootScope.getCroppedAccountList = (compUname, query) ->
    reqParam = {
      cUname: compUname
      query: query
    }
    data = {}
    if $scope.gettingCroppedAccount == false || !_.isEmpty(query)
      $scope.gettingCroppedAccount = true
      companyServices.getCroppedAcnt(reqParam, data).then($scope.getCroppedAccListSuccess, $scope.getCroppedAccListFailure)

  $scope.getCroppedAccListSuccess = (res) ->
    $scope.gettingCroppedAccount = false
    $rootScope.croppedAcntList = res.body.results

  $scope.getCroppedAccListFailure = (res) ->
    $scope.gettingCroppedAccount = false
    toastr.error(res.data.message)

  $rootScope.getFlatAccntsByQuery = (query) ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      q: query
      page: 1
      count: 0
    }
    groupService.getFlatAccList(reqParam).then($scope.flatAccntQuerySuccess, $scope.flatAccntQueryFailure)

  $rootScope.postFlatAccntsByQuery = (query,data) ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      q: query
      page: 1
      count: 0
    }
    datatosend = {
      groupUniqueNames: data
    }
    groupService.postFlatAccList(reqParam,datatosend).then($scope.flatAccntQuerySuccess, $scope.flatAccntQueryFailure)

  $scope.flatAccntQuerySuccess = (res) ->
    $rootScope.queryFltAccnt = res.body.results

  $scope.flatAccntQueryFailure = (res) ->
    toastr.error(res.data.message)

  $scope.workInProgress = false
  $rootScope.getFlatAccountList = (compUname) ->
#    console.log("work in progress", $scope.workInProgress)
    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: $scope.flatAccList.page
      count: $scope.flatAccList.count
    }
    if $scope.workInProgress == false
      $scope.workInProgress = true
      groupService.getFlatAccList(reqParam).then($scope.getFlatAccountListListSuccess, $scope.getFlatAccountListFailure)

  $scope.getFlatAccountListListSuccess = (res) ->
    $scope.workInProgress = false
    $rootScope.fltAccntListPaginated = res.body.results
    $rootScope.$emit('account-list-updated')
#    $rootScope.fltAccountLIstFixed = $rootScope.fltAccntListPaginated
    $rootScope.flatAccList.limit = 5
    $scope.$broadcast('account-list-updated')
    
  $scope.getFlatAccountListFailure = (res) ->
    $scope.workInProgress = false
    toastr.error(res.data.message)

  $rootScope.searchAccountInFilter = (str) ->
    filteredList = []
    _.each($rootScope.fltAccntListPaginated, (account) ->
      if account.name.contains(str) || account.uniqueName.contains(str)
        filteredList.push(account)
    )
    filteredList

  $rootScope.OpenManegeModal = () ->
    $rootScope.$emit('Open-Manage-Modal')

  $rootScope.NewgoToManageGroups =() ->
    if !$rootScope.canManageComp
      return
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalInstance = $uibModal.open(
        templateUrl:'/public/webapp/NewManageGroupsAndAccounts/ManageGroupModal.html'
        size: "liq90"
        backdrop: 'static'
        windowClass: 'manageModal'
        scope: $scope
      )
      # modalInstance.result.then(mc.goToManageGroupsOpen, mc.goToManageGroupsClose)


  # search flat accounts list
  $rootScope.searchAccounts = (str) ->
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    if str.length > 2
      reqParam.q = str
      groupService.getFlatAccList(reqParam).then($rootScope.getFlatAccountListListSuccess, $rootScope.getFlatAccountListFailure)
    else
      reqParam.q = ''
      reqParam.count = 5
      groupService.getFlatAccList(reqParam).then($rootScope.getFlatAccountListListSuccess, $rootScope.getFlatAccountListFailure)

  # load-more function for accounts list on add and manage popup
  $rootScope.loadMoreAcc = (compUname) ->
    $rootScope.flatAccList.limit += 5

    # set financial year
  $rootScope.setActiveFinancialYear = (FY) ->
    if FY != undefined
      activeYear = {}
      activeYear.start = moment(FY.financialYearStarts,"DD/MM/YYYY").year()
      activeYear.ends = moment(FY.financialYearEnds,"DD/MM/YYYY").year()
      if activeYear.start == activeYear.ends then (activeYear.year = activeYear.start) else (activeYear.year = activeYear.start + '-' + activeYear.ends)
      $rootScope.fy = FY
      $rootScope.activeYear = activeYear
      $rootScope.currentFinancialYear =  activeYear.year
    localStorageService.set('activeFY',FY)

  # change selected company

  

  $scope.changeCompany = (company, index, method) ->
    #console.log("method we get here is : ", method)
    # select and set active financial year
    if _.isUndefined(company)
      return
    $scope.getFlattenGrpWithAccList(company.uniqueName)
    $scope.setFYonCompanychange(company)
    #check permissions on selected company 
    $rootScope.doWeHavePermission(company)
    $scope.checkPermissions(company)
    $rootScope.canViewSpecificItems = false
    if company.userEntityRoles[0].role.uniqueName is 'shared'
      $rootScope.canManageComp = false
      if company.sharedEntity is 'groups'
        $rootScope.canViewSpecificItems = true
      localStorageService.set("_selectedCompany", company)
      $rootScope.selectedCompany = company
      $state.go('company.content.ledgerContent')
      $rootScope.$emit('company-changed')
    else
      $rootScope.canManageComp = true
      #$scope.goToCompany(company, index, "CHANGED")
      if method == 'CHANGE'
        $rootScope.setCompany(company)
      if $rootScope.selectedCompany
        $rootScope.selectedCompany.index = index
    changeData = {}
    changeData.data = company
    changeData.index = index
    changeData.type = method
    # $scope.$broadcast('company-changed', changeData)
    $rootScope.$emit('company-changed', changeData)
    url = $location.url()
    # if url.indexOf('ledger') == -1
    #   $state.go('company.content.ledgerContent')
    $scope.gwaList = {
      page: 1
      count: 10
      totalPages: 0
      currentPage : 1
      limit: 10
    }
    #return false
    #$scope.tabs[0].active = true

  $rootScope.allowed = true
  $rootScope.doWeHavePermission = (company) ->
    str = company.userEntityRoles[0].entity.entity
    $rootScope.sharedEntity = str
    if str is null
      $rootScope.allowed = true
    else
      if str is "accounts"
        $rootScope.allowed = false
      else
        if str is "groups"
          $rootScope.allowed = true

  $scope.setFYonCompanychange = (company) ->
    localStorageService.set('activeFY', company.activeFinancialYear)
    $rootScope.setActiveFinancialYear(company.activeFinancialYear)
    activeYear = {} 
    activeYear.start = moment(company.activeFinancialYear.financialYearStarts,"DD/MM/YYYY").year()
    activeYear.ends = moment(company.activeFinancialYear.financialYearEnds,"DD/MM/YYYY").year()
    if activeYear.start == activeYear.ends then (activeYear.year = activeYear.start) else (activeYear.year = activeYear.start + '-' + activeYear.ends)
    $rootScope.currentFinancialYear = activeYear.year

  $rootScope.$on 'callCheckPermissions', (event, data)->
    $scope.checkPermissions(data)

  $scope.$on('$stateChangeSuccess', ()->
    $rootScope.currentState = $state.current.name
  )

  $rootScope.$on('openAddManage', () ->
    $(document).find('#AddManage').trigger('click')
    return false
  )

  $scope.showAccounts = (e) ->
    $rootScope.flyAccounts = true

  # for accounts list
  $scope.gwaList = {
    page: 1
    count: 5
    totalPages: 0
    currentPage : 1
    limit: 5
  }
  $scope.working = false
  $scope.getFlattenGrpWithAccList = (compUname) ->
  #   console.log("working  : ",$scope.working)
    $rootScope.companyLoaded = false
    $scope.showAccountList = false
    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: $scope.gwaList.page
      count: $scope.gwaList.count
    }
    if $scope.working == false
      $scope.working = true
      groupService.getFlattenGroupAccList(reqParam).then($scope.getFlattenGrpWithAccListSuccess, $scope.getFlattenGrpWithAccListFailure)


  $scope.getFlattenGrpWithAccListSuccess = (res) ->
    $scope.gwaList.page = res.body.page
    $scope.gwaList.totalPages = res.body.totalPages
    $rootScope.flatAccntWGroupsList = res.body.results
    #$scope.flatAccntWGroupsList = gc.removeEmptyGroups(res.body.results)
  #   console.log($scope.flatAccntWGroupsList)
    $scope.showAccountList = true
    $scope.gwaList.limit = 10
    $rootScope.companyLoaded = true
    $scope.working = false
    $rootScope.toggleAcMenus(true)

  $scope.getFlattenGrpWithAccListFailure = (res) ->
    toastr.error(res.data.message)
    $scope.working = false

  $scope.loadMoreGrpWithAcc = (compUname, str) ->
    $scope.gwaList.page += 1
    reqParam = {
      companyUniqueName: compUname
      q: str || $rootScope.search.acnt
      page: $scope.gwaList.page
      count: $scope.gwaList.count
    }
    groupService.getFlattenGroupAccList(reqParam).then($scope.loadMoreGrpWithAccSuccess, $scope.loadMoreGrpWithAccFailure)
    $scope.gwaList.limit += 10

  $scope.loadMoreGrpWithAccSuccess = (res) ->
    $scope.gwaList.currentPage += 1
    #list = gc.removeEmptyGroups(res.body.results)
    if res.body.results.length > 0 && res.body.totalPages >= $scope.gwaList.currentPage
      _.each res.body.results, (grp) ->
        grp.open = true
        $rootScope.flatAccntWGroupsList.push(grp) 
      #$scope.flatAccntWGroupsList = _.union($scope.flatAccntWGroupsList, list)
    else if res.body.totalPages > $scope.gwaList.currentPage
      $scope.loadMoreGrpWithAcc($rootScope.selectedCompany.uniqueName)
    else
      $scope.hideLoadMore = true

  $scope.loadMoreGrpWithAccFailure = (res) ->
    toastr.error(res.data.message)

  $scope.searchGrpWithAccounts = (str) ->
    $rootScope.search.acnt = str
    $scope.gwaList.page = 1
    $scope.gwaList.currentPage = 1
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    if str.length > 2
      #$scope.hideLoadMore = true
      reqParam.q = str
      reqParam.page = $scope.gwaList.page
      reqParam.count = $scope.gwaList.count
      groupService.getFlattenGroupAccList(reqParam).then($scope.getFlattenGrpWithAccListSuccess, $scope.getFlattenGrpWithAccListFailure)
    else
      #$scope.hideLoadMore = false
      reqParam.q = ''
      groupService.getFlattenGroupAccList(reqParam).then($scope.getFlattenGrpWithAccListSuccess, $scope.getFlattenGrpWithAccListFailure)
    # if str.length < 1
    #   $scope.flatAccListC5.limit = 5
      #$scope.hideLoadMore = false

  $scope.removeEmptyGroups = (grpList) ->
    newList = []
    _.each grpList, (grp) ->
      if grp.accountDetails.length > 0
        newList.push(grp)
    newList

  $scope.setLedgerData = (data, acData) ->
    $scope.selectedAccountUniqueName = acData.uniqueName
    $rootScope.selectedAccount = acData
    DAServices.LedgerSet(data, acData)
    localStorageService.set("_ledgerData", data)
    localStorageService.set("_selectedAccount", acData)
    $rootScope.accClicked = true
    $rootScope.$emit('account-selected')
    return false

  $scope.getGroupsList = () ->
    @success = (res) ->
      $rootScope.groupWithAccountsList = res.body
    @failure = (res) ->

    groupService.getGroupsWithoutAccountsCropped($rootScope.selectedCompany.uniqueName).then(@success, @failure)

  # $scope.goToLedgerCash = () ->
  #   $state.go('company.content.ledgerContent',{unqName:'cash'})

  $rootScope.toggleAcMenus = (condition) ->
    $scope.showSubMenus = condition
    _.each $rootScope.flatAccntWGroupsList, (grp) ->
      grp.open = condition

  $scope.runTour = () ->
    $rootScope.$emit('run-tour')

  # $scope.showSwitchUserOption = false
  # $rootScope.checkUserCompany = () ->
  #   user = localStorageService.get('_userDetails')
  #   company = user.uniqueName.split('@')
  #   company = company[company.length - 1]
  #   company

  # $rootScope.checkWalkoverCompanies = () ->
  #   if $rootScope.checkUserCompany().toLowerCase() == 'giddh.com' || $rootScope.checkUserCompany().toLowerCase() == 'walkover.in' || $rootScope.checkUserCompany().toLowerCase() == 'msg91.com'
  #     $scope.showSwitchUserOption = true
  #   else
  #     $scope.showSwitchUserOption = false

  # $rootScope.ledgerMode = 'new'
  # $rootScope.switchLedgerMode = () ->
  #   if $rootScope.checkWalkoverCompanies()
  #     if $rootScope.ledgerMode == 'new'
  #       $rootScope.ledgerMode = 'old'
  #     else
  #       $rootScope.ledgerMode = 'new'

  $rootScope.setState = (lastState, url, param) ->
    $rootScope.selectedCompany = $rootScope.selectedCompany || localStorageService.get('_selectedCompany')
    data = {
        "lastState": lastState,
        "companyUniqueName": $rootScope.selectedCompany.uniqueName
    }
    if url.indexOf('ledger') != -1
      data.lastState = data.lastState + '@' + param
    $http.post('/state-details', data).then(
        (res) ->
          
        (res) ->
          
    )


  $rootScope.addNewGst = () ->
    gstDetail = {
      gstNumber: "",
      addressList: [
          {
            address:"",
            stateCode: "",
            stateName: "",
            isDefault: ""
          }
      ]
    }
    $rootScope.gstDetail.unshift(gstDetail)

  $rootScope.getStateByAPI = () ->
    @success=(res)->
      $rootScope.stateList = res.body

    @failure=(err)->
      console.log("failure", err)

    companyServices.getStates().then(@success, @failure)
  
  $scope.getStateByAPI()

  $rootScope.getStateCode = (val, item) ->
    if val.length >= 2
      gstState = _.findWhere($rootScope.stateList, {code:val.substr(0,2)})
      if gstState
        item.addressList[0].stateCode = gstState.code
        item.addressList[0].stateName = gstState.name
    else if val.length < 2
      item.addressList[0].stateCode = ''
      item.addressList[0].stateName = ''

  $rootScope.getGstDetail = () ->
    $rootScope.gstDetail = $rootScope.selectedCompany.gstDetails || []
    if $rootScope.gstDetail.length < 1
      $rootScope.addNewGst()
    $rootScope.findDefaultGst($scope.gstDetail)

  $rootScope.deleteGst = (obj, i) ->
    $rootScope.gstDetail.splice(i,1)

  $rootScope.removeBlankGst = (gstList) ->
    _.each gstList, (item) ->
      if item.gstNumber == ""
        gstList = _.without(gstList, item)
    $rootScope.gstDetail = gstList
    

  $rootScope.checkIsDefault = (gst, e) ->
    if $rootScope.defaultChecked.gstNumber != gst.gstNumber
      _.each $rootScope.gstDetail, (item) ->
        item.addressList[0].isDefault = false
      if gst.gstNumber
        gst.addressList[0].isDefault = true
      else
        toastr.error("Invalid GST Number")
    e.stopPropagation()

  $rootScope.findDefaultGst = (gstList) ->
    if gstList.length > 0
      _.each gstList, (item) ->
        if _.findWhere(item.addressList, {isDefault: true})
            $scope.defaultChecked = item



  $rootScope.$on('$stateChangeSuccess', (event, toState, toParams, fromState, fromParams)->
    if $rootScope.selectedCompany != undefined && $rootScope.selectedCompany != null
      $rootScope.setState(toState.name, toState.url, toParams.unqName)
  )

  $(document).on('click', (e)->
    if e.target.id != 'accountSearch'
      $rootScope.flyAccounts = false
    return false
  )

  $rootScope.$on('$stateChangeSuccess', (event, toState, toParams, fromState, fromParams)->
    if toState.name == "company.content.ledgerContent" && toParams.unqName == 'cash'
      $rootScope.ledgerState = true
    else
      $rootScope.ledgerState = false
  )

  $scope.redirectAccordingToCondition=(data)->
    
    company = _.findWhere($scope.companyList, {uniqueName:data.companyUniqueName})
    if !company && $rootScope.selectedCompany 
      company = $rootScope.selectedCompany
    if !company
      return false
    localStorageService.set('_selectedCompany', company)
    $rootScope.selectedCompany = company
    $scope.changeCompany(company, 0, 'CHANGE')

    if data.lastState.indexOf('@') isnt -1
        state = data.lastState.split('@')
        $state.go(state[0])
    else
        $state.go('company.content.ledgerContent')
    

  $rootScope.$on('different-company', (event, data)->
    if _.isUndefined($scope.companyList)
      $timeout (->
        $scope.redirectAccordingToCondition(data)
      ), 1000
    else
      $scope.redirectAccordingToCondition(data)
  )

giddh.webApp.controller 'mainController', mainController
