'use strict'

manageController = ($scope, $rootScope, localStorageService, groupService, toastr, $http, modalService, $timeout, accountService, locationService, ledgerService, $filter, permissionService, DAServices, $location, $uibModal, companyServices) ->
  mc = this
  mc.groupList = []
  mc.flattenGroupList = []
  mc.moveto = undefined
  mc.selAcntPrevObj = {}
  mc.datePicker = {accountOpeningBalanceDate: ""}
  mc.selectedGroupUName = ""
  mc.cantUpdate = false
  mc.showGroupDetails = false
  mc.showListGroupsNow = false
  mc.showAccountDetails = false
  mc.showAccountListDetails = false
  mc.showDeleteMove = false
  mc.AccountsList = []
  mc.groupAccntList = []
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
  mc.showAccountList = false
  mc.isFixedAcc = false

  mc.taxHierarchy = {}
  mc.taxHierarchy.applicableTaxes = []
  mc.taxHierarchy.inheritedTaxes = []
  mc.taxInEditMode = false
  mc.columns = []
  mc.searchColumns = []
  mc.createNew = false
  mc.gstDetail = []
  mc.keyWord = ""
#  $scope.fltAccntListPaginated = []
#  $scope.flatAccList = {
#    page: 1
#    count: 5
#    totalPages: 0
#    currentPage : 1
#    limit: 5
#  }
  mc.selectedTax = {}
  mc.selectedTax.taxes = ''

  mc.selectedGrp = {}
  mc.selectedType = undefined
  mc.breadcrumbs = []
  mc.showOnUpdate = false
  mc.prePopulate = []
  mc.getMergeAcc = []
  mc.breadCrumbList = []
  # mc.updateBreadCrumbs = true
  mc.updateSearchItem = false
  mc.radioModel = null
  mc.showDefaultGstList = true
  mc.showDefaultGst = 2
  mc.stateDetail = undefined
  mc.radioModel = ""
  mc.createNewAcc = false
  mc.createNewGrp = false
# get selected account or grp to show/hide
  mc.getSelectedType = (type) ->
    mc.selectedType = type
    if mc.selectedType == 'acc'
      if mc.breadCrumbList.length > 1
        if mc.breadCrumbList[1].uniqueName == 'sundrycreditors' || mc.breadCrumbList[1].uniqueName == 'sundrydebtors'
          mc.addNewGst()
    mc.createNew = false
# end


  $rootScope.$on('Open-Manage-Modal', ()->
      mc.NewgoToManageGroups() 
    )

  #show breadcrumbs
  mc.showBreadCrumbs = (data) ->
    mc.showBreadCrumb = true

  # mc.NewgoToManageGroups =() ->
  #   if !$rootScope.canManageComp
  #     return
  #   if _.isEmpty($rootScope.selectedCompany)
  #     toastr.error("Select company first.", "Error")
  #   else
  #     modalInstance = $uibModal.open(
  #       templateUrl: $rootScope.prefixThis+'/public/webapp/NewManageGroupsAndAccounts/ManageGroupModal.html'
  #       size: "liq90"
  #       backdrop: 'static'
  #       scope: $scope
  #     )
  #     modalInstance.result.then(mc.goToManageGroupsOpen, mc.goToManageGroupsClose)


  mc.goToManageGroupsOpen = (res) ->
    # console.log "manage opened", res

  mc.goToManageGroupsClose = () ->
    mc.selectedItem = undefined
    mc.showGroupDetails = false
    mc.showAccountDetails = false
    mc.showAccountListDetails = false
    mc.cantUpdate = false
    mc.selectedTax.taxes = {}
    mc.showEditTaxSection = false

# add hierarchy level to track open column and asset
  mc.addHLevel = (groups, level) ->
    _.each groups, (grp) ->
      grp.hLevel = level
      if grp.groups.length > 0
        mc.addHLevel(grp.groups, grp.hLevel+1)
        
# end

  mc.getGroupListSuccess = (res) ->
    mc.showNoResult = false
    res.body = mc.orderGroups(res.body)
    mc.searchLoad = false
    mc.columns = []
    mc.showListGroupsNow = true
    col = {}
    col.groups = mc.addHLevel(res.body, 0)
    col.accounts = []
    mc.columns.push(col)
    if mc.breadCrumbList.length
      mc.updateAll(res.body)
    mc.flattenGroupList = groupService.flattenGroup(res.body, [])

  mc.getGroupListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  mc.getGroupListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  mc.getGroups =() ->
    mc.searchLoad = true
    groupService.getGroupsWithAccountsCropped($rootScope.selectedCompany.uniqueName).then(mc.getGroupListSuccess, mc.getGroupListFailure)

  mc.getGroups()

  mc.orderGroups = (data) ->
    orderedGroups = []
    assets = []
    liabilities = []
    income = []
    expenses = []
    _.each data, (grp) ->
      switch grp.category
        when 'assets'
          assets.push(grp)
          # $scope.balSheet.assets.push(grp)
        when 'liabilities'
          liabilities.push(grp)
          # $scope.balSheet.liabilities.push(grp)
        when 'income'
          income.push(grp)
        when 'expenses'
          expenses.push(grp)
        else
          assets.push(grp)
    _.each liabilities, (liability) ->
      orderedGroups.push(liability)
    _.each assets, (asset) ->
      orderedGroups.push(asset) 
    _.each income, (inc) ->
      orderedGroups.push(inc)
    _.each expenses, (exp) ->
      orderedGroups.push(exp)
    orderedGroups


  # mc.selectItemAfterUpdate = (item, fromApi) ->

  mc.populateAccountList = (item) ->
    result = groupService.matchAndReturnGroupObj(item, mc.flattenGroupList)
    mc.groupAccntList = result.accounts

  mc.updateAll = (groupList) ->
    mc.fixedParentGroup = undefined
    _.each mc.breadCrumbList, (item, i) ->
      currentItem = _.findWhere(groupList, {uniqueName:item.uniqueName})
      if currentItem
        mc.selectItem(currentItem, false)
        mc.fixedParentGroup = currentItem
        ###set selcted item class####
        _.each mc.columns[i].groups, (grp, idx) ->
          if grp.uniqueName == currentItem.uniqueName
            mc.selectActiveItems(mc.columns[i], 'grp', idx)
      else if !currentItem
        if mc.fixedParentGroup.groups
          currentItem = _.findWhere(mc.selectedItem.groups, {uniqueName:item.uniqueName})
          mc.selectItem(currentItem, false)
          ###set selcted item class####
          _.each mc.columns[i].groups, (grp, index) ->
            if grp.uniqueName == currentItem.uniqueName
              mc.selectActiveItems(mc.columns[i], 'grp', index)
        else
          currentItem = _.findWhere(mc.selectedItem.accounts, {uniqueName:item.uniqueName})
          mc.getAccDetail(currentItem, i)
          ###set selcted item class####
          _.each mc.columns[i].accounts, (grp, index) ->
            if grp.uniqueName == currentItem.uniqueName
              mc.selectActiveItems(mc.columns[i], 'acc', index)



  mc.getItemIndex = (list, item, key) ->
    idx = null
    matchCount = 0
    _.each list, (crumb, index) ->
      if crumb[key] == item[key]
        matchCount += 1
        if matchCount == 1
          idx = index
    return idx

