# 'use strict'

# groupController = ($scope, $rootScope, localStorageService, groupService, toastr, modalService, $timeout, accountService, locationService, ledgerService, $filter, permissionService, DAServices, $location, $uibModal, companyServices) ->
#   gc = this
#   $scope.groupList = {}
#   $scope.flattenGroupList = []
#   $scope.moveto = undefined
#   $scope.selectedGroup = {}
#   $scope.selectedSubGroup = {}
#   $scope.selectedAccount = {}
#   $scope.selAcntPrevObj = {}
#   $scope.datePicker = {accountOpeningBalanceDate: ""}
#   $scope.selectedGroupUName = ""
#   $scope.cantUpdate = false
#   $scope.showGroupDetails = false
#   $scope.subGroupVisible = false
#   $scope.showListGroupsNow = false
#   $scope.showAccountDetails = false
#   $scope.showAccountListDetails = false
#   $scope.showMergeDescription = true
#   $scope.mergedAccounts = ''
#   $scope.showDeleteMove = false
#   $scope.AccountsList = []
#   $scope.groupAccntList = []
#   $scope.search = {}
#   $scope.search.acnt = ''
#   $scope.showEditTaxSection = false
#   $scope.shareGroupObj = {role: "view_only"}
#   $scope.shareAccountObj ={role: "view_only"}
#   $scope.openingBalType = [
#     {"name": "Credit", "val": "CREDIT"}
#     {"name": "Debit", "val": "DEBIT"}
#   ]
#   $scope.acntExt = {
#     Ccode: undefined,
#     onlyMobileNo: undefined
#   }
#   $scope.today = new Date()
#   $scope.valuationDatePickerIsOpen = false
#   $scope.dateOptions = {
#     'year-format': "'yy'",
#     'starting-day': 1,
#     'showWeeks': false,
#     'show-button-bar': false,
#     'year-range': 1,
#     'todayBtn': false
#   }
#   $scope.format = "dd-MM-yyyy"
#   $scope.flatAccntWGroupsList = []
#   $scope.showAccountList = false
#   $scope.selectedAccountUniqueName = undefined
#   $scope.flatAccntWGroupsList_1 = []
#   $scope.noGroups = false
#   $scope.hideLoadMore = false
#   $scope.hideAccLoadMore = false
#   $scope.isFixedAcc = false
#   $scope.gwaList = {
#     page: 1
#     count: 5
#     totalPages: 0
#     currentPage : 1
#     limit: 5
#   }

#   $scope.taxHierarchy = {}
#   $scope.taxHierarchy.applicableTaxes = []
#   $scope.taxHierarchy.inheritedTaxes = []
#   $scope.taxInEditMode = false
#   $scope.havePermission = false
# #  $scope.fltAccntListPaginated = []
# #  $scope.flatAccList = {
# #    page: 1
# #    count: 5
# #    totalPages: 0
# #    currentPage : 1
# #    limit: 5
# #  }

#   $scope.selectedTax = {}
#   $scope.selectedTax.taxes = ''

#   $scope.valuationDatePickerOpen = ()->
#     this.valuationDatePickerIsOpen = true

#   # dom method function
#   gc.highlightAcMenu = () ->
#     url = $location.path().split("/")
#     if url[1] is "ledger"
#       $timeout ->
#         acEle = document.getElementById("ac_" + url[2])
#         if acEle is null
#           return false
#         parentSib = acEle.parentElement.previousElementSibling
#         angular.element(parentSib).trigger('click')
#         angular.element(acEle).children().trigger('click')
#       , 500

#   # expand and collapse all tree structure
#   getRootNodesScope = ->
#     angular.element(document.getElementById('tree-root')).scope()

#   $scope.collapseAll = () ->
#     scope = getRootNodesScope()
#     scope.collapseAll()
#     $scope.subGroupVisible = true

#   $scope.expandAll = () ->
#     scope = getRootNodesScope()
#     scope.expandAll()
#     $scope.subGroupVisible = false
#   # dom method functions end

#   $scope.goToManageGroups =() ->
# #    $scope.fltAccntListPaginated = []
# #    $scope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
#     if !$rootScope.canManageComp
#       return
#     $scope.getFlatAccountListCount5($rootScope.selectedCompany.uniqueName)
#     if _.isEmpty($rootScope.selectedCompany)
#       toastr.error("Select company first.", "Error")
#     else
#       modalInstance = $uibModal.open(
#         templateUrl: '/public/webapp/ManageGroupsAndAccounts/addManageGroupModal.html'
#         size: "liq90"
#         backdrop: 'static'
#         scope: $scope
#       )
#       modalInstance.result.then(gc.goToManageGroupsOpen, gc.goToManageGroupsClose)

#   gc.goToManageGroupsOpen = (res) ->
#     console.log "manage opened", res

#   gc.goToManageGroupsClose = () ->
#     $scope.selectedGroup = {}
#     $scope.selectedAccntMenu = undefined
#     $scope.selectedItem = undefined
#     $scope.showGroupDetails = false
#     $scope.showAccountDetails = false
#     $scope.showAccountListDetails = false
#     $scope.cantUpdate = false
#     $scope.selectedTax.taxes = {}
#     $scope.showEditTaxSection = false
#     groupService.getGroupsWithoutAccountsCropped($rootScope.selectedCompany.uniqueName).then(gc.getGroupListSuccess, gc.getGroupListFailure)

# # #########################################################################################################################
# # new add & manage modal

#   # $scope.NewgoToManageGroups =() ->
#   #   if !$rootScope.canManageComp
#   #     return
#   #   $scope.getFlatAccountListCount5($rootScope.selectedCompany.uniqueName)
#   #   if _.isEmpty($rootScope.selectedCompany)
#   #     toastr.error("Select company first.", "Error")
#   #   else
#   #     modalInstance = $uibModal.open(
#   #       templateUrl: $rootScope.prefixThis+'/public/webapp/NewManageGroupsAndAccounts/ManageGroupModal.html'
#   #       size: "liq90"
#   #       backdrop: 'static'
#   #       scope: $scope
#   #     )
#   #     modalInstance.result.then(mc.goToManageGroupsOpen, mc.goToManageGroupsClose)



#   $scope.setLedgerData = (data, acData) ->
#     $scope.selectedAccountUniqueName = acData.uniqueName
#     $rootScope.selectedAccount = acData
#     DAServices.LedgerSet(data, acData)
#     localStorageService.set("_ledgerData", data)
#     localStorageService.set("_selectedAccount", acData)
#     $rootScope.$emit('account-selected')
#     return false


#   #Expand or  Collapse all account menus
#   # $scope.toggleAcMenus = (state) ->
#   #   if !_.isEmpty($scope.flatAccntWGroupsList)
#   #     _.each($scope.flatAccntWGroupsList, (e) ->
#   #       e.open = state
#   #       $scope.showSubMenus = state
#   #     )

