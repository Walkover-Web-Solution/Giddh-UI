'use strict'

manageController = ($scope, $rootScope, localStorageService, groupService, toastr, modalService, $timeout, accountService, locationService, ledgerService, $filter, permissionService, DAServices, $location, $uibModal, companyServices) ->
  mc = this
  mc.groupList = {}
  mc.flattenGroupList = []
  mc.moveto = undefined
  mc.selectedGroup = {}
  mc.selectedSubGroup = {}
  mc.selectedAccount = {}
  mc.selAcntPrevObj = {}
  mc.datePicker = {accountOpeningBalanceDate: ""}
  mc.selectedGroupUName = ""
  mc.cantUpdate = false
  mc.showGroupDetails = false
  mc.subGroupVisible = false
  mc.showListGroupsNow = false
  mc.showAccountDetails = false
  mc.showAccountListDetails = false
  mc.showMergeDescription = true
  mc.mergedAccounts = ''
  mc.showDeleteMove = false
  mc.AccountsList = []
  mc.groupAccntList = []
  mc.search = {}
  mc.search.acnt = ''
  mc.showEditTaxSection = false
  mc.shareGroupObj = {role: "view_only"}
  mc.shareAccountObj ={role: "view_only"}
  mc.openingBalType = [
    {"name": "Credit", "val": "CREDIT"}
    {"name": "Debit", "val": "DEBIT"}
  ]
  mc.acntExt = {
    Ccode: undefined,
    onlyMobileNo: undefined
  }
  mc.today = new Date()
  mc.valuationDatePickerIsOpen = false
  mc.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }
  mc.format = "dd-MM-yyyy"
  mc.flatAccntWGroupsList = []
  mc.showAccountList = false
  mc.selectedAccountUniqueName = undefined
  mc.flatAccntWGroupsList_1 = []
  mc.noGroups = false
  mc.hideLoadMore = false
  mc.hideAccLoadMore = false
  mc.isFixedAcc = false
  mc.gwaList = {
    page: 1
    count: 5
    totalPages: 0
    currentPage : 1
    limit: 5
  }

  mc.taxHierarchy = {}
  mc.taxHierarchy.applicableTaxes = []
  mc.taxHierarchy.inheritedTaxes = []
  mc.taxInEditMode = false
  mc.havePermission = false
  mc.columns = []
#  $scope.fltAccntListPaginated = []
#  $scope.flatAccList = {
#    page: 1
#    count: 5
#    totalPages: 0
#    currentPage : 1
#    limit: 5
#  }

  mc.selectedGrp = {}
  mc.selectedType = undefined

  mc.getSelectedType = (type) ->
    console.log (type)
    mc.selectedType = type
  

  mc.goToManageGroupsOpen = (res) ->
    console.log "manage opened", res

  mc.goToManageGroupsClose = () ->
    $scope.selectedGroup = {}
    groupService.getGroupsWithoutAccountsCropped($rootScope.selectedCompany.uniqueName).then(mc.getGroupListSuccess, mc.getGroupListFailure)


  mc.addHLevel = (groups, level) ->
    _.each groups, (grp) ->
      grp.hLevel = level
      if grp.groups.length > 0
        _.each grp.groups, (cGrp) ->
          cGrp.hLevel = grp.hLevel + 1
          if cGrp.groups.length > 0
            mc.addHLevel(cGrp.groups, cGrp.hLevel+1)


  mc.getGroupListSuccess = (res) ->
    mc.groupList = mc.addHLevel(res.body, 0)

  mc.getGroups =() ->
    groupService.getGroupsWithAccountsCropped($rootScope.selectedCompany.uniqueName).then(mc.getGroupListSuccess, mc.getGroupListFailure)

  mc.getGroups()




  mc.selectItem = (item) ->
    mc.selectedGrp = item
    console.log item
    existingGrp = _.findWhere(mc.columns, {uniqueName:item.uniqueName})
    groupService.get($rootScope.selectedCompany.uniqueName, item.uniqueName).then(mc.getGrpDtlSuccess, mc.getGrpDtlFailure)
    if !existingGrp
      groupData = {}
      groupData.uniqueName = item.uniqueName
      groupData.groups = item.groups
      groupData.accounts = item.accounts
      groupData.hLevel = item.hLevel
      if (item.hLevel-1) < mc.columns.length
        mc.columns = mc.columns.slice(0,item.hLevel)
      mc.columns[item.hLevel] = groupData
      # else
      #   mc.columns[item.hLevel] = groupData
    else
      groupData = {}
      groupData.groups = item.groups
      groupData.accounts = item.accounts
      existingGrp = groupData

  mc.shareLedger =() ->
    $uibModal.open(
      templateUrl: '/public/webapp/NewManageGroupsAndAccounts/shareLedger.html',
      size: "md",
      backdrop: 'true',
      animation: true,
      scope: $scope
    )

  mc.getGrpDtlSuccess = (res) ->
    mc.selectedItem = res.body
    console.log mc.selectedItem

  mc.getGrpDtlFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  mc.getAccDetail = (item) ->
    console.log item
    reqParam = {
      compUname: $rootScope.selectedCompany.uniqueName,
      acntUname: item.uniqueName
    }
    accountService.get(reqParam).then(mc.getAccDtlSuccess, mc.getAccDtlFailure)

  mc.getAccDtlSuccess = (res) ->
    mc.selectedAcc = res.body
    console.log mc.selectedAcc

  mc.getAccDtlFailure = (res) ->
    toastr.error(res.data.message, res.data.status)



  return mc

#init angular app
giddh.webApp.controller 'manageController', manageController