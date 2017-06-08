"use strict"
inventoryStockReportController = ($scope, $rootScope, $timeout, toastr, stockService, $state, $filter) ->
  
  vm = this

  vm.selectedStock = {}

  vm.stockId = $state.params.stockId;
  if (_.isUndefined($rootScope.selectedCompany))
    $rootScope.selectedCompany = localStorageService.get('_selectedCompany')
  
  vm.today = new Date()
  vm.fromDatePickerIsOpen = false
  vm.toDatePickerIsOpen = false
  vm.format = "dd-MM-yyyy"
  vm.dateOptions=
    'year-format': "'yy'"
    'starting-day': 1
    'showWeeks': false
    'show-button-bar': false
    'year-range': 1
    'todayBtn': false

  vm.report=
    page: 0

  vm.fromDate=
    date:new Date(moment().subtract(1, 'month').utc())

  vm.toDate =
    date: new Date()

  vm.findAndSet=()->
    vm.selectedStock = _.find(vm.stockArr, (item)->
      return item.uniqueName is vm.stockId
    )

  vm.setStockArr=()->
    vm.stockArr = $scope.$parent.stock.updateStockGroup.stocks
    if angular.isUndefined(vm.stockArr)
      $timeout(()->
        vm.stockArr = $scope.$parent.stock.updateStockGroup.stocks
        vm.findAndSet()
      ,1500)
    else
      vm.findAndSet()

  vm.fromDatePickerOpen = (e)->
    vm.fromDatePickerIsOpen = true
    vm.toDatePickerIsOpen = false
    e.stopPropagation()
      
  vm.toDatePickerOpen = (e)->
    vm.fromDatePickerIsOpen = false
    vm.toDatePickerIsOpen = true
    e.stopPropagation()

  vm.onFailure = (res) ->
    toastr.error(res.data.message)

  vm.getStockReportSuccess=(res)->
    vm.report = res.body

  vm.getStockReport=()->
    reqParam=
      companyUniqueName: $rootScope.selectedCompany.uniqueName,
      stockGroupUniqueName: $state.params.grpId,
      stockUniqueName: $state.params.stockId,
      to:$filter('date')(vm.toDate.date, 'dd-MM-yyyy'),
      from:$filter('date')(vm.fromDate.date, 'dd-MM-yyyy'),
      page:vm.report.page,
      count: 10

    stockService.getStockReport(reqParam).then(vm.getStockReportSuccess, vm.onFailure)

  vm.goToManageStock=()->
    $state.go('inventory.add-group.add-stock', { stockId: $state.params.stockId});

  # init func on dom ready
  $timeout(->
    if _.isEmpty($state.params.stockId)
      $state.go('inventory', {}, {reload: true, notify: true})
    else
      vm.getStockReport()
      vm.setStockArr()
  ,100)
  
  return vm

giddh.webApp.controller 'inventoryStockReportController', inventoryStockReportController