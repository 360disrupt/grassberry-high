angular.module "login", []
  .controller "LoginCtrl", ($rootScope, $scope, $http, $state, authUserService, Auto) ->

    self = @
    @.login = {}

    #TODO DELTE DUMMY
    #@.login.email = 'a.geissinger@gmx.de'
    @.login.email = 'geisinger@autofokus-marketing.de'
    @.login.password = 'Photonlaser0000'

    # console.log "Auto",Auto

    if Auto == true
      $http
        url: "/login/auto"
        method: "GET"
      .then (response) ->
        console.log response
        if response.data.success?
          authUserService.getUserData('permissionLevel').then (permissionLevel)->
            $rootScope.$broadcast("loggedIn")
            $state.go('root.main') if permissionLevel?
        else
          BootstrapDialog.alert({
            title: 'Fehler',
            message: 'Bitte Kundendienst kontaktieren',
            type: BootstrapDialog.TYPE_DANGER
          })

    $scope.save = () ->
      $scope.$broadcast('show-errors-check-validity')
      if $scope.loginForm.$valid
        $http
          url: "/login"
          method: "POST"
          data:
            email: self.login.email
            password: self.login.password
        .success (response) ->
          if response.success?
            authUserService.getUserData('permissionLevel').then((permissionLevel)->
              $state.go('root.main')
            )
        .error (data, status, headers, config) ->
          if(status == 401)
            BootstrapDialog.alert({
              title: 'Fehler',
              message: 'Passwort oder Email fehlerhaft',
              type: BootstrapDialog.TYPE_DANGER
            })

      else
        BootstrapDialog.alert({
          title: 'Fehlende Angaben',
          message: 'Bitte die Pflichtfelder ausfüllen!',
          type: BootstrapDialog.TYPE_DANGER
        })
      return

    return