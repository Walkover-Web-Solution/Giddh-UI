angular.module('inventoryController', [])
.controller('stockController', ['$scope','$rootScope','stockService','localStorageService','groupService' ,'toastr','$filter', '$state', 'localInventoryService', function($scope, $rootScope, stockService, localStorageService, groupService, toastr, $filter, $state, localInventoryService){
	
	var vm = this;
	vm.$state = $state

	if(_.isUndefined($rootScope.selectedCompany)){
    $rootScope.selectedCompany = localStorageService.get('_selectedCompany')
	}

	vm.addNewGroup = false
	vm.addStockForm = false
	vm.showSidebar = true
	vm.showStockReport = true
	vm.today = new Date()
	vm.fromDate = {date: new Date(moment().subtract(1, 'month').utc())}
	vm.toDate = {date: new Date()}
	vm.fromDatePickerIsOpen = false
	vm.toDatePickerIsOpen = false
	vm.format = "dd-MM-yyyy"
	vm.dateOptions = {
	    'year-format': "'yy'",
	    'starting-day': 1,
	    'showWeeks': false,
	    'show-button-bar': false,
	    'year-range': 1,
	    'todayBtn': false
	}

	vm.fromDatePickerOpen = function(e){
		vm.fromDatePickerIsOpen = true
		vm.toDatePickerIsOpen = false
		e.stopPropagation()
	}
    	
  	vm.toDatePickerOpen = function(e){
  		vm.fromDatePickerIsOpen = false
  		vm.toDatePickerIsOpen = true
  		e.stopPropagation()
  	}
    	
	vm.sideBarOn = function(e){
		e.stopPropagation();
		vm.showSidebar = true;
	}

	// vm.sideBarOff = function(){
	// 	vm.showSidebar = false
	// 	return false
	// }
	
	// get flattten stock groups
	vm.stockGroup = {}
	vm.stockGroup.list = [];
	vm.stockGroup.page = 1
	vm.stockGroup.count = 5
	vm.stockGroup.totalPages = null


	vm.getStockGroupsFlatten = function(query,page, call){
		this.success = function(res){
			if(vm.stockGroup.list.length < 1){
				vm.stockGroup.list = res.body.results;
			}
			else if(call == 'get'){
				angular.forEach(res.body.results, function(result){
					vm.stockGroup.list.push(result)
				})
			}
			else if(call == 'search'){
				vm.stockGroup.list = res.body.results;
			}
			vm.stockGroup.page = res.body.page
			vm.stockGroup.totalPages = res.body.totalPages
		},
		this.failure = function(res){
			toastr.error(res.data.message)
		}

		var reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
		reqParam.page = page
		reqParam.q = query || ''
		reqParam.count = vm.stockGroup.count
		stockService.getStockGroupsFlatten(reqParam).then(this.success, this.failure)
	}
	vm.getStockGroupsFlatten('', 1,'get');
	
	// get heirarchical stock groups
	vm.getHeirarchicalStockGroups = function(){
		
		function onSuccess(res){
			vm.groupListHr = res.body.results
		}

		function onFailure(res){
			toastr.error(res.data.message)
		}

		var reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName

		stockService.getStockGroupsHeirarchy(reqParam).then(onSuccess, onFailure)
	}

	vm.getHeirarchicalStockGroups()


	//close other stock groups on click 
	vm.closeOtherStockGroups = function(stockGroup, parent){
		_.each(vm.groupListHr, function(grp){
			if(grp.uniqueName != stockGroup.uniqueName && vm.parentGroupsList.indexOf(parent.uniqueName) == -1){
				grp.childStockGroups = []
			}
		})
	}

	//search stock groups
	vm.getStockGroupsByQuery = function(query){
		this.success = function(res){
			vm.groupListHr = res.body.results
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		if(query.length > 2){
			reqParam = {
				companyUniqueName: $rootScope.selectedCompany.uniqueName,
				q : query,
				page: 1,
				count: 0
			}
			stockService.getFilteredStockGroups(reqParam).then(this.success, this.failure)
		}
		else{
			vm.getHeirarchicalStockGroups()
		}
	}

	//get stock report
	vm.report = {
		page: 1
	}
	vm.getStockReport = function(stk, grp){
		vm.selectedReportStock = stk
		vm.selectedReportGrp = grp
		this.success = function(res){
			vm.report = res.body
			//vm.report.page = 
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: grp.uniqueName,
			stockUniqueName: stk.uniqueName,
			to:$filter('date')(vm.toDate.date, 'dd-MM-yyyy'),
			from:$filter('date')(vm.fromDate.date, 'dd-MM-yyyy'),
			page:vm.report.page
		}
		stockService.getStockReport(reqParam).then(this.success, this.failure)

	}


	vm.resetGroupStockForm = function(){
		vm.groupStockObj = angular.copy({})
		vm.updateStockGroup = angular.copy({})
	}

	vm.addGroup = function(){
		
		this.success = function(res){
			toastr.success('Group addedd successfully')
			vm.getHeirarchicalStockGroups()
			vm.resetGroupStockForm();
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName
		}

		if(vm.groupStockObj.isSelfParent){
			vm.groupStockObj.parentStockGroupUniqueName = '';
		}

		stockService.addGroup(reqParam, vm.groupStockObj).then(this.success, this.failure)
	}

	//update Stock group
	vm.updateGroup = function(){

		this.success = function(res){
			toastr.success('Updated successfully')
			vm.getHeirarchicalStockGroups()
			vm.loadStockGroup(res.body)
		}

		this.failure = function(res){
			toastr.error(res.data.message)
		}
		
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: $state.params.grpId
		}
		var a = vm.updateStockGroup
		var obj = {
			name: a.name,
			uniqueName: a.uniqueName,
			parentStockGroupUniqueName: a.parentStockGroupUniqueName
		}

		if(_.isNull(a.parentStockGroupUniqueName)){
			obj.parentStockGroupUniqueName = ''
		}

		stockService.updateStockGroup(reqParam, obj).then(this.success, this.failure)
	}

	//Add new stock
	vm.addStockItem = {}
	vm.addStockItem.newStock = true
	vm.addStock = function(stockItem){
		this.success = function(res){
			toastr.success('Stock Item added successfully')
			vm.selectedStockGrp.stocks.push(res.body)
			vm.getAllStocks()
			vm.addStockItem = {}
			$rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
		}
		this.failure = function(res){
			toastr.error(res.data.message || 'Something went Wrong, please check all input values')
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: vm.selectedStockGrp.uniqueName
		}
		stockItem.stockPurchaseAccount = stockItem.stockPurchaseAccount || {}
		stockItem.stockSalesAccount = stockItem.stockSalesAccount || {}
		var data = {
		    "name":stockItem.stockName,
		    "uniqueName":stockItem.stockUnqName,
		    "openingQuantity":stockItem.stockQty,
		    "openingAmount":stockItem.stockAmount,
		    "openingStockUnitName":stockItem.stockType.name,
		    "purchaseAccountUniqueName":stockItem.stockPurchaseAccount.uniqueName,
		    "purchaseRate":stockItem.stockPurchaseRate,
		    "salesRate":stockItem.stockSalesRate,
		    "salesAccountUniqueName":stockItem.stockSalesAccount.uniqueName,
		}
		stockService.createStock(reqParam, data).then(this.success, this.failure)
	}

	//update stock
	

	

	//load stock group
	vm.loadStockGroup = function(grp){
		$state.go('inventory.add-group', { grpId: grp.uniqueName })
		vm.getStockGroupDetail(grp.uniqueName)
		//vm.getStockGroups(grp)
	}

	// get stocks of selected group
	vm.selectedStockGrp = {}
	vm.getStockGroups = function(grp){
		vm.selectedStockGrp = grp
		this.success = function(res){
			vm.selectedStockGrp.childStockGroups = res.body
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: grp.uniqueName
		}

		stockService.getStockGroups(reqParam).then(this.success, this.failure)
	}

	// get all stocks
	vm.getAllStocks = function(query){
		this.success = function(res){
			vm.allStocks = res.body.results
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName
		}
		if(query && query.length > 1){
			reqParam.q = query
			reqParam.page = 1,
			reqParam.count = 0
		}
		stockService.getAllStocks(reqParam).then(this.success, this.failure)
	}
	vm.getAllStocks()

	//get stock detail
	vm.parentGroupsList = []
	vm.getStockGroupDetail = function(uName){
		this.success = function(res){
			vm.groupEditMode = true
			vm.updateStockGroup = angular.copy(res.body)
			if(!_.isNull(res.body.parentStockGroup)){
				vm.updateStockGroup.parentStockGroupUniqueName = res.body.parentStockGroup.uniqueName
			}
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: uName
		}

		stockService.getStockDetail(reqParam).then(this.success, this.failure)
	}


	//delete stock
	vm.deleteStock = function(stk){
		this.success= function(res){
			toastr.success(res.body)
			vm.getStockGroupDetail(vm.selectedStockGrp.uniqueName)
			vm.getAllStocks()
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		var stockGroupUniqueName;
		stk.stockGroup != undefined ? stockGroupUniqueName = stk.stockGroup.uniqueName : stockGroupUniqueName = vm.selectedStockGrp.uniqueName
		reqParam = {
			companyUniqueName : $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stockGroupUniqueName,
			stockUniqueName: stk.uniqueName
		}
		stockService.deleteStock(reqParam).then(this.success, this.failure)

	}

	// delete stock group
	vm.deleteStockGrp = function(){
		this.success = function(res){
			toastr.success(res.body)
			vm.getHeirarchicalStockGroups()
			$state.go('inventory', {});
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		reqParam = {
			companyUniqueName : $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: $state.params.grpId
		}

		stockService.deleteStockGrp(reqParam).then(this.success, this.failure)

	}

	

	// check whether to move selected stock grp to another
	vm.modificationState = "Modify"
	vm.setModificationState = function(grp){
		if(vm.selectedStockGrp.uniqueName != grp.uniqueName)
			vm.modificationState = "Modify and Move"
		else
			vm.modificationState = "Modify"
	}

	//func by dude
	//vm.Groupadd()
	vm.loadPage = function(page){
		var state = 'inventory.'+page
		if(page === 'add-group'){
			vm.groupEditMode =  false
			$state.go('inventory.add-group', { grpId: null });
		}
		else if(page === 'add-stock'){
			$state.go('inventory.add-group.add-stock', { stockId: null });
		}
		else{
			$state.go(state);
		}
	}

	vm.loadGroupStockItemDetails=function(item){
		$state.go('inventory.add-group.add-stock', { stockId: item.uniqueName });
	}

	//toggle views from report to manage
	vm.toggleViews = function(){
		// vm.showStockReport = !vm.showStockReport;
		vm.getHeirarchicalStockGroups();
	}

	// vm.toggleViews()
	// vm.Groupadd = function() {
	// 	vm.addNewGroup = true;
	// 	e.stopPropagation();
	// }

	// vm.AddNewStock = function() {
	// 	vm.addNewGroup = false;
	// 	vm.addNewStock = true;
	// 	e.stopPropagation();
	// }

	// to hide sidebar
	$(document).on('click', function(e){
		vm.showSidebar = false;
	});

	//set mode 
	if(!_.isEmpty($state.params) && angular.isDefined($state.params.grpId) && $state.params.grpId !== ''){
		vm.groupEditMode =  true
		vm.getStockGroupDetail($state.params.grpId)
	}
	else{
		vm.groupEditMode =  false
		//stock group obj init
		vm.groupStockObj = {
			isSelfParent: true
		}
	}


}])