#   # trigger expand or collapse func
#   # $scope.checkLength = (val)->
#   #   if val is '' || _.isUndefined(val)
#   #     $scope.toggleAcMenus(false)
#   #   else if val.length >= 4
#   #     $scope.toggleAcMenus(true)
#   #   else
#   #     $scope.toggleAcMenus(false)
#   # end acCntrl

#   $scope.getGroups =() ->
#     $scope.search = {}
#     if _.isEmpty($rootScope.selectedCompany)
#       toastr.error("Select company first.", "Error")
#     else
#       # with accounts, group data
#       $scope.getFlattenGrpWithAccList($rootScope.selectedCompany.uniqueName)
#       $scope.getFlatAccountListCount5($rootScope.selectedCompany.uniqueName)
#       #$rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
#       groupService.getGroupsWithAccountsCropped($rootScope.selectedCompany.uniqueName).then(gc.makeAccountsList, gc.makeAccountsListFailure)

#       # without accounts only groups conditionally
#       cData = localStorageService.get("_selectedCompany")
#       if cData.sharedEntity is 'accounts'
#         #console.info "sharedEntity:"+ cData.sharedEntity
#       else
#         groupService.getGroupsWithoutAccountsCropped($rootScope.selectedCompany.uniqueName).then(gc.getGroupListSuccess, gc.getGroupListFailure)

#   gc.makeAccountsList = (res) ->
#     # flatten all groups with accounts and only accounts flatten
#     a = []
#     angular.copy(res.body, a)
#     $rootScope.flatGroupsList = groupService.flattenGroup(a, [])
#     #$scope.flatAccntWGroupsList = groupService.flattenGroupsWithAccounts($rootScope.flatGroupsList)
#     #$scope.showAccountList = true
#     $rootScope.canChangeCompany = true
#     b = groupService.flattenAccount(a)
#     #$rootScope.makeAccountFlatten(b)
#     $scope.flattenGroupList = groupService.makeGroupListFlatwithLessDtl($rootScope.flatGroupsList)

#   $scope.getParticularGroup = (searchThis) ->
#     groupList = []
#     _.filter($scope.flattenGroupList,(group) ->
#       if(group.name.match(searchThis) != null || group.uniqueName.match(searchThis) != null)
#         groupList.push(group)
#     )
#     groupList

#   gc.makeAccountsListFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   #-------------------Functions for API side search and fetching flat account list-----------------------------------------------#

#   $scope.getFlatAccountList = (compUname) ->
#     $rootScope.getFlatAccountList(compUname)


#   # get flat account list with count 5

#   $scope.flatAccListC5 = {
#     page: 1
#     count: 5
#     totalPages: 0
#     currentPage : 1
#     limit : 5
#   }

#   gc.accountsListShort = []
#   $scope.getFlatAccountListCount5 = (compUname) ->
#     reqParam = {
#       companyUniqueName: compUname
#       q: ''
#       page: $scope.flatAccListC5.page
#       count: $scope.flatAccListC5.count
#     }
#     # if $scope.workInProgress == false
#     groupService.getFlatAccList(reqParam).then(gc.getFlatAccountListCount5ListSuccess, gc.getFlatAccountListCount5ListFailure)
#       #$scope.workInProgress = true

#   gc.getFlatAccountListCount5ListSuccess = (res) ->
# #    console.log res.body.res
#     #$scope.workInProgress = false
#     #$scope.fltAccntListcount5 = res.body.results
#     gc.accountsListShort = res.body.results
#     $scope.flatAccListC5.totalPages = res.body.totalPages

#   gc.getFlatAccountListCount5ListFailure = (res) ->
#     $scope.workInProgress = false
#     if !_.isUndefined(res)
#       toastr.error(res.data.message)

#   # search flat accounts list
#   $scope.searchAccountsC5 = (str) ->
#     reqParam = {
#       companyUniqueName: $rootScope.selectedCompany.uniqueName
#       q: str
#       page: 1
#       count: $scope.flatAccListC5.count
#     }
#     if str.length > 2
#       groupService.getFlatAccList(reqParam).then(gc.getFlatAccountListCount5ListSuccess, gc.getFlatAccountListCount5ListFailure)
#     else
#       reqParam.q = ''
#       groupService.getFlatAccList(reqParam).then(gc.getFlatAccountListCount5ListSuccess, gc.getFlatAccountListCount5ListFailure)
#     if str.length < 1
#       $scope.flatAccListC5.limit = 5

#   # load-more function for accounts list on add and manage popup
#   $rootScope.loadMoreAcc = (compUname, query) ->
#     if query == undefined then (query = '') else (query = query)
#     $scope.flatAccListC5.page += 1
#     reqParam = {
#       companyUniqueName: compUname
#       q: query
#       page: $scope.flatAccListC5.page
#       count: $scope.flatAccListC5.count
#     }
#     groupService.getFlatAccList(reqParam).then($scope.loadMoreAccSuccess, gc.loadMoreAccFailure)
#     #$scope.flatAccList.limit += 5
#     #$scope.flatAccListC5.limit += 5
    
#   $scope.loadMoreAccSuccess = (res) ->
#     list = res.body.results
#     if res.body.totalPages > $scope.flatAccListC5.currentPage
#      #$scope.fltAccntListcount5 = _.union($scope.fltAccntListcount5, list)
#       _.each res.body.results, (acc) ->
#         #$scope.fltAccntListcount5.push(acc)
#         gc.accountsListShort.push(acc)
      
#     else
#      $scope.hideAccLoadMore = true
#     $scope.flatAccListC5.limit += 5
#     $scope.flatAccListC5.currentPage = res.body.page
#     $scope.flatAccListC5.totalPages = res.body.totalPages

#   gc.loadMoreAccFailure = (res) ->
#     toastr.error(res.data.message)

#   #----------for merge account refresh----------#
#   $scope.mergeAccList = []
#   $scope.refreshFlatAccount = (str) ->
#     @success = (res) ->
#       $scope.mergeAccList = res.body.results
#     @failure = (res) ->
#       toastr.error(res.data.message)
#     reqParam = {
#       companyUniqueName: $rootScope.selectedCompany.uniqueName
#       q: str
#       page: 1
#       count: 0
#     }
#     if str.length > 1
#       groupService.getFlatAccList(reqParam).then(@success, @failure)

#   #-------- fetch groups with accounts list-------
# #   $scope.working = false
# #   $scope.getFlattenGrpWithAccList = (compUname) ->
# # #    console.log("working  : ",$scope.working)
# #     $rootScope.companyLoaded = false
# #     reqParam = {
# #       companyUniqueName: compUname
# #       q: ''
# #       page: $scope.gwaList.page
# #       count: $scope.gwaList.count
# #     }
# #     if $scope.working == false
# #       $scope.working = true
# #       groupService.getFlattenGroupAccList(reqParam).then(gc.getFlattenGrpWithAccListSuccess, gc.getFlattenGrpWithAccListFailure)


