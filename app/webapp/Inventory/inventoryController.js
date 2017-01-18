angular.module('inventoryController', [])

.controller('stockController', ['$scope','$rootScope','stockService','localStorageService','groupService' ,'toastr' ,function($scope, $rootScope, stockService, localStorageService,groupService, toastr){
	
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
			stock.addStockGroup = {}
			stock.updateStockGroup = {}
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
			toastr.success('Updated successfully')
			stock.getHeirarchicalStockGroups()
			stock.updateStockGroup = {}
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

	//Add new stock
	stock.addStock = function(stockItem){
		this.success = function(res){
			console.log(res)
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stock.selectedStockGrp.uniqueName
		}
		var data = {
		    "name":stockItem.stockName,
		    "openingQuantity":stockItem.stockQty,
		    "openingAmount":stockItem.stockAmount,
		    "openingStockUnitName":stockItem.stockType,
		    "purchaseAccountUniqueName":stockItem.stockPurchaseAccount.uniqueName,
		    "purchaseRate":stockItem.stockPurchaseRate,
		    "salesRate":stockItem.stockSalesRate,
		    "salesAccountUniqueName":stockItem.stockSalesAccount.uniqueName,
		}
		stockService.createStock(reqParam, data).then(this.success, this.failure)
	}


	//load stock group
	stock.loadStockGroup = function(grp){
		stock.updateStockGroup.stockName = grp.name
		stock.updateStockGroup.stockUnqName = grp.uniqueName
		stock.addStockGroup.parentStockGroupUniqueName = grp.uniqueName
		stock.selectedStockGrp = grp
		//stock.getStockGroups(grp)
	}

	// get stocks of selected group
	stock.getStockGroups = function(grp){
		stock.selectedStockGrp = grp
		this.success = function(res){
			console.log(res)
			stock.selectedStockGrp.childStockGroups = res.body
		}
		this.failure = function(res){
			console.log(res)
		}
		reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: grp.uniqueName
		}

		stockService.getStockGroups(reqParam).then(this.success, this.failure)
	}

	// get all stocks
	stock.getAllStocks = function(){
		this.success = function(res){
			console.log(res)
			stock.selectedStockGrp.childStockGroups = res.body
		}
		this.failure = function(res){
			console.log(res)
		}
		reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName
		}
		//stockService.getAllStocks(reqParam).then(this.success, this.failure)
	}
	stock.getAllStocks()


	//get purchase accounts
	stock.getPurchaseAccounts = function(query) {
	    var reqParam = {
	      companyUniqueName: $rootScope.selectedCompany.uniqueName,
	      q: query,
	      page: 1,
	      count: 0
	    }
	    var data = {
	      groupUniqueNames: [$rootScope.groupName.purchase]
	    }
	    return groupService.postFlatAccList(reqParam,data).then(
	      function(res){
	      	stock.purchaseAccounts = res.body.results 
	      },
	      function(res){
	      	return []
	      }  
	    )
	}

	//get sales accounts
	stock.getSalesAccounts = function(query) {
	    var reqParam = {
	      companyUniqueName: $rootScope.selectedCompany.uniqueName,
	      q: query,
	      page: 1,
	      count: 0
	    }
	    var data = {
	      groupUniqueNames: [$rootScope.groupName.sales]
	    }
	    return groupService.postFlatAccList(reqParam,data).then(
	      function(res){
	      	stock.salesAccounts = res.body.results 
	      },
	      function(res){
	      	return []
	      }  
	    )
	}

	// to hide sidebar
	$(document).on('click', function(e){
		stock.showSidebar = false;
	});

	return stock;

}])