# create breadcrumbs list
  mc.addToBreadCrumbs = (item, type, accIndex) ->
    item.type = type
    # if type == 'account'
    #   mc.breadCrumbList[mc.breadCrumbList.length] = item 
    #   return 0
    itemExists = _.findWhere(mc.breadCrumbList, {uniqueName:item.uniqueName,type:item.type})
    if item.hLevel == 0
      mc.breadCrumbList = []
      mc.breadCrumbList.push(item)
      return 0
    if !itemExists
      hLevelMatch = _.findWhere(mc.breadCrumbList, {hLevel:item.hLevel})
      if !hLevelMatch
        mc.breadCrumbList.push(item)
      else
        idx = mc.getItemIndex(mc.breadCrumbList, item, 'hLevel')
        if idx != null
          mc.breadCrumbList.length = idx
          mc.breadCrumbList.push(item)
    else
      idx = mc.getItemIndex(mc.breadCrumbList, item, 'uniqueName')
      if idx != null
        mc.breadCrumbList.length = idx+1

# get selected group or account
  mc.selectItem = (item, updateBreadCrumbs, parentIndex, currentIndex) ->
    mc.updateBreadCrumbs = true
    mc.parentIndex = parentIndex
    mc.currentIndex = currentIndex
    mc.selectedType = 'grp'
    if item.hLevel == undefined
      item.hLevel = parentIndex + 1
    if mc.keyWord != undefined
      if mc.keyWord.length > 3
        mc.updateSearchItem = true
        mc.updateSearchhierarchy(item)
    if mc.breadCrumbList.length > 0
      if item.uniqueName == mc.breadCrumbList[mc.breadCrumbList.length-1].uniqueName && mc.parentIndex == item.hLevel
        mc.updateBreadCrumbs = false
    if updateBreadCrumbs && mc.updateBreadCrumbs
      mc.addToBreadCrumbs(item, 'grp')
    mc.selectedGrp = item
    mc.grpCategory = item.category
    mc.showEditTaxSection = false
    mc.selectedGrp.oldUName = item.uniqueName
    mc.getGroupSharedList(item)
    # mc.createNew = false
    mc.showOnUpdate = true
    existingGrp = _.findWhere(mc.columns, {uniqueName:item.uniqueName})
    mc.selectedItem = mc.selectedGrp
    groupService.get($rootScope.selectedCompany.uniqueName, item.uniqueName).then(mc.getGrpDtlSuccess, mc.getGrpDtlFailure)
    mc.getCurrentColIndex = undefined
    if !existingGrp
      if (item.hLevel-1) < mc.columns.length
        mc.columns = mc.columns.splice(0,item.hLevel+1)
        mc.columns.push(item)
    else
      existingGrp = item
      mc.columns = mc.columns.splice(0,item.hLevel+1)
      mc.columns.push(item)
    if parentIndex <= mc.columns.length-1 && mc.keyWord != undefined
      mc.checkCurrentColumn(parentIndex)
    if mc.breadCrumbList.length < 1 && mc.columns.length > 2
      mc.breadCrumbList = item.parentGroups

  mc.getGrpDtlSuccess = (res) ->
    mc.selectedItem = res.body
    # mc.populateAccountList(res.body)
    # if mc.parentIndex != undefined
    #   mc.columns.length = mc.parentIndex + 2
    if mc.createNewGrp
      mc.showOnUpdate = false
      mc.selectedItem = {}
    else if mc.createNewAcc
      mc.showOnUpdate = false
      mc.selectedAcc = {}
      mc.selectedType = 'acc'
    mc.createNewGrp = false
    mc.createNewAcc =  false
    mc.getColsCount()



  mc.getGrpDtlFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
# end

# set active item with respect to column
  mc.selectActiveItems = (col, type, index) ->
    col.active = {}
    col.active.type = type
    col.active.index = index
    mc.col = col

  mc.resetActive = () ->
    _.each mc.columns, (col) ->
      delete col.active

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
    # mc.keyWord = ''
    res.body.hLevel = mc.addToIndex
    res.body.accounts = res.body.accounts || []
    res.body.parentGroups = mc.breadCrumbList
    mc.flattenGroupList.push(res.body)
    mc.columns[mc.addToIndex].groups.push(res.body)
    toastr.success("Sub group added successfully", "Success")
    # mc.selectedItem = {}
    # mc.getGroups()
    mc.selectItem(mc.columns[mc.columns.length-1], false, mc.parentIndex, mc.currentIndex)
    mc.createNewGrp = true

  mc.onCreateGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
# end



# update subgroup
  mc.updateGroup = (form) ->
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

  mc.onUpdateGroupSuccess = (res, i) ->
    updateAtIndex = null
    mc.selectedGrp.oldUName = mc.selectedGrp.uniqueName
    mc.selectedGrp.applicableTaxes = res.body.applicableTaxes
    if not _.isEmpty(mc.selectedGrp)
      mc.selectedItem = mc.selectedGrp
    _.each mc.breadCrumbList, (item,i) ->
      if item.uniqueName == mc.selectedGrp.oldUName
        updateAtIndex = i
    if updateAtIndex
      mc.breadCrumbList[updateAtIndex] = res.body
    toastr.success("Group has been updated successfully.", "Success")
    mc.breadCrumbList.pop()
    angular.merge(mc.selectedGrp, res.body)
    mc.selectedItem = mc.breadCrumbList[mc.breadCrumbList.length-1]
    mc.selectItem(mc.selectedGrp, true, mc.parentIndex, mc.currentIndex)
    # mc.getGroups()
    # mc.selectActiveItems(mc.col.groups[i], 'grp', updateAtIndex)
    # mc.selectActiveItems(mc.selectedItem, false)

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
    mc.selectedItem = {}
    mc.showGroupDetails = false
    mc.showAccountListDetails = false
    mc.breadCrumbList.pop()
    # mc.getGroups()
    # mc.columns[mc.parentIndex].groups.pop()
    mc.selectItem(mc.breadCrumbList[mc.breadCrumbList.length-1], true, mc.parentIndex, mc.currentIndex)

  mc.onDeleteGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
