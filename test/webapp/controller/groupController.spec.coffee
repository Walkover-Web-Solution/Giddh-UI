# 'use strict'

# describe 'groupController', ->
#   beforeEach module('giddhWebApp')

#   describe 'local variables', ->
#     beforeEach inject ($rootScope, $controller, localStorageService) ->
#       @scope = $rootScope.$new()
#       @rootScope = $rootScope
#       @groupController = $controller('groupController',
#         {
#           $scope: @scope, 
#           $rootScope: @rootScope
#         }
#       )

#     it 'should check scope variables set by default', ->
#       expect(@scope.groupList).toEqual({})
#       expect(@scope.flattenGroupList).toEqual([])
#       expect(@scope.moveto).toBeUndefined()
#       expect(@scope.selectedGroup).toEqual({})
#       expect(@scope.selectedSubGroup).toEqual({})
#       expect(@scope.selectedAccount).toEqual({})
#       expect(@scope.selAcntPrevObj).toEqual({})
#       expect(@scope.selectedGroupUName).toBe("")
#       expect(@scope.cantUpdate).toBeFalsy()
#       expect(@scope.showGroupDetails).toBeFalsy()
#       expect(@scope.subGroupVisible).toBeFalsy()
#       expect(@scope.showListGroupsNow).toBeFalsy()
#       expect(@scope.showAccountDetails).toBeFalsy()
#       expect(@scope.showAccountListDetails).toBeFalsy()
#       expect(@scope.canUpdate).toBeFalsy()
#       expect(@scope.canDelete).toBeFalsy()
#       expect(@scope.canAdd).toBeFalsy()
#       expect(@scope.groupAccntList).toEqual([])
#       #expect(@scope.acntSrch).toBe('')
#       expect(@scope.shareGroupObj).toEqual({role: "view_only"})
#       expect(@scope.shareAccountObj).toEqual({role: "view_only"})
#       openingBalType_resp = [
#         {"name": "Credit", "val": "CREDIT"}
#         {"name": "Debit", "val": "DEBIT"}
#       ]
#       expect(@scope.openingBalType).toEqual(openingBalType_resp)
#       acntExt_resp = {
#         Ccode: undefined
#         onlyMobileNo: undefined
#       }
#       expect(@scope.acntExt).toEqual(acntExt_resp)
#       expect(@scope.today).toBeDefined()
#       expect(@scope.valuationDatePickerIsOpen).toBeFalsy()
#       expect(@scope.dateOptions).toEqual({'year-format': "'yy'", 'starting-day': 1, 'showWeeks': false, 'show-button-bar': false, 'year-range': 1, 'todayBtn': false})
#       expect(@scope.format).toBe("dd-MM-yyyy")
#       expect(@scope.flatAccntWGroupsList).toEqual({})
#       expect(@scope.showAccountList).toBeFalsy()
#       expect(@scope.selectedAccountUniqueName).toBeUndefined()

#   beforeEach inject ($rootScope, $controller, localStorageService, toastr, groupService, $q, permissionService, modalService, accountService, $uibModal, DAServices) ->
#     @scope = $rootScope.$new()
#     @rootScope = $rootScope
#     @localStorageService = localStorageService
#     @toastr = toastr
#     @groupService = groupService
#     @permissionService = permissionService
#     @q = $q
#     @uibModal = $uibModal
#     @modalService = modalService
#     @DAServices = DAServices
#     @accountService = accountService
#     @groupController = $controller('groupController',
#       {
#         $scope: @scope,
#         $rootScope: @rootScope,
#         localStorageService: @localStorageService,
#         permissionService: @permissionService
#         accountService: @accountService
#         $uibModal: @uibModal
#         DAServices: @DAServices
#       })
#   describe '#goToManageGroups', ->
#     it 'should show a toastr error message if object is blank', ->
#       @rootScope.selectedCompany = {}
#       spyOn(@toastr, 'error')
#       deferred = @q.defer()
#       spyOn(@uibModal, 'open').andReturn({result: deferred.promise})

#       @scope.goToManageGroups()
#       expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')
#       expect(@uibModal.open).not.toHaveBeenCalled()

#     it 'should call modal service', ->
#       @rootScope.selectedCompany = {something: "something"}
#       modalData = {
#         templateUrl: '/public/webapp/views/addManageGroupModal.html',
#         size: "liq90",
#         backdrop: 'static',
#         scope: @scope
#       }
#       deferred = @q.defer()
#       spyOn(@uibModal, 'open').andReturn({result: deferred.promise})
#       @scope.goToManageGroups()
#       expect(@uibModal.open).toHaveBeenCalledWith(modalData)

#   describe '#goToManageGroupsClose', ->
#     it 'should reset variables', ->
#       @rootScope.selectedCompany = {uniqueName: 'walkover'}
#       deferred = @q.defer()
#       spyOn(@groupService,'getGroupsWithoutAccountsCropped').andReturn(deferred.promise)
#       @scope.goToManageGroupsClose()
#       expect(@scope.selectedGroup).toEqual({})
#       expect(@scope.selectedAccntMenu).toBeUndefined()
#       expect(@scope.selectedItem).toBeUndefined()
#       expect(@scope.showGroupDetails).toBeFalsy()
#       expect(@scope.showAccountDetails).toBeFalsy()
#       expect(@scope.showAccountListDetails).toBeFalsy()
#       expect(@scope.cantUpdate).toBeFalsy()
#       expect(@groupService.getGroupsWithoutAccountsCropped).toHaveBeenCalledWith('walkover')
    

#   describe '#setLedgerData', ->
#     it 'should set value in a variable and call DAServices ledgerset method and set value in localStorageService', ->
#       data = {}
#       acData = {uniqueName: "name"}
#       spyOn(@DAServices, "LedgerSet")
#       spyOn(@localStorageService, "set")
#       @scope.setLedgerData(data, acData)
#       expect(@scope.selectedAccountUniqueName).toEqual(acData.uniqueName)
#       expect(@DAServices.LedgerSet).toHaveBeenCalledWith(data, acData)
#       expect(@localStorageService.set).toHaveBeenCalledWith("_ledgerData", data)
#       expect(@localStorageService.set).toHaveBeenCalledWith("_selectedAccount", acData)

#   describe '#toggleAcMenus', ->
#     varx = [{
#         open: false,
#         name: "group1"
#         uniqueName: "g1"
#         accounts: []
#       }
#       {
#         open: false,
#         name: "group1"
#         uniqueName: "g1"
#         accounts: []
#     }]
#     it 'should check if flatAccntWGroupsList is empty then do nothing', ->
#       @scope.flatAccntWGroupsList = {}
#       @scope.toggleAcMenus(true)
#       expect(angular.forEach).toBeDefined()
#       expect(@scope.showSubMenus).not.toBeTruthy()
#     it 'should expand menus', ->
#       @scope.flatAccntWGroupsList = varx
#       @scope.toggleAcMenus(true)
#       expect(angular.forEach).toBeDefined()
#       expect(@scope.showSubMenus).toBeTruthy()
#     it 'should collapse all menus', ->
#       @scope.flatAccntWGroupsList = varx
#       @scope.toggleAcMenus(false)
#       expect(angular.forEach).toBeDefined()
#       expect(@scope.showSubMenus).toBeFalsy()
    
