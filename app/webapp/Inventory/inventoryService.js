

angular.module('inventoryServices', [])

.service('stockService', ['$resource', '$q', function($resource, $q){
	
	var stock = $resource('/company/:companyUniqueName/stock-group', {
		'companyUniqueName': this.companyUniqueName,
		'stockGroupUniqueName' : this.stockGroupUniqueName
	},
	{
		get: {
			method: 'GET',
			url: '/company/:companyUniqueName/stock-group/groups-with-stocks-flatten'
		},
		getHeirarchy: {
			method: 'GET',
			url: '/company/:companyUniqueName/stock-group/groups-with-stocks-hierarchy'
		},
		addGroup: {
			method: 'POST',
			url: '/company/:companyUniqueName/stock-group'
		},
		updateGroup: {
			method: 'PUT',
			url: '/company/:companyUniqueName/stock-group/:stockGroupUniqueName'
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

	    getStockGroups: function(reqParam){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return stock.get({
	    			companyUniqueName: reqParam.companyUniqueName
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
	    }

	}

	return stockService

}])


