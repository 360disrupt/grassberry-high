angular.module 'myAnchorSmoothScroll' ,[]
  .directive 'anchorSmoothScroll', ($location) ->
    'use strict'
    {
      restrict: 'A'
      replace: false
      link: (scope, element, attrs) ->
        bindEvent = attrs.bindEvent || 'click'

        initialize = ->
          createEventListeners()
          return

        createEventListeners = ->
          element.on bindEvent, ->
            # console.log "scroll to id",attrs.scrollTo
            $location.hash attrs.scrollTo
            scrollTo attrs.scrollTo
            return
          return

        scrollTo = (eID) ->
          i = undefined
          startY = currentYPosition()
          stopY = elmYPosition(eID)
          if stopY?
            distance = if stopY > startY then stopY - startY else startY - stopY
            if distance < 100
              scrollTo 0, stopY
              return
            speed = Math.round(distance / 100)
            if speed >= 20
              speed = 20
            step = Math.round(distance / 25)
            leapY = if stopY > startY then startY + step else startY - step
            timer = 0
            if stopY > startY
              i = startY
              while i < stopY
                setTimeout 'window.scrollTo(0, ' + leapY + ')', timer * speed
                leapY += step
                if leapY > stopY
                  leapY = stopY
                timer++
                i += step
              return
            i = startY
            while i > stopY
              setTimeout 'window.scrollTo(0, ' + leapY + ')', timer * speed
              leapY -= step
              if leapY < stopY
                leapY = stopY
              timer++
              i -= step
          return

        currentYPosition = ->
          if window.pageYOffset
            return window.pageYOffset
          if document.documentElement and document.documentElement.scrollTop
            return document.documentElement.scrollTop
          if document.body.scrollTop
            return document.body.scrollTop
          0

        elmYPosition = (eID) ->
          elm = document.getElementById(eID)
          # console.log "element ID", eID, elm
          if elm?
            y = elm.offsetTop
            node = elm
            while node.offsetParent and node.offsetParent != document.body
              node = node.offsetParent
              y += node.offsetTop
            y
          else null

        initialize()
        return

    }