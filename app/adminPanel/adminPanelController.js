adminPanel.controller('adminPanelController', ['$scope','$state','$http' ,function($scope, $state, $http){
	
	$this = this;
	
	var loggedIn = false
	var ak = window.sessionStorage.getItem('_ak')
	ak ? loggedIn = true : $state.go('login')
	
	$this.title = 'Admin Panel'

	// var getCompaniesList = function (){
	// 	url = '/admin/companies'
	// 	$http.post(url)
	// }
	


	return $this;
}])