# #   gc.getFlattenGrpWithAccListSuccess = (res) ->
# #     $scope.gwaList.page = res.body.page
# #     $scope.gwaList.totalPages = res.body.totalPages
# #     $scope.flatAccntWGroupsList = res.body.results
# #     #$scope.flatAccntWGroupsList = gc.removeEmptyGroups(res.body.results)
# # #    console.log($scope.flatAccntWGroupsList)
# #     $scope.showAccountList = true
# #     $scope.gwaList.limit = 5
# #     $rootScope.companyLoaded = true
# #     $scope.working = false

# #   gc.getFlattenGrpWithAccListFailure = (res) ->
# #     toastr.error(res.data.message)
# #     $scope.working = false

# #   $scope.loadMoreGrpWithAcc = (compUname, str) ->
# #     $scope.gwaList.page += 1
# #     reqParam = {
# #       companyUniqueName: compUname
# #       q: str
# #       page: $scope.gwaList.page
# #       count: $scope.gwaList.count
# #     }
# #     groupService.getFlattenGroupAccList(reqParam).then(gc.loadMoreGrpWithAccSuccess, gc.loadMoreGrpWithAccFailure)
# #     $scope.gwaList.limit += 5

# #   gc.loadMoreGrpWithAccSuccess = (res) ->
# #     $scope.gwaList.currentPage += 1
# #     #list = gc.removeEmptyGroups(res.body.results)
# #     if res.body.results.length > 0 && res.body.totalPages >= $scope.gwaList.currentPage
# #       _.each res.body.results, (grp) ->
# #         $scope.flatAccntWGroupsList.push(grp) 
# #       #$scope.flatAccntWGroupsList = _.union($scope.flatAccntWGroupsList, list)
# #     else if res.body.totalPages >= $scope.gwaList.currentPage
# #       $scope.loadMoreGrpWithAcc($rootScope.selectedCompany.uniqueName)
# #     else
# #       $scope.hideLoadMore = true

# #   gc.loadMoreGrpWithAccFailure = (res) ->
# #     toastr.error(res.data.message)

# #   $scope.searchGrpWithAccounts = (str) ->
# #     $scope.gwaList.page = 1
# #     $scope.gwaList.currentPage = 1
# #     reqParam = {}
# #     reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
# #     if str.length > 2
# #       #$scope.hideLoadMore = true
# #       reqParam.q = str
# #       reqParam.page = $scope.gwaList.page
# #       reqParam.count = $scope.gwaList.count
# #       groupService.getFlattenGroupAccList(reqParam).then(gc.getFlattenGrpWithAccListSuccess, gc.getFlattenGrpWithAccListFailure)
# #     else
# #       #$scope.hideLoadMore = false
# #       reqParam.q = ''
# #       groupService.getFlattenGroupAccList(reqParam).then(gc.getFlattenGrpWithAccListSuccess, gc.getFlattenGrpWithAccListFailure)
# #     if str.length < 1
# #       $scope.flatAccListC5.limit = 5
# #       #$scope.hideLoadMore = false

# #   gc.removeEmptyGroups = (grpList) ->
# #     newList = []
# #     _.each grpList, (grp) ->
# #       if grp.accountDetails.length > 0
# #         newList.push(grp)
# #     newList

#   #-------------------Functions for API side search and fetching flat account list end here-----------------------------------------------#

#   gc.addFilterKey = (data, n) ->
#     n = n || 1
#     _.each data, (grp) ->
#       grp.isVisible = true
#       grp.hLevel = n

#       if grp.groups.length > 0
#         n += 1
#         _.each grp.groups, (sub) ->
#           sub.isVisible = true
#           sub.hLevel = n
#           if sub.groups.length > 0
#             n += 1
#             gc.addFilterKey(sub.groups, n)
#     data

#   gc.getGroupListSuccess = (res) ->
#     $scope.groupList = gc.addFilterKey(res.body)
#     $scope.showListGroupsNow = true
#     gc.highlightAcMenu()

#   gc.getGroupListFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   $scope.getGroupSharedList = () ->
#     if $scope.canShare
#       unqNamesObj = {
#         compUname: $rootScope.selectedCompany.uniqueName
#         selGrpUname: $scope.selectedGroup.uniqueName
#       }
#       groupService.sharedList(unqNamesObj).then(gc.onsharedListSuccess, gc.onsharedListFailure)

#   gc.onsharedListSuccess = (res) ->
#     $scope.groupSharedUserList = res.body

#   gc.onsharedListFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   #share group with user
#   $scope.shareGroup = () ->
#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       selGrpUname: $scope.selectedGroup.uniqueName
#     }
#     groupService.share(unqNamesObj, $scope.shareGroupObj).then(gc.onShareGroupSuccess, gc.onShareGroupFailure)

#   gc.onShareGroupSuccess = (res) ->
#     $scope.shareGroupObj = {
#       role: "view_only"
#       user: ""
#     }
#     toastr.success(res.body, res.status)
#     $scope.getGroupSharedList($scope.selectedGroup)

#   gc.onShareGroupFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   #unShare group with user
#   $scope.unShareGroup = (user) ->
#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       selGrpUname: $scope.selectedGroup.uniqueName
#     }
#     data = {
#       user: user
#     }
#     groupService.unshare(unqNamesObj, data).then(gc.unShareGroupSuccess, gc.unShareGroupFailure)

#   gc.unShareGroupSuccess = (res)->
#     toastr.success(res.body, res.status)
#     $scope.getGroupSharedList($scope.selectedGroup)

#   gc.unShareGroupFailure = (res)->
#     toastr.error(res.data.message, res.data.status)

#   $scope.updateGroup = ->
#     $scope.selectedGroup.uniqueName = $scope.selectedGroup.uniqueName.toLowerCase()
#     if $scope.selectedGroup.applicableTaxes.length > 0
#       $scope.selectedGroup.applicableTaxes = _.pluck($scope.selectedGroup.applicableTaxes, 'uniqueName')
#     groupService.update($scope.selectedCompany.uniqueName, $scope.selectedGroup).then(gc.onUpdateGroupSuccess,
#         gc.onUpdateGroupFailure)

#   gc.onUpdateGroupSuccess = (res) ->
#     $scope.selectedGroup.oldUName = $scope.selectedGroup.uniqueName
#     $scope.selectedGroup.applicableTaxes = res.body.applicableTaxes
#     if not _.isEmpty($scope.selectedGroup)
#       $scope.selectedItem = $scope.selectedGroup
#     toastr.success("Group has been updated successfully.", "Success")
#     $scope.getGroups()

