"use strict"
inventoryCustomStockController = ($scope, $rootScope, $timeout, toastr, localStorageService, stockService, $state) ->
  
  vm = this
  vm.editMode = false
  $rootScope.selectedCompany = {}
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

  #getStockUnits
  vm.getStockUnits = () ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
    }
    stockService.getStockUnits(reqParam).then(vm.getStockUnitsSuccess,vm.getStockUnitsFailure)

  vm.getStockUnitsSuccess = (res) ->
    console.log(res.body, "unitTypes")
    vm.unitTypes = res.body

  vm.getStockUnitsFailure = (res) ->
    toastr.error(res.data.message)

  vm.clearCustomUnitStock =()->
    vm.customUnitObj = angular.copy({})

  vm.addCustomUnitStock = ()->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
    }
    stockService.createStockUnit(reqParam, vm.customUnitObj).then(vm.createStockUnitSuccess,vm.getStockUnitsFailure)

  vm.createStockUnitSuccess = (res) ->
    vm.unitTypes.push(res.body)

  vm.updateCustomUnitStock = ()->
    console.log(vm.customUnitObj, "addCustomUnitStock")
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
    }
    stockService.updateStockUnit(reqParam, vm.customUnitObj).then(vm.updateStockUnitSuccess,vm.getStockUnitsFailure)

  vm.updateStockUnitSuccess = (res) ->
    console.log(res.body, "updateStockUnitSuccess")

  vm.deleteCustomUnitStock = ()->
    console.log(vm.customUnitObj, "addCustomUnitStock")
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
    }
    stockService.deleteStockUnit(reqParam, vm.customUnitObj).then(vm.deleteStockUnitSuccess,vm.getStockUnitsFailure)

  vm.deleteStockUnitSuccess = (res) ->
    console.log(res.body, "updateStockUnitSuccess")

  vm.cancelEditMode=()->
    vm.editMode = false
    vm.customUnitObj = angular.copy({})

  vm.editUnit=(item)->
    console.log("ingo", item)
    vm.editMode = true
    #vm.customUnitObj = angular.copy(item)


  # init func on dom ready
  $timeout(->

    #get stocks
    vm.getStockUnits()

  ,10)
  
  return vm

giddh.webApp.controller 'inventoryCustomStockController', inventoryCustomStockController