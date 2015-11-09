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
  $scope.shareGroupObj =
    role: "view_only"
    user: ""
  $scope.openingBalType = [
    {"name": "Credit", "val": "CREDIT"}
    {"name": "Debit", "val": "DEBIT"}
  ]
  $scope.acntExt = {
    Ccode: undefined,
    onlyMobileNo: undefined
  }




  # expand and collapse all tree structure
  getRootNodesScope = ->
    angular.element(document.getElementById('tree-root')).scope()

  $scope.collapseAll = ->
    scope = getRootNodesScope()
    scope.collapseAll()
    $scope.subGroupVisible = true

  $scope.expandAll = ->
    scope = getRootNodesScope()
    scope.expandAll()
    $scope.subGroupVisible = false

  $scope.getGroups = ->
    if _.isEmpty($rootScope.selectedCompany)
      toastr.error("Select company first.", "Error")
    else
      groupService.getAllWithAccountsFor($rootScope.selectedCompany.uniqueName).then($scope.getGroupListSuccess,
          $scope.getGroupListFailure)

  $scope.getGroupListSuccess = (result) ->
# angular.extend($scope.groupList, result.body)
    $scope.groupList = result.body
    $scope.flattenGroupList = groupService.flattenGroup($scope.groupList, [])
    $scope.flatAccntList = groupService.flattenAccount($scope.groupList)
    $scope.showListGroupsNow = true
    if not _.isEmpty($scope.selectedGroup)
      $scope.selectedGroup = _.find($scope.flattenGroupList, (item) ->
        item.uniqueName == $scope.selectedGroup.uniqueName
      )
      $scope.selectItem($scope.selectedGroup)

  $scope.getGroupListFailure = () ->
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

  $scope.onsharedListSuccess = (result) ->
    $scope.groupSharedUserList = result.body

  $scope.onsharedListFailure = (result) ->
    console.log result, "on shared List Failure"

  #share group with user
  $scope.shareGroup = () ->
    unqNamesObj = {
      compUname: $rootScope.selectedCompany.uniqueName
      selGrpUname: $scope.selectedGroup.uniqueName
    }
    groupService.share(unqNamesObj, $scope.shareGroupObj).then($scope.onShareGroupSuccess, $scope.onShareGroupFailure)

  $scope.onShareGroupSuccess = (response) ->
    $scope.shareGroupObj = {
      role: "view_only"
      user: ""
    }
    toastr.success(response.body, response.status)
    $scope.getGroupSharedList($scope.selectedGroup)

  $scope.onShareGroupFailure = (response) ->
    toastr.error(response.data.message, response.data.status)

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

  $scope.unShareGroupSuccess = (response)->
    toastr.success(response.body, response.status)
    $scope.getGroupSharedList($scope.selectedGroup)

  $scope.unShareGroupFailure = (response)->
    toastr.error(response.data.message, response.data.status)

  $scope.updateGroup = ->
    $scope.selectedGroup.uniqueName = $scope.selectedGroup.uniqueName.toLowerCase()
    groupService.update($scope.selectedCompany.uniqueName, $scope.selectedGroup).then($scope.onUpdateGroupSuccess,
        $scope.onUpdateGroupFailure)

  $scope.onUpdateGroupSuccess = () ->
    $scope.selectedGroup.oldUName = $scope.selectedGroup.uniqueName
    if not _.isEmpty($scope.selectedGroup)
      $scope.selectedItem = $scope.selectedGroup
    toastr.success("Group has been updated successfully.", "Success")
    $scope.getGroups()
    $rootScope.$broadcast('$reloadAccount')

  $scope.onUpdateGroupFailure = () ->
    toastr.error("Unable to update group at the moment. Please try again later.", "Error")

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

  $scope.onCreateGroupSuccess = () ->
    toastr.success("Sub group added successfully", "Success")
    $scope.selectedSubGroup = {}
    $scope.getGroups()

  $scope.onCreateGroupFailure = () ->
    toastr.error("Unable to create subgroup.", "Error")

  $scope.deleteGroup = ->
    if not $scope.selectedGroup.isFixed
      modalService.openConfirmModal(
        title: 'Delete group?',
        body: 'Are you sure you want to delete this group? All child groups will also be deleted.',
        ok: 'Yes',
        cancel: 'No').then -> groupService.delete($rootScope.selectedCompany.uniqueName,
          $scope.selectedGroup).then($scope.onDeleteGroupSuccess,
          $scope.onDeleteGroupFailure)

  $scope.onDeleteGroupSuccess = () ->
    toastr.success("Group deleted successfully.", "Success")
    $scope.selectedGroup = {}
    $scope.showGroupDetails = false
    $scope.showAccountListDetails = false
    $scope.getGroups()
    $rootScope.$broadcast('$reloadAccount')

  $scope.onDeleteGroupFailure = () ->
    toastr.error("Unable to delete group.", "Error")

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

  $scope.onMoveGroupSuccess = () ->
    toastr.success("Group moved successfully.", "Success")
    $scope.getGroups()
    #    $scope.selectedGroup = {}
    #    $scope.showGroupDetails = false
    $scope.moveto = undefined
  #    $scope.showAccountListDetails = false

  $scope.onMoveGroupFailure = () ->
    toastr.error("Unable to move group.", "Error")

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
    console.log "jumpToGroup"
    fltGrpList = groupService.flattenGroup(grpList, [])
    obj = _.find(fltGrpList, (item) ->
      item.uniqueName == grpUniqName
    )
    $scope.selectGroupToEdit(obj)
    $scope.selectItem(obj)


  #check if object is empty
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

  #show account
  $scope.showAccountDtl = (data) ->
    console.log data, "showAccountDtl"
    angular.copy(data, $scope.selAcntPrevObj)
    if _.isEmpty($scope.selectedGroup)
      $scope.hasSharePermission()
      $scope.hasAddPermission(data.parentGroups[0])
      $scope.hasUpdatePermission(data.parentGroups[0])
      $scope.hasDeletePermission(data.parentGroups[0])
    $scope.showGroupDetails = false
    $scope.showAccountDetails = true
    angular.extend($scope.selectedAccount, data)
    pGroups = []
    angular.extend(pGroups, data.parentGroups)
    $scope.showBreadCrumbs(pGroups.reverse())
    $scope.breakMobNo(data)
    $scope.setOpeningBalanceDate()
    # for play between update and add
    $scope.acntCase = "Update"
    

  # prepare date object
  $scope.setOpeningBalanceDate = () ->
    if $scope.selectedAccount.openingBalanceDate
      newDateObj = $scope.selectedAccount.openingBalanceDate.split("-");
      $scope.datePicker.accountOpeningBalanceDate = new Date(newDateObj[2], newDateObj[1] - 1, newDateObj[0]);
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
    $scope.setOpeningBalanceDate()
    $scope.showGroupDetails = false
    $scope.showAccountDetails = true
    # for play between update and add
    $scope.acntCase = "Add"
    $scope.selectedAccntMenu = undefined
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
    console.log "addAccount", $scope.selectedAccount
    unqNamesObj = $scope.setAdditionalAccountDetails()
    console.log unqNamesObj
    # accountService.createAc(unqNamesObj, $scope.selectedAccount).then($scope.addAccountSuccess,
    #     $scope.addAccountFailure)

  # $scope.selectGroupToEdit = (group)
  $scope.addAccountSuccess = (result) ->
    toastr.success("Account updated successfully", result.status)
    $scope.selectedAccount = {}
    $scope.selectedGroup.accounts.push(result.body)
    $scope.groupAccntList = $scope.selectedGroup.accounts
    $rootScope.$broadcast('$reloadAccount')


  $scope.addAccountFailure = (result) ->
    console.log "addAccountFailure", result
    toastr.error(result.data.message, "Error")


  $scope.deleteAccount = ->
    if $scope.canDelete
      unqNamesObj = $scope.setAdditionalAccountDetails()
      if $scope.selectedAccount.uniqueName isnt $scope.selAcntPrevObj.uniqueName
        unqNamesObj.acntUname = $scope.selAcntPrevObj.uniqueName

      if _.isEmpty($scope.selectedGroup)
        unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName

      modalService.openConfirmModal(
        title: 'Delete Account?',
        body: 'Are you sure you want to delete this Account?',
        ok: 'Yes',
        cancel: 'No').then -> accountService.deleteAc(unqNamesObj,
          $scope.selectedAccount).then($scope.onDeleteAccountSuccess,
          $scope.onDeleteAccountFailure)

  $scope.onDeleteAccountSuccess = () ->
    toastr.success("Account deleted successfully.", "Success")
    $scope.getGroups()
    $scope.selectedAccount = {}


  $scope.onDeleteAccountFailure = () ->
    toastr.error("Unable to delete group.", "Error")

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

  $scope.updateAccountSuccess = (result) ->
    toastr.success("Group updated successfully", result.status)
    angular.merge($scope.selectedAccount, result.body)
    getTrueIndex = 0
    getIndex = _.find($scope.selectedGroup.accounts, (item, index) ->
      if item.uniqueName == $scope.selectedAccount.uniqueName
        getTrueIndex = index
    )
    if !_.isEmpty($scope.selectedGroup)
      angular.merge($scope.groupAccntList[getTrueIndex], $scope.selectedAccount)
  
  $scope.updateAccountFailure = (result) ->
    console.log "updateAccountFailure", result
    toastr.error(result.data.message, "Error")

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