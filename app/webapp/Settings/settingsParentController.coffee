SettingsParentController = ($rootScope, Upload, $timeout, toastr) ->

  @Upload = Upload
  @$rootScope = $rootScope
  @$timeout = $timeout
  @toastr = toastr
  # assign universal this for ctrl
  $this = @;

  console.log "in SettingsParentController"
  
  # centralize vars for setting module
  @tabs = [
    {
      "heading": "Templates"
      "active": true
      "template":"/public/webapp/Settings1/invoice-temp.html"
    }
    {
      "heading": "Taxes"
      "active": false
      "template":"/public/webapp/Settings1/tax-temp.html"
    }
  ]
 
  # centralize function for setting module
  @dummyFunction = ->
    console.log "in dummyFunction"
  
  return

SettingsParentController.$inject = ['$rootScope', 'Upload', '$timeout', 'toastr']

giddh.webApp.controller('settingsParentController', SettingsParentController)