#   describe '#checkLength', ->
#     it 'should checkLength of value if value is blank or undefined it will call toggleAcMenus function with false', ->
#       spyOn(@scope, "toggleAcMenus")
#       @scope.checkLength("")
#       expect(@scope.toggleAcMenus).toHaveBeenCalledWith(false)
#     it 'should checkLength of value if value length is greater than or equals to four it will call toggleAcMenus with true function', ->
#       spyOn(@scope, "toggleAcMenus")
#       @scope.checkLength("abcd")
#       expect(@scope.toggleAcMenus).toHaveBeenCalledWith(true)
#     it 'should checkLength of value if value length is less than or to four it will call toggleAcMenus with false function', ->
#       spyOn(@scope, "toggleAcMenus")
#       @scope.checkLength("abc")
#       expect(@scope.toggleAcMenus).toHaveBeenCalledWith(false)
      
#   describe '#getGroups', ->
#     it 'should show a toastr error to user for select company first when no company selected', ->
#       @rootScope.selectedCompany = {}
#       spyOn(@toastr, 'error')
#       @scope.getGroups()
#       expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')

#     it 'should call groupService getGroupsWithAccountsCropped method and not call getGroupsWithoutAccountsCropped method and set canManageComp variable to false', ->
#       cData = {
#         address: "sasd"
#         baseCurrency: "INR"
#         city: "Indore"
#         companyIdentity: []
#         country: "India"
#         createdAt: "02-12-2015 11:27:33"
#         email: "dsfdsf@asd.com"
#         name: "testComapany - yash"
#         pincode: "452010"
#         role: {
#           name: "Shared"
#           uniqueName: "shared"
#         }
#         shared: true
#         sharedEntity: "accounts"
#         state: "Madhya Pradesh"
#         uniqueName: "testcoindore144903585841105rgap"
#         updatedAt: "02-12-2015 11:28:46"
#       }
#       @rootScope.selectedCompany = {"data": "Got it", "uniqueName": "soniravi"}
#       deferred = @q.defer()
#       spyOn(@groupService, 'getGroupsWithAccountsCropped').andReturn(deferred.promise)
#       deferred = @q.defer()
#       spyOn(@groupService, 'getGroupsWithoutAccountsCropped').andReturn(deferred.promise)
#       spyOn(@localStorageService, "get").andReturn(cData)
#       @scope.getGroups()
#       expect(@groupService.getGroupsWithAccountsCropped).toHaveBeenCalledWith("soniravi")
#       expect(@groupService.getGroupsWithoutAccountsCropped).not.toHaveBeenCalledWith("soniravi")
#       expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")

#     it 'should call groupService getGroupsWithAccountsCropped method and getGroupsWithoutAccountsCropped method and set canManageComp variable to true', ->
#       cData = {
#         address: "sasd"
#         baseCurrency: "INR"
#         city: "Indore"
#         companyIdentity: []
#         country: "India"
#         createdAt: "02-12-2015 11:27:33"
#         email: "dsfdsf@asd.com"
#         name: "testComapany - yash"
#         pincode: "452010"
#         role: {
#           name: "Shared"
#           uniqueName: "shared"
#         }
#         shared: true
#         sharedEntity: "groups"
#         state: "Madhya Pradesh"
#         uniqueName: "testcoindore144903585841105rgap"
#         updatedAt: "02-12-2015 11:28:46"
#       }
#       @rootScope.selectedCompany = {"data": "Got it", "uniqueName": "soniravi"}
#       deferred = @q.defer()
#       spyOn(@groupService, 'getGroupsWithAccountsCropped').andReturn(deferred.promise)
#       deferred = @q.defer()
#       spyOn(@groupService, 'getGroupsWithoutAccountsCropped').andReturn(deferred.promise)
#       spyOn(@localStorageService, "get").andReturn(cData)
#       @scope.getGroups()
#       expect(@groupService.getGroupsWithAccountsCropped).toHaveBeenCalledWith("soniravi")
#       expect(@groupService.getGroupsWithoutAccountsCropped).toHaveBeenCalledWith("soniravi")
#       expect(@localStorageService.get).toHaveBeenCalledWith("_selectedCompany")
    

#   describe '#makeAccountsList', ->
#     it 'should copy response into a local variable call groupService multiple methods and assign values in scope or rootScope variables', ->
#       res = {
#         "status": "success",
#         "body": []
#       }
#       @rootScope.selectedCompany = {"data": "Got it", "uniqueName": "soniravi"}
#       @rootScope.makeAccountFlatten = () ->
#       spyOn(@rootScope, "makeAccountFlatten")
#       spyOn(@groupService, "flattenGroup").andReturn([])
#       spyOn(@groupService, "flattenGroupsWithAccounts").andReturn([])
#       spyOn(@groupService, "flattenAccount").andReturn([])
#       spyOn(@groupService, "makeGroupListFlatwithLessDtl").andReturn([])
#       spyOn(@scope, "getFlattenGrpWithAccList")
#       @scope.makeAccountsList(res)
#       expect(@rootScope.flatGroupsList).toEqual([])
#       #expect(@scope.getFlattenGrpWithAccList).toHaveBeenCalled()
#       expect(@scope.flatAccntWGroupsList).toEqual([])
#       #expect(@scope.showAccountList).toBeTruthy()
#       expect(@rootScope.makeAccountFlatten).toHaveBeenCalledWith([])
#       expect(@scope.flattenGroupList).toEqual([])

#   describe '#makeAccountsListFailure', ->
#     it 'should show a toastr for error', ->
#       res = {
#         data: {
#           "message": "Unable to get group details."
#           "status": "Error"
#         }
#       }
#       spyOn(@toastr, 'error')
#       @scope.makeAccountsListFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#getGroupListSuccess', ->
#     it 'should set group list', ->
#       result = ["body": {"name": "fixed assets"}, {"name": "capital account"}]
#       spyOn(@scope, "highlightAcMenu")
#       @scope.getGroupListSuccess(result)
#       expect(@scope.groupList).toBe(result.body)
#       expect(@scope.showListGroupsNow).toBeTruthy()
#       expect(@scope.highlightAcMenu).toHaveBeenCalled()

#   describe '#getGroupListFailure', ->
#     it 'should show a toastr for error', ->
#       res = {
#         data: {
#           "message": "Unable to get group details."
#           "status": "Error"
#         }
#       }
#       spyOn(@toastr, 'error')
#       @scope.getGroupListFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)
#       expect(@rootScope.canManageComp).toBeFalsy()

#   describe '#getGroupSharedList', ->
#     it 'should call a service with a obj var to get data if user has share permission', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       group = {"name": "Fixed Assets"}
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedGroup.uniqueName
#       }
#       deferred = @q.defer()
#       @scope.canShare = true
#       spyOn(@groupService, "sharedList").andReturn(deferred.promise)