# end


# add grp to same column
  mc.createNewGrpAccount = (index) ->
    mc.addToIndex = index
    mc.toggleView(true)
    mc.showOnUpdate = false
    # if mc.breadCrumbList[mc.breadCrumbList.length-1].type == 'account'
    #   mc.breadCrumbList.pop()
    # if mc.breadCrumbList[mc.breadCrumbList.length-1].type == 'grp'
    if mc.addToIndex == mc.parentIndex || mc.addToIndex == mc.getCurrentColIndex
      if mc.breadCrumbList[mc.breadCrumbList.length-1].type == 'account'
        mc.breadCrumbList.pop()
        mc.getCurrentColIndex = undefined
      else
        mc.parentIndex = undefined
        mc.getCurrentColIndex = undefined
        mc.breadCrumbList.pop()
        mc.selectedGrp = mc.breadCrumbList[mc.breadCrumbList.length-1]
        mc.updateBreadCrumbs = false
        mc.columns = mc.columns.splice(0,mc.addToIndex+1)
        mc.selectedItem = {}
        mc.selectedAcc = {}
    # if mc.keyWord != undefined
    #   mc.breadCrumbList = []
    #   mc.keyWord = undefined
    else
      mc.columns = mc.columns.splice(0,mc.addToIndex+1)
      mc.breadCrumbList.splice(mc.addToIndex)
      mc.selectItem(mc.columns[mc.columns.length-1])
      mc.parentIndex = mc.breadCrumbList[mc.breadCrumbList.length-1].hLevel
    mc.gstDetail = []

# get account details under groups and sub groups
  mc.getAccDetail = (item, parentIndex, currentIndex) ->
    mc.selectedAcc = item
    mc.showOnUpdate = true
    mc.showDeleteMove = false
    mc.getCurrentColIndex = parentIndex
    mc.currentAccIndex = currentIndex
    item.hLevel = mc.getCurrentColIndex
    mc.selectedType = 'acc'
    if mc.keyWord != undefined
      if mc.keyWord.length >= 3
        mc.updateSearchItem = true
        mc.updateSearchhierarchy(item)
    reqParam = {
      compUname: $rootScope.selectedCompany.uniqueName,
      acntUname: item.uniqueName
    }
    accountService.get(reqParam).then(mc.getAccDtlSuccess, mc.getAccDtlFailure)
    mc.parentIndex = undefined
    mc.updateBreadCrumbs = true
    if mc.updateBreadCrumbs
      mc.addToBreadCrumbs(item, 'account', parentIndex)
    mc.toMerge.toUnMerge.uniqueNames = null


  mc.getAccDtlSuccess = (res, data) ->
    data = res.body
    mc.selectedAcc = res.body
    mc.getServiceCode(mc.selectedAcc.hsnNumber, mc.selectedAcc.sacNumber)
    mc.getMergeAcc = mc.selectedAcc.mergedAccounts.replace(RegExp(' ', 'g'), '')
    if mc.getMergeAcc.indexOf(',') != -1
      mc.getMergeAcc = mc.getMergeAcc.split(",")
    else if mc.selectedAcc.mergedAccounts.length > 1
      mc.getMergeAcc = [mc.selectedAcc.mergedAccounts]
    mc.AccountCategory = mc.getAccountCategory(data.parentGroups)
    mc.getMergedAccounts(data)
    if data.uniqueName is $rootScope.selAcntUname
      mc.cantUpdate = true
    _.extend(mc.selAcntPrevObj, data)
    _.extend(mc.selectedAcc, data)
    # mc.breakMobNo(data)
    mc.acntCase = "Update"
    mc.setOpeningBalanceDate()
    mc.getAccountSharedList()
    mc.isFixedAcc = res.body.isFixed
    mc.showBreadCrumbs(data.parentGroups)
    mc.selectedAcc = res.body
    mc.columns.length = mc.getCurrentColIndex+1
    mc.gstDetail = res.body.gstDetails
    mc.getColsCount()
    # mc.fetchingUnq = false
    if mc.selectedAcc.parentGroups[1].uniqueName == 'sundrycreditors' || mc.selectedAcc.parentGroups[1].uniqueName == 'sundrydebtors'
      if mc.gstDetail.length < 1
        mc.addNewGst()

  mc.addNewGst = () ->
    gstDetail = {
      gstNumber: "",
      addressList: [
          {
            address:"",
            stateCode: "",
            stateName: ""
          }
      ]
    }
    mc.gstDetail.unshift(gstDetail)

  mc.deleteGst = (obj, i) ->
    mc.gstDetail.splice(i,1)

  mc.getAccDtlFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
# end

# show create new div 
  mc.toggleView = () ->
    mc.createNew = true
    mc.selectedItem = {}
    mc.selectedAcc = {}
# end

# get tax list
  mc.getTaxList = () ->
    companyServices.getTax($rootScope.selectedCompany.uniqueName).then(mc.getTaxSuccess, mc.getTaxFailure)

  mc.getTaxSuccess = (res) ->
    mc.taxList = res.body

  mc.getTaxFailure = (res) ->
    toastr.error(res.data.message)
# end

