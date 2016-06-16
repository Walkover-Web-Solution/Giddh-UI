# 'use strict'

# describe 'mainController', ->
#   beforeEach module('giddhWebApp')

#   beforeEach inject ($rootScope, $controller, localStorageService, toastr, groupService, $q, $uibModal, roleServices, permissionService) ->
#     @scope = $rootScope.$new()
#     @rootScope = $rootScope
#     @roleServices = roleServices
#     @localStorageService = localStorageService
#     @toastr = toastr
#     @uibModal = $uibModal
#     @permissionService = permissionService
#     @q = $q
#     @mainController = $controller('mainController',
#         {
#           $scope: @scope,
#           $rootScope: @rootScope,
#           localStorageService: @localStorageService
#           permissionService: @permissionService
#           roleServices: @roleServices
#         })

#   describe '#getRoles', ->
#     it 'should call service method to fetch roles', ->
#       deferred = @q.defer()
#       spyOn(@roleServices, 'getAll').andReturn(deferred.promise)
#       @scope.getRoles()
#       expect(@roleServices.getAll).toHaveBeenCalled()

#   describe '#onGetRolesSuccess', ->
#     it 'should call service method to fetch roles', ->
#       spyOn(@localStorageService, 'set')
#       @scope.onGetRolesSuccess({body: [{name: 'admin'}]})
#       expect(@localStorageService.set).toHaveBeenCalledWith('_roles', [{name: 'admin'}])

#   describe '#onGetRolesFailure', ->
#     it 'should show toastr with error message', ->
#       spyOn(@toastr, 'error')
#       @scope.onGetRolesFailure()
#       expect(@toastr.error).toHaveBeenCalledWith("Something went wrong while fetching role", "Error")

#   describe '#checkPermissions', ->
#     it 'should call permission service hasPermissionOn method and set value true to canUpdate variable', ->
#       data = {role: {permissions: [{code: "UPDT"}]}}
#       spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
#       @scope.checkPermissions(data)
#       expect(@scope.canUpdate).toBeTruthy()
#       expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "UPDT")

#     it 'should call permission service hasPermissionOn method and set value true to canAdd variable', ->
#       data = {role: {permissions: [{code: "ADD"}]}}
#       spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
#       @scope.checkPermissions(data)
#       expect(@scope.canAdd).toBeTruthy()
#       expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "ADD")

#     it 'should call permission service hasPermissionOn method and set value true to canDelete variable', ->
#       data = {role: {permissions: [{code: "DLT"}]}}
#       spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
#       @scope.checkPermissions(data)
#       expect(@scope.canDelete).toBeTruthy()
#       expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "DLT")

#     it 'should call permission service hasPermissionOn method and set value true to canDelete variable', ->
#       data = {role: {permissions: [{code: "SHR"}]}}
#       spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
#       @scope.checkPermissions(data)
#       expect(@scope.canShare).toBeTruthy()
#       expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "SHR")

#     it 'should call permission service hasPermissionOn method and set value true to canDelete variable', ->
#       data = {role: {permissions: [{code: "MNG_CMPNY"}]}}
#       spyOn(@permissionService, 'hasPermissionOn').andReturn(true)
#       @scope.checkPermissions(data)
#       expect(@scope.canManageCompany).toBeTruthy()
#       expect(@permissionService.hasPermissionOn).toHaveBeenCalledWith(data, "MNG_CMPNY")

#   describe '#validateEmail', ->
#       it 'should validate string and return true if string is valid email id', ->
#         result =  @scope.validateEmail("abc@xyz.com")
#         expect(result).toBeTruthy()
#       it 'should return false if string is not valid email id', ->
#         result =  @scope.validateEmail("abc@x")
#         expect(result).toBeFalsy()
