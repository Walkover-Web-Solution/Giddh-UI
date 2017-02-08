angular.module('inventoryController', [])

.controller('stockController', ['$scope','$rootScope','stockService','localStorageService','groupService' ,'toastr','$filter' ,function($scope, $rootScope, stockService, localStorageService,groupService, toastr, $filter){
	
	var stock = this;
	if(_.isUndefined($rootScope.selectedCompany)){
    	$rootScope.selectedCompany = localStorageService.get('_selectedCompany')
	}

	stock.showSidebar = true
	stock.showStockReport = true
	stock.today = new Date()
	stock.fromDate = {date: new Date(moment().subtract(1, 'month').utc())}
	stock.toDate = {date: new Date()}
	stock.fromDatePickerIsOpen = false
	stock.toDatePickerIsOpen = false
	stock.format = "dd-MM-yyyy"
	stock.dateOptions = {
	    'year-format': "'yy'",
	    'starting-day': 1,
	    'showWeeks': false,
	    'show-button-bar': false,
	    'year-range': 1,
	    'todayBtn': false
	}

	stock.fromDatePickerOpen = function(e){
		stock.fromDatePickerIsOpen = true
		stock.toDatePickerIsOpen = false
		e.stopPropagation()
	}
    	
  	stock.toDatePickerOpen = function(e){
  		stock.fromDatePickerIsOpen = false
  		stock.toDatePickerIsOpen = true
  		e.stopPropagation()
  	}
    	
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
	stock.stockGroup.count = 5
	stock.stockGroup.totalPages = null
	stock.getStockGroupsFlatten = function(query,page, call){
		this.success = function(res){
			if(stock.stockGroup.list.length < 1){
				stock.stockGroup.list = res.body.results
			}else if(call == 'get'){
				angular.forEach(res.body.results, function(result){
					stock.stockGroup.list.push(result)
				})
			}else if(call == 'search'){
				stock.stockGroup.list = res.body.results
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
	stock.getStockGroupsFlatten('', 1,'get')

	// get heirarchical stock groups
	stock.getHeirarchicalStockGroups = function(){
		this.success = function(res){
			stock.groupListHr = res.body
		},
		this.failure = function(res){
			toastr.error(res.data.message)
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

	//get stock report
	stock.report = {
		page: 1
	}
	stock.getStockReport = function(stk, grp){
		stock.selectedReportStock = stk
		stock.selectedReportGrp = grp
		this.success = function(res){
			stock.report = res.body
			//stock.report.page = 
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: grp.uniqueName,
			stockUniqueName: stk.uniqueName,
			to:$filter('date')(stock.toDate.date, 'dd-MM-yyyy'),
			from:$filter('date')(stock.fromDate.date, 'dd-MM-yyyy'),
			page:stock.report.page
		}
		stockService.getStockReport(reqParam).then(this.success, this.failure)

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
			stock.modificationState = "Modify"
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		if(typeof(obj.parentStockGroupUniqueName) == 'object'){
			obj.parentStockGroupUniqueName = obj.parentStockGroupUniqueName.uniqueName
		}
		var data = {
		    "name":obj.stockName,
		    "parentStockGroupUniqueName":obj.parentStockGroupUniqueName,
		    "uniqueName": obj.stockUnqName
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stock.selectedStockGrp.uniqueName
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
			$rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
		}
		this.failure = function(res){
			toastr.error(res.data.message || 'Something went Wrong, please check all input values')
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stock.selectedStockGrp.uniqueName
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
	stock.updateStock = function(stockItem){
		this.success = function(res){
			_.each(stock.selectedStockGrp.stocks, function(stk, idx){
				if(stk.uniqueName == res.body.uniqueName){
					stock.selectedStockGrp.stocks[idx] = res.body
				}
			})
			$rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)
			stock.getAllStocks()
			toastr.success('Stock Updated successfully')
		}

		this.failure = function(res){
			toastr.error(res.data.message)
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
		    "salesAccountUniqueName":stockItem.stockSalesAccount.uniqueName
		}
		var reqParam = {
			companyUniqueName: $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stock.selectedStockItem.stockGroup.uniqueName,
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
			toastr.error(res.data.message)
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
			res.body.parentStockGroup = res.body.parentStockGroup || {}
			stock.updateStockGroup.parentStockGroupUniqueName = res.body.parentStockGroup.uniqueName
			if(res.body.childStockGroups.length > 0 && stock.prevselectedStockGrp != undefined){
				stock.parentGroupsList.push(stockGroup.uniqueName)
			}else if(res.body.childStockGroups.length == 0 && stock.prevselectedStockGrp == undefined){
				stock.parentGroupsList = []
			}
			var parent = res.body.parentStockGroup || {}
			stock.closeOtherStockGroups(stockGroup, parent)
			stock.setModificationState(res.body) 
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
	stock.selectStock = function(stk, parent){
		this.success = function(res){
			res.body.mappedPurchaseAccount = res.body.mappedPurchaseAccount || {}
			res.body.mappedSalesAccount = res.body.mappedSalesAccount || {}
			stock.selectedStockItem = res.body
			stock.addStockItem.stockName = stock.selectedStockItem.name
			stock.addStockItem.stockUnqName = stock.selectedStockItem.uniqueName
			stock.addStockItem.stockType = stock.selectedStockItem.openingStockUnit
			stock.addStockItem.stockQty = stock.selectedStockItem.openingQuantity
			stock.addStockItem.stockClosingQty = stock.selectedStockItem.closingQuantity
			stock.addStockItem.stockAmount = stock.selectedStockItem.openingAmount
			stock.addStockItem.stockPurchaseAccount = stock.selectedStockItem.mappedPurchaseAccount
			stock.addStockItem.stockPurchaseRate = stock.selectedStockItem.mappedPurchaseAccount.rate
			stock.addStockItem.stockSalesAccount = stock.selectedStockItem.mappedSalesAccount
			stock.addStockItem.stockSalesRate = stock.selectedStockItem.mappedSalesAccount.rate
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		var uniqueName;
		parent != undefined ? uniqueName = parent.uniqueName : uniqueName = stk.stockGroup.uniqueName
		reqParam = {
			companyUniqueName : $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: uniqueName,
			stockUniqueName: stk.uniqueName
		}
		stockService.getStock(reqParam).then(this.success, this.failure)
	}

	//delete stock
	stock.deleteStock = function(stk){
		this.success= function(res){
			toastr.success(res.body)
			stock.getStockGroupDetail(stock.selectedStockGrp)
			stock.getAllStocks()
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		var stockGroupUniqueName;
		stk.stockGroup != undefined ? stockGroupUniqueName = stk.stockGroup.uniqueName : stockGroupUniqueName = stock.selectedStockGrp.uniqueName
		reqParam = {
			companyUniqueName : $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: stockGroupUniqueName,
			stockUniqueName: stk.uniqueName
		}
		stockService.deleteStock(reqParam).then(this.success, this.failure)

	}


	// delete stock group
	stock.deleteStockGrp = function(grp){
		this.success = function(res){
			toastr.success(res.body)
			stock.getHeirarchicalStockGroups()
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		reqParam = {
			companyUniqueName : $rootScope.selectedCompany.uniqueName,
			stockGroupUniqueName: grp.uniqueName
		}
		stockService.deleteStockGrp(reqParam).then(this.success, this.failure)

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
			toastr.error(res.data.message)
		}

		var reqParam = {
	      companyUniqueName: $rootScope.selectedCompany.uniqueName
	    }
	    stockService.getStockUnits(reqParam).then(this.success, this.failure)
	}
	stock.getStockUnits()

	// check whether to move selected stock grp to another
	stock.modificationState = "Modify"
	stock.setModificationState = function(grp){
		if(stock.selectedStockGrp.uniqueName != grp.uniqueName)
			stock.modificationState = "Modify and Move"
		else
			stock.modificationState = "Modify"
	}


	// to hide sidebar
	$(document).on('click', function(e){
		stock.showSidebar = false;
	});

	return stock;

}])