#       @scope.getGroupSharedList(group)
#       expect(@groupService.sharedList).toHaveBeenCalledWith(unqNamesObj)

#     it 'should not call a service with a obj var to get data if user does not have share permission', ->
#       spyOn(@groupService, "sharedList")
#       @scope.canShare = false

#       @scope.getGroupSharedList({})
#       expect(@groupService.sharedList).not.toHaveBeenCalled()

#   describe '#onsharedListSuccess', ->
#     it 'should set result to a variable', ->
#       result = {"body": "something"}
#       @scope.onsharedListSuccess(result)
#       expect(@scope.groupSharedUserList).toBe(result.body)

#   describe '#onsharedListFailure', ->
#     it 'should show error message with toastr', ->
#       res =
#         data:
#           status: "Error"
#           message: "some-message"
#       spyOn(@toastr, "error")
#       @scope.onsharedListFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#shareGroup', ->
#     it 'should call service share method with obj var', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedGroup.uniqueName
#       }
#       @scope.shareGroupObj = {
#         role: "view_only"
#         user: "someUser"
#       }
#       deferred = @q.defer()
#       spyOn(@groupService, "share").andReturn(deferred.promise)
#       @scope.shareGroup()
#       expect(@groupService.share).toHaveBeenCalledWith(unqNamesObj, @scope.shareGroupObj)

#   describe '#onShareGroupSuccess', ->
#     it 'should blank a key and show success message with toastr and call getGroupSharedList with selected group variable', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       @scope.shareGroupObj = {
#         role: "view_only"
#         user: ""
#       }
#       res = {"status": "Success", "body": "Group shared successfully"}
#       spyOn(@toastr, 'success')
#       spyOn(@scope, "getGroupSharedList")
#       @scope.onShareGroupSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith('Group shared successfully', 'Success')
#       expect(@scope.getGroupSharedList).toHaveBeenCalledWith(@scope.selectedGroup)

#   describe '#onShareGroupFailure', ->
#     it 'should show error message with toastr', ->
#       res = {"data": {"status": "Error", "message": "some-message"}}
#       spyOn(@toastr, "error")
#       @scope.onShareGroupFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#unShareGroup', ->
#     it 'should call service share method with obj var', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedGroup.uniqueName
#       }
#       user = "user"
#       data = {
#         user: user
#       }
#       deferred = @q.defer()
#       spyOn(@groupService, "unshare").andReturn(deferred.promise)
#       @scope.unShareGroup(user)
#       expect(@groupService.unshare).toHaveBeenCalledWith(unqNamesObj, data)

#   describe '#unShareGroupSuccess', ->
#     it 'should show success message with toastr and call getGroupSharedList with selected group variable', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       res = {"status": "Success", "body": "Group unShared successfully"}
#       spyOn(@toastr, 'success')
#       spyOn(@scope, "getGroupSharedList")
#       @scope.unShareGroupSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith('Group unShared successfully', 'Success')
#       expect(@scope.getGroupSharedList).toHaveBeenCalledWith(@scope.selectedGroup)

#   describe '#unShareGroupFailure', ->
#     it 'should show error message with toastr', ->
#       res = {"data": {"status": "Error", "message": "some-message"}}
#       spyOn(@toastr, "error")
#       @scope.unShareGroupFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#updateGroup', ->
#     it 'should change the unique name to lower case & call group service and update group', ->
#       @scope.selectedGroup = {"uniqueName": "1R"}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       deferred = @q.defer()
#       spyOn(@groupService, 'update').andReturn(deferred.promise)
#       @scope.updateGroup()
#       expect(@scope.selectedGroup.uniqueName).toEqual("1r")
#       expect(@groupService.update).toHaveBeenCalledWith("2", {'uniqueName': '1r'})

#   describe '#onUpdateGroupSuccess', ->
#     it 'should show success message with toastr and set value in variable', ->
#       res = {"status": "Success", "body": "Group has been updated successfully."}
#       spyOn(@toastr, 'success')
#       @scope.onUpdateGroupSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith('Group has been updated successfully.', 'Success')
#       expect(@scope.selectedGroup.oldUName).toEqual(@scope.selectedGroup.uniqueName)

#     it 'should set scope variable if selectedGroup is not empty', ->
#       res = {"status": "Success", "body": "Group has been updated successfully."}
#       @scope.selectedGroup = {"name": "g1"}
#       @scope.onUpdateGroupSuccess(res)
#       expect(@scope.selectedItem).toEqual(@scope.selectedGroup)

#   describe '#onUpdateGroupFailure', ->
#     it 'should show error message with toastr', ->
#       res = {
#         "data": {
#           "status": "Error",
#           "message": "Unable to update group at the moment. Please try again later."
#         }
#       }
#       spyOn(@toastr, "error")
#       @scope.onUpdateGroupFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#getUniqueNameFromGroupList', ->
#     it 'should take list of group as input and return unique name of all groups in flatten way', ->
#       groupList = [{
#         "name": "group1",
#         "uniqueName": "g1",
#         "groups": [{"name": "group2", "uniqueName": "g2", "groups": []}]
#       },
#         {"name": "group3", "uniqueName": "g3", "groups": []}]
#       result = @scope.getUniqueNameFromGroupList(groupList)
#       expect(result).toContain("g1")
#       expect(result).toContain("g2")
#       expect(result).toContain("g3")

#   describe '#addNewSubGroup', ->
#     it 'should call group service and add new subgroup to selected group', ->
#       @scope.selectedSubGroup = {"name": "subgroup1", "desc": "description", "uniqueName": "suniqueName"}
#       @rootScope.selectedCompany = {"uniqueName": "CmpUniqueName"}
#       @scope.selectedGroup = {"uniqueName": "grpUName"}
#       body = {
#         "name": @scope.selectedSubGroup.name,
#         "uniqueName": "suniquename",
#         "parentGroupUniqueName": @scope.selectedGroup.uniqueName
#         "description": "description"
#       }
#       deferred = @q.defer()
#       spyOn(@groupService, 'create').andReturn(deferred.promise)
#       @scope.addNewSubGroup()
#       expect(@groupService.create).toHaveBeenCalledWith("CmpUniqueName", body)

#   describe '#onCreateGroupFailure', ->
#     res = {
#       "data": {
#         "status": "Error",
#         "message": "Unable to create subgroup."
#       }
#     }
#     it 'should call toastr to show error', ->
#       spyOn(@toastr, "error")
#       @scope.onCreateGroupFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#onCreateGroupSuccess', ->
#     it 'should call toastr with success, empty selected sub group and call getGroups', ->
#       spyOn(@toastr, "success")
#       spyOn(@scope, "getGroups")
#       @scope.onCreateGroupSuccess()
#       expect(@toastr.success).toHaveBeenCalledWith("Sub group added successfully", "Success")
#       expect(@scope.selectedSubGroup).toEqual({})
#       expect(@scope.getGroups).toHaveBeenCalled()

