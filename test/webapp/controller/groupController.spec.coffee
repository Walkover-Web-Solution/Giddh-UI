'use strict'

describe 'groupController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, localStorageService, toastr, groupService, $q) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @localStorageService = localStorageService
    @toastr = toastr
    @groupService = groupService
    @q = $q
    @groupController = $controller('groupController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService})


  describe '#getGroups', ->
    it 'should show a toastr informing user to select company first when no company selected', ->
      @rootScope.selectedCompany = {}
      spyOn(@toastr, 'error')
      @scope.getGroups()
      expect(@toastr.error).toHaveBeenCalledWith('Select company first.', 'Error')

    it 'should call groups from route after getting company unique name', ->
      @rootScope.selectedCompany = {"data": "Got it", "uniqueName": "soniravi"}
      deferred = @q.defer()
      spyOn(@groupService, 'getAllWithAccountsFor').andReturn(deferred.promise)
      @scope.getGroups()
      expect(@groupService.getAllWithAccountsFor).toHaveBeenCalledWith("soniravi")

  describe '#getGroupListSuccess', ->
    it 'should set group list', ->
      result = ["body": {"name": "fixed assets"}, {"name": "capital account"}]
      @scope.getGroupListSuccess(result)
      expect(@scope.groupList).toBe(result.body)

  describe '#getGroupListFailure', ->
    it 'should show a toastr for error', ->
      spyOn(@toastr, 'error')
      @scope.getGroupListFailure()
      expect(@toastr.error).toHaveBeenCalledWith("Unable to get group details.", "Error")

  describe '#selectGroupToEdit', ->
    it 'should check if variable is empty then set value according to condition', ->
      spyOn(@scope, "getGroupSharedList")
      @scope.selectedGroup.oldUName = ''
      group = {"name": "Fixed Assets"}
      @scope.selectGroupToEdit(group)
      expect(@scope.selectedGroup.oldUName).toEqual(@scope.selectedGroup.uniqueName)

    it 'should set group as selected and a variable to true and make a call to fuction with group variable', ->
      spyOn(@scope, "getGroupSharedList")
      group = {"name": "Fixed Assets"}
      @scope.selectGroupToEdit(group)
      expect(@scope.selectedGroup).toEqual(group)
      expect(@scope.showGroupDetails).toBeTruthy()
      expect(@scope.getGroupSharedList).toHaveBeenCalledWith(group)

  describe '#getGroupSharedList', ->
    it 'should call a service with a obj var to get data', ->
      @scope.selectedGroup = {"uniqueName": "1"}
      @rootScope.selectedCompany = {"uniqueName": "2"}
      group = {"name": "Fixed Assets"}
      unqNamesObj = {
        compUname: @rootScope.selectedCompany.uniqueName
        selGrpUname: @scope.selectedGroup.uniqueName
      }
      deferred = @q.defer()
      spyOn(@groupService, "sharedList").andReturn(deferred.promise)
      @scope.getGroupSharedList(group)
      expect(@groupService.sharedList).toHaveBeenCalledWith(unqNamesObj)

  describe '#onsharedListSuccess', ->
    it 'should set response to a variable', ->
      result = {"body": "something"}
      @scope.onsharedListSuccess(result)
      expect(@scope.groupSharedUserList).toBe(result.body)

  describe '#shareGroup', ->
    it 'should call service share method with obj var', ->
      @scope.selectedGroup = {"uniqueName": "1"}
      @rootScope.selectedCompany = {"uniqueName": "2"}
      unqNamesObj = {
        compUname: @rootScope.selectedCompany.uniqueName
        selGrpUname: @scope.selectedGroup.uniqueName
      }
      @scope.shareGroupObj = {
        role: "view_only"
        user: "someUser"
      }
      deferred = @q.defer()
      spyOn(@groupService, "share").andReturn(deferred.promise)
      @scope.shareGroup()
      expect(@groupService.share).toHaveBeenCalledWith(unqNamesObj, @scope.shareGroupObj)

  describe '#onShareGroupSuccess', ->
    it 'should blank a key and show success message with toastr and call getGroupSharedList with selected group variable', ->
      @scope.selectedGroup = {"uniqueName": "1"}
      @scope.shareGroupObj = {
        role: "view_only"
        user: ""
      }
      response = {"status": "Success", "body": "Group shared successfully"}
      spyOn(@toastr, 'success')
      spyOn(@scope, "getGroupSharedList")
      @scope.onShareGroupSuccess(response)
      expect(@toastr.success).toHaveBeenCalledWith('Group shared successfully', 'Success')
      expect(@scope.getGroupSharedList).toHaveBeenCalledWith(@scope.selectedGroup)

  describe '#onShareGroupFailure', ->
    it 'should show error message with toastr', ->
      response = {"data": {"status": "Error", "message": "some-message"}}
      @spyOn(@toastr, "error")
      @scope.onShareGroupFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#unShareGroup', ->
    it 'should call service share method with obj var', ->
      @scope.selectedGroup = {"uniqueName": "1"}
      @rootScope.selectedCompany = {"uniqueName": "2"}
      unqNamesObj = {
        compUname: @rootScope.selectedCompany.uniqueName
        selGrpUname: @scope.selectedGroup.uniqueName
      }
      user = "user"
      data = {
        user: user
      }
      deferred = @q.defer()
      spyOn(@groupService, "unshare").andReturn(deferred.promise)
      @scope.unShareGroup(user)
      expect(@groupService.unshare).toHaveBeenCalledWith(unqNamesObj, data)

  describe '#unShareGroupSuccess', ->
    it 'should show success message with toastr and call getGroupSharedList with selected group variable', ->
      @scope.selectedGroup = {"uniqueName": "1"}
      response = {"status": "Success", "body": "Group unShared successfully"}
      spyOn(@toastr, 'success')
      spyOn(@scope, "getGroupSharedList")
      @scope.unShareGroupSuccess(response)
      expect(@toastr.success).toHaveBeenCalledWith('Group unShared successfully', 'Success')
      expect(@scope.getGroupSharedList).toHaveBeenCalledWith(@scope.selectedGroup)

  describe '#unShareGroupFailure', ->
    it 'should show error message with toastr', ->
      response = {"data": {"status": "Error", "message": "some-message"}}
      @spyOn(@toastr, "error")
      @scope.unShareGroupFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('some-message', 'Error')

  describe '#updateGroup', ->
    it 'should call group service and update group', ->
      @scope.selectedGroup = {"uniqueName": "1"}
      @rootScope.selectedCompany = {"uniqueName": "2"}
      deferred = @q.defer()
      spyOn(@groupService, 'update').andReturn(deferred.promise)
      @scope.updateGroup()
      expect(@groupService.update).toHaveBeenCalledWith("2", {'uniqueName': '1'})

  describe '#onUpdateGroupSuccess', ->
    it 'should show success message with toastr and set value in variable', ->
      response = {"status": "Success", "body": "Group has been updated successfully."}
      spyOn(@toastr, 'success')
      @scope.onUpdateGroupSuccess(response)
      expect(@toastr.success).toHaveBeenCalledWith('Group has been updated successfully.', 'Success')
      expect(@scope.selectedGroup.oldUName).toEqual(@scope.selectedGroup.uniqueName)

  describe '#onUpdateGroupFailure', ->
    it 'should show error message with toastr', ->
      response = {
        "data": {
          "status": "Error",
          "message": "Unable to update group at the moment. Please try again later."
        }
      }
      @spyOn(@toastr, "error")
      @scope.onUpdateGroupFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('Unable to update group at the moment. Please try again later.',
          'Error')

  describe '#getUniqueNameFromGroupList', ->
    it 'should take list of group as input and return unique name of all groups in flatten way', ->
      groupList = [{
        "name": "group1",
        "uniqueName": "g1",
        "groups": [{"name": "group2", "uniqueName": "g2", "groups": []}]
      },
        {"name": "group3", "uniqueName": "g3", "groups": []}]
      result = @scope.getUniqueNameFromGroupList(groupList)
      expect(result).toContain("g1")
      expect(result).toContain("g2")
      expect(result).toContain("g3")

  describe '#addNewSubGroup', ->
    it 'should call group service and add new subgroup to selected group', ->
      @scope.selectedSubGroup = {"name": "subgroup1", "desc": "description", "uniqueName": "suniqueName"}
      @rootScope.selectedCompany = {"uniqueName": "CmpUniqueName"}
      @scope.selectedGroup = {"uniqueName": "grpUName"}
      body = {
        "name": @scope.selectedSubGroup.name,
        "uniqueName": "suniquename",
        "parentGroupUniqueName": @scope.selectedGroup.uniqueName
        "description": "description"
      }
      deferred = @q.defer()
      spyOn(@groupService, 'create').andReturn(deferred.promise)
      @scope.addNewSubGroup()
      expect(@groupService.create).toHaveBeenCalledWith("CmpUniqueName", body)

  describe '#onCreateGroupFailure', ->
    it 'should call toastr to show error', ->
      spyOn(@toastr, "error")
      @scope.onCreateGroupFailure()
      expect(@toastr.error).toHaveBeenCalledWith("Unable to create subgroup.", "Error")

  describe '#onCreateGroupSuccess', ->
    it 'should call toastr with success, empty selected sub group and call getGroups', ->
      spyOn(@toastr, "success")
      spyOn(@scope, "getGroups")
      @scope.onCreateGroupSuccess()
      expect(@toastr.success).toHaveBeenCalledWith("Sub group added successfully", "Success")
      expect(@scope.selectedSubGroup).toEqual({})
      expect(@scope.getGroups)

  describe '#deleteGroup', ->
    it 'should call group service and delete and call group list', ->
      deferred = @q.defer()
      @rootScope.selectedCompany = {"uniqueName": "CmpUniqueName", "isFixed": "false"}
      spyOn(@groupService, 'delete').andReturn(deferred.promise)
      @scope.deleteGroup()
      expect(@rootScope.selectedCompany.isFixed).toBeTruthy()
      expect(@groupService.delete)

    xit 'should not call service if isFixed variable is true', ->
      deferred = @q.defer()
      @rootScope.selectedCompany = {"uniqueName": "CmpUniqueName", "isFixed": "true"}
      spyOn(@groupService, 'delete').andReturn(deferred.promise)
      @scope.deleteGroup()
      expect(@rootScope.selectedCompany.isFixed).toBeTruthy()
      expect(@groupService.delete).not.toHaveBeenCalled()

  describe '#onDeleteGroupFailure', ->
    it 'should show a toastr for error', ->
      spyOn(@toastr, "error")
      @scope.onDeleteGroupFailure()
      expect(@toastr.error).toHaveBeenCalledWith("Unable to delete group.", "Error")

  describe '#onDeleteGroupSuccess', ->
    it 'should show a toastr, empty the selected group, show group detail to be false & get group list from server', ->
      emptyObject = {}
      spyOn(@toastr, "success")
      @scope.onDeleteGroupSuccess()
      expect(@toastr.success).toHaveBeenCalledWith("Group deleted successfully.", "Success")
      expect(@scope.selectedGroup).toEqual(emptyObject)

  describe '#moveGroup', ->
    it 'should call group service move method with variables', ->
      @scope.selectedGroup = {"uniqueName": "1"}
      @rootScope.selectedCompany = {"uniqueName": "2"}
      unqNamesObj = {
        compUname: @rootScope.selectedCompany.uniqueName
        selGrpUname: @scope.selectedGroup.uniqueName
      }
      group = {"uniqueName": "abc"}
      body = {
        "parentGroupUniqueName": group.uniqueName
      }
      deferred = @q.defer()
      spyOn(@groupService, 'move').andReturn(deferred.promise)
      @scope.moveGroup(group)
      expect(@groupService.move).toHaveBeenCalledWith(unqNamesObj, body)

  describe '#onUpdateGroupSuccess', ->
    it 'should show success message with toastr, call getgroups fucntion, set a blank object, set a variable false, and make a scope var undefined', ->
      response = {"status": "Success", "body": "Group moved successfully."}
      spyOn(@toastr, 'success')
      spyOn(@scope, "getGroups")
      @scope.onMoveGroupSuccess(response)
      expect(@toastr.success).toHaveBeenCalledWith('Group moved successfully.', 'Success')
      expect(@scope.getGroups).toHaveBeenCalled()
      expect(@scope.selectedGroup).toEqual({})
      expect(@scope.showGroupDetails).toBeFalsy()
      expect(@scope.moveto).toBe(undefined)


  describe '#onMoveGroupFailure', ->
    it 'should show error message with toastr', ->
      response = {"data": {"status": "Error", "message": "Unable to move group."}}
      @spyOn(@toastr, "error")
      @scope.onMoveGroupFailure(response)
      expect(@toastr.error).toHaveBeenCalledWith('Unable to move group.', 'Error')

  describe '#selectItem', ->
    it 'should make group menus highlight set active class', ->
      item = "item"
      @scope.selectItem(item)
      expect(@scope.selectedItem).toBe(item)

  describe '#onMoveGroupSuccess', ->
    it 'should show success toastr, call getGroups, set selected group to be empty, set showGroupDetails variable to be false and moveTo variable to undefined', ->
      spyOn(@toastr, "success")
      @scope.onMoveGroupSuccess()
      expect(@toastr.success).toHaveBeenCalledWith("Group moved successfully.", "Success")
      expect(@scope.getGroups)
      expect(@scope.selectedGroup).toEqual({})
      expect(@scope.showGroupDetails).toBeFalsy()
      expect(@scope.moveto).toBeUndefined()


  describe '#showAccountDtl', ->
    xit 'should set showGroupDetails variable to false, showAccountDetails to true & set value for selected account variable and set breadcrum', ->
      data = {"name": "testing","groups":[{"name":"g1"},{"name":"g1"}]}
      spyOn(@scope, 'breakMobNo')
      spyOn(@scope, 'setOpeningBalanceDate')
      @scope.showAccountDtl(data)
      expect(@scope.showGroupDetails).toBeFalsy()
      expect(@scope.showAccountDetails).toBeTruthy()
      expect(@scope.selectedAccount).toEqual(data)
      expect(@scope.breakMobNo).toHaveBeenCalledWith(data)
      expect(@scope.setOpeningBalanceDate).toHaveBeenCalled()
      expect(@scope.acntCase).toBe("Update")


  describe '#showBreadCrumbs', ->
    it 'should set showBreadCrumbs variable to true & set value in breadCrumbList', ->
      data = {"pName": ["n1", "n2", "n3"], "pUnqName": ["un1", "un2", "un3"]}
      @scope.showBreadCrumbs(data)
      expect(@scope.showBreadCrumb).toBeTruthy()
      expect(@scope.breadCrumbList).toEqual({"pName": ["n1", "n2", "n3"], "pUnqName": ["un1", "un2", "un3"]})

  describe '#isEmptyObject', ->
    it 'should return true if object is empty', ->
      data = {}
      result = @scope.isEmptyObject(data)
      expect(result).toBeTruthy()

    it 'should return false if object is not empty', ->
      data = {"name"}
      result = @scope.isEmptyObject(data)
      expect(result).toBeFalsy()

  describe '#selectAcMenu', ->
    it 'should set value for account menu variable', ->
      data = {"name"}
      @scope.selectAcMenu(data)
      expect(@scope.selectedAccntMenu).toBe(data)