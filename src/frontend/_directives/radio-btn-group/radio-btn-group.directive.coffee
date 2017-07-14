angular.module 'tsd.radioBtnGroup', ['ui.bootstrap']
  .directive "radioBtnGroup", () ->
    return {
      restrict: 'E',
      replace: true,
      templateUrl: '_directives/radio-btn-group/radio-btn-group.html'
      scope:
        model: '='
        label: '@'
        class: '@?'
        radioOptions: '='
        otherInput: '@?'
        otherInline: '@?'
        break: '@?'
      link: (scope, element, attrs) ->
        return
    }