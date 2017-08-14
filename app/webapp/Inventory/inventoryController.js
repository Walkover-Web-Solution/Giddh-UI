angular.module('inventoryController', [])
.controller('stockController', ['$scope','$rootScope','stockService','localStorageService','groupService' ,'toastr','$filter', '$state',  function($scope, $rootScope, stockService, localStorageService, groupService, toastr, $filter, $state ){
	
	var vm = this;
	vm.$state = $state

	if(_.isUndefined($rootScope.selectedCompany)){
    $rootScope.selectedCompany = localStorageService.get('_selectedCompany')
	}

	vm.addNewGroup = false
	vm.addStockForm = false
	vm.showSidebar = true
    	
	vm.sideBarOn = function(e){
		e.stopPropagation();
		vm.showSidebar = true;
	}
	
	// get flattten stock groups
	vm.stockGroup = {}
	vm.stockGroup.list = [];
	vm.stockGroup.page = 1
	vm.stockGroup.count = 5
	vm.stockGroup.totalPages = null


	vm.getStockGroupsFlatten = function(query,page, call){
		this.success = function(res){
			/*
			@dude: don't know why this condition that's why commented
			if(vm.stockGroup.list.length < 1){
				vm.stockGroup.list = res.body.results;
			}
			else if(call == 'get'){
				angular.forEach(res.body.results, function(result){
					vm.stockGroup.list.push(result)
				})
			}
			if(call == 'search'){
				vm.stockGroup.list = res.body.results;
			}
			*/
			vm.stockGroup.list = res.body.results;
			vm.stockGroup.page = res.body.page
			vm.stockGroup.totalPages = res.body.totalPages
		},
		this.failure = function(res){
			toastr.error(res.data.message)
		}

		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			page: page,
			q: query || '',
			count: ''
		}
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

	vm.resetParentSelectBox = function(){
		if (vm.groupStockObj.isSelfParent)
			vm.groupStockObj.parentStockGroupUniqueName = null
	}
	vm.resetParentSelectBoxUpdt = function(){
		if (vm.updateStockGroup.isSelfParent)
			vm.updateStockGroup.parent = null
	}

	vm.resetGroupStockForm = function(){
		vm.groupStockObj = angular.copy({})
		vm.updateStockGroup = angular.copy({})
	}

	vm.addGroup = function(){
		this.success = function(res){
			toastr.success('Group addedd successfully');
			vm.getHeirarchicalStockGroups();
			vm.getStockGroupsFlatten('', 1,'get');
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
			vm.getStockGroupsFlatten('', 1,'get')
			vm.loadStockGroup(res.body)
		}

		this.failure = function(res){
			toastr.error(res.data.message)
		}
		
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: $state.params.grpId
		}
		var a = angular.copy(vm.updateStockGroup)
		var obj = {
			name: a.name,
			uniqueName: a.uniqueName,
			parentStockGroupUniqueName: a.parent
		}

		if(!a.parent){
			obj.parentStockGroupUniqueName = ''
		}

		stockService.updateStockGroup(reqParam, obj).then(this.success, this.failure)
	}

	//load stock group
	vm.loadStockGroup = function(grp){
		$state.go('inventory.add-group', { grpId: grp.uniqueName })
		vm.getStockGroupDetail(grp.uniqueName)
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
		vm.updateStockGroup = angular.copy({})
		this.success = function(res){
			vm.groupEditMode = true
			vm.updateStockGroup = res.body
			if(res.body.parentStockGroup){
				vm.updateStockGroup.parent = res.body.parentStockGroup.uniqueName
			}
			else{
				vm.updateStockGroup.parent = null
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

	// delete stock group
	vm.deleteStockGrp = function(){
		this.success = function(res){
			toastr.success(res.body)
			// vm.getHeirarchicalStockGroups()
			// vm.getStockGroupsFlatten('', 1,'get')
			$state.go('inventory', {}, {reload: true, notify: true});
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
			$state.go('inventory.add-group.add-stock', { stockId: null }, {notify: true, reload:true});
		}
		else{
			vm.groupEditMode =  false
			$state.go(state);
		}
	}

	vm.loadGroupStockItemDetails=function(item){
		$state.go('inventory.add-group.add-stock', { stockId: item.uniqueName });
	}

	vm.loadStockReportView=function(item){
		$state.go('inventory.add-group.stock-report', { stockId: item.uniqueName });
	}

	//toggle views from report to manage
	vm.toggleViews = function(){
		vm.getHeirarchicalStockGroups();
	}


	// to hide sidebar
	$(document).on('click', function(e){
		vm.showSidebar = false;
	});

	//set mode 
	vm.groupEditMode = false
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

	//reload when company changed
	$rootScope.$on('company-changed' , function(e, data){
		if (!_.isUndefined(data.index)){
    		$state.go('inventory', {}, {reload: true, notify: true});
		}
		vm.getStockGroupsFlatten('', 1,'get');
  	});
		

}])