#   gc.onUpdateGroupFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   gc.getUniqueNameFromGroupList = (list) ->
#     listofUN = _.map(list, (listItem) ->
#       if listItem.groups.length > 0
#         uniqueList = gc.getUniqueNameFromGroupList(listItem.groups)
#         uniqueList.push(listItem.uniqueName)
#         uniqueList
#       else
#         listItem.uniqueName
#     )
#     _.flatten(listofUN)

#   $scope.addNewSubGroup = ->
#     uNameList = gc.getUniqueNameFromGroupList($scope.groupList)
#     UNameExist = _.contains(uNameList, $scope.selectedSubGroup.uniqueName)
#     if UNameExist
#       toastr.error("Unique name is already in use.", "Error")
#       return

#     if _.isEmpty($scope.selectedSubGroup.name)
#       return

#     body = {
#       "name": $scope.selectedSubGroup.name,
#       "uniqueName": $scope.selectedSubGroup.uniqueName.toLowerCase(),
#       "parentGroupUniqueName": $scope.selectedGroup.uniqueName,
#       "description": $scope.selectedSubGroup.desc
#     }
#     groupService.create($rootScope.selectedCompany.uniqueName, body).then(gc.onCreateGroupSuccess,gc.onCreateGroupFailure)

#   gc.onCreateGroupSuccess = (res) ->
#     toastr.success("Sub group added successfully", "Success")
#     $scope.selectedSubGroup = {}
#     $scope.getGroups()

#   gc.onCreateGroupFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   $scope.deleteGroup = ->
#     if not $scope.selectedGroup.isFixed
#       modalService.openConfirmModal(
#         title: 'Delete group?',
#         body: 'Are you sure you want to delete this group? All child groups will also be deleted.',
#         ok: 'Yes',
#         cancel: 'No').then(gc.deleteGroupConfirm)

#   gc.deleteGroupConfirm = () ->
#     groupService.delete($rootScope.selectedCompany.uniqueName,$scope.selectedGroup).then(gc.onDeleteGroupSuccess,gc.onDeleteGroupFailure)

#   gc.onDeleteGroupSuccess = () ->
#     toastr.success("Group deleted successfully.", "Success")
#     $scope.selectedGroup = {}
#     $scope.showGroupDetails = false
#     $scope.showAccountListDetails = false
#     $scope.getGroups()

#   gc.onDeleteGroupFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   $scope.isChildGroup =(group) ->
#     _.some(group.parentGroups, (group) ->
#       group.uniqueName == $scope.selectedGroup.uniqueName)

#   $scope.moveGroup = (group) ->
#     if _.isUndefined(group.uniqueName)
#       toastr.error("Select group only from list", "Error")
#       return

#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       selGrpUname: $scope.selectedGroup.uniqueName
#     }
#     body = {
#       "parentGroupUniqueName": group.uniqueName
#     }
#     groupService.move(unqNamesObj, body).then(gc.onMoveGroupSuccess, gc.onMoveGroupFailure)

#   gc.onMoveGroupSuccess = (res) ->
#     $scope.moveto = undefined
#     toastr.success("Group moved successfully.", "Success")
#     $scope.getGroups()

#   gc.onMoveGroupFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   gc.stopBubble = (e) ->
#     e.stopPropagation()

#   $scope.selectItem = (item) ->
#     $scope.search.flataccount = ""
#     $scope.grpCategory = item.category
#     $scope.showEditTaxSection = false
#     groupService.get($rootScope.selectedCompany.uniqueName, item.uniqueName).then(gc.getGrpDtlSuccess,
#           gc.getGrpDtlFailure)

#   gc.getGrpDtlSuccess = (res) ->
#     $scope.selectedItem = res.body
#     $scope.selectedAccntMenu = undefined
#     gc.selectGroupToEdit(res.body)
#     $scope.accountsSearch = undefined
#     $scope.showGroupDetails = true
#     $scope.showAccountListDetails = true
#     $scope.showAccountDetails = false
#     gc.populateAccountList(res.body)

#   gc.getGrpDtlFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   gc.selectGroupToEdit = (group) ->
#     _.each $scope.groupList, (grp) ->
#       if grp.uniqueName == group.uniqueName
#         group.isTopLevel = true
#     if group.isTopLevel == undefined
#       group.isTopLevel = false
#     $scope.selectedGroup = group
#     if _.isEmpty($scope.selectedGroup.oldUName)
#       $scope.selectedGroup.oldUName = $scope.selectedGroup.uniqueName
#     $scope.selectedSubGroup = {}
#     $rootScope.$emit('callCheckPermissions', group)
#     $scope.getGroupSharedList(group)


#   gc.populateAccountList = (item) ->
#     result = groupService.matchAndReturnGroupObj(item, $rootScope.flatGroupsList)
#     $scope.groupAccntList = result.accounts

#   #show breadcrumbs
#   gc.showBreadCrumbs = (data) ->
#     $scope.showBreadCrumb = true
#     $scope.breadCrumbList = data

#   #jump to group
#   $scope.jumpToGroup = (grpUniqName, grpList)  ->
#     fltGrpList = groupService.flattenGroup(grpList, [])
#     obj = _.find(fltGrpList, (item) ->
#       item.uniqueName == grpUniqName
#     )
# #    $scope.selectGroupToEdit(obj)
#     $scope.selectItem(obj)

#   #check if object is empty on client side by mechanic
#   $scope.isEmptyObject = (obj) ->
#     return _.isEmpty(obj)

#   gc.mergeNum = (num) ->
#     if _.isUndefined(num.Ccode) || _.isUndefined(num.onlyMobileNo) || _.isEmpty(num.Ccode) || _.isEmpty(num.onlyMobileNo)
#       return null

#     if _.isObject(num.Ccode)
#       num.Ccode.value + "-" + num.onlyMobileNo
#     else
#       num.Ccode + "-" + num.onlyMobileNo

#   gc.breakMobNo = (data) ->
#     if data.mobileNo
#       res = data.mobileNo.split("-")
#       $scope.acntExt = {
#         Ccode: res[0]
#         onlyMobileNo: res[1]
#       }
#     else
#       $scope.acntExt = {
#         Ccode: undefined
#         onlyMobileNo: undefined
#       }

#   #show account
#   gc.getAccountCategory = (parentGroups) ->
#     pg = parentGroups[0]['uniqueName']
#     grp = _.findWhere($rootScope.flatGroupsList, {uniqueName:pg})
#     grp.category


#   $scope.showAccountDtl = (data) ->
#     $scope.cantUpdate = false
#     #highlight account menus
#     $scope.selectedAccntMenu = data
#     reqParams = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       acntUname: data.uniqueName
#     }
#     $scope.showEditTaxSection = false
#     accountService.get(reqParams).then(
#       (res) -> gc.getAcDtlSuccess(res, data), 
#       (res) -> gc.getAcDtlFailure(res)
#     )

