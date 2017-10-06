"use strict"
inventoryCustomStockController = ($scope, $rootScope, $timeout, toastr, localStorageService, stockService, $state) ->
  
  vm = this
  vm.editMode = false
  $rootScope.selectedCompany = {}
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")
  
  if $rootScope.selectedCompany.country
    vm.country = $rootScope.selectedCompany.country.toLocaleLowerCase()
  else
    vm.country = 'india' 



  #getStockUnits
  vm.getStockUnits = () ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
    }
    stockService.getStockUnits(reqParam).then(vm.getStockUnitsSuccess,vm.getStockUnitsFailure)

  vm.getStockUnitsSuccess = (res) ->
    vm.unitTypes = res.body
    vm.makeUnits()

  vm.getStockUnitsFailure = (res) ->
    toastr.error(res.data.message)

  vm.clearCustomUnitStock =()->
    vm.customUnitObj = angular.copy({})
    vm.customUnitObj.parentStockUnit = null

  vm.addCustomUnitStock = ()->
    if vm.customUnitObj.nameObj
      delete vm.customUnitObj.nameObj
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
    }
    stockService.createStockUnit(reqParam, vm.customUnitObj).then(vm.createStockUnitSuccess,vm.getStockUnitsFailure)

  vm.createStockUnitSuccess = (res) ->
    vm.clearCustomUnitStock()
    vm.unitTypes.push(res.body)
    vm.makeUnits()

  vm.updateCustomUnitStock = ()->
    if vm.customUnitObj.nameObj
      delete vm.customUnitObj.nameObj
    reqParam=
      companyUniqueName: $rootScope.selectedCompany.uniqueName
    stockService.updateStockUnit(reqParam, vm.customUnitObj).then(vm.updateStockUnitSuccess,vm.getStockUnitsFailure)

  vm.updateStockUnitSuccess = (res) ->
    vm.unitTypes.splice(vm.customUnitObj.idx, 1, res.body)
    # vm.unitTypes = _.reject(vm.unitTypes, (o)->
    #   return o.code is res.body.code
    # )
    # vm.unitTypes.push(res.body)
    vm.makeUnits()
    vm.cancelEditMode()

  vm.deleteCustomUnitStock = (item)->
    vm.tempDelItem = item
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName,
      uName: item.code
    }
    stockService.deleteStockUnit(reqParam).then(vm.deleteStockUnitSuccess,vm.getStockUnitsFailure)

  vm.deleteStockUnitSuccess = (res) ->
    toastr.success(res.body, res.status)
    vm.unitTypes = _.reject(vm.unitTypes, (o)->
      return o.code is vm.tempDelItem.code
    )
    vm.tempDelItem = undefined
    vm.makeUnits()

  vm.cancelEditMode=()->
    vm.editMode = false
    vm.customUnitObj = angular.copy({})

  vm.editUnit=(item, idx)->
    vm.editMode = true
    vm.customUnitObj = angular.copy(item)
    vm.customUnitObj.uName = _.clone(item.code)
    vm.customUnitObj.idx = idx
    vm.customUnitObj.nameObj = {
      text: vm.customUnitObj.name
      id: vm.customUnitObj.code
    }

  vm.makeUnits = () ->
    vm.customUnits = []
    arr = _.clone(vm.unitTypes)
    _.each(arr, (o)->
      vm.customUnits.push(_.pick(o, 'code', 'name'))
    )

  vm.getStockName = () ->
    vm.stockNameList = stockService.getStockUnit()

  vm.setUnitName = (item) ->
    if item.id
      vm.customUnitObj.code = item.id
      vm.customUnitObj.name = item.text

  vm.getStockName()


  # init func on dom ready
  $timeout(->
    #get stocks
    vm.getStockUnits()
  ,10)
  
  return vm

giddh.webApp.controller 'inventoryCustomStockController', inventoryCustomStockController