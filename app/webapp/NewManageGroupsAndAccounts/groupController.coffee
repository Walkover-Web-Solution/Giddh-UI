'use strict'

manageController = ($scope, $rootScope, localStorageService, groupService, toastr, modalService, $timeout, accountService, locationService, ledgerService, $filter, permissionService, DAServices, $location, $uibModal, companyServices) ->
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
#  $scope.fltAccntListPaginated = []
#  $scope.flatAccList = {
#    page: 1
#    count: 5
#    totalPages: 0
#    currentPage : 1
#    limit: 5
#  }
  # mc.selectedTax = {}
  # mc.selectedTax.taxes = ''

  mc.selectedGrp = {}
  mc.selectedType = undefined
  mc.breadcrumbs = []
  mc.showOnUpdate = false
  mc.prePopulate = []
  mc.getMergeAcc = []
  mc.breadCrumbList = []

# get selected account or grp to show/hide
  mc.getSelectedType = (type) ->
    console.log (type)
    mc.selectedType = type
    mc.createNew = false
# end


  #show breadcrumbs
  mc.showBreadCrumbs = (data) ->
    mc.showBreadCrumb = true


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
        mc.addHLevel(grp.groups, grp.hLevel+1)
        
# end

  mc.getGroupListSuccess = (res) ->
    mc.searchLoad = false
    mc.columns = []
    mc.showListGroupsNow = true
    col = {}
    col.groups = mc.addHLevel(res.body, 0)
    col.accounts = []
    mc.columns.push(col)
    mc.updateAll(res.body)

  mc.getGroups =() ->
    mc.searchLoad = true
    groupService.getGroupsWithAccountsCropped($rootScope.selectedCompany.uniqueName).then(mc.getGroupListSuccess, mc.getGroupListFailure)

  mc.getGroups()

  mc.selectItemAfterUpdate = (item, fromApi) ->


  mc.updateAll = (groupList) ->
    # console.log res
    _.each mc.breadCrumbList, (item, i) ->
      currentItem = _.findWhere(groupList, {uniqueName:item.uniqueName})
      if currentItem
        mc.selectItem(currentItem, false)
        ###set selcted item class####
        _.each mc.columns[i].groups, (grp, idx) ->
          if grp.uniqueName == currentItem.uniqueName
            mc.selectActiveItems(mc.columns[i], 'grp', idx)
      else if !currentItem
        if item.groups
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
  mc.selectItem = (item, updateBreadCrumbs) ->
    # mc.columns
    if updateBreadCrumbs
      mc.addToBreadCrumbs(item, 'grp')
    mc.selectedGrp = item
    mc.grpCategory = item.category
    mc.showEditTaxSection = false
    mc.selectedGrp.oldUName = item.uniqueName
    mc.getGroupSharedList(item)
    # mc.createNew = false
    mc.showOnUpdate = true
    # console.log item
    existingGrp = _.findWhere(mc.columns, {uniqueName:item.uniqueName})
    mc.selectedItem = mc.selectedGrp
    groupService.get($rootScope.selectedCompany.uniqueName, item.uniqueName).then(mc.getGrpDtlSuccess, mc.getGrpDtlFailure)
    if !existingGrp
      # if (item.hLevel-1) < mc.columns.length
      mc.columns = mc.columns.splice(0,item.hLevel+1)
      mc.columns.push(item)
    else
      existingGrp = item
      mc.columns = mc.columns.splice(0,item.hLevel+2)

  mc.getGrpDtlSuccess = (res) ->
    mc.selectedItem = res.body
    console.log mc.selectedItem
    console.log mc.columns

  mc.getGrpDtlFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
# end

# set active item with respect to column
  mc.selectActiveItems = (col, type, index) ->
    col.active = {}
    col.active.type = type
    col.active.index = index

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
    mc.columns[mc.addToIndex].groups.push(res.body)
    toastr.success("Sub group added successfully", "Success")
    # mc.selectedItem = {}
    mc.getGroups()

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
    mc.selectedItem = {}
    mc.showGroupDetails = false
    mc.showAccountListDetails = false
    mc.breadCrumbList.pop()
    mc.getGroups()

  mc.onDeleteGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
# end


# add grp to same column
  mc.createNewGrpAccount = (index) ->
    mc.addToIndex = index
    mc.toggleView(true)
    mc.showOnUpdate = false


# get account details under groups and sub groups
  mc.getAccDetail = (item, parentIndex) ->
    mc.showOnUpdate = true
    mc.getCurrentAccIndex = parentIndex
    mc.selectedAcc = item
    item.hLevel = parentIndex
    reqParam = {
      compUname: $rootScope.selectedCompany.uniqueName,
      acntUname: item.uniqueName
    }
    accountService.get(reqParam).then(mc.getAccDtlSuccess, mc.getAccDtlFailure)
    mc.addToBreadCrumbs(item, 'account', parentIndex)

  mc.getAccDtlSuccess = (res, data) ->
    console.log mc.getCurrentAccIndex 
    data = res.body
    mc.selectedAcc = res.body
    mc.getMergeAcc = mc.selectedAcc.mergedAccounts.replace(RegExp(' ', 'g'), '')
    if mc.getMergeAcc.indexOf(',') != -1
      mc.getMergeAcc = mc.getMergeAcc.split(",")
    else if mc.selectedAcc.mergedAccounts.length > 1
      mc.getMergeAcc = [mc.selectedAcc.mergedAccounts]
    mc.AccountCategory = mc.getAccountCategory(data.parentGroups)
    mc.getMergedAccounts(data)
    mc.showGroupDetails = false
    mc.showAccountDetails = true
    console.log mc.selectedAcc
    if data.uniqueName is $rootScope.selAcntUname
      mc.cantUpdate = true
    _.extend(mc.selAcntPrevObj, data)
    _.extend(mc.selectedAcc, data)
    # mc.breakMobNo(data)
    mc.setOpeningBalanceDate()
    mc.getAccountSharedList()
    mc.isFixedAcc = res.body.isFixed
    mc.showBreadCrumbs(data.parentGroups)
    mc.columns = mc.columns.splice(0,mc.getCurrentAccIndex+1)
    # mc.breadCrumbList = mc.breadCrumbList.splice(0,mc.getCurrentAccIndex+1)
    console.log mc.columns

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
    # mc.taxHierarchy = res.body
    # mc.selectedTax.taxes = mc.taxHierarchy.applicableTaxes
    mc.showEditTaxSection = true
    mc.allInheritedTaxes = []
    mc.createInheritedTaxList(mc.taxHierarchy.inheritedTaxes)

  mc.getTaxHierarchyOnFailure = (res) ->
    toastr.error(res.data.message)

# end


  mc.createInheritedTaxList = (inTaxList) ->