# getTaxHierarchy on edit button
  mc.getTaxHierarchy = (type) ->
    mc.getTaxList()
    if type == 'group'
      groupService.getTaxHierarchy($rootScope.selectedCompany.uniqueName,mc.selectedGrp.uniqueName).then(mc.getTaxHierarchyOnSuccess,mc.getTaxHierarchyOnFailure)
    else if type == 'account'
      accountService.getTaxHierarchy($rootScope.selectedCompany.uniqueName, mc.selectedAcc.uniqueName).then(mc.getTaxHierarchyOnSuccess,mc.getTaxHierarchyOnFailure)

  mc.getTaxHierarchyOnSuccess = (res) ->
    mc.taxHierarchy = res.body
    mc.selectedTax.taxes = mc.taxHierarchy.applicableTaxes
    mc.showEditTaxSection = true
    mc.allInheritedTaxes = []
    mc.createInheritedTaxList(mc.taxHierarchy.inheritedTaxes)

  mc.getTaxHierarchyOnFailure = (res) ->
    toastr.error(res.data.message)

# end


  mc.createInheritedTaxList = (inTaxList) ->
#get all taxes by uniqueName
    mc.inTaxUnq = []
    _.each inTaxList, (tax) ->
      _.each tax.applicableTaxes, (inTax) ->
        mc.inTaxUnq.push(inTax.uniqueName)
    mc.inTaxUnq = _.uniq(mc.inTaxUnq)

    # match groups with tax uniqueNames
    _.each mc.inTaxUnq, (unq) ->
      tax = {}
      tax.uniqueName = unq
      tax.groups = []
      _.each inTaxList, (inTax) ->
        _.each mc.inTax.applicableTaxes, (inAppTax) ->
          if tax.uniqueName == inAppTax.uniqueName
            grp = {}
            grp.name = inTax.name
            grp.uniqueName = inTax.uniqueName
            tax.name = inAppTax.name
            tax.groups.push(grp)
      mc.allInheritedTaxes.push(tax)


  mc.isAccount = false
  mc.assignTax = (dataToSend) ->
    companyServices.assignTax($rootScope.selectedCompany.uniqueName,dataToSend).then(mc.assignTaxOnSuccess,mc.assignTaxOnFailure)

  mc.assignTaxOnSuccess = (res) ->
    mc.showEditTaxSection = false
    toastr.success(res.body)
    if not mc.isAccount
      groupService.get($rootScope.selectedCompany.uniqueName, mc.selectedGrp.uniqueName).then(mc.getGrpDtlSuccess,
          mc.getGrpDtlFailure)
    else
      reqParams = {
        compUname: $rootScope.selectedCompany.uniqueName
        acntUname: mc.selectedAcc.uniqueName
      }
      accountService.get(reqParams).then(mc.getAccDtlSuccess, mc.getAccDtlFailure)



  mc.assignTaxOnFailure = (res) ->
    mc.showEditTaxSection = false
    toastr.error(res.data.message)

  mc.applyTax = (type) ->
    if _.isEmpty(type)
      toastr.warning("Please do not mess with html.")
    else
      # We have to send all the taxes
      mc.mergeTaxes = []
      mc.mergeTaxes.push(mc.taxHierarchy.applicableTaxes)
      mc.mergeTaxes.push(_.pluck(mc.taxHierarchy.inheritedTaxes, 'applicableTaxes'))
      mc.sendThisList = _.pluck(_.flatten(mc.mergeTaxes),'uniqueName')
      mc.getSendTax = mc.sendThisList
      data = {}
      if type == 'group'
        data = [{"uniqueName":mc.selectedGrp.uniqueName, "taxes":mc.sendThisList,"isAccount":false}]
        mc.isAccount = false
      else if type == 'account'
        data = [{"uniqueName":mc.selectedAcc.uniqueName, "taxes":mc.sendThisList,"isAccount":true}]
        mc.isAccount = true
      mc.assignTax(data)

  # fetch taxes
  mc.alreadyAppliedTaxes = (tax) ->
    mc.inheritTax = _.pluck(mc.taxHierarchy.inheritedTaxes,'applicableTaxes')
    mc.applicableTaxes = _.flatten(mc.taxHierarchy)
    mc.applicableTaxes.push(mc.inheritTax)
    checkInThis = _.pluck(_.flatten(mc.applicableTaxes),'uniqueName')
    condition = _.contains(checkInThis, tax.uniqueName)

  mc.removeAppliedtax = (tax, type) ->
    idx = null
    _.each mc.taxHierarchy.applicableTaxes, (tx, i) ->
      if tx.uniqueName == tax.uniqueName
        idx = i
    mc.taxHierarchy.applicableTaxes.splice(idx, 1)
    mc.applyTax(type)
#end

# move group
  mc.moveGroup = (group) ->
    if _.isUndefined(group.uniqueName)
      toastr.error("Select group only from list", "Error")
      return

    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: mc.selectedItem.uniqueName
    }
    body = {
      "parentGroupUniqueName": group.uniqueName
    }
    groupService.move(unqNamesObj, body).then(mc.onMoveGroupSuccess, mc.onMoveGroupFailure)

  mc.onMoveGroupSuccess = (res) ->
    mc.moveto = undefined
    toastr.success("Group moved successfully.", "Success")
    mc.breadCrumbList.pop()
    mc.getGroups()
    mc.columns[mc.parentIndex].groups.pop()
    mc.selectItem(mc.breadCrumbList[mc.breadCrumbList.length-1], true, mc.parentIndex, mc.currentIndex)
    mc.selectedItem = mc.breadCrumbList[mc.breadCrumbList.length-1]

  mc.onMoveGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)



# share group
  mc.shareGrpModal = () ->
    $uibModal.open(
      templateUrl: '/public/webapp/NewManageGroupsAndAccounts/shareGroup.html',
      size: "md",
      backdrop: 'true',
      animation: true,
      scope: $scope
    )

  mc.shareGroup = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: mc.selectedGrp.uniqueName
    }
    groupService.share(unqNamesObj, mc.shareGroupObj).then(mc.onShareGroupSuccess, mc.onShareGroupFailure)

  mc.onShareGroupSuccess = (res) ->
    mc.shareGroupObj = {
      role: "view_only"
      user: ""
    }
    toastr.success(res.body, res.status)
    mc.getGroupSharedList(mc.selectedGrp)
    mc.shareGroupObj.user = ''

  mc.onShareGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


