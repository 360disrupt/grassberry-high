angular.module "grassberryHigh", ['ngAnimate', 'ngCookies', 'ngSanitize', 'ngResource', 'ui.router', 'ui.bootstrap', "ui.bootstrap.showErrors", 'ngLocale', 'ngFlash', 'ngIdle', 'myAnchorSmoothScroll', 'myAuthUserService','root', 'dashboard', 'feedback', 'subscription', 'setup', 'login','adminTools', 'header', 'angularMoment']
  .config ($stateProvider, $urlRouterProvider, showErrorsConfigProvider, IdleProvider, KeepaliveProvider, statesSetup, statesDashboard, statesFeedback, statesSubscription, statesAdminTools) ->
    showErrorsConfigProvider.showSuccess true
    $stateProvider
      .state "root",
        views:
          "header@":
            templateUrl: "common/header/header.html"
            controller: "HeaderCtrl"
            controllerAs: "headerController"
          "footer@":
            templateUrl: "common/footer/footer.html"
            controller: "RootCtrl"
            controllerAs: "rootController"
        resolve:
          user: (authUserService)->
            if authUserService.isLoggedIn()
              return true
            else
              authUserService.getUserData('permissionLevel').then((permissionLevel)->
                return true
              )
      .state 'root.login',
        url: '/login',
        views:
          'container@':
            templateUrl: "common/login/login.html"
            controller: "LoginCtrl"
            controllerAs: "loginController"
        resolve:
          Auto: ()->
            return false
      .state "root.imprint",
        url: '/impressum'
        views:
          'container@':
            templateUrl: "common/imprint/imprint.html"
            # controller: "ImprintCtrl"
            # controllerAs: "imprintController"
      .state "root.styleguide",
        url: '/style'
        views:
          'container@':
            templateUrl: "common/styleguide/styleguide.html"
            controller: "StyleGuideCtrl"
            controllerAs: "styleGuideController"
      .state "root.error",
        url: '/error'
        resolve:
          errorObj: () ->
            return this.error
        views:
          'container@':
            templateUrl: "error/error.html"
            controller: "ErrorCtrl"
            controllerAs: "errorController"
    angular.forEach(statesAdminTools, (state) ->
      $stateProvider.state(state.name, state.options)
    )
    angular.forEach(statesSetup, (state) ->
      $stateProvider.state(state.name, state.options)
    )
    angular.forEach(statesDashboard, (state) ->
      $stateProvider.state(state.name, state.options)
    )
    angular.forEach(statesFeedback, (state) ->
      $stateProvider.state(state.name, state.options)
    )
    angular.forEach(statesSubscription, (state) ->
      $stateProvider.state(state.name, state.options)
    )
    $urlRouterProvider.otherwise '/dashboard'

    IdleProvider.idle(3)
    IdleProvider.timeout(300)
    KeepaliveProvider.interval(2)

  .run ($rootScope, $state, Idle, authUserService) ->
    Idle.watch()
    $rootScope.permissionCheck = (event, toState, $state, authUserService) ->
      if toState.name is "root.login"
        console.log "login route"
        true
      else if toState.name != "root.login" && !authUserService.isLoggedIn() && toState.data?.allowedRoles?
        event.preventDefault()
        console.log "not logged in sending from #{toState.name} to login"
        $state.go "root.login"
        true
      #If user is not logged in and has no permission send him back to login
      else if toState.data?.allowedRoles? && !authUserService.checkPermission(toState.data.allowedRoles)
        console.log "not authorized"
        event.preventDefault()
        $state.go "root.login"
        BootstrapDialog.alert({
          title: 'Erforderliche Rechte fehlen',
          message: 'Bitte mit Account, der die erforderlichen Rechte besitzt einloggen.',
          type: BootstrapDialog.TYPE_DANGER
        })
        false

    $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
      if authUserService.isLoggedIn()
        $rootScope.permissionCheck(event, toState, $state, authUserService)
      else
        authUserService.getUserData('permissionLevel').then((permissionLevel)->
          $rootScope.permissionCheck(event, toState, $state, authUserService)
        )

    $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error)->
      event.preventDefault()
      console.error error
      # $state.get('error').error = { code: 123, description: 'Exception stack trace' }
      return $state.go('error', {errorObj: error})


    return


