//Service : Audit Logs : HttpService

(function(app){

	app.AuditLogsHttpService = ng.core.Injectable().Class({
	    constructor: [ng.http.Http,  function(http){
		    this.http = http;
		    this.selectedCompany = {};
		    this.update = new ng.core.EventEmitter(); 
	    }],

	    getLogs: function(reqBody){		
		  	// get and set selected Company
		  	var selectedCompany;
	        var usrInfo = JSON.parse(window.localStorage.getItem('giddh._selectedCompany'));
	        
	        usrInfo != null ? selectedCompany = usrInfo : selectedCompany = app.logs.selectedCompany;	

	        // Define request variables
		  	var body = JSON.stringify(reqBody.body)
		  	var headers = new ng.http.Headers({ 'Content-Type': 'application/json' });
		  	var options = new ng.http.RequestOptions({ headers: headers });
		  	var page = reqBody.page;
		  	var url = '/company/' + selectedCompany.uniqueName + '/logs/' + page;

		    // return http request as observer
		    return this.http.post(url,body, options)	
		      .map(function (res) {
		          return res;
		    });
	    }
	});

})(app = window.giddh.webApp || (window.giddh.webApp = {}));


