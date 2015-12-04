'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr, modalService, $timeout, accountService, locationService, $filter, permissionService) ->
  $scope.groupList = {}
  $scope.flattenGroupList = {}
  $scope.moveto = undefined
  $scope.selectedGroup = {}
  $scope.selectedSubGroup = {}
  $scope.selectedAccount = {}
  $scope.selAcntPrevObj = {}
  $scope.datePicker = {accountOpeningBalanceDate: ""}
  $scope.selectedGroupUName = ""

  $scope.showGroupDetails = false
  $scope.subGroupVisible = false
  $scope.showListGroupsNow = false
  $scope.showAccountDetails = false
  $scope.showAccountListDetails = false

  $scope.canUpdate = false
  $scope.canDelete = false
  $scope.canAdd = false

  #set a object for share group
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
  
  #date time picker code starts here
  $scope.today = new Date()

  $scope.valuationDatePickerIsOpen = false

  $scope.valuationDatePickerOpen = ->
    this.valuationDatePickerIsOpen = true

  $scope.dateOptions = {
    'year-format': "'yy'",
    'starting-day': 1,
    'showWeeks': false,
    'show-button-bar': false,
    'year-range': 1,
    'todayBtn': false
  }
  $scope.format = "dd-MM-yyyy"

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

  $scope.getGroups = ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllWithAccountsFor($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess,
          $scope.getGroupListFailure)

  $scope.getGroupListSuccess = (res) ->
    $scope.groupList = res.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList, [])
    $scope.flatAccntList = groupService.flattenAccount($scope.groupList)
    $scope.showListGroupsNow = true
    if not _.isEmpty($scope.selectedGroup)
      $scope.selectedGroup = _.find($scope.flattenGroupList, (item) ->
        item.uniqueName == $scope.selectedGroup.uniqueName
      )
      $scope.selectItem($scope.selectedGroup)

  $scope.getGroupListFailure = (res) ->
    toastr.error("Unable to get group details.", "Error")

  $scope.selectGroupToEdit = (group) ->
    $scope.selectedGroup = group
    if _.isEmpty($scope.selectedGroup.oldUName)
      $scope.selectedGroup.oldUName = $scope.selectedGroup.uniqueName
    $scope.selectedSubGroup = {}
    $scope.showGroupDetails = true
    $scope.showAccountListDetails = true
    $scope.showAccountDetails = false
    $scope.hasAddPermission(group)
    $scope.hasUpdatePermission(group)
    $scope.hasDeletePermission(group)

    $scope.getGroupSharedList(group)
    $scope.groupAccntList = group.accounts
    $scope.accountsSearch = undefined

  $scope.getGroupSharedList = () ->
    if $scope.hasSharePermission()
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
    $rootScope.$broadcast('$reloadAccount')

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
    $rootScope.$broadcast('$reloadAccount')

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
    toastr.success("Group moved successfully.", "Success")
    $scope.getGroups()
    $scope.moveto = undefined

  $scope.onMoveGroupFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.stopBubble = (e) ->
    e.stopPropagation()

  $scope.selectItem = (item) ->
    $scope.selectedItem = item
    $scope.selectedAccntMenu = undefined
    $scope.selectGroupToEdit(item)

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

  #highlight account menus
  $scope.selectAcMenu = (item) ->
    $scope.selectedAccntMenu = item

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
    pGroups = []
    if _.isEmpty($scope.selectedGroup)
      $scope.hasSharePermission()
      $scope.hasAddPermission(data.parentGroups[0])
      $scope.hasUpdatePermission(data.parentGroups[0])
      $scope.hasDeletePermission(data.parentGroups[0])
    $scope.showGroupDetails = false
    $scope.showAccountDetails = true
    angular.copy(data, $scope.selAcntPrevObj)
    _.extend($scope.selectedAccount, data)
    _.extend(pGroups, data.parentGroups)
    $scope.showBreadCrumbs(pGroups.reverse())
    $scope.breakMobNo(data)
    $scope.setOpeningBalanceDate()
    $scope.getAccountSharedList()
    # for play between update and add
    $scope.acntCase = "Update"

  # prepare date object
  $scope.setOpeningBalanceDate = () ->
    if $scope.selectedAccount.openingBalanceDate
      newDateObj = $scope.selectedAccount.openingBalanceDate.split("-")
      $scope.datePicker.accountOpeningBalanceDate = new Date(newDateObj[2], newDateObj[1] - 1, newDateObj[0])
    else
      $scope.datePicker.accountOpeningBalanceDate = new Date()

  $scope.addNewAccountShow = (groupData)  ->
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
    $scope.selectedAccount = {}
    $scope.selectedGroup.accounts.push(res.body)
    $scope.groupAccntList = $scope.selectedGroup.accounts
    $rootScope.$broadcast('$reloadAccount')

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

    accountService.deleteAc(unqNamesObj, $scope.selectedAccount).then($scope.onDeleteAccountSuccess, $scope.onDeleteAccountFailure)

  $scope.onDeleteAccountSuccess = (res) ->
    toastr.success("Account deleted successfully.", "Success")
    $scope.getGroups()
    $scope.selectedAccount = {}

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
      unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName

    accountService.updateAc(unqNamesObj, $scope.selectedAccount).then($scope.updateAccountSuccess,
        $scope.updateAccountFailure)
    $rootScope.$broadcast('$reloadAccount')

  $scope.updateAccountSuccess = (res) ->
    $rootScope.$broadcast('$reloadLedger')
    toastr.success("Group updated successfully", res.status)
    angular.merge($scope.selectedAccount, res.body)
    angular.merge($scope.selAcntPrevObj, res.body)
    getTrueIndex = 0
    getIndex = _.find($scope.selectedGroup.accounts, (item, index) ->
      if item.uniqueName == $scope.selectedAccount.uniqueName
        getTrueIndex = index
    )
    if !_.isEmpty($scope.selectedGroup)
      angular.merge($scope.groupAccntList[getTrueIndex], $scope.selectedAccount)

  $scope.updateAccountFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.isCurrentGroup =(group) ->
    group.uniqueName is $scope.selectedAccount.parentGroups[0].uniqueName

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
      unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName

    body = {
      "uniqueName": group.uniqueName
    }
    accountService.move(unqNamesObj, body).then($scope.moveAccntSuccess, $scope.moveAccntFailure)

  $scope.moveAccntSuccess = (res) ->
    toastr.success(res.body, res.status)
    $scope.getGroups()
    $scope.showAccountDetails = false

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
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
      acntUname: $scope.selectedAccount.uniqueName
    }
    if _.isEmpty($scope.selectedGroup)
      unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName
    accountService.sharedWith(unqNamesObj).then($scope.onGetAccountSharedListSuccess, $scope.onGetAccountSharedListSuccess)

  $scope.onGetAccountSharedListSuccess = (res) ->
    $scope.accountSharedUserList = res.body

  $scope.onGetAccountSharedListFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.hasSharePermission = () ->
    permissionService.hasPermissionOn($scope.selectedCompany, "MNG_USR")

  $scope.hasUpdatePermission = (group) ->
    $scope.canUpdate = permissionService.hasPermissionOn(group, "UPDT")

  $scope.hasAddPermission = (group) ->
    $scope.canAdd = permissionService.hasPermissionOn(group, "ADD")

  $scope.hasDeletePermission = (group) ->
    $scope.canDelete = permissionService.hasPermissionOn(group, "DLT")

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController