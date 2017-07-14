angular.module "tsd.stretchFlexbox", ['matchmedia-ng']
  .directive 'stretchFlexbox', ($window, $timeout, matchmedia)->
    return {
      restrict: 'A',
      link: (scope, element, attrs) ->
        init = false

        resizeId = null
        angular.element($window).on 'resize', ->
          $timeout.cancel(resizeId)
          resizeId = $timeout(stretch, 500)

        stretch = ()->
          init = true
          buttonRow = element.find('.row:nth-last-of-type(1)')
          # console.log "buttonRow",buttonRow
          element.css('min-height', 0)
          buttonRow.css('position', 'relative').css('bottom', 'auto')

          if matchmedia.is '(max-width: 768px)'
            element.parent().css('text-align', 'center')
            buttonRow.css('text-align', 'center')
            element.css('min-height', element.parent().height())
          else
            element.css('min-height', element.parent().height())
            element.parent().css('text-align', 'inherit')
            buttonRow.css('position', 'absolute').css('bottom', '2rem')

        scope.$on '$viewContentLoaded', ()->
          stretch()

        stretch() if init == false
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        return
    }