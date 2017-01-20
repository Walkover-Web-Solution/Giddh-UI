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
	stock.stockGroup = {}
	stock.stockGroup.list = []
	stock.stockGroup.page = 1
	stock.stockGroup.count = 2
	stock.stockGroup.totalPages = null
	stock.getStockGroupsFlatten = function(query,page){
		this.success = function(res){
			if(stock.stockGroup.list.length < 1){
				stock.stockGroup.list = res.body.results
			}else{
				stock.stockGroup.list.push(res.body.results)
			}
			stock.stockGroup.page = res.body.page
			stock.stockGroup.totalPages = res.body.totalPages
		},
		this.failure = function(res){
			toastr.error(res.data.message)
		}

		var reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
		reqParam.page = page
		reqParam.q = query || ''
		reqParam.count = stock.stockGroup.count
		stockService.getStockGroupsFlatten(reqParam).then(this.success, this.failure)
	}
	stock.getStockGroupsFlatten('', 1)

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
	stock.addStockItem = {}
	stock.addStock = function(stockItem){
		this.success = function(res){
			toastr.success('Stock Item added successfully')
			stock.selectedStockGrp.stocks.push(res.body)
			stock.getAllStocks()
			stock.addStockItem = {}
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stock.selectedStockGrp.uniqueName
		}
		stockItem.stockPurchaseAccount = stockItem.stockPurchaseAccount || {}
		stockItem.stockSalesAccount = stockItem.stockSalesAccount || {}
		var data = {
		    "name":stockItem.stockName,
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
	stock.updateStock = function(stockItem){
		this.success = function(res){
			_.each(stock.selectedStockGrp.stocks, function(stk, idx){
				if(stk.uniqueName == res.body.uniqueName){
					stock.selectedStockGrp.stocks[idx] = res.body
				}
			})
			toastr.success('Stock Updated successfully')
		}

		this.failure = function(res){
			toastr.error(res.data.message)
		}
		stockItem.stockPurchaseAccount = stockItem.stockPurchaseAccount || {}
		stockItem.stockSalesAccount = stockItem.stockSalesAccount || {}
		var data = {
			"name":stockItem.stockName,
		    "openingQuantity":stockItem.stockQty,
		    "openingAmount":stockItem.stockAmount,
		    "openingStockUnitName":stockItem.stockType.name,
		    "purchaseAccountUniqueName":stockItem.stockPurchaseAccount.uniqueName,
		    "purchaseRate":stockItem.stockPurchaseRate,
		    "salesRate":stockItem.stockSalesRate,
		    "salesAccountUniqueName":stockItem.stockSalesAccount.uniqueName
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stock.selectedStockGrp.uniqueName,
			stockUniqueName: stock.selectedStockItem.uniqueName
		}
		stockService.updateStockItem(reqParam, data).then(this.success, this.failure)

	}


	//load stock group
	stock.selectedStockGrp = {}
	stock.loadStockGroup = function(grp){
		stock.updateStockGroup.stockName = grp.name
		stock.updateStockGroup.stockUnqName = grp.uniqueName
		stock.addStockGroup.parentStockGroupUniqueName = grp.uniqueName
		stock.prevselectedStockGrp = stock.selectedStockGrp
		stock.selectedStockGrp = grp
		stock.getStockGroupDetail(grp)
		//stock.getStockGroups(grp)
	}

	// get stocks of selected group
	stock.getStockGroups = function(grp){
		stock.selectedStockGrp = grp
		this.success = function(res){
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
	stock.getAllStocks = function(query){
		this.success = function(res){
			stock.allStocks = res.body.results
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
	stock.getAllStocks()

	//get stock detail
	stock.parentGroupsList = []
	stock.getStockGroupDetail = function(stockGroup){
		this.success = function(res){
			stockGroup.stocks = res.body.stocks
			if(res.body.childStockGroups.length > 0 && stock.prevselectedStockGrp != undefined){
				stock.parentGroupsList.push(stockGroup.uniqueName)
			}else if(res.body.childStockGroups.length == 0 && stock.prevselectedStockGrp == undefined){
				stock.parentGroupsList = []
			}
			var parent = res.body.parentStockGroup || {}
			stock.closeOtherStockGroups(stockGroup, parent)
			stockGroup.childStockGroups = res.body.childStockGroups
			stock.selectedStockItem = null
			stock.addStockItem = {}
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stockGroup.uniqueName
		}
		stockService.getStockDetail(reqParam).then(this.success, this.failure)
	}


	//close other stock groups on click 
	stock.closeOtherStockGroups = function(stockGroup, parent){
		_.each(stock.groupListHr, function(grp){
			if(grp.uniqueName != stockGroup.uniqueName && stock.parentGroupsList.indexOf(parent.uniqueName) == -1){
				grp.childStockGroups = []
			}
		})
	}

	//search stock groups
	stock.getStockGroupsByQuery = function(query){
		this.success = function(res){
			stock.groupListHr = res.body.results
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
		}else{
			stock.getHeirarchicalStockGroups()
		}

	}

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

	//select stock
	stock.selectedStockItem = null
	stock.selectStock = function(stk){
		this.success = function(res){
			res.body.mappedPurchaseAccount = res.body.mappedPurchaseAccount || {}
			res.body.mappedSalesAccount = res.body.mappedSalesAccount || {}
			stock.selectedStockItem = res.body
			stock.addStockItem.stockName = stock.selectedStockItem.name
			stock.addStockItem.stockType = stock.selectedStockItem.openingStockUnit
			stock.addStockItem.stockQty = stock.selectedStockItem.openingQuantity
			stock.addStockItem.stockAmount = stock.selectedStockItem.openingAmount
			stock.addStockItem.stockPurchaseAccount = stock.selectedStockItem.mappedPurchaseAccount.name
			stock.addStockItem.stockPurchaseRate = stock.selectedStockItem.mappedPurchaseAccount.rate
			stock.addStockItem.stockSalesAccount = stock.selectedStockItem.mappedSalesAccount.name
			stock.addStockItem.stockSalesRate = stock.selectedStockItem.mappedSalesAccount.rate
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		reqParam = {
			companyUniqueName : $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stock.selectedStockGrp.uniqueName || stk.stockGroup.uniqueName,
			stockUniqueName: stk.uniqueName
		}
		stockService.getStock(reqParam).then(this.success, this.failure)
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

	// get stock unit types
	stock.getStockUnits = function(){
		this.success = function(res){
			stock.stockUnitTypes = res.body
		}

		this.failure = function(res){

		}

		var reqParam = {
	      companyUniqueName: $rootScope.selectedCompany.uniqueName
	    }
	    stockService.getStockUnits(reqParam).then(this.success, this.failure)
	}
	stock.getStockUnits()


	// to hide sidebar
	$(document).on('click', function(e){
		stock.showSidebar = false;
	});

	return stock;

}])