#   gc.getAcDtlSuccess = (res, data) ->
#     #getPgrps = groupService.matchAndReturnGroupObj(res.body, $rootScope.fltAccntListPaginated)
#     #getPgrps = groupService.matchAndReturnGroupObj(res.body, $rootScope.fltAccntListPaginated)
#     data = res.body
#     $scope.AccountCategory = gc.getAccountCategory(data.parentGroups)
#     gc.getMergedAccounts(data)
#     # data.parentGroups = []
#     #_.extend(data.parentGroups, getPgrps.parentGroups)
#     $rootScope.$emit('callCheckPermissions', data)
#     pGroups = []
#     $scope.showGroupDetails = false
#     $scope.showAccountDetails = true
#     if data.uniqueName is $rootScope.selAcntUname
#       $scope.cantUpdate = true
#     _.extend($scope.selAcntPrevObj, data)
#     _.extend($scope.selectedAccount, data)
#     $rootScope.selectedAccount = $scope.selectedAccount
#     gc.breakMobNo(data)
#     gc.setOpeningBalanceDate()
#     $scope.getAccountSharedList()
#     $scope.acntCase = "Update"
#     $scope.isFixedAcc = res.body.isFixed
#     gc.showBreadCrumbs(data.parentGroups)
#     $scope.fetchingUnq = false
# #    console.log $scope.selectedAccount


#   gc.getAcDtlFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   # prepare date object
#   gc.setOpeningBalanceDate = () ->
#     if $scope.selectedAccount.openingBalanceDate
#       newDateObj = $scope.selectedAccount.openingBalanceDate.split("-")
#       $scope.datePicker.accountOpeningBalanceDate = new Date(newDateObj[2], newDateObj[1] - 1, newDateObj[0])
#     else
#       $scope.datePicker.accountOpeningBalanceDate = new Date()

#   $scope.addNewAccountShow = (groupData)  ->
#     $scope.isFixedAcc = false
#     $scope.cantUpdate = false
#     # make blank for new
#     $scope.selectedAccount = {}
#     $scope.acntExt = {
#       Ccode: undefined
#       onlyMobileNo: undefined
#     }
#     $scope.breadCrumbList = undefined
#     $scope.selectedAccntMenu = undefined
#     $scope.showGroupDetails = false
#     $scope.showAccountDetails = true
#     # for play between update and add
#     $scope.acntCase = "Add"
#     gc.setOpeningBalanceDate()
#     gc.showBreadCrumbs([_.pick($scope.selectedGroup,'uniqueName','name')])

#   gc.setAdditionalAccountDetails = ()->
#     $scope.selectedAccount.openingBalanceDate = $filter('date')($scope.datePicker.accountOpeningBalanceDate,"dd-MM-yyyy")
#     if(_.isUndefined($scope.selectedAccount.mobileNo) || _.isEmpty($scope.selectedAccount.mobileNo))
#       $scope.selectedAccount.mobileNo = ""
#     if(_.isUndefined($scope.selectedAccount.email) || _.isEmpty($scope.selectedAccount.email))
#       $scope.selectedAccount.email = ""
#     #$scope.selectedAccount.mobileNo = $scope.mergeNum($scope.acntExt)
#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       selGrpUname: $scope.selectedGroup.uniqueName
#       acntUname: $scope.selectedAccount.uniqueName
#     }

#   $scope.addAccount = () ->
#     unqNamesObj = gc.setAdditionalAccountDetails()
#     accountService.createAc(unqNamesObj, $scope.selectedAccount).then(gc.addAccountSuccess, gc.addAccountFailure)

#   gc.addAccountSuccess = (res) ->
#     toastr.success("Account created successfully", res.status)
#     $scope.getGroups()
#     $scope.selectedAccount = {}
#     abc = _.pick(res.body, 'name', 'uniqueName', 'mergedAccounts','applicableTaxes','parentGroups')
#     $scope.groupAccntList.push(abc)
#     $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)

#   gc.addAccountFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   $scope.deleteAccount = ->
#     if $scope.canDelete
#       modalService.openConfirmModal(
#         title: 'Delete Account?',
#         body: 'Are you sure you want to delete this Account?',
#         ok: 'Yes',
#         cancel: 'No').then(gc.deleteAccountConfirm)

#   gc.deleteAccountConfirm = ->
#     unqNamesObj = gc.setAdditionalAccountDetails()
#     if $scope.selectedAccount.uniqueName isnt $scope.selAcntPrevObj.uniqueName
#       unqNamesObj.acntUname = $scope.selAcntPrevObj.uniqueName
#     if _.isEmpty($scope.selectedGroup)
#       unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName

#     accountService.deleteAc(unqNamesObj, $scope.selectedAccount).then(gc.moveAccntSuccess, gc.onDeleteAccountFailure)

#   gc.onDeleteAccountFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   $scope.updateAccount = () ->
#     unqNamesObj = gc.setAdditionalAccountDetails()
#     if angular.equals($scope.selectedAccount, $scope.selAcntPrevObj)
#       toastr.info("Nothing to update", "Info")
#       return false

#     if $scope.selectedAccount.openingBalanceType == null
#       $scope.selectedAccount.openingBalanceType = 'credit'

#     if $scope.selectedAccount.uniqueName isnt $scope.selAcntPrevObj.uniqueName
#       unqNamesObj.acntUname = $scope.selAcntPrevObj.uniqueName

#     if _.isEmpty($scope.selectedGroup)
#       lastVal = _.last($scope.selectedAccount.parentGroups)
#       unqNamesObj.selGrpUname = lastVal.uniqueName

#     if $scope.selectedAccount.applicableTaxes.length > 0
#       $scope.selectedAccount.applicableTaxes = _.pluck($scope.selectedAccount.applicableTaxes,'uniqueName')

#     accountPayload = angular.copy($scope.selectedAccount, {})
#     delete accountPayload.stocks  
#     accountService.updateAc(unqNamesObj, accountPayload).then(gc.updateAccountSuccess,
#         gc.updateAccountFailure)


#   gc.updateAccountSuccess = (res) ->
#     toastr.success("Account updated successfully", res.status)
#     angular.merge($scope.selectedAccount, res.body)
#     $scope.getGroups()
#     abc = _.pick($scope.selectedAccount, 'name', 'uniqueName', 'mergedAccounts')
#     if !_.isEmpty($scope.selectedGroup)
#       _.find($scope.groupAccntList, (item, index) ->
#         if item.uniqueName == $scope.selAcntPrevObj.uniqueName
#           angular.merge($scope.groupAccntList[index], abc)
#       )
#     # end if
#     angular.merge($scope.selAcntPrevObj, res.body)


#   gc.updateAccountFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   $scope.isCurrentGroup =(group) ->
#     group.uniqueName is $scope.selectedAccount.parentGroups[0].uniqueName || group.uniqueName is $scope.selectedAccount.parentGroups[$scope.selectedAccount.parentGroups.length-1].uniqueName

