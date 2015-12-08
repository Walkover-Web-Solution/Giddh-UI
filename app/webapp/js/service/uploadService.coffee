'use strict'

# angular.module('giddhWebApp').service('uploadService',
#   ($modal, $confirmModalDefaults) ->
#     modalService =
#       openConfirmModal: (data, settings) ->
#         settings = angular.extend($confirmModalDefaults, settings or {})
#         data = angular.extend({}, settings.defaultLabels, data or {})
#         if 'templateUrl' of settings and 'template' of settings
#           delete settings.template
#         settings.resolve =
#           data: () ->
#             data
#         $modal.open(settings).result

#       openManageGroupsModal: () ->
#         $modal.open(
#           templateUrl: '/public/webapp/views/addManageGroupModal.html'
#           size: "liq90"
#           backdrop: 'static'
#           controller: 'groupController'
#         )

#     uploadService
# )

angular.module('giddhWebApp').service 'uploadService', [
  '$http'
  ($http) ->

    @uploadFileToUrl = (file, uploadUrl) ->
      console.log file
      fd = new FormData()
      fd.append 'files', file
      console.log fd, "service", uploadUrl
      $http.post(uploadUrl, fd,
        transformRequest: angular.identity
        headers: 'Content-Type': undefined).success(->
          console.log "upload completed"
          console.log fd, "service"
      ).error ->
          console.log "error"
      return

    return
]