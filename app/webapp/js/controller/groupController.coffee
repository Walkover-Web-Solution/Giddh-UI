'use strict'

groupController = ($scope, $rootScope, localStorageService, groupService, toastr, $filter) ->
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


  $scope.treeFilter = $filter('uiTreeFilter')
  # $scope.availableFields = [
  #   'name'
  #   'groups.name'
  # ]
  $scope.supportedFields = [
    'name'
    'name.groups.name'
  ]

  $scope.lista = [
    {
      id: 1
      name: '1. dragon-breath'
      description: 'lorem ipsum dolor sit amet'
      groups: []
    }
    {
      id: 2
      name: '2. moiré-vision'
      description: 'Ut tempus magna id nibh'
      groups: [
        {
          id: 21
          name: '2.1. tofu-animation'
          description: 'Sed nec diam laoreet, aliquam'
          groups: [
            {
              id: 211
              name: '2.1.1. spooky-giraffe'
              description: 'In vel imperdiet justo. Ut'
              groups: []
            }
            {
              id: 212
              name: '2.1.2. bubble-burst'
              description: 'Maecenas sodales a ante at'
              groups: []
            }
          ]
        }
        {
          id: 22
          name: '2.2. barehand-atomsplitting'
          description: 'Fusce ut tellus posuere sapien'
          groups: []
        }
      ]
    }
    {
      id: 3
      name: '3. unicorn-zapper'
      description: 'Integer ullamcorper nibh eu ipsum'
      groups: []
    }
    {
      id: 4
      name: '4. romantic-transclusion'
      description: 'Nulam luctus velit eget enim'
      groups: []
    }
  ]
  

  $scope.toggleSupport = (propertyName) ->
    if $scope.supportedFields.indexOf(propertyName) > -1 then $scope.supportedFields.splice($scope.supportedFields.indexOf(propertyName), 1) else $scope.supportedFields.push(propertyName)





#init angular app
angular.module('giddhWebApp').controller 'groupController', groupController