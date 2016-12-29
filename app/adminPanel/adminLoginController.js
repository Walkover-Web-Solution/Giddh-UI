adminPanel.controller('adminLoginController', ['$scope','$auth','localStorageService', 'toastr','$state','$window',function($scope,$auth,localStorageService, toastr, $state, $window){
	console.log('login')
	$this = this;


	$this.authenticate = function(provider) {
      return $auth.authenticate(provider).then(function(response) {
        if (response.data.result.status === "error") {
          toastr.error(response.data.result.message, "Error");
          return $timeout((function() {
            $state.go('login')
          }), 3000);
        } else {
          localStorageService.set("_userDetails", response.data.userDetails);
          $window.sessionStorage.setItem("_ak", response.data.result.body.authKey);
          $state.go('admin-panel')
        }
      })["catch"](function(response) {
        if (response.data.result.status === "error") {
          toastr.error(response.data.result.message, "Error");
          return $timeout((function() {
            $state.go('login')
          }), 3000);
        } else if (response.status === 502) {
          return toastr.error("Something went wrong please reload page", "Error");
        } else {
          return toastr.error("Something went wrong please reload page", "Error");
        }
      });
    };








    return $this;
}])