angular.module('inventoryController', [])

.controller('stockController', ['$scope','$rootScope','stockService','localStorageService' ,function($scope, $rootScope, stockService, localStorageService){
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

	stock.stockList = [
		{
			name: 'Stock 1'
		},
		{
			name: 'Stock 1'
		},
		{
			name: 'Stock 1'
		},
		{
			name: 'Stock 1'
		}

	] 

	// get flattten stock groups
	stock.getStockGroups = function(){
		this.success = function(res){
			console.log(res)
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
			console.log(res)
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
	stock.addGroup = function(obj, form){
		this.success = function(res){
			console.log(res)
		}
		this.failure = function(res){
			console.log(res)
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

	// to hide sidebar
	$(document).on('click', function(e){
		stock.showSidebar = false;
	});

	return stock;

}])