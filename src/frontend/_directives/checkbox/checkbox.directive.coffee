angular.module 'tsd.checkbox', []
  .directive 'checkbox', ($log) ->
    return {
      restrict: 'EA',
      replace: true,
      require: 'ngModel',
      scope:
        #@ reads the attribute value, = provides two-way binding, & works with functions
        # ngModel: '='
        inline: '@'
        titleYes: '@?'
        titleNo: '@?'
        ngModel: '='
      templateUrl: '_directives/checkbox/checkbox.html'
      link: (scope, element, attrs, ngModel) ->
        # console.log (scope.notDefined == 'true' && !scope.titleDefault?)

        scope.titleYes = "Yes" if !scope.titleYes?
        scope.titleNo = "No" if !scope.titleNo?

        scope.make = (value) ->
          ngModel.$setViewValue(value)
          scope.ngModel = value
          # $log.info ngModel == true, ngModel.$modelValue
          return

        return
    }