#   $scope.isCurrentAccount =(acnt) ->
#     acnt.uniqueName is $scope.selectedAccount.uniqueName

#   $scope.moveAccnt = (group) ->
#     if _.isUndefined(group.uniqueName)
#       toastr.error("Select group only from list", "Error")
#       return
#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       selGrpUname: $scope.selectedGroup.uniqueName
#       acntUname: $scope.selectedAccount.uniqueName
#     }
#     if _.isUndefined($scope.selectedGroup.uniqueName)
#       lastVal = _.last($scope.selectedAccount.parentGroups)
#       unqNamesObj.selGrpUname = lastVal.uniqueName

#     body = {
#       "uniqueName": group.uniqueName
#     }
#     accountService.move(unqNamesObj, body).then(gc.moveAccntSuccess, $scope.moveAccntFailure)

#   gc.moveAccntSuccess = (res) ->
#     toastr.success(res.body, res.status)
#     $scope.getGroups()
#     $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
#     $scope.showAccountDetails = false
#     if !_.isEmpty($scope.selectedGroup)
#       $scope.groupAccntList = _.reject($scope.groupAccntList, (item) ->
#         return item.uniqueName == $scope.selectedAccount.uniqueName
#       )
#     # end if
#     $scope.selectedAccount = {}
#     $scope.selAcntPrevObj = {}


#   $scope.moveAccntFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   $scope.shareAccount = () ->
#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       selGrpUname: $scope.selectedGroup.uniqueName
#       acntUname: $scope.selectedAccount.uniqueName
#     }
#     if _.isEmpty($scope.selectedGroup)
#       unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName

#     accountService.share(unqNamesObj, $scope.shareAccountObj).then($scope.onShareAccountSuccess, $scope.onShareAccountFailure)

#   $scope.onShareAccountSuccess = (res) ->
#     $scope.shareAccountObj.user = ""
#     toastr.success(res.body, res.status)
#     $scope.getAccountSharedList()

#   $scope.onShareAccountFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   $scope.unShareAccount = (user) ->
#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       selGrpUname: $scope.selectedGroup.uniqueName
#       acntUname: $scope.selectedAccount.uniqueName
#     }
#     if _.isEmpty($scope.selectedGroup)
#       unqNamesObj.selGrpUname = $scope.selectedAccount.parentGroups[0].uniqueName

#     data = { user: user}
#     accountService.unshare(unqNamesObj, data).then($scope.unShareAccountSuccess, $scope.unShareAccountFailure)

#   $scope.unShareAccountSuccess = (res)->
#     toastr.success(res.body, res.status)
#     $scope.getAccountSharedList()

#   $scope.unShareAccountFailure = (res)->
#     toastr.error(res.data.message, res.data.status)

#   $scope.getAccountSharedList = () ->
#     if $scope.canShare
#       unqNamesObj = {
#         compUname: $rootScope.selectedCompany.uniqueName
#         selGrpUname: $scope.selectedAccount.parentGroups[0].uniqueName
#         acntUname: $scope.selectedAccount.uniqueName
#       }
#       accountService.sharedWith(unqNamesObj).then($scope.onGetAccountSharedListSuccess, $scope.onGetAccountSharedListSuccess)

#   $scope.onGetAccountSharedListSuccess = (res) ->
#     $scope.accountSharedUserList = res.body

#   $scope.onGetAccountSharedListFailure = (res) ->
#     toastr.error(res.data.message, res.data.status)

#   $scope.loadAccountsList = () ->
#     if !_.isEmpty($rootScope.selectedCompany)
#       $scope.getGroups()

#   $scope.assignValues = () ->
#     data = localStorageService.get("_selectedCompany")
#     $rootScope.canViewSpecificItems = false
#     if _.isUndefined(data) || _.isEmpty(data)

#     else if data.role.uniqueName is 'shared'
#       $rootScope.canManageComp = false
#       if data.sharedEntity is 'groups'
#         $rootScope.canViewSpecificItems = true
#     else
#       $rootScope.canManageComp = true

#   $rootScope.$on 'reloadAccounts', ->
#     $rootScope.canChangeCompany = false
#     $scope.showAccountList = false
#     $scope.getGroups()
#     $('#accountSearch').val('')



#   $rootScope.$on 'callManageGroups', ->
#     $scope.goToManageGroups()

#   $timeout(->
#     # $scope.loadAccountsList()
#     if !_.isEmpty($rootScope.selectedCompany) && $scope.flatAccntWGroupsList.length < 1
#       $scope.getGroups()
#     $scope.assignValues()
#   ,2000)

#   ############################ for merge/unmerge accounts ############################
#   $scope.toMerge = {
#     mergeTo:''
#     mergedAcc: []
#     toUnMerge : {
#       name: ''
#       uniqueNames: []
#       moveTo: ''
#     }
#     moveToAcc: ''
#   }
#   gc.getMergedAccounts = (accData) ->
#     $scope.showDeleteMove = false
#     $scope.AccountsList = $rootScope.fltAccntListPaginated
#     #remove selected account from AccountsList
#     accToRemove = {
#       uniqueName: accData.uniqueName
#     }
#     $scope.AccountsList = _.without($scope.AccountsList, _.findWhere($scope.AccountsList, accToRemove))

#     $scope.prePopulate = []
#     $scope.toMerge.mergeTo = accData.uniqueName
#     mergedAcc = accData.mergedAccounts
#     mList = []
#     if !_.isEmpty(mergedAcc) && !_.isUndefined(mergedAcc)
#       mList = mergedAcc.split(',')
#       _.each mList, (mAcc) ->
#         mObj = {
#           uniqueName: ''
#           noRemove : true
#         }
#         mObj.uniqueName = mAcc
#         $scope.prePopulate.push(mObj)
#       $scope.toMerge.mergedAcc = $scope.prePopulate
#     else
#       $scope.prePopulate = []
#       $scope.toMerge.mergedAcc = []

#   $scope.enableMergeButton = () ->
#     if $scope.prePopulate.length == 0 && $scope.toMerge.mergedAcc.length == 0
#       true
#     else if  $scope.prePopulate.length > 0 && $scope.toMerge.mergedAcc.length == $scope.prePopulate.length
#       true
#     else if $scope.prePopulate.length > 0 && $scope.toMerge.mergedAcc.length > $scope.prePopulate.length
#       false
#     else if $scope.prePopulate.length > 0 && $scope.toMerge.mergedAcc.length < $scope.prePopulate.length
#       true