#   describe '#deleteGroup', ->
#     beforeEach ->
#       @deferred = @q.defer()
#       @promise = @deferred.promise

#     it 'should open confirmation modal if selectedGroup is not fixed', ->
#       @scope.selectedGroup = {isFixed: false}
#       @rootScope.selectedCompany = {"uniqueName": "CmpUniqueName"}
#       spyOn(@modalService, 'openConfirmModal').andReturn(@promise)
#       @scope.deleteGroup()
#       expect(@scope.selectedGroup.isFixed).toBeFalsy()
#       expect(@modalService.openConfirmModal).toHaveBeenCalledWith({
#         title: 'Delete group?',
#         body: 'Are you sure you want to delete this group? All child groups will also be deleted.',
#         ok: 'Yes',
#         cancel: 'No'
#       })

#     it 'should not openConfirmModal if selectedGroup is fixed group', ->
#       @scope.selectedGroup = {isFixed: true}
#       spyOn(@modalService, 'openConfirmModal').andReturn(@promise)
#       @scope.deleteGroup()
#       expect(@scope.selectedGroup.isFixed).toBeTruthy()
#       expect(@modalService.openConfirmModal).not.toHaveBeenCalled()

#   describe '#deleteGroupConfirm', ->
#     it 'should call groupService delete method with two parameters', ->
#       @scope.selectedGroup = {isFixed: false}
#       @rootScope.selectedCompany = {"uniqueName": "CmpUniqueName"}
#       deferred = @q.defer()
#       spyOn(@groupService, 'delete').andReturn(deferred.promise)
#       @scope.deleteGroupConfirm()
#       expect(@groupService.delete).toHaveBeenCalledWith("CmpUniqueName", @scope.selectedGroup)

#   describe '#onDeleteGroupFailure', ->
#     it 'should show a toastr for error', ->
#       res = {
#         "data": {
#           "status": "Error",
#           "message": "Only empty groups can be deleted."
#         }
#       }
#       spyOn(@toastr, "error")
#       @scope.onDeleteGroupFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#onDeleteGroupSuccess', ->
#     it 'should show a toastr, empty the selected group, show group detail to be false & get group list from server', ->
#       emptyObject = {}
#       spyOn(@toastr, "success")
#       @scope.onDeleteGroupSuccess()
#       expect(@toastr.success).toHaveBeenCalledWith("Group deleted successfully.", "Success")
#       expect(@scope.selectedGroup).toEqual(emptyObject)

#   describe '#moveGroup', ->
#     it 'should call group service move method with variables', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedGroup.uniqueName
#       }
#       group = {"uniqueName": "abc"}
#       body = {
#         "parentGroupUniqueName": group.uniqueName
#       }
#       deferred = @q.defer()
#       spyOn(@groupService, 'move').andReturn(deferred.promise)
#       @scope.moveGroup(group)
#       expect(@groupService.move).toHaveBeenCalledWith(unqNamesObj, body)

#   describe '#onMoveGroupSuccess', ->
#     it 'should show success message with toastr, call getgroups fucntion, set a blank object, set a variable false, and make a scope var undefined', ->
#       res = {data: {"status": "Success", "body": "Group moved successfully."}}
#       spyOn(@toastr, 'success')
#       spyOn(@scope, "getGroups")
#       @scope.onMoveGroupSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith('Group moved successfully.', 'Success')
#       expect(@scope.getGroups).toHaveBeenCalled()
#       expect(@scope.selectedGroup).toEqual({})
#       expect(@scope.showGroupDetails).toBeFalsy()
#       expect(@scope.moveto).toBeUndefined()

#   describe '#onMoveGroupFailure', ->
#     it 'should show error message with toastr', ->
#       res = {"data": {"status": "Error", "message": "Unable to move group."}}
#       spyOn(@toastr, "error")
#       @scope.onMoveGroupFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#stopBubble', ->
#     it 'should prevent event from bubbling', ->
#       # e = {stopPropagation: jasmine.createSpy()}
#       e = jasmine.createSpyObj('e', ['stopPropagation'])
#       @scope.stopBubble(e)
#       expect(e.stopPropagation).toHaveBeenCalled()

#   describe '#selectItem', ->
#     it 'should call groupService get method with data.uniqueName and rootScope selectedCompany uniqueName', ->
#       data = {
#         uniqueName: "item"
#       }
#       @rootScope.selectedCompany = {
#         uniqueName: "somename"
#       }
#       deferred = @q.defer()
#       spyOn(@groupService, 'get').andReturn(deferred.promise)
#       @scope.selectItem(data)
#       expect(@groupService.get).toHaveBeenCalledWith(@rootScope.selectedCompany.uniqueName, data.uniqueName)

#   describe '#getGrpDtlSuccess', ->
#     it 'should assign values to some variables and call some scope functions with response', ->
#       res = {
#         "status": "success",
#         "body": [
#           uniqueName: "item"
#         ]
#       }
#       spyOn(@scope, "selectGroupToEdit")
#       spyOn(@scope, "populateAccountList")
#       @scope.getGrpDtlSuccess(res)
#       expect(@scope.selectedItem).toBe(res.body)
#       expect(@scope.selectedAccntMenu).toBeUndefined()
#       expect(@scope.selectGroupToEdit).toHaveBeenCalledWith(res.body)
#       expect(@scope.accountsSearch).toBeUndefined()
#       expect(@scope.showGroupDetails).toBeTruthy()
#       expect(@scope.showAccountListDetails).toBeTruthy()
#       expect(@scope.showAccountDetails).toBeFalsy()
#       expect(@scope.populateAccountList).toHaveBeenCalledWith(res.body)
      
#   describe '#getGrpDtlFailure', ->
#     it 'should show error message with toastr', ->
#       res = {"data": {"status": "Error", "message": "Unable to get group details"}}
#       spyOn(@toastr, "error")
#       @scope.getGrpDtlFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#selectGroupToEdit', ->
#     group = {
#       name: "Fixed Assets"
#       uniqueName: "fixed"
#     }
#     it 'should check if variable is empty then set value according to condition', ->
#       spyOn(@scope, "getGroupSharedList")
#       spyOn(@rootScope, "$emit")
#       @scope.selectedGroup.oldUName = 'Hey dude'
#       @scope.selectGroupToEdit(group)
#       expect(@scope.selectedGroup).toEqual(group)
#       expect(@scope.selectedSubGroup).toEqual({})
#       expect(@scope.getGroupSharedList).toHaveBeenCalledWith(group)
#       expect(@rootScope.$emit).toHaveBeenCalledWith('callCheckPermissions', group)

#     it 'should check if oldUName is empty then set value in oldUName', ->
#       spyOn(@scope, "getGroupSharedList")
#       spyOn(@rootScope, "$emit")
#       @scope.selectedGroup.oldUName = ''
#       @scope.selectGroupToEdit(group)
#       expect(@scope.selectedGroup).toEqual(group)
#       expect(@scope.selectedSubGroup).toEqual({})
#       expect(@scope.getGroupSharedList).toHaveBeenCalledWith(group)
#       expect(@rootScope.$emit).toHaveBeenCalledWith('callCheckPermissions', group)
#       expect(@scope.selectedGroup.oldUName).toEqual(@scope.selectedGroup.uniqueName)

