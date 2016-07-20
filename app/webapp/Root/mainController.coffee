"use strict"

mainController = ($scope, $state, $rootScope, $timeout, $http, $uibModal, localStorageService, toastr, locationService, modalService, roleServices, permissionService, companyServices, $window,groupService) ->
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
  $rootScope.flatAccList = {
    page: 1
    count: 5000
    totalPages: 0
    currentPage : 1
    limit: 5
  }
  $rootScope.fltAccntListPaginated = []
#  $rootScope.fltAccountLIstFixed = []
  $rootScope.CompanyList = []
  $rootScope.companyIndex = 0
  $rootScope.selectedAccount = {}
  $scope.showCompanyList = false

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
      localStorageService.clearAll()
      window.location = "/thanks"
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

  $scope.getRoles = () ->
    roleServices.getAll().then($scope.onGetRolesSuccess, $scope.onGetRolesFailure)

  $scope.onGetRolesSuccess = (res) ->
    localStorageService.set("_roles", res.body)

  $scope.onGetRolesFailure = (res) ->
    toastr.error("Something went wrong while fetching role", "Error")

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
    $rootScope.canUpdate = permissionService.hasPermissionOn(entity, "UPDT")
    $rootScope.canDelete = permissionService.hasPermissionOn(entity, "DLT")
    $rootScope.canAdd = permissionService.hasPermissionOn(entity, "ADD")
    $rootScope.canShare = permissionService.hasPermissionOn(entity, "SHR")
    $rootScope.canManageCompany = permissionService.hasPermissionOn(entity, "MNG_CMPNY")
    $rootScope.canVWDLT = permissionService.hasPermissionOn(entity, "VWDLT")

    

  $rootScope.setScrollToTop = (val, elem)->
    if val is '' || _.isUndefined(val)
      return false
    if val.length > 0
      cntBox = document.getElementById(elem)
      cntBox.scrollTop = 0

  $rootScope.validateEmail = (emailStr)->
    pattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return pattern.test(emailStr)
  
  $scope.getRoles()
  $timeout(->
    $rootScope.basicInfo = localStorageService.get("_userDetails")
    if !_.isEmpty($rootScope.selectedCompany)
      $rootScope.cmpViewShow = true
  ,1000)

  $timeout (->
    cdt = localStorageService.get("_selectedCompany")
    if !_.isNull(cdt)
      $rootScope.setActiveFinancialYear(cdt.activeFinancialYear)
  ), 500


  $scope.beforeDeleteCompany = {}

  #delete company
  $scope.deleteCompany = (company, index, name, event) ->
    event.stopPropagation()
    $scope.beforeDeleteCompany.company = company
    $scope.beforeDeleteCompany.index = index
    modalService.openConfirmModal(
      title: 'Are you sure you want to delete? ' + name,
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
      $scope.getCompanyList()
    else
      $scope.companyList = _.without($scope.companyList, $scope.beforeDeleteCompany.company)
    $scope.beforeDeleteCompany = {}
    toastr.success("Company deleted successfully", "Success")

#    $scope.getCompanyList()


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
    $scope.companyList.push(res.body)

  #create company failure
  $scope.onCreateCompanyFailure = (res) ->
    toastr.error(res.data.message, "Error")

  #Create ne company
  $scope.createNewCompany = () ->
    # Open modal here and ask for company details
    modalInstance = $uibModal.open(
      templateUrl: '/public/webapp/Globals/modals/createCompanyModal.html',
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

  #Get company list
  $rootScope.getCompanyList = ()->
    companyServices.getAll().then($scope.getCompanyListSuccess, $scope.getCompanyListFailure)

  #Get company list success
  $scope.getCompanyListSuccess = (res) ->    
    $scope.companyList = _.sortBy(res.body, 'shared')
    $rootScope.CompanyList = $scope.companyList
    if _.isEmpty($scope.companyList)
      #When no company is there
      $scope.companyList.count
    else
      # When there are companies
      $rootScope.mngCompDataFound = true
      cdt = localStorageService.get("_selectedCompany")
      if not _.isNull(cdt) && not _.isEmpty(cdt) && not _.isUndefined(cdt)
        cdt = _.findWhere($scope.companyList, {uniqueName: cdt.uniqueName})
        if _.isUndefined(cdt)
          $scope.changeCompany($scope.companyList[0],0,'SELECT')
          $rootScope.setCompany($scope.companyList[0])
          $rootScope.companyIndex = 0
        else
          $scope.changeCompany(cdt,cdt.index,'SELECT')
          $rootScope.setCompany(cdt)
          $rootScope.companyIndex = cdt.index
      else
        $scope.changeCompany($scope.companyList[0],0,'SELECT')
        $rootScope.setCompany($scope.companyList[0])
        $rootScope.companyIndex = 0

  #get company list failure
  $scope.getCompanyListFailure = (res)->
    $rootScope.CompanyList = []
    toastr.error(res.data.message, res.data.status)

  $rootScope.setCompany = (company) ->
    #angular.extend($rootScope.selectedCompany, company)
    $rootScope.selectedCompany = company
    $rootScope.fltAccntListPaginated = []
    #$rootScope.selectedCompany = company
    $scope.checkPermissions($rootScope.selectedCompany)
    localStorageService.set("_selectedCompany", $rootScope.selectedCompany)
    $rootScope.getFlatAccountList(company.uniqueName)


  $rootScope.getParticularAccount = (searchThis) ->
    accountList = []
    _.filter($rootScope.fltAccntListPaginated,(account) ->
      if(account.name.toLowerCase().match(searchThis.toLowerCase()) != null || account.uniqueName.match(searchThis) != null)
        accountList.push(account)
    )
    accountList

  $rootScope.removeAccountFromPaginatedList = (account) ->
    $rootScope.fltAccntListPaginated = _.without($rootScope.fltAccntListPaginated,account)

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
#    $rootScope.fltAccountLIstFixed = $rootScope.fltAccntListPaginated
    $rootScope.flatAccList.limit = 5
    
  $scope.getFlatAccountListFailure = (res) ->
    $scope.workInProgress = false
    toastr.error(res.data.message)


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

  $rootScope.getCompanyList()

  $scope.selectCompany = (e) ->
    e.stopPropagation()
    $scope.showCompanyList = !$scope.showCompanyList

  $scope.changeCompany = (company, index, method) ->
    # select and set active financial year
    $scope.setFYonCompanychange(company)
    #check permissions on selected company
    $scope.checkPermissions(company)
    $rootScope.canViewSpecificItems = false
    if company.role.uniqueName is 'shared'
      $rootScope.canManageComp = false
      if company.sharedEntity is 'groups'
        $rootScope.canViewSpecificItems = true
      localStorageService.set("_selectedCompany", company)
      $rootScope.selectedCompany = company
      $state.go('company.content.ledgerContent')
      $rootScope.$emit('companyChanged')
    else
      $rootScope.canManageComp = true
      #$scope.goToCompany(company, index, "CHANGED")
      $rootScope.setCompany(company)
      $rootScope.selectedCompany.index = index
    $rootScope.$emit('reloadAccounts')
    changeData = {}
    changeData.data = company
    changeData.index = index
    changeData.type = method
    $rootScope.$emit('company-changed', changeData)
    #$scope.tabs[0].active = true

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

  $(document).on('click', ()->
    $scope.showCompanyList = false
  )


giddh.webApp.controller 'mainController', mainController