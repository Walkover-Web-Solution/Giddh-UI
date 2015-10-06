'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr) ->
  $scope.groupList = {}
  $scope.selectedGroup = {}
  $scope.selectedSubGroup = {}

  $scope.showGroupDetails = false

  $scope.subGroupVisible = false

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
    console.log result.body
    $scope.groupList = result.body

  $scope.getGroupListFailure = () ->
    toastr.error("Unable to get group details.", "Error")

  $scope.selectGroupToEdit = (group) ->
    $scope.selectedGroup = group
    console.log $scope.selectedGroup
    $scope.showGroupDetails = true

  $scope.selectSubgroupToEdit = (sGroup) ->
    $scope.selectedGroup = sGroup
    console.log $scope.selectedGroup
    $scope.showGroupDetails = true

  $scope.updateGroup = ->
    groupService.update($rootScope.selectedCompany.uniqueName, $scope.selectedGroup).then(onUpdateGroupSuccess,
        onUpdateGroupFailure)

  onUpdateGroupSuccess = (result) ->
    toastr.success("Group has been updated successfully.", "Success")

  onUpdateGroupFailure = (result) ->
    toastr.error("Unable to update group at the moment. Please try again later.", "Error")

  $scope.addNewSubGroup = (subGroupForm) ->
    if _.isEmpty($scope.selectedSubGroup.name)
      return
    body = {
      "name": $scope.selectedSubGroup.name,
      "uniqueName": "group",
      "parentGroupUniqueName": $scope.selectedGroup.uniqueName
    }
    groupService.create($rootScope.selectedCompany.uniqueName, body).then(onCreateGroupSuccess, onCreateGroupFailure)

  onCreateGroupSuccess = (result) ->
    toastr.success("Sub group added successfully", "Success")
    $scope.selectedSubGroup = {}
    $scope.getGroups()

  onCreateGroupFailure = (result) ->
    toastr.error("Unable to create subgroup.", "Error")


  

  $scope.lista = [
    {
      id: 1
      name: 'Fixed Assets'
      uniqueName: "fixed_assets"
      description: 'lorem ipsum dolor sit amet'
      groups: [
        {
          "accounts": [],
          "uniqueName": "sarfa",
          "description": "null",
          "role": "null",
          "groups": [],
          "name": "sarfa"
        },
        {
          "accounts": [],
          "uniqueName": "sarfara",
          "description": "null",
          "role": "null",
          "groups": [],
          "name": "sarfara"
        },
        {
          "accounts": [],
          "uniqueName": "sarfar",
          "description": "null",
          "role": "null",
          "groups": [],
          "name": "sarfar"
        },
        {
          "accounts": [],
          "uniqueName": "sara",
          "description": "null",
          "role": "null",
          "groups": [],
          "name": "sara"
        },
        {
          "accounts": [],
          "uniqueName": "saraf",
          "description": "null",
          "role": "null",
          "groups": [],
          "name": "saraf"
        },
        {
          "accounts": [],
          "uniqueName": "sarfaraz",
          "description": "null",
          "role": "null",
          "groups": [],
          "name": "sarfaraz"
        },
        {
          "accounts": [],
          "uniqueName": "sarf",
          "description": "null",
          "role": "null",
          "groups": [],
          "name": "sarf"
        }
      ]
    }
    {
      id: 2
      name: 'moiré-vision'
      description: 'Ut tempus magna id nibh'
      groups: [
        {
          id: 21
          name: 'tofu-animation'
          description: 'Sed nec diam laoreet, aliquam'
          groups: [
            {
              id: 211
              name: 'spooky-giraffe'
              description: 'In vel imperdiet justo. Ut'
              groups: []
            }
            {
              id: 212
              name: 'bubble-burst'
              description: 'Maecenas sodales a ante at'
              groups: []
            }
          ]
        }
        {
          id: 22
          name: 'barehand-atomsplitting'
          description: 'Fusce ut tellus posuere sapien'
          groups: []
        }
      ]
    }
    {
      id: 3
      name: 'unicorn-zapper'
      description: 'Integer ullamcorper nibh eu ipsum'
      groups: []
    }
    {
      id: 4
      name: 'romantic-transclusion'
      description: 'Nulam luctus velit eget enim'
      groups: []
    }
  ]
  

  





#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController