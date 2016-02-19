'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr, modalService, $timeout, accountService, locationService, ledgerService, $filter, permissionService, DAServices, $location, $uibModal) ->
  $scope.groupList = {}
  $scope.flattenGroupList = []
  $scope.moveto = undefined
  $scope.selectedGroup = {}
  $scope.selectedSubGroup = {}
  $scope.selectedAccount = {}
  $scope.selAcntPrevObj = {}
  $scope.datePicker = {accountOpeningBalanceDate: ""}
  $scope.selectedGroupUName = ""
  $scope.cantUpdate = false
  $scope.showGroupDetails = false
  $scope.subGroupVisible = false
  $scope.showListGroupsNow = false
  $scope.showAccountDetails = false
  $scope.showAccountListDetails = false
  $scope.showMergeDescription = true
  $scope.mergedAccounts = ''
  $scope.showDeleteMove = false
  $scope.AccountsList = []
  $scope.groupAccntList = []
  $scope.acntSrch = ''
  $scope.shareGroupObj ={role: "view_only"}
  $scope.shareAccountObj ={role: "view_only"}
  $scope.openingBalType = [
    {"name": "Credit", "val": "CREDIT"}
    {"name": "Debit", "val": "DEBIT"}
  ]
  $scope.acntExt = {
    Ccode: undefined,
    onlyMobileNo: undefined
  }
  $scope.today = new Date()
  $scope.valuationDatePickerIsOpen = false
  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }
  $scope.format = "dd-MM-yyyy"
  $scope.flatAccntWGroupsList = {}
  $scope.showAccountList = false
  $scope.selectedAccountUniqueName = undefined

  $scope.valuationDatePickerOpen = ()->
    this.valuationDatePickerIsOpen = true

  # dom method function
  $scope.highlightAcMenu = () ->
    url = $location.path().split("/")
    if url[1] is "ledger"
      $timeout ->
        acEle = document.getElementById("ac_" + url[2])
        if acEle is null
          return false
        parentSib = acEle.parentElement.previousElementSibling
        angular.element(parentSib).trigger('click')
        angular.element(acEle).children().trigger('click')
      , 500

  # expand and collapse all tree structure
  getRootNodesScope = ->
    angular.element(document.getElementById('tree-root')).scope()

  $scope.collapseAll = () ->
    scope = getRootNodesScope()
    scope.collapseAll()
    $scope.subGroupVisible = true

  $scope.expandAll = () ->
    scope = getRootNodesScope()
    scope.expandAll()
    $scope.subGroupVisible = false
  # dom method functions end

  $scope.goToManageGroups =() ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      modalInstance = $uibModal.open(
        templateUrl: '/public/webapp/views/addManageGroupModal.html'
        size: "liq90"
        backdrop: 'static'
        scope: $scope
      )
      modalInstance.result.then($scope.goToManageGroupsOpen, $scope.goToManageGroupsClose)

  $scope.goToManageGroupsOpen = (res) ->
    console.log "opened", res
  
  $scope.goToManageGroupsClose = () ->
    $scope.selectedGroup = {}
    $scope.selectedAccntMenu = undefined
    $scope.selectedItem = undefined
    $scope.showGroupDetails = false
    $scope.showAccountDetails = false
    $scope.showAccountListDetails = false
    $scope.cantUpdate = false
  
  $scope.setLedgerData = (data, acData) ->
    $scope.selectedAccountUniqueName = acData.uniqueName
    DAServices.LedgerSet(data, acData)
    localStorageService.set("_ledgerData", data)
    localStorageService.set("_selectedAccount", acData)


  #Expand or  Collapse all account menus
  $scope.toggleAcMenus = (state) ->
    if !_.isEmpty($scope.flatAccntWGroupsList)
      _.each($scope.flatAccntWGroupsList, (e) ->
        e.open = state
        $scope.showSubMenus = state
      )

  # trigger expand or collapse func
  $scope.checkLength = (val)->
    if val is '' || _.isUndefined(val)
      $scope.toggleAcMenus(false)
    else if val.length >= 4
      $scope.toggleAcMenus(true)
    else
      $scope.toggleAcMenus(false)
  # end acCntrl

  $scope.getGroups =() ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      # with accounts, group data
      groupService.getGroupsWithAccountsCropped($rootScope.selectedCompany.uniqueName).then($scope.makeAccountsList, $scope.makeAccountsListFailure)
      # without accounts only groups conditionally
      cData = localStorageService.get("_selectedCompany")
      if cData.sharedEntity is 'accounts'
        console.info "sharedEntity:"+ cData.sharedEntity
      else
        groupService.getGroupsWithoutAccountsCropped($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess, $scope.getGroupListFailure)

  $scope.makeAccountsList = (res) ->
    # flatten all groups with accounts and only accounts flatten
    a =[]
    angular.copy(res.body, a)
    $rootScope.flatGroupsList = groupService.flattenGroup(a, [])
    $scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($rootScope.flatGroupsList)
    $scope.showAccountList = true
    b = groupService.flattenAccount(a)
    $rootScope.makeAccountFlatten(b)
    $scope.flattenGroupList = groupService.makeGroupListFlatwithLessDtl($rootScope.flatGroupsList)

  $scope.makeAccountsListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getGroupListSuccess = (res) ->
    $scope.groupList = res.body
    $scope.showListGroupsNow = true
    $scope.highlightAcMenu()

  $scope.getGroupListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)
  
  $scope.getGroupSharedList = () ->
    if $scope.canShare
      unqNamesObj = {
        compUname: $rootScope.selectedCompany.uniqueName
        selGrpUname: $scope.selectedGroup.uniqueName
      }
      groupService.sharedList(unqNamesObj).then($scope.onsharedListSuccess, $scope.onsharedListFailure)

  $scope.onsharedListSuccess = (res) ->
    $scope.groupSharedUserList = res.body

  $scope.onsharedListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #share group with user
  $scope.shareGroup = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
    }
    groupService.share(unqNamesObj, $scope.shareGroupObj).then($scope.onShareGroupSuccess, $scope.onShareGroupFailure)

  $scope.onShareGroupSuccess = (res) ->
    $scope.shareGroupObj = {
      role: "view_only"
      user: ""
    }
    toastr.success(res.body, res.status)
    $scope.getGroupSharedList($scope.selectedGroup)

  $scope.onShareGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  #unShare group with user
  $scope.unShareGroup = (user) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
    }
    data = {
      user: user
    }
    groupService.unshare(unqNamesObj, data).then($scope.unShareGroupSuccess, $scope.unShareGroupFailure)

  $scope.unShareGroupSuccess = (res)->
    toastr.success(res.body, res.status)
    $scope.getGroupSharedList($scope.selectedGroup)

  $scope.unShareGroupFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  $scope.updateGroup = ->
    $scope.selectedGroup.uniqueName = $scope.selectedGroup.uniqueName.toLowerCase()
    groupService.update($scope.selectedCompany.uniqueName, $scope.selectedGroup).then($scope.onUpdateGroupSuccess,
        $scope.onUpdateGroupFailure)

  $scope.onUpdateGroupSuccess = (res) ->
    $scope.selectedGroup.oldUName = $scope.selectedGroup.uniqueName
    if not _.isEmpty($scope.selectedGroup)
      $scope.selectedItem = $scope.selectedGroup
    toastr.success("Group has been updated successfully.", "Success")
    $scope.getGroups()

  $scope.onUpdateGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.getUniqueNameFromGroupList = (list) ->
    listofUN = _.map(list, (listItem) ->
      if listItem.groups.length > 0
        uniqueList = $scope.getUniqueNameFromGroupList(listItem.groups)
        uniqueList.push(listItem.uniqueName)
        uniqueList
      else
        listItem.uniqueName
    )
    _.flatten(listofUN)

  $scope.addNewSubGroup = ->
    uNameList = $scope.getUniqueNameFromGroupList($scope.groupList)
    UNameExist = _.contains(uNameList, $scope.selectedSubGroup.uniqueName)
    if UNameExist
      toastr.error("Unique name is already in use.", "Error")
      return

    if _.isEmpty($scope.selectedSubGroup.name)
      return

    body = {
      "name": $scope.selectedSubGroup.name,
      "uniqueName": $scope.selectedSubGroup.uniqueName.toLowerCase(),
      "parentGroupUniqueName": $scope.selectedGroup.uniqueName,
      "description": $scope.selectedSubGroup.desc
    }
    groupService.create($rootScope.selectedCompany.uniqueName, body).then($scope.onCreateGroupSuccess,
        $scope.onCreateGroupFailure)

  $scope.onCreateGroupSuccess = (res) ->
    toastr.success("Sub group added successfully", "Success")
    $scope.selectedSubGroup = {}
    $scope.getGroups()

  $scope.onCreateGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.deleteGroup = ->
    if not $scope.selectedGroup.isFixed
      modalService.openConfirmModal(
        title: 'Delete group?',
        body: 'Are you sure you want to delete this group? All child groups will also be deleted.',
        ok: 'Yes',
        cancel: 'No').then($scope.deleteGroupConfirm)

  $scope.deleteGroupConfirm = () ->
    groupService.delete($rootScope.selectedCompany.uniqueName,
      $scope.selectedGroup).then($scope.onDeleteGroupSuccess,
          $scope.onDeleteGroupFailure)

  $scope.onDeleteGroupSuccess = () ->
    toastr.success("Group deleted successfully.", "Success")
    $scope.selectedGroup = {}
    $scope.showGroupDetails = false
    $scope.showAccountListDetails = false
    $scope.getGroups()

  $scope.onDeleteGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.isChildGroup =(group) ->
    _.some(group.parentGroups, (group) ->
      group.uniqueName == $scope.selectedGroup.uniqueName)

  $scope.moveGroup = (group) ->
    if _.isUndefined(group.uniqueName)
      toastr.error("Select group only from list", "Error")
      return

    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
    }
    body = {
      "parentGroupUniqueName": group.uniqueName
    }
    groupService.move(unqNamesObj, body).then($scope.onMoveGroupSuccess, $scope.onMoveGroupFailure)

  $scope.onMoveGroupSuccess = (res) ->
    $scope.moveto = undefined
    toastr.success("Group moved successfully.", "Success")
    $scope.getGroups()

  $scope.onMoveGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.stopBubble = (e) ->
    e.stopPropagation()

  $scope.selectItem = (item) ->
    groupService.get($rootScope.selectedCompany.uniqueName, item.uniqueName).then($scope.getGrpDtlSuccess,
          $scope.getGrpDtlFailure)

  $scope.getGrpDtlSuccess = (res) ->
    $scope.selectedItem = res.body
    $scope.selectedAccntMenu = undefined
    $scope.selectGroupToEdit(res.body)
    $scope.accountsSearch = undefined
    $scope.showGroupDetails = true
    $scope.showAccountListDetails = true
    $scope.showAccountDetails = false
    $scope.populateAccountList(res.body)

  $scope.getGrpDtlFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.selectGroupToEdit = (group) ->
    $scope.selectedGroup = group
    if _.isEmpty($scope.selectedGroup.oldUName)
      $scope.selectedGroup.oldUName = $scope.selectedGroup.uniqueName
    $scope.selectedSubGroup = {}
    $rootScope.$emit('callCheckPermissions', group)
    $scope.getGroupSharedList(group)

  $scope.populateAccountList = (item) ->
    result = groupService.matchAndReturnGroupObj(item, $rootScope.flatGroupsList)
    $scope.groupAccntList = groupService.makeAcListWithLessDtl(result.accounts, $rootScope.flatGroupsList)

  #show breadcrumbs
  $scope.showBreadCrumbs = (data) ->
    $scope.showBreadCrumb = true
    $scope.breadCrumbList = data

  #jump to group
  $scope.jumpToGroup = (grpUniqName, grpList)  ->
    fltGrpList = groupService.flattenGroup(grpList, [])
    obj = _.find(fltGrpList, (item) ->
      item.uniqueName == grpUniqName
    )
    $scope.selectGroupToEdit(obj)
    $scope.selectItem(obj)

  #check if object is empty on client side by mechanic
  $scope.isEmptyObject = (obj) ->
    return _.isEmpty(obj)

  $scope.mergeNum = (num) ->
    if _.isUndefined(num.Ccode) || _.isUndefined(num.onlyMobileNo) || _.isEmpty(num.Ccode) || _.isEmpty(num.onlyMobileNo)
      return null

    if _.isObject(num.Ccode)
      num.Ccode.value + "-" + num.onlyMobileNo
    else
      num.Ccode + "-" + num.onlyMobileNo

  $scope.breakMobNo = (data) ->
    if data.mobileNo
      res = data.mobileNo.split("-")
      $scope.acntExt = {
        Ccode: res[0]
        onlyMobileNo: res[1]
      }
    else
      $scope.acntExt = {
        Ccode: undefined
        onlyMobileNo: undefined
      }

  #show account
  $scope.showAccountDtl = (data) ->
    $scope.cantUpdate = false
    #highlight account menus
    $scope.selectedAccntMenu = data
    reqParams = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: data.uniqueName
    }
    accountService.get(reqParams).then($scope.getAcDtlSuccess, $scope.getAcDtlFailure)

  $scope.getAcDtlSuccess = (res) ->
    getPgrps = groupService.matchAndReturnGroupObj(res.body, $rootScope.flatAccntListWithParents)
    data = res.body
    $scope.getMergedAccounts(data)
    data.parentGroups = []
    _.extend(data.parentGroups, getPgrps.parentGroups)
    $rootScope.$emit('callCheckPermissions', data)
    pGroups = []
    $scope.showGroupDetails = false
    $scope.showAccountDetails = true
    if data.uniqueName is $rootScope.selAcntUname
      $scope.cantUpdate = true
    _.extend($scope.selAcntPrevObj, data)
    _.extend($scope.selectedAccount, data)
    $scope.breakMobNo(data)
    $scope.setOpeningBalanceDate()
    $scope.getAccountSharedList()
    $scope.acntCase = "Update"
    $scope.showBreadCrumbs(data.parentGroups.reverse())
    

  $scope.getAcDtlFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  # prepare date object
  $scope.setOpeningBalanceDate = () ->
    if $scope.selectedAccount.openingBalanceDate
      newDateObj = $scope.selectedAccount.openingBalanceDate.split("-")
      $scope.datePicker.accountOpeningBalanceDate = new Date(newDateObj[2], newDateObj[1] - 1, newDateObj[0])
    else
      $scope.datePicker.accountOpeningBalanceDate = new Date()

  $scope.addNewAccountShow = (groupData)  ->
    $scope.cantUpdate = false
    # make blank for new
    $scope.selectedAccount = {}
    $scope.acntExt = {
      Ccode: undefined
      onlyMobileNo: undefined
    }
    $scope.breadCrumbList = undefined
    $scope.selectedAccntMenu = undefined
    $scope.showGroupDetails = false
    $scope.showAccountDetails = true
    # for play between update and add
    $scope.acntCase = "Add"
    $scope.setOpeningBalanceDate()
    $scope.showBreadCrumbs($scope.selectedGroup.parentGroups)

  $scope.setAdditionalAccountDetails = ()->
    $scope.selectedAccount.openingBalanceDate = $filter('date')($scope.datePicker.accountOpeningBalanceDate,
        "dd-MM-yyyy")
    $scope.selectedAccount.mobileNo = $scope.mergeNum($scope.acntExt)
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
      acntUname: $scope.selectedAccount.uniqueName
    }

  $scope.addAccount = () ->
    unqNamesObj = $scope.setAdditionalAccountDetails()
    accountService.createAc(unqNamesObj, $scope.selectedAccount).then($scope.addAccountSuccess, $scope.addAccountFailure)

  $scope.addAccountSuccess = (res) ->
    toastr.success("Account created successfully", res.status)
    $scope.getGroups()
    $scope.selectedAccount = {}
    abc = _.pick(res.body, 'name', 'uniqueName', 'mergedAccounts')
    $scope.groupAccntList.push(abc)

  $scope.addAccountFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.deleteAccount = ->
    if $scope.canDelete
      modalService.openConfirmModal(
        title: 'Delete Account?',
        body: 'Are you sure you want to delete this Account?',
        ok: 'Yes',
        cancel: 'No').then($scope.deleteAccountConfirm)

  $scope.deleteAccountConfirm = ->
    unqNamesObj = $scope.setAdditionalAccountDetails()
    if $scope.selectedAccount.uniqueName isnt $scope.selAcntPrevObj.uniqueName
      unqNamesObj.acntUname = $scope.selAcntPrevObj.uniqueName
    if _.isEmpty($scope.selectedGroup)
      unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName

    accountService.deleteAc(unqNamesObj, $scope.selectedAccount).then($scope.moveAccntSuccess, $scope.onDeleteAccountFailure)

  $scope.onDeleteAccountFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.updateAccount = () ->
    unqNamesObj = $scope.setAdditionalAccountDetails()
    if angular.equals($scope.selectedAccount, $scope.selAcntPrevObj)
      toastr.info("Nothing to update", "Info")
      return false

    if $scope.selectedAccount.uniqueName isnt $scope.selAcntPrevObj.uniqueName
      unqNamesObj.acntUname = $scope.selAcntPrevObj.uniqueName
      
    if _.isEmpty($scope.selectedGroup)
      lastVal = _.last($scope.selectedAccount.parentGroups)
      unqNamesObj.selGrpUname = lastVal.uniqueName

    accountService.updateAc(unqNamesObj, $scope.selectedAccount).then($scope.updateAccountSuccess,
        $scope.updateAccountFailure)
    

  $scope.updateAccountSuccess = (res) ->
    toastr.success("Account updated successfully", res.status)
    angular.merge($scope.selectedAccount, res.body)
    $scope.getGroups()
    abc = _.pick($scope.selectedAccount, 'name', 'uniqueName', 'mergedAccounts')
    if !_.isEmpty($scope.selectedGroup)
      _.find($scope.groupAccntList, (item, index) ->
        if item.uniqueName == $scope.selAcntPrevObj.uniqueName
          angular.merge($scope.groupAccntList[index], abc)
      )
    # end if
    angular.merge($scope.selAcntPrevObj, res.body)      
    

  $scope.updateAccountFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.isCurrentGroup =(group) ->
    group.uniqueName is $scope.selectedAccount.parentGroups[0].uniqueName

  $scope.isCurrentAccount =(acnt) ->
    acnt.uniqueName is $rootScope.selAcntUname

  $scope.moveAccnt = (group) ->
    if _.isUndefined(group.uniqueName)
      toastr.error("Select group only from list", "Error")
      return
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
      acntUname: $scope.selectedAccount.uniqueName
    }
    if _.isUndefined($scope.selectedGroup.uniqueName)
      lastVal = _.last($scope.selectedAccount.parentGroups)
      unqNamesObj.selGrpUname = lastVal.uniqueName

    body = {
      "uniqueName": group.uniqueName
    }
    accountService.move(unqNamesObj, body).then($scope.moveAccntSuccess, $scope.moveAccntFailure)

  $scope.moveAccntSuccess = (res) ->
    toastr.success(res.body, res.status)
    $scope.getGroups()
    $scope.showAccountDetails = false
    if !_.isEmpty($scope.selectedGroup)
      $scope.groupAccntList = _.reject($scope.groupAccntList, (item) ->
        return item.uniqueName == $scope.selectedAccount.uniqueName
      )
    # end if
    $scope.selectedAccount = {}
    $scope.selAcntPrevObj = {}


  $scope.moveAccntFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.shareAccount = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
      acntUname: $scope.selectedAccount.uniqueName
    }
    if _.isEmpty($scope.selectedGroup)
      unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName

    accountService.share(unqNamesObj, $scope.shareAccountObj).then($scope.onShareAccountSuccess, $scope.onShareAccountFailure)

  $scope.onShareAccountSuccess = (res) ->
    $scope.shareAccountObj.user = ""
    toastr.success(res.body, res.status)
    $scope.getAccountSharedList()

  $scope.onShareAccountFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.unShareAccount = (user) ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
      acntUname: $scope.selectedAccount.uniqueName
    }
    if _.isEmpty($scope.selectedGroup)
      unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName

    data = { user: user}
    accountService.unshare(unqNamesObj, data).then($scope.unShareAccountSuccess, $scope.unShareAccountFailure)

  $scope.unShareAccountSuccess = (res)->
    toastr.success(res.body, res.status)
    $scope.getAccountSharedList()

  $scope.unShareAccountFailure = (res)->
    toastr.error(res.data.message, res.data.status)

  $scope.getAccountSharedList = () ->
    if $scope.canShare
      unqNamesObj = {
        compUname: $rootScope.selectedCompany.uniqueName
        selGrpUname: $scope.selectedAccount.parentGroups[0].uniqueName
        acntUname: $scope.selectedAccount.uniqueName
      }
      accountService.sharedWith(unqNamesObj).then($scope.onGetAccountSharedListSuccess, $scope.onGetAccountSharedListSuccess)

  $scope.onGetAccountSharedListSuccess = (res) ->
    $scope.accountSharedUserList = res.body

  $scope.onGetAccountSharedListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.loadAccountsList = () ->
    if !_.isEmpty($rootScope.selectedCompany)
      $scope.getGroups()

  $scope.assignValues = () ->
    data = localStorageService.get("_selectedCompany")
    $rootScope.canViewSpecificItems = false
    if _.isUndefined(data) || _.isEmpty(data)
      
    else if data.role.uniqueName is 'shared'
      $rootScope.canManageComp = false
      if data.sharedEntity is 'groups'
        $rootScope.canViewSpecificItems = true
    else
      $rootScope.canManageComp = true

  $rootScope.$on 'reloadAccounts', ->
    $scope.showAccountList = false
    $scope.getGroups()

  $rootScope.$on 'callManageGroups', ->
    $scope.goToManageGroups()

  $timeout(->
    # $scope.loadAccountsList()
    if !_.isEmpty($rootScope.selectedCompany)
      $rootScope.$emit('reloadAccounts')
    $scope.assignValues()
  ,2000)
    
  ############################ for merge/unmerge accounts ############################
  $scope.toMerge = {
    mergeTo:''
    mergedAcc: []
    toUnMerge : {
      name: ''
      uniqueNames: []
      moveTo: ''
    }
    moveToAcc: ''
  }
  $scope.getMergedAccounts = (accData) ->
    $scope.showDeleteMove = false
    _.extend($scope.AccountsList ,$rootScope.fltAccntList)
    #remove selected account from AccountsList
    accToRemove = {
      uniqueName: accData.uniqueName
    }
    $scope.AccountsList = _.without($scope.AccountsList, _.findWhere($scope.AccountsList, accToRemove))

    $scope.prePopulate = []
    $scope.toMerge.mergeTo = accData.uniqueName
    mergedAcc = accData.mergedAccounts
    mList = []
    splitIdx = 0
    if !_.isEmpty(mergedAcc) && !_.isUndefined(mergedAcc)
      mList = mergedAcc.split(',')
      _.each mList, (mAcc) ->
        mObj = {
          uniqueName: ''
          noRemove : true
        }
        mObj.uniqueName = mAcc
        $scope.prePopulate.push(mObj)
      $scope.toMerge.mergedAcc = $scope.prePopulate
    else
      $scope.prePopulate = []
      $scope.toMerge.mergedAcc = []
  
  #merge account
  $scope.mergeAccounts = () ->
    accToMerge = []
    if $scope.prePopulate.length > 0
      _.each $scope.prePopulate,(pre) ->
        _.each $scope.toMerge.mergedAcc, (acc) ->
          accToSend = {
            "uniqueName": ""
          }
          if acc.uniqueName != pre.uniqueName
            accToSend.uniqueName = acc.uniqueName
            accToMerge.push(accToSend)
    else
      _.each $scope.toMerge.mergedAcc, (acc) ->
        accToSend = {
          "uniqueName": ""
        }
        accToSend.uniqueName = acc.uniqueName
        accToMerge.push(accToSend)  
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.toMerge.mergeTo
    }
    if accToMerge.length > 0 
      accountService.merge(unqNamesObj, accToMerge).then( $scope.mergeSuccess, $scope.mergeFailure)
    else
      toastr.error("Please select at least one account.")

  $scope.mergeSuccess = (res) ->
    toastr.success(res.body)
    $scope.getGroups()

  $scope.mergeFailure = (res) ->
    toastr.error(res.data.message)
  
  #delete account
  $scope.unmerge = (item) ->
    item.uniqueName = item.uniqueName.replace(RegExp(' ', 'g'), '')
    $scope.toMerge.toUnMerge.uniqueNames = []
    $scope.toMerge.toUnMerge.uniqueNames.push(item.uniqueName)
    $scope.showDeleteMove = true

  $scope.deleteMergedAccount = () ->
    $scope.toMerge.toUnMerge.moveTo = null
    modalService.openConfirmModal(
      title: 'Delete Merged Account',
      body: 'Are you sure you want to delete ' + $scope.toMerge.toUnMerge.uniqueNames[0] + ' ?',
      ok: 'Yes',
      cancel: 'No').then($scope.deleteMergedAccountConfirm)

  $scope.deleteMergedAccountConfirm = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.toMerge.mergeTo
    }
    accTosend = {
      "uniqueNames": $scope.toMerge.toUnMerge.uniqueNames
      "moveTo": $scope.toMerge.toUnMerge.moveTo
    }
    if $scope.toMerge.toUnMerge.uniqueNames.length != 0
      accountService.unMerge(unqNamesObj, accTosend).then( $scope.deleteMergedAccountSuccess, $scope.deleteMergedAccountFailure)
    else
      toastr.error('Please Select an Account to delete')

  $scope.deleteMergedAccountSuccess = (res) ->
    toastr.success(res.body)
    updatedMergedAccList = []
    _.each $scope.toMerge.mergedAcc, (obj) ->
      toRemove = {}
      if obj.uniqueName != $scope.toMerge.toUnMerge.uniqueNames[0]
        toRemove.uniqueName = obj.uniqueName
        updatedMergedAccList.push(toRemove)
    $scope.toMerge.mergedAcc = updatedMergedAccList
    $scope.toMerge.toUnMerge.uniqueNames = []

  $scope.deleteMergedAccountFailure = (res) ->
    toastr.error(res.body)

  # move to account
  $scope.moveToAccount = () ->
    modalService.openConfirmModal(
      title: 'Move Merged Account',
      body: 'Are you sure you want to move ' + $scope.toMerge.toUnMerge.uniqueNames[0] + ' to ' + $scope.toMerge.moveToAcc.uniqueName,
      ok: 'Yes',
      cancel: 'No').then($scope.moveToAccountConfirm)

  $scope.moveToAccountConfirm = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      acntUname: $scope.toMerge.mergeTo
    }
    accTosend = {
      uniqueNames: $scope.toMerge.toUnMerge.uniqueNames
      moveTo: $scope.toMerge.moveToAcc.uniqueName
    }
    if $scope.toMerge.toUnMerge.uniqueNames.length != 0
      accountService.unMerge(unqNamesObj, accTosend).then( $scope.moveToAccountConfirmSuccess, $scope.moveToAccountConfirmFailure)
    else
      toastr.error('Please Select an account to move.')

  $scope.moveToAccountConfirmSuccess = (res) ->
    toastr.success(res.body)
    updatedMergedAccList = []
    _.each $scope.toMerge.mergedAcc, (obj) ->
      toRemove = {}
      if obj.uniqueName != $scope.toMerge.toUnMerge.uniqueNames[0]
        toRemove.uniqueName = obj.uniqueName
        updatedMergedAccList.push(toRemove)

    $scope.toMerge.mergedAcc = updatedMergedAccList
    $scope.toMerge.toUnMerge.uniqueNames = []
    
  $scope.moveToAccountConfirmFailure = (res) ->
    toastr.error(res.body)


#init angular app
giddh.webApp.controller 'groupController', groupController