# get Shared Group List
  mc.getGroupSharedList = () ->
    # if $scope.canShare
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: mc.selectedGrp.uniqueName
    }
    groupService.sharedList(unqNamesObj).then(mc.onsharedListSuccess, mc.onsharedListFailure)

  mc.onsharedListSuccess = (res) ->
    mc.groupSharedUserList = res.body

  mc.onsharedListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  #unShare group with user
  mc.unShareGroup = (user) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: mc.selectedGrp.uniqueName
    }
    data = {
      user: user
    }
    groupService.unshare(unqNamesObj, data).then(mc.unShareGroupSuccess, mc.unShareGroupFailure)

  mc.unShareGroupSuccess = (res)->
    toastr.success(res.body, res.status)
    mc.getGroupSharedList(mc.selectedGrp)
    mc.shareGroupObj.user = ""

  mc.unShareGroupFailure = (res)->
    toastr.error(res.data.message, res.data.status)



# add Account

  mc.getAccountCategory = (parentGroups) ->
    pg = parentGroups[0]['uniqueName']
    grp = _.findWhere(mc.flattenGroupList, {uniqueName:pg})
    grp.category



  # prepare date object
  mc.setOpeningBalanceDate = () ->
    if mc.selectedAcc.openingBalanceDate
      newDateObj = mc.selectedAcc.openingBalanceDate.split("-")
      mc.datePicker.accountOpeningBalanceDate = new Date(newDateObj[2], newDateObj[1] - 1, newDateObj[0])
    else
      mc.datePicker.accountOpeningBalanceDate = new Date()



  mc.setAdditionalAccountDetails = ()->
    mc.selectedAcc.openingBalanceDate = $filter('date')(mc.datePicker.accountOpeningBalanceDate,"dd-MM-yyyy")
    if(_.isUndefined(mc.selectedAcc.mobileNo) || _.isEmpty(mc.selectedAcc.mobileNo))
      mc.selectedAcc.mobileNo = ""
    if(_.isUndefined(mc.selectedAcc.email) || _.isEmpty(mc.selectedAcc.email))
      mc.selectedAcc.email = ""
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: mc.selectedGrp.uniqueName
      acntUname: mc.selectedAcc.uniqueName
    }




  mc.addAccount = () ->
    unqNamesObj = mc.setAdditionalAccountDetails()
    accountService.createAc(unqNamesObj, mc.selectedAcc).then(mc.addAccountSuccess, mc.addAccountFailure)
    # mc.breadCrumbList = undefined
    mc.stateDetail = mc.stateDetail
    mc.removeBlankGst(mc.gstDetail)
    mc.selectedAcc.gstDetails = mc.gstDetail

  mc.addAccountSuccess = (res) ->
    toastr.success("Account created successfully", res.status)
    mc.selectedAcc = {}
    abc = _.pick(res.body, 'name', 'uniqueName', 'mergedAccounts','applicableTaxes','parentGroups')
    mc.groupAccntList.push(abc)
    mc.columns[mc.addToIndex].accounts.push(res.body)
    # $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    mc.getSelectedType('acc')
    mc.selectItem(mc.columns[mc.columns.length-1], true, mc.parentIndex, mc.currentIndex)
    mc.updateBreadCrumbs = true
    mc.createNewAcc = true
    # mc.columns = []
    # mc.getGroups()
    
  mc.addAccountFailure = (res) ->
    if mc.breadCrumbList[1].uniqueName == 'sundrycreditors' || mc.breadCrumbList[1].uniqueName == 'sundrydebtors'
      if mc.gstDetail.length < 1
        mc.addNewGst()
    toastr.error(res.data.message, res.data.status)


  mc.updateAccount = () ->
    unqNamesObj = mc.setAdditionalAccountDetails()
