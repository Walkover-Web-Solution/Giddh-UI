adminPanel.controller('adminPanelController', ['$scope','$state', function($scope, $state){
	
	$this = this;
	
	var loggedIn = false
	var ak = window.sessionStorage.getItem('_ak')
	ak ? loggedIn = true : $state.go('login')
	
	$this.title = 'Admin Panel'




	return $this;
}])