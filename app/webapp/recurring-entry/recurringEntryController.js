angular.module('recurringEntryController', [])

.controller('recurringEntryController', ['$scope','$rootScope','stockService','localStorageService','groupService' ,'toastr','$filter','companyServices' ,function($scope, $rootScope, stockService, localStorageService,groupService, toastr, $filter,companyServices){
	
	if (_.isUndefined($rootScope.selectedCompany)) $rootScope.selectedCompany = localStorageService.get('_selectedCompany')

	var recEntry = this;

	recEntry.today = $filter('date')(new Date(), "dd-MM-yyyy")
	recEntry.format = 'dd-MM-yyyy'


	recEntry.rows = []

	//durations list
	recEntry.durationList = [
		'Weekly',
		'Monthly',
		'Quarterly',
		'Half Yearly',
		'Yearly'
	]

	//voucher types
	recEntry.voucherTypes = [
	    {
	      name: "Sales",
	      shortCode: "sal"
	    },
	    {
	      name: "Purchases",
	      shortCode: "pur"
	    },
	    {
	      name: "Receipt",
	      shortCode: "rcpt"
	    },
	    {
	      name: "Payment",
	      shortCode: "pay"
	    },
	    {
	      name: "Journal",
	      shortCode: "jr"
	    },
	    {
	      name: "Contra",
	      shortCode: "cntr"
	    },
	    {
	      name: "Debit Note",
	      shortCode: "debit note"
	    },
	    {
	      name: "Credit Note",
	      shortCode: "credit note"
	    }
	  ]

	//entry types
	recEntry.entryTypes = [
		'debit',
		'credit'
	]  

	//tax list
	recEntry.taxes = []

	//select entry on double click, show current entry panel, hide previous
	recEntry.selectEntry = function(entry, index){
		recEntry.prevEntry = recEntry.selectedEntry || {}
		recEntry.selectedEntry = entry
		entry.showPanel = !entry.showPanel
		recEntry.prevEntry.showPanel = false
	}

	//blank entry model 
	recEntry.entryModel = function(){
		this.model = {
		  "transactions": [
		    {
		      "amount": 0,
		      "particular": "",
		      "type": "debit"
		    }
		  ],
		  "voucherType": "sales",
		  "entryDate": recEntry.today,
		  "applyApplicableTaxes": "false",
		  "isInclusiveTax": "false",
		  "unconfirmedEntry": "false",
		  "tag": "$crnNumber",
		  "description": "",
		  "showPanel":true,
		  "taxes": [],
		  "isRecurring":true
		}
		return this.model;
	}

	// blank transaction model
	recEntry.txnModel = function(){
		this.txn = {
			"amount": 0,
		    "particular": "",
		    "type": "debit"
		}
		return this.txn;
	}

	//add new blank entry
	recEntry.addNewEntry = function(){
		var entry = new recEntry.entryModel()
		entry.taxes = recEntry.taxes
		recEntry.rows.unshift(entry)
		if(recEntry.prevEntry) recEntry.prevEntry.showPanel = false
		
	}

	//add new transaction
	recEntry.addNewTxn = function(ledger){
		var txn = new recEntry.txnModel()
		ledger.transactions.push(txn)
	}

	//get flat account list
	$rootScope.getFlatAccountList($rootScope.selectedCompany.uniqueName)


	//get tax list
	recEntry.getTaxList = function(){
		this.success = function(res){
			recEntry.taxes = res.body
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		companyServices.getTax($rootScope.selectedCompany.uniqueName).then(this.success, this.failure)
	}
	recEntry.getTaxList()


	//create recurring entry
	recEntry.createEntry = function(ledger){
		console.log(ledger)
	}

	return recEntry;
}])