#    if angular.equals(mc.selectedAcc, mc.selAcntPrevObj)
#      toastr.info("Nothing to update", "Info")
#      return false
    delete mc.selectedAcc.stocks
    delete mc.selectedAcc.createdBy
    delete mc.selectedAcc.role

    if mc.selectedAcc.openingBalanceType == null
      mc.selectedAcc.openingBalanceType = 'credit'

    if mc.selectedAcc.uniqueName isnt mc.selAcntPrevObj.uniqueName
      unqNamesObj.acntUname = mc.selAcntPrevObj.uniqueName

    if _.isEmpty(mc.selectedGrp)
      lastVal = _.last(mc.selectedAcc.parentGroups)
      unqNamesObj.selGrpUname = lastVal.uniqueName

    if mc.selectedAcc.applicableTaxes.length > 0
      mc.selectedAcc.applicableTaxes = _.pluck(mc.selectedAcc.applicableTaxes,'uniqueName')

    mc.removeBlankGst(mc.gstDetail)

    mc.selectedAcc.gstDetails = mc.gstDetail

    accountService.updateAc(unqNamesObj, mc.selectedAcc).then(mc.updateAccountSuccess,
        mc.updateAccountFailure)


  mc.updateAccountSuccess = (res) ->
    updateAtIndex = null
    toastr.success("Account updated successfully", res.status)
    angular.merge(mc.selectedAcc, res.body)
    abc = _.pick(mc.selectedAcc, 'name', 'uniqueName', 'mergedAccounts')
    if !_.isEmpty(mc.selectedGrp)
      _.find(mc.groupAccntList, (item, index) ->
        if item.uniqueName == mc.selAcntPrevObj.uniqueName
          angular.merge(mc.groupAccntList[index], abc)
      )
    _.each mc.breadCrumbList, (item,i) ->
      if item.uniqueName == mc.selectedAcc.uniqueName
        updateAtIndex = i
    if updateAtIndex
      mc.breadCrumbList[updateAtIndex] = res.body
    # end if
    mc.breadCrumbList.pop()
    angular.merge(mc.selAcntPrevObj, res.body)
    mc.columns[mc.columns.length-1].accounts.splice(mc.currentAccIndex, 1, res.body)
    mc.getAccDetail(mc.selectedAcc, mc.getCurrentColIndex, mc.currentAccIndex)

  mc.updateAccountFailure = (res) ->
    if mc.breadCrumbList[1].uniqueName == 'sundrycreditors' || mc.breadCrumbList[1].uniqueName == 'sundrydebtors'
      if mc.gstDetail.length < 1
        mc.addNewGst()
    toastr.error(res.data.message, res.data.status)


  mc.deleteAccount = ->
    if $scope.canDelete
      modalService.openConfirmModal(
        title: 'Delete Account?',
        body: 'Are you sure you want to delete this Account?',
        ok: 'Yes',
        cancel: 'No').then(mc.deleteAccountConfirm)

  mc.deleteAccountConfirm = ->
    unqNamesObj = mc.setAdditionalAccountDetails()
    if mc.selectedAcc.uniqueName isnt mc.selAcntPrevObj.uniqueName
      unqNamesObj.acntUname = mc.selAcntPrevObj.uniqueName
    if _.isEmpty(mc.selectedGrp)
      unqNamesObj.selGrpUname = mc.selectedAcc.parentGroups[0].uniqueName
    accountService.deleteAc(unqNamesObj, mc.selectedAcc).then(mc.moveAccntSuccess, mc.onDeleteAccountFailure)

  mc.onDeleteAccountFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  mc.isCurrentGroup =(group) ->
    group.uniqueName is mc.selectedAcc.parentGroups[0].uniqueName || group.uniqueName is mc.selectedAcc.parentGroups[mc.selectedAcc.parentGroups.length-1].uniqueName

  mc.isCurrentAccount =(acnt) ->
    acnt.uniqueName is mc.selectedAcc.uniqueName


  mc.moveAccnt = (group) ->
    if _.isUndefined(group.uniqueName)
      toastr.error("Select group only from list", "Error")
      return
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: mc.selectedGrp.uniqueName
      acntUname: mc.selectedAcc.uniqueName
    }
    if _.isUndefined(mc.selectedGrp.uniqueName)
      lastVal = _.last(mc.selectedAcc.parentGroups)
      unqNamesObj.selGrpUname = lastVal.uniqueName

    body = {
      "uniqueName": group.uniqueName
    }
    accountService.move(unqNamesObj, body).then(mc.moveAccntSuccess, mc.moveAccntFailure)


  mc.moveAccntSuccess = (res) ->
    mc.keyWord = ''
    mc.showOnUpdate = false
    toastr.success(res.body, res.status)
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    mc.showAccountDetails = false
    if !_.isEmpty(mc.selectedGrp)
      mc.groupAccntList = _.reject(mc.groupAccntList, (item) ->
        return item.uniqueName == mc.selectedAcc.uniqueName
      )
    mc.selAcntPrevObj = {}
    mc.moveacto = ''
    mc.getSelectedType('grp')
    mc.breadCrumbList.pop()
    mc.getGroups()
    mc.selectItem(mc.breadCrumbList[mc.breadCrumbList.length-1], true, mc.parentIndex, mc.currentIndex)


  mc.moveAccntFailure = (res) ->
    toastr.error(res.data.message, res.data.status)



 ############################ for merge/unmerge accounts ############################


  #----------for merge account refresh----------#
  mc.mergeAccList = []
  mc.refreshFlatAccount = (str) ->
    @success = (res) ->
      mc.mergeAccList = res.body.results
      mc.mergeAccList = _.reject(mc.mergeAccList, (item) ->
        return item.isFixed == true
      )
    @failure = (res) ->
      toastr.error(res.data.message)
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      q: str
      page: 1
      count: 0
    }
    if str.length > 1
      groupService.getFlatAccList(reqParam).then(@success, @failure)

  mc.toMerge = {
    mergeTo:''
    mergedAcc: []
    toUnMerge : {
      name: ''
      uniqueNames: []
      moveTo: ''
    }
    moveToAcc: ''
  }

  mc.getMergedAccounts = (accData) ->
    $rootScope.fltAccntListPaginated
    accToRemove = {
      uniqueName: accData.uniqueName
    }
    mc.AccountsList = _.without(mc.AccountsList, _.findWhere(mc.AccountsList, accToRemove))
    mc.toMerge.mergeTo = accData.uniqueName
    mc.mergedAcc = accData.mergedAccounts
    mc.mList = []
    if !_.isEmpty(mc.mergedAcc) && !_.isUndefined(mc.mergedAcc)
      mc.mList = mc.mergedAcc.split(',')
      _.each mc.mList, (mAcc) ->
        mObj = {
          uniqueName: ''
          noRemove : true
        }
        mObj.uniqueName = mAcc
        mc.prePopulate.push(mObj)
      # mc.toMerge.mergedAcc = mc.prePopulate
    else
      mc.prePopulate = []
      mc.toMerge.mergedAcc = []


 #merge account
  mc.mergeAccounts = () ->
    mc.accToMerge = []
    withoutMerged = []
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: mc.toMerge.mergeTo
    }
    mc.accToMerge = mc.toMerge.mergedAcc
    if mc.accToMerge.length > 0
      accountService.merge(unqNamesObj, mc.accToMerge).then( mc.mergeSuccess, mc.mergeFailure)
      _.each mc.accToMerge, (acc) ->
        mc.removeMerged = {
          uniqueName: acc.uniqueName
        }
        mc.AccountsList = _.without(mc.AccountsList, _.findWhere(mc.AccountsList, mc.removeMerged))
    else
      toastr.error("Please select at least one account.")


  mc.mergeSuccess = (res) ->
    mc.toMerge.mergedAcc = []
    mc.mergeAccList = []
    toastr.success(res.body)
    _.each mc.toMerge.mergedAcc, (acc) ->
      $rootScope.removeAccountFromPaginatedList(acc)
      acc.noRemove = true
    mc.prePopulate = mc.toMerge.mergedAcc
    # mc.updateAll()
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    mc.getAccDetail(mc.selectedAcc, mc.getCurrentColIndex)

  mc.mergeFailure = (res) ->
    toastr.error(res.data.message)


