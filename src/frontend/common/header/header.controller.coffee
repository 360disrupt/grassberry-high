angular.module "header", ['websockets', 'myAuthUserService', 'ui.bootstrap', 'tsd.reaper', 'mySystemService']
  .controller "HeaderCtrl", ($scope, $rootScope, $state, $log, $window, $q, $timeout, $location, chatSocket, systemService, authUserService) ->
    self = @
    @.user = {}

    @.checkPermission = (userType) ->
      authUserService.checkPermission(userType)

    @.isLoggedIn = () ->
      authUserService.isLoggedIn()

    @.logOut = (vitabook) ->
      authUserService.logOut()
      return

    @.getUser = ()->
      authUserService.getUserData('all').then (user)->
        self.user = user
        return self.user

    @.checkLicense = ()->
      systemService.checkLicense().then (system)->
        self.system = system
        self.updateDaysLeft()

    @.updateDaysLeft = ()->
      timeLeftInDays = moment(self.system.validTill).diff(moment(), 'days') if self.system?.validTill?
      self.timeLeftInDays = timeLeftInDays if timeLeftInDays?

    @.reboot = ()->
      systemService.reboot()

    $scope.showFeedback = ()->
      return $state.current.name != 'root.feedback'

    $rootScope.$on("loggedIn", ()->
      $timeout self.getUser()
      ,100
    )

    $rootScope.$on('loggedOut', (event) ->
      self.user = {}
    )

    $rootScope.$on "socket:system", (event, data) ->
      if data.id == 'update'
        BootstrapDialog.alert({
          title: data.title,
          message: data.message,
          type: BootstrapDialog.TYPE_INFO
        })




    systemService.getSystem().then (system)->
      self.system = system
      self.updateDaysLeft()
    @.getUser()
#//////////////////////////////////////////////////////////////////////////////////////////////
    return