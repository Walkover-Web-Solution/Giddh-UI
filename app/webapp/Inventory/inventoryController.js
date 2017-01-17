angular.module('inventoryController', [])

.controller('stockController', ['$scope','$rootScope','stockService','localStorageService', 'toastr' ,function($scope, $rootScope, stockService, localStorageService, toastr){
	
	var stock = this;
	if(_.isUndefined($rootScope.selectedCompany)){
    	$rootScope.selectedCompany = localStorageService.get('_selectedCompany')
	}
	stock.showSidebar = false
	stock.showStockReport = true

	stock.sideBarOn = function(e){
		stock.showSidebar = true;
		e.stopPropagation();
	}

	stock.sideBarOff = function(){
		stock.showSidebar = false
		return false
	}

	// get flattten stock groups
	stock.getStockGroups = function(){
		this.success = function(res){
			stock.stockList = res.body
		},
		this.failure = function(res){
			console.log(res)
		}

		var reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName

		stockService.getStockGroups(reqParam).then(this.success, this.failure)
	}
	stock.getStockGroups()

	// get heirarchical stock groups
	stock.getHeirarchicalStockGroups = function(){
		this.success = function(res){
			stock.groupListHr = res.body
		},
		this.failure = function(res){
			console.log(res)
		}

		var reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName

		stockService.getStockGroupsHeirarchy(reqParam).then(this.success, this.failure)
	}


	//toggle views from report to manage
	stock.toggleViews = function(){
		stock.showStockReport = !stock.showStockReport;
		stock.getHeirarchicalStockGroups();
	}


	//add stock group
	stock.addStockGroup = {}
	stock.addStockGroup.stockName = ''
	stock.addStockGroup.stockUnqName = ''
	stock.updateStockGroup = {}
	stock.updateStockGroup.stockName = ''
	stock.updateStockGroup.stockUnqName = ''
	stock.addGroup = function(obj){
		this.success = function(res){
			toastr.success('Group addedd successfully')
			stock.getHeirarchicalStockGroups()
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		var data = {
		    "name":obj.stockName,
		    "uniqueName":obj.stockUnqName,
		    "parentStockGroupUniqueName":obj.parentStockGroupUniqueName
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName
		}
		stockService.addGroup(reqParam, data).then(this.success, this.failure)
	}

	//update Stock group
	stock.updateGroup = function(obj){
		this.success = function(res){
			console.log(res)
		}
		this.failure = function(res){
			console.log(res)
		}
		var data = {
		    "name":obj.stockName,
		    "parentStockGroupUniqueName":obj.parentStockGroupUniqueName
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName:obj.stockUnqName
		}
		stockService.updateStockGroup(reqParam, data).then(this.success, this.failure)
	}

	//load stock group
	stock.loadStockGroup = function(grp){
		stock.updateStockGroup.stockName = grp.name
		stock.updateStockGroup.stockUnqName = grp.uniqueName
		stock.addStockGroup.parentStockGroupUniqueName = grp.uniqueName
	}


	// to hide sidebar
	$(document).on('click', function(e){
		stock.showSidebar = false;
	});

	return stock;

}])