# ############################################### DELETE MERGE ACCOUNT PENDING ################################################
  mc.deleteMergedAccount = (item) ->
    mc.toMerge.toUnMerge.uniqueNames = item
    mc.toMerge.toUnMerge.moveTo = null
    modalService.openConfirmModal(
      title: 'Delete Merged Account',
      body: 'Are you sure you want to delete ' + mc.toMerge.toUnMerge.uniqueNames + ' ?',
      ok: 'Yes',
      cancel: 'No').then(
        () ->
          mc.deleteMergedAccountConfirm(mc.toMerge.toUnMerge.uniqueNames)
      )
    return 0

  mc.deleteMergedAccountConfirm = (unqname) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: mc.toMerge.mergeTo
    }
    accTosend = {
      "uniqueNames": []
    }
    if mc.toMerge.toUnMerge.uniqueNames.length != 0
      accTosend.uniqueNames.push(unqname)
      accountService.unMergeDelete(unqNamesObj, accTosend).then(mc.deleteMergedAccountSuccess, mc.deleteMergedAccountFailure)
      _.each accTosend.uniqueNames, (accUnq) ->
        removeFromPrePopulate = {
          uniqueName: accUnq
        }
        mc.prePopulate = _.without(mc.prePopulate, _.findWhere(mc.prePopulate, removeFromPrePopulate))
    else
      toastr.error('Please Select an Account to delete')

  mc.deleteMergedAccountSuccess = (res) ->
    toastr.success(res.body)
    updatedMergedAccList = []
    _.each mc.toMerge.mergedAcc, (obj) ->
      toRemove = {}
      if obj.uniqueName != mc.toMerge.toUnMerge.uniqueNames
        toRemove = obj
        toRemove.noRemove = false
        if !obj.hasOwnProperty('mergedAccounts')
          toRemove.noRemove = true
        updatedMergedAccList.push(toRemove)
    mc.toMerge.mergedAcc = updatedMergedAccList
    mc.toMerge.toUnMerge.uniqueNames = ''
    mc.toMerge.moveToAcc = ''
    mc.getAccDetail(mc.selectedAcc, mc.getCurrentColIndex)



  mc.deleteMergedAccountFailure = (res) ->
    toastr.error(res.data.message)
# ############################################### DELETE MERGE ACCOUNT PENDING ################################################

  #delete account
  mc.unmerge = (item) ->
    item = item.replace(RegExp(' ', 'g'), '')
    mc.toMerge.toUnMerge.uniqueNames = item
    mc.showDeleteMove = true

  mc.moveToAccount = () ->
    modalService.openConfirmModal(
      title: 'Delete Merged Account',
      body: 'Are you sure you want to move ' + mc.toMerge.toUnMerge.uniqueNames + ' to ' + mc.toMerge.moveToAcc.uniqueName,
      ok: 'Yes',
      cancel: 'No').then(mc.moveToAccountConfirm)

  mc.moveToAccountConfirm = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: mc.toMerge.moveToAcc.uniqueName
    }
    accTosend = {
      uniqueName: mc.toMerge.toUnMerge.uniqueNames
    }
    if mc.toMerge.toUnMerge.uniqueNames.length != 0
      accountService.merge(unqNamesObj, [accTosend]).then(mc.moveToAccountConfirmSuccess, mc.moveToAccountConfirmFailure)
      _.each mc.accToSendArray, (accUnq) ->
        removeFromPrePopulate = {
          uniqueName: accUnq
        }
        mc.prePopulate = _.without(mc.prePopulate, _.findWhere(mc.prePopulate, removeFromPrePopulate.uniqueName))
    else
      toastr.error('Please Select an account to move.')

  mc.moveToAccountConfirmSuccess = (res) ->
    toastr.success(res.body)
    mc.updatedMergedAccList = []
    _.each mc.toMerge.mergedAcc, (obj) ->
      toRemove = {}
      if obj.uniqueName != mc.toMerge.toUnMerge.uniqueNames
        toRemove = obj
        toRemove.noRemove = false
        if !obj.hasOwnProperty('mergedAccounts')
          toRemove.noRemove = true
        mc.updatedMergedAccList.push(toRemove)
    mc.toMerge.mergedAcc = mc.updatedMergedAccList
    mc.toMerge.toUnMerge.uniqueNames = ''
    mc.toMerge.moveToAcc = ''
    mc.getAccDetail(mc.selectedAcc, mc.getCurrentColIndex)

  mc.moveToAccountConfirmFailure = (res) ->
    toastr.error(res.data.message)


  mc.shareAccModal = () ->
    $uibModal.open(
      templateUrl: '/public/webapp/NewManageGroupsAndAccounts/shareacc.html',
      size: "md",
      backdrop: 'true',
      animation: true,
      scope: $scope
    )


  mc.shareAccount = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: mc.selectedGrp.uniqueName
      acntUname: mc.selectedAcc.uniqueName
    }
    if _.isEmpty(mc.selectedGroup)
      unqNamesObj.selGrpUname = mc.selectedAcc.parentGroups[0].uniqueName

    accountService.share(unqNamesObj, mc.shareAccountObj).then(mc.onShareAccountSuccess, mc.onShareAccountFailure)

  mc.onShareAccountSuccess = (res) ->
    mc.shareAccountObj.user = ""
    toastr.success(res.body, res.status)
    mc.getAccountSharedList()

  mc.onShareAccountFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  mc.unShareAccount = (user) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: mc.selectedGrp.uniqueName
      acntUname: mc.selectedAcc.uniqueName
    }
    if _.isEmpty(mc.selectedGrp)
      unqNamesObj.selGrpUname = mc.selectedAcc.parentGroups[0].uniqueName

    data = { user: user}
    accountService.unshare(unqNamesObj, data).then(mc.unShareAccountSuccess, mc.unShareAccountFailure)

  mc.unShareAccountSuccess = (res)->
    toastr.success(res.body, res.status)
    mc.getAccountSharedList()

  mc.unShareAccountFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  mc.getAccountSharedList = () ->
    if $scope.canShare
      unqNamesObj = {
        compUname: $rootScope.selectedCompany.uniqueName
        selGrpUname: mc.selectedAcc.parentGroups[0].uniqueName
        acntUname: mc.selectedAcc.uniqueName
      }
      accountService.sharedWith(unqNamesObj).then(mc.onGetAccountSharedListSuccess, mc.onGetAccountSharedListSuccess)

  mc.onGetAccountSharedListSuccess = (res) ->
    mc.accountSharedUserList = res.body

  mc.onGetAccountSharedListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