#   #merge account
#   $scope.mergeAccounts = () ->
#     accToMerge = []
#     withoutMerged = []
#     if $scope.prePopulate.length > 0
#       # _.each $scope.prePopulate,(pre) ->
#       #   _.each $scope.toMerge.mergedAcc, (acc) ->
#       #     console.log pre.uniqueName, acc.uniqueName
#       #     accToSend = {
#       #       "uniqueName": ""
#       #     }
#       #     if pre.uniqueName != acc.uniqueName
#       #       accToSend.uniqueName = acc.uniqueName
#       #       accToMerge.push(accToSend)
#       withoutMerged = _.difference($scope.toMerge.mergedAcc, $scope.prePopulate)
#       _.each withoutMerged, (acc) ->
#         accToSend = {
#           "uniqueName": ""
#         }
#         if acc.hasOwnProperty('mergedAccounts')
#           accToSend.uniqueName = acc.uniqueName
#           accToMerge.push(accToSend)
#     else
#       _.each $scope.toMerge.mergedAcc, (acc) ->
#         accToSend = {
#           "uniqueName": ""
#         }
#         accToSend.uniqueName = acc.uniqueName
#         accToMerge.push(accToSend)
#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       acntUname: $scope.toMerge.mergeTo
#     }
#     if accToMerge.length > 0
#       accountService.merge(unqNamesObj, accToMerge).then( gc.mergeSuccess, gc.mergeFailure)
#       _.each accToMerge, (acc) ->
#         removeMerged = {
#           uniqueName: acc.uniqueName
#         }
#         $scope.AccountsList = _.without($scope.AccountsList, _.findWhere($scope.AccountsList, removeMerged))
#     else
#       toastr.error("Please select at least one account.")


#   gc.mergeSuccess = (res) ->
#     toastr.success(res.body)
#     _.each $scope.toMerge.mergedAcc, (acc) ->
#       $rootScope.removeAccountFromPaginatedList(acc)
#       acc.noRemove = true
#     $scope.getGroups()
#     $scope.prePopulate = $scope.toMerge.mergedAcc
#     $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)

#   gc.mergeFailure = (res) ->
#     toastr.error(res.data.message)

#   #delete account
#   $scope.unmerge = (item) ->
#     item.uniqueName = item.uniqueName.replace(RegExp(' ', 'g'), '')
#     $scope.toMerge.toUnMerge.uniqueNames = ''
#     $scope.toMerge.toUnMerge.uniqueNames = item.uniqueName
#     if item.noRemove == true then ($scope.showDeleteMove = true) else ($scope.showDeleteMove = false)


#   $scope.deleteMergedAccount = () ->
#     $scope.toMerge.toUnMerge.moveTo = null
#     modalService.openConfirmModal(
#       title: 'Delete Merged Account',
#       body: 'Are you sure you want to delete ' + $scope.toMerge.toUnMerge.uniqueNames + ' ?',
#       ok: 'Yes',
#       cancel: 'No').then(gc.deleteMergedAccountConfirm)

#   gc.deleteMergedAccountConfirm = () ->
#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       acntUname: $scope.toMerge.mergeTo
#     }
#     accTosend = {
#       "uniqueNames": []
#     }
#     if $scope.toMerge.toUnMerge.uniqueNames.length != 0
#       accTosend.uniqueNames.push($scope.toMerge.toUnMerge.uniqueNames)
#       accountService.unMergeDelete(unqNamesObj, accTosend).then( gc.deleteMergedAccountSuccess, gc.deleteMergedAccountFailure)
#       _.each accTosend.uniqueNames, (accUnq) ->
#         removeFromPrePopulate = {
#           uniqueName: accUnq
#         }
#         $scope.prePopulate = _.without($scope.prePopulate, _.findWhere($scope.prePopulate, removeFromPrePopulate))
#     else
#       toastr.error('Please Select an Account to delete')

#   gc.deleteMergedAccountSuccess = (res) ->
#     toastr.success(res.body)
#     updatedMergedAccList = []
#     _.each $scope.toMerge.mergedAcc, (obj) ->
#       toRemove = {}
#       if obj.uniqueName != $scope.toMerge.toUnMerge.uniqueNames
#         toRemove = obj
#         toRemove.noRemove = false
#         if !obj.hasOwnProperty('mergedAccounts')
#           toRemove.noRemove = true
#         updatedMergedAccList.push(toRemove)
#     $scope.toMerge.mergedAcc = updatedMergedAccList
#     $scope.toMerge.toUnMerge.uniqueNames = ''
#     $scope.toMerge.moveToAcc = ''


#   gc.deleteMergedAccountFailure = (res) ->
#     toastr.error(res.data.message)

#   # move to account
#   $scope.moveToAccount = () ->
#     modalService.openConfirmModal(
#       title: 'Move Merged Account',
#       body: 'Are you sure you want to move ' + $scope.toMerge.toUnMerge.uniqueNames + ' to ' + $scope.toMerge.moveToAcc.uniqueName,
#       ok: 'Yes',
#       cancel: 'No').then(gc.moveToAccountConfirm)

#   gc.moveToAccountConfirm = () ->
#     unqNamesObj = {
#       compUname: $rootScope.selectedCompany.uniqueName
#       acntUname: $scope.toMerge.moveToAcc.uniqueName
#     }
#     accTosend = {
#       uniqueName: $scope.toMerge.toUnMerge.uniqueNames
#     }
#     accToSendArray = []
#     if $scope.toMerge.toUnMerge.uniqueNames.length != 0
#       accToSendArray.push(accTosend)
#       accountService.merge(unqNamesObj, accToSendArray).then( gc.moveToAccountConfirmSuccess, gc.moveToAccountConfirmFailure)
#       _.each accToSendArray, (accUnq) ->
#         removeFromPrePopulate = {
#           uniqueName: accUnq
#         }
#         $scope.prePopulate = _.without($scope.prePopulate, _.findWhere($scope.prePopulate, removeFromPrePopulate))
#     else
#       toastr.error('Please Select an account to move.')

#   gc.moveToAccountConfirmSuccess = (res) ->
#     toastr.success(res.body)
#     updatedMergedAccList = []
#     _.each $scope.toMerge.mergedAcc, (obj) ->
#       toRemove = {}
#       if obj.uniqueName != $scope.toMerge.toUnMerge.uniqueNames
#         toRemove = obj
#         toRemove.noRemove = false
#         if !obj.hasOwnProperty('mergedAccounts')
#           toRemove.noRemove = true
#         updatedMergedAccList.push(toRemove)
#     $scope.toMerge.mergedAcc = updatedMergedAccList
#     $scope.toMerge.toUnMerge.uniqueNames = ''
#     $scope.toMerge.moveToAcc = ''

#   gc.moveToAccountConfirmFailure = (res) ->
#     toastr.error(res.data.message)

#   # $scope.isGrpMatch = (g, q) ->
#   #   p = RegExp(q,"i")
#   #   if (g.groupName.match(p) || g.groupUniqueName.match(p))
#   #     return true
#   #   return false

