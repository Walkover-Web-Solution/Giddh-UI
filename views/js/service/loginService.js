(function() {
  'use strict';
  angular.module('giddhApp').service('loginService', function($resource) {
    var Login, loginService;
    Login = $resource('/submitBetaInviteDetails', {}, {
      sendInvite: {
        method: 'POST'
      }
    });
    loginService = {
      submitUserForm: function(user, onSuccess, onFailure) {
        return Login.sendInvite({
          uFname: user.uFname,
          uLname: user.uLname,
          email: user.email,
          company: user.company,
          reason: user.reason
        }, onSuccess, onFailure);
      }
    };
    return loginService;
  });

}).call(this);
