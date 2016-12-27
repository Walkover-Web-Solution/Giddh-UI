SettingsTaxController = ($rootScope, Upload, $timeout, toastr) ->

  @Upload = Upload
  @$rootScope = $rootScope
  @$timeout = $timeout
  @toastr = toastr
  # assign universal this for ctrl
  $this = @;

  console.log("in SettingsTaxController")
  
  # local vars for tax module
  @taxTypes = [
    "MONTHLY"
    "YEARLY"
    "QUATERLY"
    "HALFYEARLY"
  ]
 
  # functions for tax module
  @getTax = ->
    console.log "in getTax"
  
  return

SettingsTaxController.$inject = ['$rootScope', 'Upload', '$timeout', 'toastr']

giddh.webApp.controller('settingsTaxController', SettingsTaxController)