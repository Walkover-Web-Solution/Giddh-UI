logsController = ($scope, $rootScope, localStorageService, groupService, toastr, modalService, $timeout, accountService, locationService, ledgerService, $filter, permissionService, DAServices, $location, $uibModal) ->

  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  window.app.logs = {
    selectedCompany: $rootScope.selectedCompany
  }
  $scope.date = {}
  $scope.fromDate = {date: new Date()}
  $scope.toDate = {date: new Date()}
  $scope.beforeDate = {date: new Date()}
  $scope.date.logDate = new Date()
  $scope.date.entryDate = new Date()
  $scope.fromDatePickerIsOpen = false
  $scope.toDatePickerIsOpen = false
  $scope.logDatePickerIsOpen = false
  $scope.beforeDatePickerIsOpen = false
  $scope.today = new Date()
  $scope.date.name = 'entryDate'
  $scope.logDate = {
    show : true
  }
  $scope.groups = []
  $scope.accounts = []
  $scope.dateOptions = {
      'year-format': "'yy'",
      'starting-day': 1,
      'showWeeks': false,
      'show-button-bar': false,
      'year-range': 1,
      'todayBtn': false
    }
  $scope.format = "dd-MM-yyyy"
  
  $scope.fromDatePickerOpen = ->
    this.fromDatePickerIsOpen = true

  $scope.toDatePickerOpen = ->
    this.toDatePickerIsOpen = true

  $scope.logDatePickerOpen = ->
    this.logDatePickerIsOpen = true

  $scope.beforeDatePickerOpen = ->
    this.beforeDatePickerIsOpen = true

  $scope.getAccountsGroupsList = ()->
    $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
    $scope.showAccountList = false
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getGroupsWithAccountsInDetail($rootScope.selectedCompany.uniqueName).then($scope.getGroupsSuccess,
        $scope.getGroupsFailure)

  $scope.getGroupsSuccess = (res) ->
    $scope.groupList = res.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList, [])
    $scope.flatAccntWGroupsList = groupService.flattenGroupsAndAccounts($scope.flattenGroupList)
    $scope.sortGroupsAndAccounts($scope.flatAccntWGroupsList)

  $scope.getGroupsFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #sort groups and accounts lists
  
  $scope.sortGroupsAndAccounts =  (dataArray) ->
    $scope.groups = []
    $scope.accounts = []
    _.each dataArray,(obj) ->
      group = {}
      group.name = obj.groupName
      group.uniqueName = obj.groupUniqueName
      $scope.groups.push(group)
      if obj.accountDetails.length > 0
        _.each obj.accountDetails, (acc) ->
          account = {}
          account.name = acc.name
          account.uniqueName = acc.uniqueName
          $scope.accounts.push(account)
    $scope.options.accountUniqueNames = $scope.accounts
    $scope.options.groupUniqueNames = $scope.groups

  $scope.getAccountsGroupsList()

  $scope.$watch('options', (newVal, oldVal)->
    if newVal != oldVal
      window.app.logs.options = newVal;
  )

  $scope.options = {
    filters : ["All", "create", "delete", "share", "unshare", "move", "merge", "unmerge", "delete-all", "update", "master-import", "daybook-import", "ledger-excel-import"],
    entities: ["All", "company", "group", "account", "ledger", "voucher", "logs"],
    userUniqueNames: [],
    accountUniqueNames: $rootScope.fltAccntListPaginated || $scope.accounts,
    groupUniqueNames: $scope.groups,
    selectedOption: '',
    selectedEntity: '',
    selectedUserUnq: '',
    selectedAccountUnq: '',
    selectedGroupUnq: '',
    selectedFromDate: $filter('date')($scope.fromDate.date,"dd-MM-yyyy"),
    selectedToDate : $filter('date')($scope.toDate.date,"dd-MM-yyyy"),
    selectedLogDate: $filter('date')($scope.date.logDate,"dd-MM-yyyy"),
    selectedEntryDate: $filter('date')($scope.date.entryDate,"dd-MM-yyyy"),
    logOrEntry: $scope.date.name
    dateOptions: [{'name':'Date Range', 'value':1}, {"name":"Entry/Log Date", 'value':0}],
    selectedDateOption: ''
    toastr: toastr
  }

  $scope.initialOptions = $scope.options

  $scope.dateModel = ()->
    if $scope.logDate.show
      $scope.date.name = 'logDate'
    else
      $scope.date.name = 'entryDate'

  $scope.assignLogData = ()->
    $scope.options.selectedFromDate = $filter('date')($scope.fromDate.date,"dd-MM-yyyy")
    $scope.options.selectedToDate = $filter('date')($scope.toDate.date,"dd-MM-yyyy")
    $scope.options.selectedLogDate = $filter('date')($scope.date.logDate,"dd-MM-yyyy")
    $scope.options.selectedEntryDate = $filter('date')($scope.date.entryDate,"dd-MM-yyyy")
    $scope.options.logOrEntry = $scope.date.name
    #console.log $scope.options
    window.giddh.webApp.logs.filterOptions = $scope.options;


  $scope.getUsers = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
    }
    groupService.getUserList(unqNamesObj).then($scope.getUsersSuccess, $scope.getUsersFailure)

  $scope.getUsersSuccess = (res) ->
    $scope.users = res.body

  $scope.getUsersFailure = (res) ->
    console.error('Unable to fetch user list', res.statusText);

  $scope.getUsers()

  $scope.resetFilters = () ->
    $scope.options = {
      filters : ["All", "create", "delete", "share", "unshare", "move", "merge", "unmerge", "delete-all", "update", "master-import", "daybook-import", "ledger-excel-import"],
      entities: ["All", "company", "group", "account", "ledger", "voucher", "logs"],
      userUniqueNames: [],
      accountUniqueNames: $scope.fltAccntListPaginated,
      groupUniqueNames: $scope.groups,
      selectedOption: '',
      selectedEntity: '',
      selectedUserUnq: '',
      selectedAccountUnq: '',
      selectedGroupUnq: '',
      selectedFromDate: $filter('date')($scope.fromDate.date,"dd-MM-yyyy"),
      selectedToDate : $filter('date')($scope.toDate.date,"dd-MM-yyyy"),
      selectedLogDate: $filter('date')($scope.date.logDate,"dd-MM-yyyy"),
      selectedEntryDate: $filter('date')($scope.date.entryDate,"dd-MM-yyyy"),
      logOrEntry: $scope.date.name
      dateOptions: [{'name':'Date Range', 'value':1}, {"name":"Entry/Log Date", 'value':0}],
      selectedDateOption: ''
      toastr: toastr
    }

  $scope.deleteLogs = () ->
    modalService.openConfirmModal(
        title: 'Delete Logs',
        body: 'Are you sure you want to delete all logs before ' + $filter('date')($scope.beforeDate.date,"dd-MM-yyyy") + '?',
        ok: 'Yes',
        cancel: 'No').then($scope.deleteLogsConfirm)
    
  $scope.deleteLogsConfirm = () ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      beforeDate: $filter('date')($scope.beforeDate.date,"dd-MM-yyyy")
    }
    groupService.deleteLogs(reqParam).then($scope.deleteLogsConfirmSuccess, $scope.deleteLogsConfirmFailure)


  $scope.deleteLogsConfirmSuccess = (res) ->
    toastr.success(res.body)

  $scope.deleteLogsConfirmFailure = (res) ->
    toastr.error(res.data.message)

  $scope.checkPermissions = (entity) ->
    $rootScope.canUpdate = permissionService.hasPermissionOn(entity, "UPDT")
    $rootScope.canDelete = permissionService.hasPermissionOn(entity, "DLT")
    $rootScope.canAdd = permissionService.hasPermissionOn(entity, "ADD")
    $rootScope.canShare = permissionService.hasPermissionOn(entity, "SHR")
    $rootScope.canManageCompany = permissionService.hasPermissionOn(entity, "MNG_CMPNY")
    $rootScope.canVWDLT = permissionService.hasPermissionOn(entity, "VWDLT")

  $scope.checkPermissions($rootScope.selectedCompany)

  #---------get flat accounts list------#
  $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
  $scope.flatAccList = {
    page: 1
    count: 5
    totalPages: 0
    currentPage : 1
  }

  $scope.getFlatAccountList = (compUname) ->
    reqParam = {
      companyUniqueName: compUname
      q: ''
      page: $scope.flatAccList.page
      count: $scope.flatAccList.count
    }
    groupService.getFlatAccList(reqParam).then($scope.getFlatAccountListListSuccess, $scope.getFlatAccountListFailure)

  $scope.getFlatAccountListListSuccess = (res) ->
    $rootScope.fltAccntListPaginated = res.body.results

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

  window.giddh.webApp.toastr = toastr

#init angular app
giddh.webApp.controller 'logsController', logsController