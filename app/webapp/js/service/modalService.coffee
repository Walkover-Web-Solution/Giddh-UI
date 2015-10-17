'use strict'

angular.module('giddhWebApp').service('modalService',
  ($modal, $confirmModalDefaults) ->
    modalService =
      openConfirmModal: (data, settings) ->
        settings = angular.extend($confirmModalDefaults, settings or {})
        data = angular.extend({}, settings.defaultLabels, data or {})
        if 'templateUrl' of settings and 'template' of settings
          delete settings.template
        settings.resolve =
          data: () ->
            data
        $modal.open(settings).result

      openManageGroupsModal: () ->
        $modal.open(
          templateUrl: '/public/webapp/views/addManageGroupModal.html'
          size: "liq90"
          backdrop: 'static'
          controller: 'groupController'
        )

    modalService
)