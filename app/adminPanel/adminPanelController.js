adminPanel.controller('adminPanelController', ['$scope','$state','$http', 'toastr' ,function($scope, $state, $http,toastr){
	
	$this = this;
	$this.superLoader = true
	var loggedIn = false
	var ak = window.sessionStorage.getItem('_ak')
	ak ? loggedIn = true : $state.go('login')
	
	$this.title = 'Admin Panel'
	$scope.companies = []
    $scope.paginationDetails = {}
    $scope.counts = [
        20,
        50,
        100
    ]
    $scope.countPage = 20
    $scope.pageNo = 1
    $scope.filters = {
        companyName : "",
        companyUniqueName : "",
        createdBy : "",
        primaryBillerBalance : "",
        secondaryBillerBalance :"",
        mobileNo : "",
        subscriptionPlan : "",
        sort : {"companyName": "DESC", "createdBy": "ASC", "subscriptionExpiringAt":"DESC", "primaryAccBalance": "DESC" , "secondaryAccBalance": "DESC" , "apiHits": "DESC"}
    }




	$scope.getCompaniesList = function (){
        this.success = function(res){
            $scope.paginationDetails = res.data.body
            $scope.companies = res.data.body.results
        }

        this.failure = function(res){
            toastr.error(res.data.message)
        }
        url = '/admin/companies'
		filter =  $scope.filters
        data = {
            params: {
                page: $scope.pageNo,
                count: $scope.countPage
            },
            filters: filter
        }
		$http.post(url, data).then(this.success, this.failure)
	}
    
    $scope.nextPage = function(){
        $scope.pageNo = $scope.pageNo + 1
    }
    
    $scope.prevPage = function(){
        $scope.pageNo = $scope.pageNo - 1
    }
	
	$scope.getCompaniesList()

	return $this;
}])