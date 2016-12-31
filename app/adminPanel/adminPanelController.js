adminPanel.controller('adminPanelController', ['$scope','$state','$http' ,function($scope, $state, $http){
	
	$this = this;
	
	var loggedIn = false
	var ak = window.sessionStorage.getItem('_ak')
	ak ? loggedIn = true : $state.go('login')
	
	$this.title = 'Admin Panel'
	$scope.companies = []

	var getCompaniesList = function (){
		url = '/admin/companies'
		data =  {
		    companyName : "",
		    companyUniqueName : "",
		    createdBy : "",
		    primaryBillerBalance : "",
		    secondaryBillerBalance :"",
		    mobileNo : "",
		    subscriptionPlan : "",
		    sort : {"companyName": "DESC", "createdBy": "ASC", "subscriptionExpiringAt":"DESC", "primaryAccBalance": "DESC" , "secondaryAccBalance": "DESC" , "apiHits": "DESC"}
		}
		$http.post(url, data).then(this.success, this.failure)

		this.success = function(res){
			$scope.companies = res.data.body.results
		}

		this.failure = function(res){
			console.log(res)
		}

	}
	
	getCompaniesList()

	return $this;
}])