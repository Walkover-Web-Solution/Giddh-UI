"use strict"
inventoryAddStockController = ($scope, $rootScope, $timeout, toastr, localStorageService, stockService, $state, groupService) ->
  
  vm = this
  vm.editMode = false
  
  vm.purchaseAccounts = []
  vm.salesAccounts = []
  vm.customUnits = []
  vm.mfsCmbItem = {}
  $rootScope.selectedCompany = {}
  $rootScope.selectedCompany = localStorageService.get("_selectedCompany")

  # init arr obj
  vm.initAcDetailsObj=()->
    return {
      rate: undefined,
      stockUnitCode: undefined
    }

  # init stock obj
  vm.initStockObj =()->
    vm.addStockObj = {
      purchaseAccountDetails:{
        unitRates: []
      },
      salesAccountDetails:{
        unitRates: []
      }
      manufacturingDetails:{
        linkedStocks: []
      }
    }
    vm.addStockObj.purchaseAccountDetails.unitRates.push(vm.initAcDetailsObj())
    vm.addStockObj.salesAccountDetails.unitRates.push(vm.initAcDetailsObj())

  # clear stock form
  vm.clearAddEditStockForm =()->
    vm.initStockObj()

  #getPurchaseAccounts
  vm.getPurchaseAccounts = (query) ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName,
      q: query,
      page: 1,
      count: 0
    }
    data = {
      groupUniqueNames: [$rootScope.groupName.purchase]
    }
    groupService.postFlatAccList(reqParam,data).then(vm.getPurchaseAccountsSuccess,vm.onFailure)

  vm.getPurchaseAccountsSuccess = (res) ->
    vm.purchaseAccounts = res.body.results

  vm.onFailure = (res) ->
    toastr.error(res.data.message)


  #getSalesAccounts
  vm.getSalesAccounts = (query) ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName,
      q: query,
      page: 1,
      count: 0
    }
    data = {
      groupUniqueNames: [$rootScope.groupName.sales]
    }
    groupService.postFlatAccList(reqParam,data).then(vm.getSalesAccountsSuccess,vm.onFailure)

  vm.getSalesAccountsSuccess = (res) ->
    vm.salesAccounts = res.body.results

  #getStockUnits
  vm.getStockUnits = () ->
    reqParam = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
    }
    stockService.getStockUnits(reqParam).then(vm.getStockUnitsSuccess,vm.onFailure)

  vm.getStockUnitsSuccess = (res) ->
    if res.body.length
      _.each(res.body, (o)->
        vm.customUnits.push(_.pick(o, 'code', 'name'))
      )

  vm.checkPrevItem=(o)->
    return if (_.isEmpty(o.stockUnitCode) || _.isEmpty(o.rate)) && (_.isUndefined(o.stockUnitCode) || _.isUndefined(o.rate)) then false else true

  vm.addUnitItem=(item, arrayType)->
    if vm.checkPrevItem(item)
      if arrayType is 'pArr'
        vm.addStockObj.purchaseAccountDetails.unitRates.push(vm.initAcDetailsObj())
      else if arrayType is 'sArr'
        vm.addStockObj.salesAccountDetails.unitRates.push(vm.initAcDetailsObj())


  vm.removeUnitItem=(item, arrayType)->
    if arrayType is 'pArr'
      vm.addStockObj.purchaseAccountDetails.unitRates = _.reject(vm.addStockObj.purchaseAccountDetails.unitRates, (o)-> 
        return o is item
      )
    else if arrayType is 'sArr'
      vm.addStockObj.salesAccountDetails.unitRates = _.reject(vm.addStockObj.salesAccountDetails.unitRates, (o)-> 
        return o is item
      )

  vm.addStock = () ->
    
    @success = (res) ->
      toastr.success 'Stock Item added successfully'
      _.extend(vm.addStockObj, res.body)
      # getting list from parent controller
      $scope.$parent.stock.getHeirarchicalStockGroups()
      $scope.$parent.stock.getStockGroupDetail($state.params.grpId)
      

    @failure = (res) ->
      toastr.error res.data.message or 'Something went Wrong, please check all input values'

    reqParam = 
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      stockGroupUniqueName: $state.params.grpId
    
    stockService.createStock(reqParam, vm.addStockObj).then @success, @failure

  vm.updateStock = () ->
    console.log vm.addStockObj


  # get stock Item details
  vm.getStockItemDetails=(uName)->
    reqParam=
      companyUniqueName: $rootScope.selectedCompany.uniqueName,
      stockGroupUniqueName: $state.params.grpId
      stockUniqueName: uName
    stockService.getStockItemDetails(reqParam).then(vm.getStockItemDetailsSuccess, vm.onFailure)


  vm.getStockItemDetailsSuccess=(res)->
    console.log(res.body, "getStockItemDetailsSuccess")
    vm.addStockObj = res.body

  # addMfsCmbItem itesm
  vm.addMfsCmbItem=()->
    if (!vm.mfsCmbItem.quantity || !vm.mfsCmbItem.stockUniqueName || !vm.mfsCmbItem.stockUnitCode)
      vm.mfsCmbItemErrMsg = "All fields are required to add Item"
      return false
    else
      vm.mfsCmbItemErrMsg = undefined
      o = _.clone(vm.mfsCmbItem)
      try
        vm.addStockObj.manufacturingDetails.linkedStocks.push(o)
      catch e
        vm.addStockObj.manufacturingDetails ={
          linkedStocks: []
        }
        vm.addStockObj.manufacturingDetails.linkedStocks.push(o)

      vm.mfsCmbItem = angular.copy({})

  vm.editMfsCmbItem=(item, idx)->
    item.idx = idx
    item.hasIdx = true
    vm.mfsCmbItem = angular.copy(item)
    console.log("after:", vm.mfsCmbItem)

  vm.deleteMfsCmbItem=(item)->
    vm.addStockObj.manufacturingDetails.linkedStocks = _.reject(vm.addStockObj.manufacturingDetails.linkedStocks, (o)->
      return _.isEqual(o, item)
    )

  vm.updateMfsCmbItem=()->
    if (!vm.mfsCmbItem.quantity || !vm.mfsCmbItem.stockUniqueName || !vm.mfsCmbItem.stockUnitCode)
      vm.mfsCmbItemErrMsg = "All fields are required to add Item"
      return false
    else
      vm.mfsCmbItemErrMsg = undefined
      o = _.clone(vm.mfsCmbItem)
      vm.addStockObj.manufacturingDetails.linkedStocks.splice(o.idx, 1, o)
      vm.mfsCmbItem = angular.copy({})

  # init func on dom ready
  $timeout(->
    if(!_.isEmpty($state.params) && angular.isDefined($state.params.stockId) && $state.params.stockId isnt '')
      vm.stockEditMode =  true
      vm.getStockItemDetails($state.params.stockId)
    else
      vm.stockEditMode =  false
      vm.initStockObj()
    

    vm.getStockUnits()
  ,100)
  
  return vm

giddh.webApp.controller 'inventoryAddStockController', inventoryAddStockController