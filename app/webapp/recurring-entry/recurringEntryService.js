angular.module('recurringEntryService', [])

.service('recurringEntryService',function($resource, $q){
	var recEntry = $resource('/company/:companyUniqueName/recurring-entry', {
		'companyUniqueName': this.companyUniqueName,
		'accountUniqueName': this.accountUniqueName,
		'q': this.q,
		'page': this.page,
		'count': this.count,
		'from' :this.from,
		'to': this.to
	},
	{
		create: {
			method: 'POST',
			url: '/company/:companyUniqueName/recurring-entry'
		}
	})
	recurringEntryService = {
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

	    createReccuringEntry: function(reqParam, data){
	    	return this.handlePromise(function(onSuccess, onFailure){
	    		return recEntry.create({
	    			companyUniqueName: reqParam.companyUniqueName,
	    			accountUniqueName: reqParam.accountUniqueName
	    		}, data, onSuccess, onFailure)

	    	})
	    }
	}

	return recurringEntryService;

})