#   describe '#populateAccountList', ->
#     xit 'should call groupService matchAndReturnGroupObj method and makeAcListWithLessDtl method and assign value in scope variable', ->
#       @rootScope.flatGroupsList = [
#         {
#           name: "Fixed Assets"
#           uniqueName: "fixed"
#           accounts: []
#         }
#       ]
#       data = {
#         name: "Fixed Assets"
#         uniqueName: "fixed"
#       }
#       spyOn(@groupService, "matchAndReturnGroupObj").andReturn([])
#       spyOn(@groupService, "makeAcListWithLessDtl").andReturn([])
#       @scope.populateAccountList(data)
#       expect(@scope.groupAccntList).toEqual([])
#       expect(@groupService.matchAndReturnGroupObj).toHaveBeenCalledWith(data, @rootScope.flatGroupsList)
#       expect(@groupService.makeAcListWithLessDtl).toHaveBeenCalledWith(undefined)
    

#   describe '#showBreadCrumbs', ->
#     it 'should set showBreadCrumbs variable to true & set value in breadCrumbList', ->
#       data = {"pName": ["n1", "n2", "n3"], "pUnqName": ["un1", "un2", "un3"]}
#       @scope.showBreadCrumbs(data)
#       expect(@scope.showBreadCrumb).toBeTruthy()
#       expect(@scope.breadCrumbList).toEqual({"pName": ["n1", "n2", "n3"], "pUnqName": ["un1", "un2", "un3"]})

#   describe '#jumpToGroup', ->
#     it 'should call selectGroupToEdit and selectItem function with a obj and make a call to groupService flattenGroup method', ->
#       abc = "loan"
#       def = [
#         {
#           groups: [{
#             accounts: []
#             description: null
#             groups: []
#             isFixed: true
#             name: "ravi"
#             parentGroups: []
#             uniqueName: "ravi"
#           }]
#           name: "Loan"
#           uniqueName: "loan"
#         }
#         {
#           groups: [{
#             accounts: []
#             description: null
#             groups: []
#             isFixed: true
#             name: "dude"
#             parentGroups: []
#             uniqueName: "dude"
#           }]
#           name: "Mortgage"
#           uniqueName: "mortgage"
#         }
#       ]
#       res = {
#         groups: [{
#           accounts: []
#           description: null
#           groups: []
#           isFixed: true
#           name: "ravi"
#           parentGroups: []
#           uniqueName: "ravi"
#         }]
#         name: "Loan"
#         uniqueName: "loan"
#       }
#       spyOn(@scope, "selectGroupToEdit")
#       spyOn(@groupService, "flattenGroup").andReturn(def)
#       spyOn(@scope, "selectItem")
#       @scope.jumpToGroup(abc, def)
#       expect(@scope.selectGroupToEdit).toHaveBeenCalledWith(res)

#   describe '#isEmptyObject', ->
#     it 'should return true if object is empty', ->
#       data = {}
#       result = @scope.isEmptyObject(data)
#       expect(result).toBeTruthy()

#     it 'should return false if object is not empty', ->
#       data = {name: "name"}
#       result = @scope.isEmptyObject(data)
#       expect(result).toBeFalsy()


#   describe '#mergeNum', ->
#     it 'should return null', ->
#       num = {
#         Ccode: undefined
#         onlyMobileNo: ""
#       }
#       expect(@scope.mergeNum(num)).toBeNull()
#     it 'should merge number', ->
#       num = {
#         Ccode: {value: "91", name: "india"}
#         onlyMobileNo: "123456"
#       }
#       expect(@scope.mergeNum(num)).toBe("91-123456")
#     it 'should merge number', ->
#       num = {
#         Ccode: "91"
#         onlyMobileNo: "123456"
#       }
#       expect(@scope.mergeNum(num)).toBe("91-123456")

#   describe '#breakMobNo', ->
#     it 'should break mobile number string', ->
#       data = {mobileNo: "91-123456"}
#       @scope.breakMobNo(data)
#       expect(@scope.acntExt.Ccode).toEqual("91")
#       expect(@scope.acntExt.onlyMobileNo).toEqual("123456")
#     it 'should set value undefined and not break string', ->
#       data = {}
#       @scope.breakMobNo(data)
#       expect(@scope.acntExt.Ccode).toEqual(undefined)
#       expect(@scope.acntExt.onlyMobileNo).toEqual(undefined)

#   describe '#showAccountDtl', ->
#     it 'should highlight accounts menu and call accountService get method', ->
#       data =
#         name: "somename"
#         uniqname: "somename"
#         mergedAccounts: "somename"
#       @rootScope.selectedCompany = {
#         uniqueName: "somename"
#       }
#       reqParams = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         acntUname: data.uniqueName
#       }
#       deferred = @q.defer()
#       spyOn(@accountService, 'get').andReturn(deferred.promise)
#       @scope.showAccountDtl(data)
#       expect(@scope.selectedAccntMenu).toEqual(data)
#       expect(@accountService.get).toHaveBeenCalledWith(reqParams)
      
#   describe '#getAcDtlSuccess', ->
#     it 'should call groupService matchAndReturnGroupObj method and copy data to selAcntPrevObj, set showGroupDetails variable to false, showAccountDetails to true and set value for selected account variable and set breadcrumb and set value cantUpdate variable to true', ->
#       res = {
#         "status": "success",
#         "body": [
#           {
#             address: null
#             companyName: null
#             description: null
#             email: null
#             mergedAccounts: ""
#             mobileNo: null
#             name: "cash in hand"
#             openingBalance: 50000
#             openingBalanceDate: "01-11-2015"
#             openingBalanceType: "DEBIT"
#             uniqueName: "cashinhand"
#             role: {
#               name: "Super Admin"
#               uniqueName: "super_admin"
#             }
#           }
#         ]
#       }
#       getPgrps = {
#         mergedAccounts: ""
#         name: "cash in hand"
#         parentGroups: [
#           {
#             name: "cash in hand"
#             uniqueName: "cashinhand"
#           }
#           {
#             name: "CPU"
#             uniqueName: "cpu"
#           }
#         ]
#         uniqueName: "cashinhand"
#       }
#       @rootScope.flatAccntListWithParents = []
#       @rootScope.selAcntUname = "cashinhand"
#       spyOn(@groupService, "matchAndReturnGroupObj").andReturn(getPgrps)
#       spyOn(@rootScope, "$emit")
#       spyOn(@scope, "breakMobNo")
#       spyOn(@scope, "setOpeningBalanceDate")
#       spyOn(@scope, "getAccountSharedList")
#       spyOn(@scope, "showBreadCrumbs")
#       @scope.getAcDtlSuccess(res)
#       expect(@groupService.matchAndReturnGroupObj).toHaveBeenCalledWith(res.body, @rootScope.flatAccntListWithParents)
#       expect(@rootScope.$emit).toHaveBeenCalledWith('callCheckPermissions', res.body)
#       expect(@scope.cantUpdate).toBeFalsy()
#       expect(@scope.showGroupDetails).toBeFalsy()
#       expect(@scope.showAccountDetails).toBeTruthy()
#       expect(@scope.cantUpdate).toBeFalsy()
#       expect(@scope.selAcntPrevObj).toEqual(res.body)
#       expect(@scope.selectedAccount).toEqual(res.body)
#       expect(@scope.breakMobNo).toHaveBeenCalled()
#       expect(@scope.setOpeningBalanceDate).toHaveBeenCalled()
#       expect(@scope.getAccountSharedList).toHaveBeenCalled()
#       expect(@scope.acntCase).toBe("Update")
#       expect(@scope.showBreadCrumbs).toHaveBeenCalledWith(getPgrps.parentGroups.reverse())

