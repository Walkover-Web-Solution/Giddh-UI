angular.module('inventoryServices', [])
	.service('localInventoryService', function(){
		return {
			_groupList: [],
			get : function() {
	      return this._groupList;
	    },
	    set : function(val) {
	      this._groupList = val;
	    },
	    insert : function(items){
	    	this._groupList.push(items);
	    }
		}
	})
	.service('stockService', ['$resource', '$q', function($resource, $q){
		var stock = $resource('/company/:companyUniqueName/stock-group', {
			'companyUniqueName': this.companyUniqueName,
			'stockGroupUniqueName' : this.stockGroupUniqueName,
			'stockUniqueName': this.stockUniqueName,
			'q': this.q,
			'page': this.page,
			'count': this.count,
			'from' :this.from,
			'to': this.to,
			'uName': this.uName
		},
		{
			get: {
				method: 'GET',
				url: '/company/:companyUniqueName/stock-group/groups-with-stocks-flatten'
			},
			getHeirarchy: {
				method: 'GET',
				url: '/company/:companyUniqueName/stock-group/groups-with-stocks-hierarchy-min'
			},
			addGroup: {
				method: 'POST',
				url: '/company/:companyUniqueName/stock-group'
			},
			updateGroup: {
				method: 'PUT',
				url: '/company/:companyUniqueName/stock-group/:stockGroupUniqueName'
			},
			getStockGroups: {
				method: 'GET',
				url: '/company/:companyUniqueName/stock-group/:stockGroupUniqueName/stocks'
			},
			createStock: {
				method: 'POST',
				url: '/company/:companyUniqueName/stock-group/:stockGroupUniqueName/stock'
			},
			updateStockItem: {
				method: 'PUT',
				url: '/company/:companyUniqueName/stock-group/update-stock-item'
			},
			getAllStocks: {
				method: 'GET',
				url: '/company/:companyUniqueName/stock-group/stocks'
			},
			getStockDetail: {
				method: 'GET',
				url: '/company/:companyUniqueName/stock-group/:stockGroupUniqueName'
			},
			getStockType: {
				method: 'GET',
				url: '/company/:companyUniqueName/stock-group/unit-types'
			},
			createStockUnit: {
				method: 'POST',
				url: '/company/:companyUniqueName/stock-group/unit-types'
			},
			updateStockUnit: {
				method: 'PUT',
				url: '/company/:companyUniqueName/stock-group/unit-types'
			},
			deleteStockUnit: {
				method: 'DELETE',
				url: '/company/:companyUniqueName/stock-group/unit-types'
			},
			getFilteredStockGroups: {
				method: 'GET',
				url: '/company/:companyUniqueName/stock-group/hierarchical-stock-groups'
			},
			getStockItemDetails: {
				method: 'GET',
				url: '/company/:companyUniqueName/stock-group/get-stock-detail'
			},
			getStockReport: {
				method: 'GET',
				url: '/company/:companyUniqueName/stock-group/get-stock-report'
			},
			deleteStock: {
				method: 'DELETE',
				url: '/company/:companyUniqueName/stock-group/delete-stock'
			},
			deleteStockGrp: {
				method: 'DELETE',
				url: '/company/:companyUniqueName/stock-group/delete-stockgrp'
			}

		})

		stockService = {
			handlePromise: function(func) {
	      var deferred, onFailure, onSuccess;
	      deferred = $q.defer();
	      onSuccess = function(data) {
	        return deferred.resolve(data);
	      };
	      onFailure = function(data) {
	        return deferred.reject(data);
	      };
	      func(onSuccess, onFailure);
	      return deferred.promise;
	    },

	    getStockGroupsFlatten: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.get({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			page:reqParam.page,
	    			q:reqParam.q,
	    			count:reqParam.count
	    		}, onSuccess, onFailure)
	    	})
	    },

			getStockGroupsHeirarchy: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.getHeirarchy({
	    			companyUniqueName: reqParam.companyUniqueName
	    		}, onSuccess, onFailure)
	    	})
	    },

	    addGroup: function(reqParam, data){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.addGroup({
	    			companyUniqueName: reqParam.companyUniqueName
	    		}, data,  onSuccess, onFailure)
	    	})
	    },

	    updateStockGroup: function(reqParam, data){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.updateGroup({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			stockGroupUniqueName: reqParam.stockGroupUniqueName
	    		}, data,  onSuccess, onFailure)
	    	})
	    },

	    getStockGroups: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.getStockGroups({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			stockGroupUniqueName: reqParam.stockGroupUniqueName
	    		}, onSuccess, onFailure)
	    	})
	    },

	    createStock: function(reqParam, data){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.createStock({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			stockGroupUniqueName: reqParam.stockGroupUniqueName
	    		}, data,  onSuccess, onFailure)
	    	})
	    },

	    updateStockItem: function(reqParam, data){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.updateStockItem({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			stockGroupUniqueName: reqParam.stockGroupUniqueName,
	    			stockUniqueName: reqParam.stockUniqueName
	    		}, data,  onSuccess, onFailure)
	    	})
	    },

	    getAllStocks: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.getAllStocks({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			q: reqParam.q,
	    			page:reqParam.page,
	    			count:reqParam.count
	    		}, onSuccess, onFailure)
	    	})
	    },

	    getStockDetail: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.getStockDetail({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			stockGroupUniqueName: reqParam.stockGroupUniqueName
	    		}, onSuccess, onFailure)
	    	})
	    },


	    getFilteredStockGroups: function(){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.getFilteredStockGroups({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			q: reqParam.q,
	    			page:reqParam.page,
	    			count:reqParam.count
	    		}, onSuccess, onFailure)
	    	})
	    },

	    getStockItemDetails: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.getStockItemDetails({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			stockGroupUniqueName : reqParam.stockGroupUniqueName,
	    			stockUniqueName: reqParam.stockUniqueName
	    		}, onSuccess, onFailure)
	    	})
	    },

	    getStockReport: function(){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.getStockReport({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			stockGroupUniqueName : reqParam.stockGroupUniqueName,
	    			stockUniqueName: reqParam.stockUniqueName,
	    			from: reqParam.from,
	    			to: reqParam.to
	    		}, onSuccess, onFailure)
	    	})
	    },

	    deleteStock: function(){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.deleteStock({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			stockGroupUniqueName : reqParam.stockGroupUniqueName,
	    			stockUniqueName: reqParam.stockUniqueName
	    		}, onSuccess, onFailure)
	    	})
	    },

	    deleteStockGrp: function(){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.deleteStockGrp({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			stockGroupUniqueName : reqParam.stockGroupUniqueName
	    		}, onSuccess, onFailure)
	    	})
	    },

	    getStockUnits: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.getStockType({
	    			companyUniqueName: reqParam.companyUniqueName
	    		}, onSuccess, onFailure)
	    	})
	    },

	    createStockUnit: function(reqParam, data){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.createStockUnit({
	    			companyUniqueName: reqParam.companyUniqueName
	    		}, data, onSuccess, onFailure)
	    	})
	    },

	    updateStockUnit: function(reqParam, data){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.updateStockUnit({
	    			companyUniqueName: reqParam.companyUniqueName
	    		}, data, onSuccess, onFailure)
	    	})
	    },

	    deleteStockUnit: function(reqParam, data){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.deleteStockUnit({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			uName: reqParam.uName
	    		}, onSuccess, onFailure)
	    	})
	    }

		}
		return stockService
}])