# search accounts & groups
  mc.searchQuery = (str) ->
    reqParam = {}
    reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
    reqParam.query = str
    if str.length <= 2
      mc.breadCrumbList = []
      mc.getGroups()
    else if str.length > 2
      mc.searchLoad = true
      mc.columns = []
      groupService.searchGroupsWithAccountsCropped(reqParam).then(mc.getSearchResultSuccess, mc.getSearchResultFailure)

  mc.getSearchResultSuccess = (res) ->
    if res.body.length < 1
      mc.columns = []
      mc.showNoResult = true
    else
      mc.showNoResult = false
    mc.searchLoad = false
    # mc.updateBreadCrumbs = false
    # toastr.success(res.status)
    mc.pushSearchResult(res.body)

  mc.getSearchResultFailure = () ->
    toastr.error(res.data.message, res.data.status)

  # add search result to first column on ui, first column has no accounts
  mc.pushSearchResult = (data) ->
    data = mc.addHLevel(data, 0)
    col = {} 
    col.groups = []
    col.accounts = []
    col.groups = data
    mc.columns.unshift(col)
    mc.addColumnOnSearchLevel1(data, {})

  #add search results to second column, we will get accounts from second column onwards
  mc.addColumnOnSearchLevel1 = (data, col) ->
    col.groups = []
    col.accounts = []
    _.each data, (grp) ->
      if grp.groups.length > 0
        _.each grp.groups, (chGrp) ->
          col.groups.push(chGrp)
    mc.columns.push(col)
    mc.addColumnOnSearchChildLevels(col.groups, {})

  # add search results to further columns, called recursively
  mc.addColumnOnSearchChildLevels = (groups, col) ->
    col.groups = []
    col.accounts = []
    _.each groups, (grp) ->
      if grp.groups.length > 0
        _.each grp.groups, (chGrp) ->
          col.groups.push(chGrp)
      if grp.accounts.length > 0
        _.each grp.accounts, (acc) ->
          col.accounts.push(acc)
    if col.groups.length > 0 || col.accounts.length > 0
      mc.columns.push(col)
    if col.groups.length > 0 || col.accounts.length > 0
      mc.addColumnOnSearchChildLevels(col.groups, {})

  mc.checkCurrentColumn = (index) ->
    mc.columns[index+1].showCreateNew = true


  # mc.pushSearchResultChildLevel = (groups, accounts) ->
  #   mc.columns.push(childCol)
    
  # mc.pushSearchResultChildLevel = (groups) ->
  #   mc.searchResultIndex = 0
  #   childCol = {} 
  #   childCol.groups = []
  #   childCol.accounts = []
  #   _.each groups, (grp, i) ->
  #     mc.searchResultIndex = grp.hLevel
  #     childCol.groups.push(grp)
  #     mc.columns[mc.searchResultIndex].groups.push(childCol)
  #   console.log childCol

  mc.resetSearch = () ->
    mc.searchQuery('')
    mc.keyWord = ''
    mc.breadCrumbList = []
    mc.getGroups()

  mc.updateSearchhierarchy = (data) ->
    currentItem = _.findWhere(mc.flattenGroupList, {uniqueName:data.uniqueName})
    if _.isUndefined(currentItem)
      currentItem = _.findWhere($rootScope.fltAccntListPaginated, {uniqueName:data.uniqueName})
    currentItem = _.extend(data, currentItem)
    mc.breadCrumbList = currentItem.parentGroups
    mc.selectedItem = currentItem
    mc.updateBreadCrumbs = true

  mc.getServiceCode = (hsn, sac)->
    if hsn
      mc.radioModel = "hsn"
    else if sac
      mc.radioModel = "sac"
    else
      mc.radioModel = ""

  mc.checkActiveServiceCode = (selected) ->
    if selected == 'hsn'
      mc.radioModel = 'hsn'

      mc.selectedAcc.sacNumber = null
    else
      mc.radioModel = 'sac'
      mc.selectedAcc.hsnNumber = null


  # mc.getState = () ->
  #   @success=(res)->
  #     mc.stateList = res.body

  #   @failure=(err)->
  #     console.log("failure", err)

  #   companyServices.getStates().then(@success, @failure)

  # mc.getState()

  mc.toggleList = () ->
    if mc.showDefaultGstList
      mc.showDefaultGst = mc.gstDetail.length
    else
      mc.showDefaultGst = 2
    mc.showDefaultGstList = !mc.showDefaultGstList

  mc.getStateCode = (val, item) ->
    if val.length >= 2
      mc.gstState = _.findWhere($rootScope.stateList, {code:val.substr(0,2)})
      if mc.gstState
        item.addressList[0].stateCode = mc.gstState.code
        item.addressList[0].stateName = mc.gstState.name
    else if val.length < 2
      item.addressList[0].stateCode = ''
      item.addressList[0].stateName = ''
    return false

  mc.getColsCount = () ->
    calcWidth = $(".grp_wrapper").width()
    # slide to last column
    leftPos = $('.grp_col').scrollLeft()
    $(".grp_col").animate({
      scrollLeft: calcWidth
    }, 800)
    return false

  mc.setStateCode = (item) ->
    mc.selectedAcc.stateCode  = item.code

  mc.removeBlankGst = (gstList) ->
    if gstList.length > 0
      _.each gstList, (item) ->
        if item.gstNumber == ""
          gstList = _.without(gstList, item)
      mc.gstDetail = gstList
# end
    
  mc.updateFlatAccountList = () ->
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)


  # featching uniqname

  # mc.fetchingUnq = false
  # num = 1
  # mc.autoFillUnq = (unq) ->
  #   unq = unq.replace(/ |,|\//g,'')
  #   unq = unq.toLowerCase()
  #   $this = @
  #   mc.fetchingUnq = true
  #   $this.success = (res) ->
  #     mc.autoFillUnq(unq+num)
  #     num += 1
  #   $this.failure = (res) ->
  #     mc.selectedAcc.uniqueName = unq
  #     num = 1
  #     mc.fetchingUnq = false
  #   if mc.acntCase == 'Add' && unq != undefined && unq.length > 2
  #     $timeout ( ->
  #       reqParams = {
  #         compUname: $rootScope.selectedCompany.uniqueName
  #         acntUname: unq
  #       }
  #       accountService.get(reqParams).then($this.success, $this.failure)
  #     ), 1000
  #   else if unq == undefined
  #     mc.selectedAcc.uniqueName == null

  mc.removeSpace = (val, item) ->
    if val && val.length  > 0
      val = val.replace(/ |,|\//g,'')
      val = val.toLowerCase()
      item.uniqueName = val

  mc.createNewForm = () ->
    mc.selectedItem = {}
    mc.selectedAcc = {}
    mc.showOnUpdate = false

  mc.checkValidState = (state) ->
    if state.length < 1
      mc.selectedAcc.stateCode = ""

  mc.isChildGroup =(group) ->
    _.some(group.parentGroups, (group) ->
      group.uniqueName == mc.selectedGrp.uniqueName)

  return mc

#init angular app
giddh.webApp.controller 'manageController', manageController