#   describe '#getAcDtlFailure', ->
#     it 'should show error message with toastr', ->
#       res = {"data": {"status": "Error", "message": "Unable to get group details"}}
#       spyOn(@toastr, "error")
#       @scope.getAcDtlFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#setOpeningBalanceDate', ->
#     it 'should check if openingBalanceDate is defined then set value according to condition', ->
#       @scope.selectedAccount = {
#         openingBalanceDate: "01-11-2015"
#       }
#       @scope.setOpeningBalanceDate()
#       expect(@scope.datePicker.accountOpeningBalanceDate instanceof Date).toBe(true)
#     it 'should check if openingBalanceDate is undefined then set new date ', ->
#       @scope.selectedAccount = {}
#       @scope.setOpeningBalanceDate()
#       expect(@scope.datePicker.accountOpeningBalanceDate instanceof Date).toBe(true)

#   describe '#addNewAccountShow', ->
#     it 'should call setOpeningBalanceDate, set false to showGroupDetails, set true to showAccountDetails, set acntCase to add, and undefined to some scope variables and call showBreadCrumbs function with data', ->
#       @scope.selectedGroup = {
#         address: null
#         companyName: null
#         description: null
#         email: null
#         mergedAccounts: []
#         mobileNo: null
#         name: "cash in hand"
#         openingBalance: 50000
#         openingBalanceDate: "01-11-2015"
#         openingBalanceType: "DEBIT"
#         uniqueName: "cashinhand"
#         parentGroups: [
#           {
#             name: "cash"
#             uniqueName: "cash"
#             role: {
#               name: "Admin"
#               uniqueName: "admin"
#               permissions: [
#                 {code: "VW", description: "View"}
#                 {code: "DLT", description: "Delete"}
#                 {code: "UPDT", description: "Update"}
#                 {code: "ADD", description: "Add"}
#               ]
#             }
#           }
#         ]
#       }
#       spyOn(@scope, "showBreadCrumbs")
#       spyOn(@scope, "setOpeningBalanceDate")
#       @scope.addNewAccountShow(@scope.selectedGroup)
#       expect(@scope.cantUpdate).toBeFalsy()
#       expect(@scope.selectedAccount).toEqual({})
#       expect(@scope.acntExt.Ccode).toBe (undefined)
#       expect(@scope.acntExt.onlyMobileNo).toBe (undefined)
#       expect(@scope.breadCrumbList).toBe (undefined)
#       expect(@scope.selectedAccntMenu).toBe (undefined)
#       expect(@scope.showGroupDetails).toBeFalsy()
#       expect(@scope.showAccountDetails).toBeTruthy()
#       expect(@scope.acntCase).toBe("Add")
#       expect(@scope.setOpeningBalanceDate).toHaveBeenCalled()
#       expect(@scope.showBreadCrumbs).toHaveBeenCalledWith(@scope.selectedGroup.parentGroups)

#   describe '#setAdditionalAccountDetails', ->
#     it 'should convert date to a string and set value in openingBalanceDate, it should call mergeNum', ->
#       @scope.datePicker = {
#         accountOpeningBalanceDate: new Date(2015, 10, 10)
#       }
#       @scope.acntExt = {
#         Ccode: undefined
#         onlyMobileNo: undefined
#       }
#       @rootScope.selectedCompany = {
#         uniqueName: "name"
#       }
#       @scope.selectedGroup = {
#         uniqueName: "name"
#       }
#       @scope.selectedAccount = {
#         uniqueName: "name"
#       }
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedGroup.uniqueName
#         acntUname: @scope.selectedAccount.uniqueName
#       }
#       res = @scope.setAdditionalAccountDetails()
#       expect(@scope.selectedAccount.openingBalanceDate).toBe("10-11-2015")
#       expect(@scope.selectedAccount.mobileNo).toBeNull()
#       expect(res).toEqual(unqNamesObj)

#   describe '#addAccount', ->
#     it 'should call accountService create method with obj', ->
#       data = {
#         compUname: "Cname"
#         selGrpUname: "Gname"
#         acntUname: "Aname"
#       }
#       @scope.selectedAccount = {}
#       spyOn(@scope, "setAdditionalAccountDetails").andReturn(data)
#       deferred = @q.defer()
#       spyOn(@accountService, 'createAc').andReturn(deferred.promise)
#       @scope.addAccount()
#       expect(@accountService.createAc).toHaveBeenCalledWith(data, @scope.selectedAccount)

#   describe '#addAccountSuccess', ->
#     it 'should show success message through toastr, set selectedAccount to blank object, and push data in selectedGroup.accounts variable, set value to groupAccntList and call getGroups function', ->
#       spyOn(@toastr, "success")
#       spyOn(@scope, "getGroups")
#       res = {
#         status: "Success"
#         body:
#           name: "name"
#           uniqueName: "name"
#           mergedAccounts: "name"
#       }
#       @scope.selectedGroup = {
#         accounts: []
#         parentGroups: [
#           {a: "a"}, {a: "b"}
#         ]
#       }
#       @scope.groupAccntList =[]
#       @scope.addAccountSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith("Account created successfully", res.status)
#       expect(@scope.getGroups).toHaveBeenCalled()
#       expect(@scope.selectedAccount).toEqual({})
#       expect(@scope.groupAccntList).toContain(res.body)

      

#   describe '#addAccountFailure', ->
#     it 'should show error message through toastr', ->
#       spyOn(@toastr, "error")
#       res = {
#         data: {
#           message: "Add account failure"
#           status: "Error"
#         }
#       }
#       @scope.addAccountFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#deleteAccount', ->
#     it 'should check whether user have permission to delete and if no then do not call servie', ->
#       @scope.canDelete = false
#       deferred = @q.defer()
#       spyOn(@modalService, 'openConfirmModal').andReturn(deferred.promise)
#       @scope.deleteAccount()
#       expect(@modalService.openConfirmModal).not.toHaveBeenCalled()

