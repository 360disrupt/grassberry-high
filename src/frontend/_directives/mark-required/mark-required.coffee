angular.module 'tsd.markRequired', []
  .directive 'markRequired', ($window, $rootScope) ->
    return {
      restrict: 'A',
      link: (scope, element, attrs) ->
        mark =(inputLabel)->
          inputLabel.classList.add('text-required')
          return

        unMarkLabel =(inputLabel)->
          if inputLabel.innerHTML.charAt(inputLabel.innerHTML.length - 1) == '*'
            inputLabel.innerHTML = inputLabel.innerHTML.substring(0, inputLabel.innerHTML.length - 1)
          inputLabel.classList.remove('text-required')
          return

        unMarkInputElement = (inputElement)->
          inputElement.classList.remove('ng-invalid','ng-invalid-required')
          return

        isRequired = (elementToCheck)->
          return angular.element(elementToCheck)[0].required
          # return elementToCheck.required || ( elementToCheck.attributes['ng-required']? && elementToCheck.attributes['ng-required'].value == "true")

        getInputElement = (formGroup)->
          inputElement = formGroup.querySelector('input,select')

        getLabel = (formGroup, needsToBeRequired)->
          inputLabel = formGroup.querySelector('label')
          inputElement = formGroup.querySelector('input,select')
          required = if needsToBeRequired == true then inputElement? && isRequired(inputElement)  else true
          if inputElement? && required == true && inputLabel? then return inputLabel else return null

        formGroups = element[0].querySelectorAll('.form-group')
        for formGroup in formGroups
          inputLabel = getLabel(formGroup, true)
          mark(inputLabel) if inputLabel?

        scope.$on "newRequiredInputGroup", (event, id)->
          formGroup = angular.element("##{id}").closest(".form-group")[0]
          if formGroup?
            inputLabel = getLabel(formGroup, true)
            mark(inputLabel) if inputLabel?

        scope.$on "removeRequiredInputGroup", (event, id, callback)->
          receivedElement = angular.element("##{id}")
          # console.log "id: #{id}", receivedElement
          if receivedElement?
            formGroup = receivedElement.parent()[0]
            # console.log "formGroup", formGroup, angular.element(formGroup)
            if formGroup?
              inputLabel = getLabel(formGroup, false)
              inputElement = getInputElement(formGroup)
              unMarkLabel(inputLabel) if inputLabel?
              unMarkInputElement(inputElement) if inputElement?
            return callback()
        return
    }