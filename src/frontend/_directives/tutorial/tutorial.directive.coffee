angular.module "tsd.tutorial", []
  .directive 'tutorial', ($window, $timeout, $compile, $templateCache)->
    return {
      restrict: 'E',
      replace: true,
      scope:
        tutorialTexts: '='
        compileScope: '='
      templateUrl: '_directives/tutorial/tutorial.html'

      link: (scope, element, attrs) ->
        scope.currentStep = 0
        scope.tutorialActive = true
        stepsNames = [] #ensure that in lists the tutorial is not listed twice
        lastActiveStep = null

        scope.changeCurrentStep = (modifier)->
          scope.currentStep += modifier if scope.tutorialTexts.length >  scope.currentStep + modifier >= 0
          return

        scope.toggleTutorial = ()->
          scope.tutorialActive = !scope.tutorialActive
          return

        createFocusFunction = (index)->
          return ()->
            # console.log "jumping to index #{index}"
            scope.currentStep = index
            return

        launchTutorial = ()->
          tutorialSteps = []
          tutorialSteps = angular.element(".tutorial-step")
          for tutorialStep in tutorialSteps
            index = stepsNames.indexOf(tutorialStep.name)
            if stepsNames.indexOf(tutorialStep.name) == -1 && tutorialStep.name?
              stepsNames.push tutorialStep.name
              # console.log "Step",angular.element(tutorialStep)
            tutorialStep = angular.element(tutorialStep)
            index = if index == -1 then stepsNames.length-1 else index
            tutorialStep.bind 'focus', createFocusFunction index
            $compile(tutorialStep)(tutorialStep.scope())

          return

        highlight = (index)->
          angular.element("[name=#{stepsNames[index]}]").addClass('highlight')
          if lastActiveStep?
            angular.element("[name=#{lastActiveStep}]").removeClass('highlight')
          lastActiveStep = stepsNames[index]


        scope.$watch 'currentStep', (nVal, oVal)->
          if nVal? && nVal - 1 < stepsNames.length
            highlight nVal
          return

        scope.$watch '$viewContentLoaded', ()->
          $timeout ()->
            launchTutorial()
          , 2000
          return
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        return
    }