#   $scope.getTaxList = () ->
#     companyServices.getTax($rootScope.selectedCompany.uniqueName).then(gc.getTaxSuccess, gc.getTaxFailure)

#   gc.getTaxSuccess = (res) ->
#     $scope.taxList = res.body

#   gc.getTaxFailure = (res) ->
#     toastr.error(res.data.message)

#   $scope.getTaxHierarchy = (type) ->
#     $scope.getTaxList()
#     if type == 'group'
#       groupService.getTaxHierarchy($rootScope.selectedCompany.uniqueName,$scope.selectedGroup.uniqueName).then(gc.getTaxHierarchyOnSuccess,gc.getTaxHierarchyOnFailure)
#     else if type == 'account'
#       accountService.getTaxHierarchy($rootScope.selectedCompany.uniqueName, $scope.selectedAccount.uniqueName).then(gc.getTaxHierarchyOnSuccess,gc.getTaxHierarchyOnFailure)

#   gc.getTaxHierarchyOnSuccess = (res) ->
#     $scope.taxHierarchy = res.body
#     $scope.selectedTax.taxes = $scope.taxHierarchy.applicableTaxes
#     $scope.showEditTaxSection = true
#     $scope.allInheritedTaxes = []
#     gc.createInheritedTaxList($scope.taxHierarchy.inheritedTaxes)

#   gc.getTaxHierarchyOnFailure = (res) ->
#     toastr.error(res.data.message)

#   gc.createInheritedTaxList = (inTaxList) ->
# #get all taxes by uniqueName
#     inTaxUnq = []
#     _.each inTaxList, (tax) ->
#       _.each tax.applicableTaxes, (inTax) ->
#         inTaxUnq.push(inTax.uniqueName)
#     inTaxUnq = _.uniq(inTaxUnq)

#     # match groups with tax uniqueNames
#     _.each inTaxUnq, (unq) ->
#       tax = {}
#       tax.uniqueName = unq
#       tax.groups = []
#       _.each inTaxList, (inTax) ->
#         _.each inTax.applicableTaxes, (inAppTax) ->
#           if tax.uniqueName == inAppTax.uniqueName
#             grp = {}
#             grp.name = inTax.name
#             grp.uniqueName = inTax.uniqueName
#             tax.name = inAppTax.name
#             tax.groups.push(grp)
#       $scope.allInheritedTaxes.push(tax)

#   $scope.isAccount = false
#   $scope.assignTax = (dataToSend) ->
#     companyServices.assignTax($rootScope.selectedCompany.uniqueName,dataToSend).then(gc.assignTaxOnSuccess,gc.assignTaxOnFailure)

#   gc.assignTaxOnSuccess = (res) ->
#     $scope.showEditTaxSection = false
#     toastr.success(res.body)
#     if not $scope.isAccount
#       groupService.get($rootScope.selectedCompany.uniqueName, $scope.selectedGroup.uniqueName).then($scope.getGrpDtlSuccess,
#           $scope.getGrpDtlFailure)
#     else
#       reqParams = {
#         compUname: $rootScope.selectedCompany.uniqueName
#         acntUname: $scope.selectedAccount.uniqueName
#       }
#       accountService.get(reqParams).then(gc.getAcDtlSuccess, $scope.getAcDtlFailure)

#     $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)

#   # $scope.getAccountDetailsSuccess = (res) ->
#   #   $scope.selectedAccount.applicableTaxes = res.body.applicableTaxes

#   gc.assignTaxOnFailure = (res) ->
#     $scope.showEditTaxSection = false
#     toastr.error(res.data.message)

#   $scope.applyTax = (type) ->
#     if _.isEmpty(type)
#       toastr.warning("Please do not mess with html.")
#     else
#       # We have to send all the taxes
#       mergeTaxes = []
#       mergeTaxes.push($scope.taxHierarchy.applicableTaxes)
#       mergeTaxes.push(_.pluck($scope.taxHierarchy.inheritedTaxes, 'applicableTaxes'))
#       sendThisList = _.pluck(_.flatten(mergeTaxes),'uniqueName')
#       data = {}
#       if type == 'group'
#         data = [{"uniqueName":$scope.selectedGroup.uniqueName, "taxes":sendThisList,"isAccount":false}]
#         $scope.isAccount = false
#       else if type == 'account'
#         data = [{"uniqueName":$scope.selectedAccount.uniqueName, "taxes":sendThisList,"isAccount":true}]
#         $scope.isAccount = true
#       $scope.assignTax(data)

#   $scope.alreadyAppliedTaxes = (tax) ->
#     inheritTax = _.pluck($scope.taxHierarchy.inheritedTaxes,'applicableTaxes')
#     applicableTaxes = _.flatten($scope.taxHierarchy)
#     applicableTaxes.push(inheritTax)
#     checkInThis = _.pluck(_.flatten(applicableTaxes),'uniqueName')
# #    checkInThis = _.pluck($scope.selectedAccount.applicableTaxes, 'uniqueName')
#     condition = _.contains(checkInThis, tax.uniqueName)
#     condition

#   $scope.fetchingUnq = false
#   num = 1
#   $scope.autoFillUnq = (unq) ->
#     unq = unq.replace(/ |,|\//g,'')
#     unq = unq.toLowerCase()
#     $this = @
#     $scope.fetchingUnq = true
#     $this.success = (res) ->
#       $scope.autoFillUnq(unq+num)
#       num += 1
#     $this.failure = (res) ->
#       $scope.selectedAccount.uniqueName = unq
#       num = 1
#       $scope.fetchingUnq = false
#     if $scope.acntCase == 'Add' && unq != undefined && unq.length > 2
#       $timeout ( ->
#         reqParams = {
#           compUname: $rootScope.selectedCompany.uniqueName
#           acntUname: unq
#         }
#         accountService.get(reqParams).then($this.success, $this.failure)
#       ), 1000
#     else if unq == undefined
#       $scope.selectedAccount.uniqueName == null

#   $scope.$watch('toMerge.mergedAcc', (newVal,oldVal) ->
#     if newVal != oldVal && newVal < 1
#       $scope.showDeleteMove = false
#   )

#   $scope.$watch('toMerge.toUnMerge.uniqueNames', (newVal, oldVal)->
#     if newVal != oldVal && newVal.length < 1
#       $scope.showDeleteMove = false
#   )

#   $rootScope.$on 'companyLoaded', ()->
#     $scope.flatAccntWGroupsList = []
#     $scope.getFlattenGrpWithAccList($rootScope.selectedCompany.uniqueName)

#   $rootScope.$on 'catchBreadcumbs', (e, breadcrumbs) ->
#     $scope.accountToShow = breadcrumbs


#   $scope.updateFlatAccountList = () ->
#     $rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)

#   return

# #init angular app
# giddh.webApp.controller 'groupController', groupController