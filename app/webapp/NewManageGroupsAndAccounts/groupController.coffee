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
  mc.createNew = false
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

# get selected account or grp to show/hide
  mc.getSelectedType = (type) ->
    console.log (type)
    mc.selectedType = type
    mc.createNew = false
# end

  mc.goToManageGroupsOpen = (res) ->
    console.log "manage opened", res

  mc.goToManageGroupsClose = () ->
    $scope.selectedGroup = {}
    groupService.getGroupsWithoutAccountsCropped($rootScope.selectedCompany.uniqueName).then(mc.getGroupListSuccess, mc.getGroupListFailure)

# add hierarchy level to track open column and asset
  mc.addHLevel = (groups, level) ->
    _.each groups, (grp) ->
      grp.hLevel = level
      if grp.groups.length > 0
        _.each grp.groups, (cGrp) ->
          cGrp.hLevel = grp.hLevel + 1
          if cGrp.groups.length > 0
            mc.addHLevel(cGrp.groups, cGrp.hLevel+1)
# end


  mc.getGroupListSuccess = (res) ->
    mc.groupList = mc.addHLevel(res.body, 0)

  mc.getGroups =() ->
    groupService.getGroupsWithAccountsCropped($rootScope.selectedCompany.uniqueName).then(mc.getGroupListSuccess, mc.getGroupListFailure)

  mc.getGroups()


# get selected group or account
  mc.selectItem = (item) ->
    mc.selectedGrp = item
    mc.selectedGrp.oldUName = item.uniqueName
    mc.createNew = false
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
# end

# get group details
  mc.getGrpDtlSuccess = (res) ->
    mc.selectedItem = res.body
    console.log mc.selectedItem

  mc.getGrpDtlFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
# end

# Open share modal
  mc.shareLedger =() ->
    $uibModal.open(
      templateUrl: '/public/webapp/NewManageGroupsAndAccounts/shareLedger.html',
      size: "md",
      backdrop: 'true',
      animation: true,
      scope: $scope
    )
# end


# add sub groups
  mc.addNewSubGroup = () ->
    # UNameExist = _.contains(mc.groupList, mc.selectedItem.uniqueName)
    body = {
      "name": mc.selectedItem.name,
      "uniqueName": mc.selectedItem.uniqueName,
      "parentGroupUniqueName": mc.selectedGrp.uniqueName,
      "description": mc.selectedItem.description
    }
    groupService.create($rootScope.selectedCompany.uniqueName, body).then(mc.onCreateGroupSuccess,mc.onCreateGroupFailure)

  mc.onCreateGroupSuccess = (res) ->
    mc.columns[mc.addToIndex].groups.push(res.body)
    toastr.success("Sub group added successfully", "Success")

  mc.onCreateGroupFailure = (res) ->
    console.log (res)
    toastr.error(res.data.message, res.data.status)
# end



# update subgroup
  mc.updateGroup = (form) ->
    console.log form
    grp = {}
    grp = _.extend(grp, mc.selectedGrp)
    grp.name = form.grpName.$viewValue
    grp.uniqueName = form.grpUnq.$viewValue
    grp.description = form.grpDescription.$viewValue
    if not mc.selectedGrp.fixed
      if mc.selectedGrp.applicableTaxes != undefined && mc.selectedGrp.applicableTaxes.length > 0
        mc.selectedGrp.applicableTaxes = _.pluck(mc.selectedGrp.applicableTaxes, 'uniqueName')
      groupService.update($rootScope.selectedCompany.uniqueName, grp).then(mc.onUpdateGroupSuccess,
          mc.onUpdateGroupFailure)

  mc.onUpdateGroupSuccess = (res) ->
    mc.selectedGrp.oldUName = mc.selectedGrp.uniqueName
    mc.selectedGrp.applicableTaxes = res.body.applicableTaxes
    if not _.isEmpty(mc.selectedGrp)
      mc.selectedItem = mc.selectedGrp
    toastr.success("Group has been updated successfully.", "Success")
    mc.getGroups()

  mc.onUpdateGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
# end


# delete groups
  mc.deleteGroup = () ->
    if not mc.selectedGrp.isFixed
      modalService.openConfirmModal(
        title: 'Delete group?',
        body: 'Are you sure you want to delete this group? All child groups will also be deleted.',
        ok: 'Yes',
        cancel: 'No').then(mc.deleteGroupConfirm)

  mc.deleteGroupConfirm = () ->
    groupService.delete($rootScope.selectedCompany.uniqueName,mc.selectedGrp).then(mc.onDeleteGroupSuccess,mc.onDeleteGroupFailure)

  mc.onDeleteGroupSuccess = () ->
    toastr.success("Group deleted successfully.", "Success")
    mc.selectedGrp = {}
    mc.showGroupDetails = false
    mc.showAccountListDetails = false
    mc.getGroups()

  mc.onDeleteGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
# end


# add grp to same column
  mc.createNewGrpAccount = (index) ->
    mc.addToIndex = index
    mc.toggleView(true)


# get account details under groups and sub groups
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
# end

# show create new div 
  mc.toggleView = () ->
    mc.createNew = true
    mc.selectedItem = {}
    mc.selectedAcc = {}
# end


  return mc

#init angular app
giddh.webApp.controller 'manageController', manageController