#     it 'should call modalService and check prev uniqueName value is same like new ', ->
#       @scope.canDelete = true
#       deferred = @q.defer()
#       spyOn(@modalService, 'openConfirmModal').andReturn(deferred.promise)
#       @scope.deleteAccount()
#       expect(@modalService.openConfirmModal).toHaveBeenCalledWith({
#         title: 'Delete Account?'
#         body: 'Are you sure you want to delete this Account?'
#         ok: 'Yes'
#         cancel: 'No'
#       })

#   describe '#deleteAccountConfirm', ->
#     it 'should call accountService delete method with two parameters', ->
#       data = {
#         compUname: "Cname"
#         selGrpUname: "Gname"
#         acntUname: "Aname"
#       }
#       @scope.selectedGroup = {}
#       @scope.selectedAccount = {
#         uniqueName: "name"
#         parentGroups: [{uniqueName: "pUnqName"}]
#       }
#       @scope.selAcntPrevObj = {uniqueName: "naame"}
#       deferred = @q.defer()
#       spyOn(@accountService, 'deleteAc').andReturn(deferred.promise)
#       spyOn(@scope, "setAdditionalAccountDetails").andReturn(data)
#       @scope.deleteAccountConfirm()
#       expect(@accountService.deleteAc).toHaveBeenCalledWith(data, @scope.selectedAccount)

#   describe '#onDeleteAccountFailure', ->
#     it 'should show error message through toastr', ->
#       res =
#         data:
#           status: "Error"
#           message: "Only empty accounts can be deleted."
#       spyOn(@toastr, "error")
#       @scope.onDeleteAccountFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#updateAccount', ->
#     it 'should check if prev object and new object is not changed then call toastr info message', ->
#       data = {
#         compUname: "Cname"
#         selGrpUname: "Gname"
#         acntUname: "Aname"
#       }
#       @scope.selectedAccount = {
#         uniqueName: "name"
#         parentGroups: [{uniqueName: "pUnqName"}]
#       }
#       @scope.selAcntPrevObj = {
#         uniqueName: "name"
#         parentGroups: [{uniqueName: "pUnqName"}]
#       }
#       spyOn(@scope, "setAdditionalAccountDetails").andReturn(data)
#       spyOn(@toastr, 'info')
#       @scope.updateAccount()
#       expect(@scope.setAdditionalAccountDetails).toHaveBeenCalled()
#       expect(@toastr.info).toHaveBeenCalledWith("Nothing to update", "Info")
    
#     it 'should call accountService updateAc method and check prev uniqueName value is same like new or selected group is empty ', ->
#       data = {
#         compUname: "Cname"
#         selGrpUname: "Gname"
#         acntUname: "Aname"
#       }
#       @scope.selectedGroup = {}
#       @scope.selectedAccount = {
#         uniqueName: "name"
#         parentGroups: [{uniqueName: "pUnqName"}]
#       }
#       @scope.selAcntPrevObj = {uniqueName: "naame"}
#       spyOn(@scope, "setAdditionalAccountDetails").andReturn(data)
#       deferred = @q.defer()
#       spyOn(@accountService, 'updateAc').andReturn(deferred.promise)
      
#       @scope.updateAccount()
#       expect(@accountService.updateAc).toHaveBeenCalledWith(data, @scope.selectedAccount)
      

#   describe '#updateAccountSuccess', ->
#     res = {
#       status: "Success"
#       body: {
#         uniqueName: "name"
#         mergedAccounts: ""
#         uniqname: "dsdd"
#       }
#     }    
#     it 'should show success message and call getGroups function and merge selectedAccount, selAcntPrevObj variables to response object', ->
#       @scope.selectedAccount = {}
#       @scope.selAcntPrevObj = {}
#       spyOn(@toastr, "success")
#       spyOn(@scope, "getGroups")
#       @scope.updateAccountSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith("Account updated successfully", res.status)
#       expect(@scope.selectedAccount).toEqual(res.body)
#       expect(@scope.getGroups).toHaveBeenCalled()
#       expect(@scope.selAcntPrevObj).toEqual(res.body)

#     it 'should show success message and call getGroups function and merge selectedAccount, selAcntPrevObj variables to response object and if selectedGroup is not empty then it will merge groupAccntList array by find index', ->
#       @scope.selectedAccount = {}
#       @scope.selAcntPrevObj = {}
#       @scope.selectedGroup = {
#         uniqueName: "ss"
#       }
#       @scope.groupAccntList = [
#         {
#           uniqueName: "ss"
#           mergedAccounts: ""
#           uniqname: "ss"
#         }
#         {
#           uniqueName: "d"
#           mergedAccounts: ""
#           uniqname: "d"
#         }
#         {
#           uniqueName: "name"
#           mergedAccounts: ""
#           uniqname: "dsdd"
#         }
#       ]
#       spyOn(@toastr, "success")
#       spyOn(@scope, "getGroups")
#       @scope.updateAccountSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith("Account updated successfully", res.status)
#       expect(@scope.selectedAccount).toEqual(res.body)
#       expect(@scope.getGroups).toHaveBeenCalled()
#       expect(@scope.selAcntPrevObj).toEqual(res.body)
#       expect(@scope.groupAccntList[2]).toEqual(res.body)
      

#   describe '#updateAccountFailure', ->
#     it 'should show error message through toastr', ->
#       res =
#         data:
#           message: "Unable to update account"
#           status: "Error"
#       spyOn(@toastr, "error")
#       @scope.updateAccountFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#isCurrentGroup', ->
#     it 'should check if condition is mathed and return true', ->
#       data = {
#         uniqueName: "name"
#       }
#       @scope.selectedAccount = {
#         uniqueName: "name"
#         parentGroups: [
#           {uniqueName: "name"}
#         ]
#       }
#       @scope.isCurrentGroup(data)
#       expect(@scope.isCurrentGroup).toBeTruthy()

#   describe '#moveAccnt', ->
#     it 'should check if group uniqname is undefined then call toastr error message and return', ->
#       data = {}
#       spyOn(@toastr, "error")
#       @scope.moveAccnt(data)
#       expect(@toastr.error).toHaveBeenCalledWith("Select group only from list", "Error")

#     it 'should call accountService move method with object', ->
#       data = {
#         uniqueName: "name"
#       }
#       @rootScope.selectedCompany = {
#         uniqueName: "myCompany"
#       }
#       @scope.selectedGroup = {
#         uniqueName: "name"
#       }
#       @scope.selectedAccount = {
#         uniqueName: "name"
#       }
#       obj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedGroup.uniqueName
#         acntUname: @scope.selectedAccount.uniqueName
#       }
#       deferred = @q.defer()
#       spyOn(@accountService, 'move').andReturn(deferred.promise)
#       @scope.moveAccnt(data)
#       expect(@accountService.move).toHaveBeenCalledWith(obj, data)

