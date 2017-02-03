angular.module('recurringEntryController', [])

.controller('recurringEntryController', ['$scope','$rootScope','stockService','localStorageService','groupService' ,'toastr','$filter','companyServices','recurringEntryService' ,function($scope, $rootScope, stockService, localStorageService,groupService, toastr, $filter,companyServices,recurringEntryService){
	
	if (_.isUndefined($rootScope.selectedCompany)) $rootScope.selectedCompany = localStorageService.get('_selectedCompany')

	var recEntry = this;
	
	recEntry.today = $filter('date')(new Date(), "dd-MM-yyyy")
	recEntry.format = 'dd-MM-yyyy'


	recEntry.rows = []
	recEntry.selectedEntry = null
	//durations list
	recEntry.durationList = [
		'WEEKLY',
		'MONTHLY',
		'QUATERLY',
		'HALF YEARLY',
		'YEARLY'
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
		'DEBIT',
		'CREDIT'
	]  

	//tax list
	recEntry.taxes = []

	//select entry on double click, show current entry panel, hide previous
	recEntry.selectEntry = function(entry, index){
		if(recEntry.selectedEntry != null){
			recEntry.prevEntry = recEntry.selectedEntry
		}
		recEntry.selectedEntry = entry
		//recEntry.selectedEntry.index = index
		recEntry.selectedEntry.showPanel = !recEntry.selectedEntry.showPanel
		// if(recEntry.prevEntry != undefined && recEntry.prevEntry.index != index){
		// 	recEntry.prevEntry.showPanel = !recEntry.prevEntry.showPanel
		// }
		// if(recEntry.selectedEntry != undefined && recEntry.selectedEntry.index != index){
		// 	recEntry.prevEntry = recEntry.selectedEntry
		// } 
		// recEntry.selectedEntry = entry
		// recEntry.selectedEntry.index = index
		// entry.showPanel = !entry.showPanel
		// if(recEntry.prevEntry != undefined) recEntry.prevEntry.showPanel = false
	}

	//blank entry model 
	recEntry.entryModel = function(){
		this.model = {
		  "transactions": [
		    {
		      "amount": 0,
		      "particular": "",
		      "type": "debit",
		      "inventory":{
		    	"quantity":0
		      }
		    }
		  ],
		  "voucherType": recEntry.voucherTypes[0],
		  "entryDate": recEntry.today,
		  "applyApplicableTaxes": "false",
		  "isInclusiveTax": "false",
		  "unconfirmedEntry": "false",
		  "tag": "",
		  "description": "",
		  "showPanel":true,
		  "taxes": [],
		  "isRecurring":true,
		  "duration":recEntry.durationList[0]
		}
		return this.model;
	}

	// blank transaction model
	recEntry.txnModel = function(){
		this.txn = {
			"amount": 0,
		    "particular": "",
		    "type": "debit",
		    "inventory":{
		    	"quantity":0
		    }
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

	//get all recurring entries
	recEntry.getAllEntries = function(){
		this.success = function(res){
			console.log(res)
			recEntry.rows = res.body.results
		}

		this.failure = function(res){
			toastr.error(res.data.message)
		}
		reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
		recurringEntryService.getEntries(reqParam).then(this.success, this.failure)
	}
	recEntry.getAllEntries()


	//create recurring entry
	recEntry.createEntry = function(ledger){
		this.success = function(res){
			console.log(res)
		}

		this.failure = function(res){
			console.log(res)
		}

		var entry = {}
		entry = _.extend(ledger, entry)
		entry.transactions = recEntry.formatTxns(entry.transactions)
		entry.taxes = recEntry.formatTaxes(entry.taxes)
		entry.voucherType = ledger.voucherType.name
		var reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
		reqParam.accountUniqueName = ledger.account.uniqueName
		delete entry.account
		delete entry.showPanel
		recurringEntryService.createReccuringEntry(reqParam, entry).then(this.success, this.failure)
	}

	//format and prepare transactions
	 recEntry.formatTxns = function(transactions){
	 	var txns = []
	 	_.each(transactions,function(txn){
	 		var tx = new recEntry.txnModel()
	 		tx = _.extendOwn(tx, txn)
	 		particular = {}
	 		particular.name = tx.particular.name
	 		particular.uniqueName = tx.particular.uniqueName
	 		tx.particular = particular
	 		delete tx.showPanel
	 		delete tx.inventory
	 		txns.push(tx)
	 	})
	 	return txns;
	 }

	// format and return taxes
	recEntry.formatTaxes = function(taxes) {
		var taxList = []
		_.each(taxes, function(tax){
			if(tax.isSelected){
				taxList.push(tax.uniqueName)
			}
		})
		return taxList
	}


	//get duration types 
	recEntry.getDuration = function(){
		this.success = function(res){
			recEntry.durationList = res.body.durationTypes
		},
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
		recurringEntryService.getDuration(reqParam).then(this.success, this.failure)
	}
	recEntry.getDuration()

	return recEntry;
}])
