angular.module('inventoryServices', [])
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
			deleteStock: {
				method: 'DELETE',
				url: '/company/:companyUniqueName/stock-group/delete-stock'
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

	    deleteStock: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.deleteStock(reqParam, onSuccess, onFailure)
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


	    getFilteredStockGroups: function(reqParam){
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

	    getStockReport: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.getStockReport(reqParam, onSuccess, onFailure)
	    	})
	    },
	    deleteStockGrp: function(reqParam){
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

	    deleteStockUnit: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.deleteStockUnit(reqParam, onSuccess, onFailure)
	    	})
	    },
	    

	    getStockUnit: function () {
			return [{
			    text: 'BAGS',
			    id: 'BAG'
			},
			{
			    text: 'BALE',
			    id: 'BAL'
			},
			{
			    text: 'BUNDLES',
			    id: 'BDL'
			},
			{
			    text: 'BUCKLES',
			    id: 'BKL'
			},
			{
			    text: 'BILLION OF UNITS',
			    id: 'BOU'
			},
			{
			    text: 'BOX',
			    id: 'BOX'
			},
			{
			    text: 'BOTTLES',
			    id: 'BTL'
			},
			{
			    text: 'BUNCHES',
			    id: 'BUN'
			},
			{
			    text: 'CANS',
			    id: 'CAN'
			},
			{
			    text: 'CUBIC METERS',
			    id: 'CBM'
			},
			{
			    text: 'CUBIC CENTIMETERS',
			    id: 'CCM'
			},
			{
			    text: 'CENTIMETERS',
			    id: 'CMS'
			},
			{
			    text: 'CARTONS',
			    id: 'CTN'
			},
			{
			    text: 'DOZENS',
			    id: 'DOZ'
			},
			{
			    text: 'DRUMS',
			    id: 'DRM'
			},
			{
			    text: 'GREAT GROSS',
			    id: 'GGK'
			},
			{
			    text: 'GRAMMES',
			    id: 'GMS'
			},
			{
			    text: 'GROSS',
			    id: 'GRS'
			},
			{
			    text: 'GROSS YARDS',
			    id: 'GYD'
			},
			{
			    text: 'KILOGRAMS',
			    id: 'KGS'
			},
			{
			    text: 'KILOLITRE',
			    id: 'KLR'
			},
			{
			    text: 'KILOMETRE',
			    id: 'KME'
			},
			{
			    text: 'MILILITRE',
			    id: 'MLT'
			},
			{
			    text: 'METERS',
			    id: 'MTR'
			},
			{
			    text: 'METRIC TON',
			    id: 'MTS'
			},
			{
			    text: 'NUMBERS',
			    id: 'NOS'
			},
			{
			    text: 'PACKS',
			    id: 'PAC'
			},
			{
			    text: 'PIECES',
			    id: 'PCS'
			},
			{
			    text: 'PAIRS',
			    id: 'PRS'
			},
			{
			    text: 'QUINTAL',
			    id: 'QTL'
			},
			{
			    text: 'ROLLS',
			    id: 'ROL'
			},
			{
			    text: 'SETS',
			    id: 'SET'
			},
			{
			    text: 'SQUARE FEET',
			    id: 'SQF'
			},
			{
			    text: 'SQUARE METERS',
			    id: 'SQM'
			},
			{
			    text: 'SQUARE YARDS',
			    id: 'SQY'
			},
			{
			    text: 'TABLETS',
			    id: 'TBS'
			},
			{
			    text: 'TEN GROSS',
			    id: 'TGM'
			},
			{
			    text: 'THOUSANDS',
			    id: 'THD'
			},
			{
			    text: 'TONNES',
			    id: 'TON'
			},
			{
			    text: 'TUBES',
			    id: 'TUB'
			},
			{
			    text: 'US GALLONS',
			    id: 'UGS'
			},
			{
			    text: 'UNITS',
			    id: 'UNT'
			},
			{
			    text: 'YARDS',
			    id: 'YDS'
			},
			{
			    text: 'OTHERS',
			    id: 'OTH'
			}
			];

	    }
	    }

		return stockService
}])


