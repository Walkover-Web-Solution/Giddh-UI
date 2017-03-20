adminPanel.controller('adminPanelController', ['$rootScope','$scope','$state','$http', 'toastr' ,function($rootScope, $scope, $state, $http, toastr){
	
	$this = this;
	$scope.superLoader = false
	var loggedIn = false
	var ak = window.sessionStorage.getItem('_ak')
	ak ? loggedIn = true : $state.go('login')
	
	$this.title = 'Admin Panel'
    $scope.showfilters = false
	$scope.companies = []
    $scope.paginationDetails = {}
    $scope.counts = [
        20,
        50,
        100
    ]
    $scope.countPage = 20
    $scope.pageNo = 1
    sortModel = function (){
     return this.model = [
        {
            name: 'Name',
            key: 'companyName',
            show: true,
            value: null
        },
        {
            name: 'Created By',
            key: 'createdBy',
            show: true,
            value: null
        },
        {
            name: 'Created At',
            key: 'createdAt',
            show: false,
            value: null
        },
        {
            name: 'Mobile No.',
            key: 'mobileNum',
            show: false,
            value: null
        },
        {
            name: 'Expiry Date',
            key: 'subscriptionExpiringAt',
            show: true,
            value: null
        },
        {
            name: 'Last Activity',
            key: 'lastActivity',
            show: false,
            value: null
        },
        {
            name: 'Prim. Account balance',
            key: 'primaryAccBalance',
            show: true,
            value: null
        },
        {
            name: 'Sec. Account balance',
            key: 'secondaryAccBalance',
            show: true,
            value: null
        },
        {
            name: 'Subscription plan',
            key: 'subscriptionPlan',
            show: false,
            value: null
        },
        {
            name: 'Total Api Hits',
            key: 'apiHits',
            show: true,
            value: null
        },

    ]}

    $scope.sortOptions = new sortModel()

    $scope.filters = {
        companyName : "",
        companyUniqueName : "",
        createdBy : "",
        primaryBillerBalance : "",
        secondaryBillerBalance :"",
        mobileNo : "",
        subscriptionPlan : "",
        sort : {"companyName": "DESC"}
    }

    $this.enableSorting = function (){
        sort = {}
        _.each($scope.sortOptions, function(option){
            if(option.value != null){
                if(option.value == true){
                    option.value = 'ASC'
                }
                else if (option.value == false){
                    option.value = 'DESC'
                }
                sort[option.key] = option.value
            }
        })
        return sort
    }

	$scope.getCompaniesList = function (){
        $scope.superLoader = true
        this.success = function(res){
            $scope.paginationDetails = res.data.body
            $scope.companies = res.data.body.results
            //$scope.sortOptions = new sortModel()
            $scope.superLoader = false
        }

        this.failure = function(res){
            toastr.error(res.data.message)
            $scope.superLoader = false
        }
        url = '/admin/companies'
		filter =  $scope.filters
        filter.sort = $this.enableSorting()
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
	
    $scope.sortColumn = function(value){
        $scope.getCompaniesList()
    }

	$scope.getCompaniesList()

	return $this;
}])