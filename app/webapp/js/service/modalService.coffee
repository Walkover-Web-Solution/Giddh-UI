'use strict'

angular.module('giddhWebApp').service('modalService',
  ($uibModal, $confirmModalDefaults) ->
    modalService =
      openConfirmModal: (data, settings) ->
        settings = angular.extend($confirmModalDefaults, settings or {})
        data = angular.extend({}, settings.defaultLabels, data or {})
        if 'templateUrl' of settings and 'template' of settings
          delete settings.template
        settings.resolve =
          data: () ->
            data
        $uibModal.open(settings).result

      openManageGroupsModal: () ->
        $uibModal.open(
          templateUrl: '/public/webapp/views/addManageGroupModal.html'
          size: "liq90"
          backdrop: 'static'
          controller: 'groupController'
        )

    modalService
)