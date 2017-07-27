angular.module('recurringEntryController', [])

.controller('recurringEntryController', ['$scope','$rootScope','stockService','localStorageService','groupService' ,'toastr','$filter','companyServices','recurringEntryService' ,function($scope, $rootScope, stockService, localStorageService,groupService, toastr, $filter,companyServices,recurringEntryService){
	
	if (_.isUndefined($rootScope.selectedCompany)) $rootScope.selectedCompany = localStorageService.get('_selectedCompany')

	var recEntry = this;
	recEntry.showLoader = true
	recEntry.today = $filter('date')(new Date(), "dd-MM-yyyy")
	recEntry.format = 'dd-MM-yyyy'


	recEntry.rows = []
	recEntry.selectedEntry = null
	//durations list
	recEntry.durationList = [
		'WEEKLY',
		'MONTHLY',
		'QUARTERLY',
		'HALF YEARLY',
		'YEARLY'
	]

	//btn style
	recEntry.btnStyle = {
		add: {
			"right":"82px"
		},
		update:{
			"right:":"100px"
		}
	}

	//voucher types
	recEntry.voucherTypes = [
	    {
	      name: "sales",
	      shortCode: "sal"
	    },
	    {
	      name: "purchase",
	      shortCode: "pur"
	    },
	    {
	      name: "receipt",
	      shortCode: "rcpt"
	    },
	    {
	      name: "payment",
	      shortCode: "pay"
	    },
	    {
	      name: "journal",
	      shortCode: "jr"
	    },
	    {
	      name: "contra",
	      shortCode: "cntr"
	    },
	    {
	      name: "debit note",
	      shortCode: "debit note"
	    },
	    {
	      name: "dredit note",
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

	//select and highlight ledger
	recEntry.selectLedger = function(ledger){
		if(recEntry.selectedLedger){
			recEntry.prevLedger = recEntry.selectedLedger
		}
		recEntry.selectedLedger = ledger
		recEntry.selectedLedger.highlight = true
		if(recEntry.prevLedger && recEntry.prevLedger != recEntry.selectedLedger){
			recEntry.prevLedger.highlight = false
		}
	}


	//select entry on double click, show current entry panel, hide previous
	recEntry.selectEntry = function(entry, index, ledger){
		if(recEntry.selectedEntry != null){
			recEntry.prevEntry = recEntry.selectedEntry
		}
		recEntry.selectedEntry = entry
		recEntry.selectedEntry.showPanel = !recEntry.selectedEntry.showPanel
		if(recEntry.prevEntry && recEntry.prevEntry != recEntry.selectedEntry){
			recEntry.prevEntry.showPanel = false
		}
		recEntry.selectLedger(ledger)
	}

	//blank entry model 
	recEntry.entryModel = function(){
		this.model = {
		  "transactions": [
		    {
		      "amount": 0,
		      "particular": "",
		      "type": recEntry.entryTypes[0],
		      "inventory":{
		    	"quantity":0
		      }
		    }
		  ],
		  "recurringEntryDetail": {
		  	"account":'',
		  	"durationType": recEntry.durationList[1]
		  },
		  "voucher":recEntry.voucherTypes[0] ,
		  "entryDate": recEntry.today,
		  "applyApplicableTaxes": "false",
		  "isInclusiveTax": "false",
		  "unconfirmedEntry": "false",
		  "tag": "",
		  "description": "",
		  "showPanel":true,
		  "taxes": [],
		  "isRecurring":true,
		  "newEntry" : true
		  // "duration":recEntry.durationList[0]
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
		if(recEntry.rows.length > 0 && !recEntry.rows[0]['newEntry']){
			recEntry.rows.unshift(entry)
			recEntry.selectEntry(entry.transactions[0], 0, entry)
		}else if(recEntry.rows.length == 0){
			recEntry.rows.unshift(entry)
		}else{
			recEntry.selectEntry(entry.transactions[0], 0, entry)
		}
	}

	//add new transaction
	recEntry.addNewTxn = function(ledger){
		var txn = new recEntry.txnModel()
		txn.newTxn = true
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
			recEntry.rows = res.body.results
			recEntry.showLoader = false
		}

		this.failure = function(res){
			toastr.error(res.data.message)
			recEntry.showLoader = false
		}
		reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
		recurringEntryService.getEntries(reqParam).then(this.success, this.failure)
	}
	recEntry.getAllEntries()


	//create recurring entry
	recEntry.createEntry = function(ledger){
		this.success = function(res){
			ledger = angular.copy(res.body[0], ledger)
			toastr.success('Entry created successfully')
		}

		this.failure = function(res){
			toastr.error(res.data.message)
		}

		var entry = {}
		entry = angular.copy(ledger, entry)
		entry.transactions = recEntry.formatTxns(entry.transactions)
		entry.taxes = recEntry.formatTaxes(entry.taxes)
		entry.voucherType = ledger.voucher.name
		entry.duration = ledger.recurringEntryDetail.durationType
		var reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
		reqParam.accountUniqueName = ledger.recurringEntryDetail.account.uniqueName
		delete entry.recurringEntryDetail
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

	// update existing entry
	recEntry.updateEntry = function(ledger){
		this.success = function(res){
			ledger = _.extendOwn(ledger, res.body)
			toastr.success('Entry updated successfully')
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		var entry = angular.copy(ledger, entry)
		entry.duration = ledger.recurringEntryDetail.durationType
		entry.voucherType = ledger.voucher.name
		entry.isRecurring = true
		var reqParam = {}
		reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
		reqParam.accountUniqueName = ledger.recurringEntryDetail.account.uniqueName
		reqParam.recurringentryUniqueName = ledger.recurringEntryDetail.uniqueName
		delete entry.recurringEntryDetail 
		delete entry.updatedBy
		delete entry.updatedAt
		delete entry.voucher
		delete entry.voucherNo
		recurringEntryService.update(reqParam, entry).then(this.success, this.failure)

	}

	//delete entry
	recEntry.deleteEntry = function(ledger, index){
		var idx;
		this.success = function(res){
			toastr.success(res.body)
			recEntry.rows.splice(idx, 1)
		}
		this.failure = function(res){
			toastr.error(res.data.message)
		}
		if(ledger.newEntry){
			recEntry.rows.splice(0, 1)
		}else{
			idx = recEntry.getLedgerIndex(ledger)
			var reqParam = {}
			reqParam.companyUniqueName = $rootScope.selectedCompany.uniqueName
			reqParam.accountUniqueName = ledger.recurringEntryDetail.account.uniqueName
			reqParam.recurringentryUniqueName = ledger.recurringEntryDetail.uniqueName
			recurringEntryService.delete(reqParam).then(this.success, this.failure)			
		}

	}

	//get ledger index
	recEntry.getLedgerIndex = function(ledger){
		var ledgerIndex;
		_.each(recEntry.rows, function(ldr, index){
			if(!ledger.newEntry && ledger.uniqueName && ledger.uniqueName == ldr.uniqueName){
				ledgerIndex = index
			}
		})
		return ledgerIndex
	}

	// remove blank transaction
	recEntry.removeTxn = function(ledger, index){
		ledger.transactions.splice(index, 1)
	}

	$rootScope.$on('company-changed', function(event, changeData) {
		recEntry.rows = []
		recEntry.getAllEntries();
	});

	return recEntry;
}])