#get all taxes by uniqueName
    inTaxUnq = []
    _.each inTaxList, (tax) ->
      _.each tax.applicableTaxes, (inTax) ->
        inTaxUnq.push(inTax.uniqueName)
    inTaxUnq = _.uniq(inTaxUnq)

    # match groups with tax uniqueNames
    _.each inTaxUnq, (unq) ->
      tax = {}
      tax.uniqueName = unq
      tax.groups = []
      _.each inTaxList, (inTax) ->
        _.each inTax.applicableTaxes, (inAppTax) ->
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
    console.log mc.getSendTax
    console.log mc.taxHierarchy.applicableTaxes
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
      mergeTaxes = []
      mergeTaxes.push(mc.taxHierarchy.applicableTaxes)
      mergeTaxes.push(_.pluck(mc.taxHierarchy.inheritedTaxes, 'applicableTaxes'))
      sendThisList = _.pluck(_.flatten(mergeTaxes),'uniqueName')
      mc.getSendTax = sendThisList
      data = {}
      if type == 'group'
        data = [{"uniqueName":mc.selectedGrp.uniqueName, "taxes":sendThisList,"isAccount":false}]
        $scope.isAccount = false
      else if type == 'account'
        data = [{"uniqueName":mc.selectedAcc.uniqueName, "taxes":sendThisList,"isAccount":true}]
        mc.isAccount = true
      mc.assignTax(data)

  # fetch taxes
  mc.alreadyAppliedTaxes = (tax) ->
    inheritTax = _.pluck(mc.taxHierarchy.inheritedTaxes,'applicableTaxes')
    applicableTaxes = _.flatten(mc.taxHierarchy)
    applicableTaxes.push(inheritTax)
    checkInThis = _.pluck(_.flatten(applicableTaxes),'uniqueName')
    condition = _.contains(checkInThis, tax.uniqueName)
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
    mc.selectedItem = {}

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
    grp = _.findWhere($rootScope.flatGroupsList, {uniqueName:pg})
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

  mc.addAccountSuccess = (res) ->
    toastr.success("Account created successfully", res.status)
    mc.selectedAcc = {}
    abc = _.pick(res.body, 'name', 'uniqueName', 'mergedAccounts','applicableTaxes','parentGroups')
    mc.groupAccntList.push(abc)
    mc.columns[mc.addToIndex].accounts.push(res.body)
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    # mc.columns = []
    # mc.getGroups()
    
  mc.addAccountFailure = (res) ->
    toastr.error(res.data.message, res.data.status)


  mc.updateAccount = () ->
    unqNamesObj = mc.setAdditionalAccountDetails()
    if angular.equals(mc.selectedAcc, mc.selAcntPrevObj)
      toastr.info("Nothing to update", "Info")
      return false

    if mc.selectedAcc.openingBalanceType == null
      mc.selectedAcc.openingBalanceType = 'credit'

    if mc.selectedAcc.uniqueName isnt mc.selAcntPrevObj.uniqueName
      unqNamesObj.acntUname = mc.selAcntPrevObj.uniqueName

    if _.isEmpty(mc.selectedGrp)
      lastVal = _.last(mc.selectedAcc.parentGroups)
      unqNamesObj.selGrpUname = lastVal.uniqueName

    if mc.selectedAcc.applicableTaxes.length > 0
      mc.selectedAcc.applicableTaxes = _.pluck(mc.selectedAcc.applicableTaxes,'uniqueName')

    accountService.updateAc(unqNamesObj, mc.selectedAcc).then(mc.updateAccountSuccess,
        mc.updateAccountFailure)


  mc.updateAccountSuccess = (res) ->
    toastr.success("Account updated successfully", res.status)
    angular.merge(mc.selectedAcc, res.body)
    abc = _.pick(mc.selectedAcc, 'name', 'uniqueName', 'mergedAccounts')
    if !_.isEmpty(mc.selectedGrp)
      _.find(mc.groupAccntList, (item, index) ->
        if item.uniqueName == mc.selAcntPrevObj.uniqueName
          angular.merge(mc.groupAccntList[index], abc)
      )
    # end if
    angular.merge(mc.selAcntPrevObj, res.body)
    mc.getGroups()
    # mc.getAccDetail(mc.selectedAcc, mc.getCurrentAccIndex)


  mc.updateAccountFailure = (res) ->
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
    mc.getGroups()
    mc.breadCrumbList.pop()
    mc.selectedItem = mc.selectItem(mc.breadCrumbList[mc.breadCrumbList.length-1], false)


  mc.moveAccntFailure = (res) ->
    toastr.error(res.data.message, res.data.status)



 ############################ for merge/unmerge accounts ############################


  #----------for merge account refresh----------#
  mc.mergeAccList = []
  mc.refreshFlatAccount = (str) ->
    @success = (res) ->
      mc.mergeAccList = res.body.results
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
    console.log mc.toMerge.mergedAcc
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
    toastr.success(res.body)
    _.each mc.toMerge.mergedAcc, (acc) ->
      $rootScope.removeAccountFromPaginatedList(acc)
      acc.noRemove = true
    # mc.getGroups()
    mc.prePopulate = mc.toMerge.mergedAcc
    $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
    mc.getAccDetail(mc.selectedAcc, mc.getCurrentAccIndex)

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
    mc.getAccDetail(mc.selectedAcc, mc.getCurrentAccIndex)



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
    mc.getAccDetail(mc.selectedAcc, mc.getCurrentAccIndex)

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
    if str.length < 3
      mc.columns = []
      mc.getGroups()
    else if str.length > 2
      mc.searchLoad = true
      mc.columns = []
      groupService.searchGroupsWithAccountsCropped(reqParam).then(mc.getSearchResultSuccess, mc.getSearchResultFailure)

  mc.getSearchResultSuccess = (res) ->
    mc.searchLoad = false
    # toastr.success(res.status)
    mc.pushSearchResultLevel1(res.body)

  mc.getSearchResultFailure = () ->
    toastr.error(res.data.message, res.data.status)


  mc.pushSearchResultLevel1 = (data) ->
    data = mc.addHLevel(data, 0)
    col = {} 
    col.groups = []
    col.accounts = []
    _.each data, (grp) ->
      col.groups.push(grp)
      if grp.groups.length > 0
        mc.pushSearchResultChildLevel(grp.groups)
    mc.columns.unshift(col)

  mc.pushSearchResultChildLevel = (groups) ->
    childCol = {} 
    childCol.groups = []
    childCol.accounts = []
    _.each groups, (grp) ->
      childCol.groups.push(grp)
      if grp.accounts.length > 0
        _.each grp.accounts, (acc) ->
          childCol.accounts.push(acc)
      if grp.groups.length > 0
        mc.pushSearchResultChildLevel(grp.groups)
    mc.columns.unshift(childCol)
        
# end

  return mc

#init angular app
giddh.webApp.controller 'manageController', manageController