#     it 'should call accountService move method with object and also check if selectedGroup uniqname is undefined', ->
#       data = {
#         uniqueName: "name"
#       }
#       @rootScope.selectedCompany = {
#         uniqueName: "myCompany"
#       }
#       @scope.selectedGroup = {}
#       @scope.selectedAccount = {
#         uniqueName: "name"
#         parentGroups: [
#           {uniqueName: "name"}
#         ]
#       }
#       obj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedAccount.parentGroups[0].uniqueName
#         acntUname: @scope.selectedAccount.uniqueName
#       }
#       deferred = @q.defer()
#       spyOn(@accountService, 'move').andReturn(deferred.promise)
#       @scope.moveAccnt(data)
#       expect(@accountService.move).toHaveBeenCalledWith(obj, data)

#   describe '#moveAccntSuccess', ->
#     it 'should show success message and call getGroups function and set showAccountDetails variable to false', ->
#       res =
#         body: "Account moved successfully"
#         status: "Success"
#       spyOn(@toastr, "success")
#       spyOn(@scope, "getGroups")
#       @scope.moveAccntSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith(res.body, res.status)
#       expect(@scope.getGroups).toHaveBeenCalled()
#       expect(@scope.showAccountDetails).toBeFalsy

#   describe '#moveAccntFailure', ->
#     it 'should show error message through toastr', ->
#       res =
#         data:
#           message: "Unable to move account"
#           status: "Error"
#       spyOn(@toastr, "error")
#       @scope.moveAccntFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#shareAccount', ->
#     it 'should call service share method with obj var when group is selected', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       @scope.selectedAccount = {uniqueName: "3"}
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedGroup.uniqueName
#         acntUname: @scope.selectedAccount.uniqueName
#       }
#       @scope.shareAccountObj = {
#         role: "view_only"
#         user: "someUser"
#       }
#       deferred = @q.defer()
#       spyOn(@accountService, "share").andReturn(deferred.promise)
#       @scope.shareAccount()
#       expect(@accountService.share).toHaveBeenCalledWith(unqNamesObj, @scope.shareAccountObj)

#     it 'should call service share method with obj var when group is not selected', ->
#       @scope.selectedGroup = {}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       @scope.selectedAccount = {uniqueName: "3", parentGroups: [{uniqueName: 1}]}
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedAccount.parentGroups[0].uniqueName
#         acntUname: @scope.selectedAccount.uniqueName
#       }
#       @scope.shareAccountObj = {
#         role: "view_only"
#         user: "someUser"
#       }
#       deferred = @q.defer()
#       spyOn(@accountService, "share").andReturn(deferred.promise)
#       @scope.shareAccount()
#       expect(@accountService.share).toHaveBeenCalledWith(unqNamesObj, @scope.shareAccountObj)

#   describe '#onShareAccountSuccess', ->
#     it 'should blank a key and show success message with toastr and call getGroupSharedList with selected group variable', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       @scope.shareAccountObj = {
#         role: "view_only"
#         user: ""
#       }
#       res = {"status": "Success", "body": "Account shared successfully"}
#       spyOn(@toastr, 'success')
#       spyOn(@scope, "getGroupSharedList")
#       spyOn(@scope, 'getAccountSharedList')
#       @scope.onShareAccountSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith('Account shared successfully', 'Success')
#       expect(@scope.getAccountSharedList).toHaveBeenCalled()

#   describe '#onShareAccountFailure', ->
#     it 'should show error message with toastr', ->
#       res = {"data": {"status": "Error", "message": "some-message"}}
#       spyOn(@toastr, "error")
#       @scope.onShareAccountFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#unShareAccount', ->
#     it 'should call service share method with obj var when group is selected', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       @scope.selectedAccount = {uniqueName: "3"}
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedGroup.uniqueName
#         acntUname: @scope.selectedAccount.uniqueName
#       }
#       data = {user: "user"}
#       deferred = @q.defer()
#       spyOn(@accountService, "unshare").andReturn(deferred.promise)
#       @scope.unShareAccount("user")
#       expect(@accountService.unshare).toHaveBeenCalledWith(unqNamesObj, data)

#     it 'should call service share method with obj var when group is not selected', ->
#       @scope.selectedGroup = {}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       @scope.selectedAccount = {uniqueName: "3", parentGroups: [{uniqueName: 1}]}
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedAccount.parentGroups[0].uniqueName
#         acntUname: @scope.selectedAccount.uniqueName
#       }
#       data = {user: "user"}
#       deferred = @q.defer()
#       spyOn(@accountService, "unshare").andReturn(deferred.promise)
#       @scope.unShareAccount("user")
#       expect(@accountService.unshare).toHaveBeenCalledWith(unqNamesObj, data)

#   describe '#unShareAccountSuccess', ->
#     it 'should show success message with toastr and call getAccountSharedList', ->
#       @scope.selectedGroup = {"uniqueName": "1"}
#       res = {"status": "Success", "body": "Account unShared successfully"}
#       spyOn(@toastr, 'success')
#       spyOn(@scope, "getAccountSharedList")
#       @scope.unShareAccountSuccess(res)
#       expect(@toastr.success).toHaveBeenCalledWith('Account unShared successfully', 'Success')
#       expect(@scope.getAccountSharedList).toHaveBeenCalled()

#   describe '#unShareAccountFailure', ->
#     it 'should show error message with toastr', ->
#       res = {"data": {"status": "Error", "message": "some-message"}}
#       spyOn(@toastr, "error")
#       @scope.unShareAccountFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)

#   describe '#getAccountSharedList', ->
#     it 'should call a service with a obj var to get data when account is selected and user has permission', ->
#       @scope.canShare = true
#       @scope.selectedGroup = {"uniqueName": "1"}
#       @rootScope.selectedCompany = {"uniqueName": "2"}
#       @scope.selectedAccount = {
#         uniqueName: "3"
#         parentGroups: [
#           {uniqueName: "milk"}
#           {uniqueName: "milk2"}
#         ]
#       }
#       unqNamesObj = {
#         compUname: @rootScope.selectedCompany.uniqueName
#         selGrpUname: @scope.selectedAccount.parentGroups[0].uniqueName
#         acntUname: @scope.selectedAccount.uniqueName
#       }
#       deferred = @q.defer()
#       spyOn(@accountService, "sharedWith").andReturn(deferred.promise)

#       @scope.getAccountSharedList()
#       expect(@accountService.sharedWith).toHaveBeenCalledWith(unqNamesObj)

#     it 'should not call a service with a obj var to get data when user does not have permission', ->
#       @scope.canShare = false
#       spyOn(@accountService, "sharedWith")

#       @scope.getAccountSharedList()
#       expect(@accountService.sharedWith).not.toHaveBeenCalled()

#   describe '#onGetAccountSharedListSuccess', ->
#     it 'should set result to a variable', ->
#       result = {"body": "something"}
#       @scope.onGetAccountSharedListSuccess(result)
#       expect(@scope.accountSharedUserList).toBe(result.body)

#   describe '#onGetAccountSharedListFailure', ->
#     it 'should show error message with toastr', ->
#       res =
#         data:
#           status: "Error"
#           message: "some-message"
#       spyOn(@toastr, "error")
#       @scope.onGetAccountSharedListFailure(res)
#       expect(@toastr.error).toHaveBeenCalledWith(res.data.message, res.data.status)


  

#   