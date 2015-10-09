'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr) ->
  $scope.groupList = {}
  $scope.selectedGroup = {}
  $scope.selectedSubGroup = {}

  $scope.showGroupDetails = false

  $scope.subGroupVisible = false

  $scope.showListGroupsNow = false

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
    $scope.groupList = result.body
    $scope.showListGroupsNow = true

  $scope.getGroupListFailure = () ->
    toastr.error("Unable to get group details.", "Error")

  $scope.selectGroupToEdit = (group) ->
    $scope.selectedGroup = group
    $scope.showGroupDetails = true


  $scope.updateGroup = ->
    groupService.update($rootScope.selectedCompany.uniqueName, $scope.selectedGroup).then(onUpdateGroupSuccess,
        onUpdateGroupFailure)

  onUpdateGroupSuccess = (result) ->
    toastr.success("Group has been updated successfully.", "Success")

  onUpdateGroupFailure = (result) ->
    toastr.error("Unable to update group at the moment. Please try again later.", "Error")

  $scope.addNewSubGroup = ->
    if _.isEmpty($scope.selectedSubGroup.name)
      return
    body = {
      "name": $scope.selectedSubGroup.name,
      "uniqueName": "",
      "parentGroupUniqueName": $scope.selectedGroup.uniqueName,
      "description": $scope.selectedSubGroup.desc
    }
    groupService.create($rootScope.selectedCompany.uniqueName, body).then(onCreateGroupSuccess, onCreateGroupFailure)

  onCreateGroupSuccess = (result) ->
    toastr.success("Sub group added successfully", "Success")
    $scope.selectedSubGroup = {}
    $scope.getGroups()

  onCreateGroupFailure = (result) ->
    toastr.error("Unable to create subgroup.", "Error")

#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController