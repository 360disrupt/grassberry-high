angular.module("myAuthUserService", ['websockets']).service("authUserService", ($http, $rootScope, $state, $cookies, $q, $log, chatSocket) ->
  self = @
  @.user = null
  @.instanceType = null
  @.maintainance = null

  @.getUserFromBackend = () ->#getUserInstituteAndFieldFromBackend
    $http
      url: "/getAppUser"
      method: "GET"
    .then((response) ->
      user = response.data
      self.user = {}
      self.user._id = user._id if user._id?
      self.user.lastName = user.lastName if user.lastName?
      self.user.firstName = user.firstName if user.firstName?
      self.user.permissionLevel = user.permissionLevel if user.permissionLevel?

      # console.log "got user from backend", self.user
      if user.permissionLevel? && user._id?
        chatSocket.emit('loggedIn', {"userId": user._id})
      return self.user.permissionLevel
    )

  @.getUserData = (field) ->
    # console.log field, self.user
    if !self.user? || !self.user.permissionLevel?
      @.getUserFromBackend().then (permissionLevel)->
        if permissionLevel?
          return self.getUserData(field)
        else
          return null
    else
      defer = $q.defer()
      switch field
        when 'all'
          defer.resolve(self.user)
        when 'userId'
          defer.resolve(self.user._id)
        when 'lastName'
          defer.resolve(self.user.lastName)
        when 'permissionLevel'
          defer.resolve(self.user.permissionLevel)
        else
          console.log "no valid user data request"
          defer.reject()
      return defer.promise

  @.isLoggedIn = () ->
    return @.user?.permissionLevel? && @.user.permissionLevel != null

  @.logOut = () ->
    $http
      url: "/logout"
      method: "GET"
    .then((response) ->
      if response.data.success?
        self.user = null
        $rootScope.$broadcast('loggedOut')
        chatSocket.emit('loggedOut')
        # console.log "logged out", response
        $state.go "root.login"
      else
        console.log "no logout", response
    )


  @.checkPermission = (permissions) ->
    if !self.user?.permissionLevel?
      return false
    if typeof permissions == 'object'
      return permissions.some((permission) -> permission == self.user.permissionLevel)
    else if typeof permissions == 'string'
      return permissions == self.user.permissionLevel
    else
      return false


  @.checkForMaintainance = ()->
    if self.maintainance?
      defer = $q.defer()
      defer.resolve(self.maintainance)
      return defer.promise
    $http(
      url: "/maintainance/"
      method: "GET"
    ).then (response)->
      if response.data?.maintainance?.date?
        if moment().diff(response.data.maintainance.date) > 0 #maintaince date is older as the current date
          response.data.maintainance.date = null
        else
          response.data.maintainance.date = moment(response.data.maintainance.date).format('DD.MM.YYYY') + ' um ' +moment(response.data.maintainance.date).format('HH:mm')
        self.maintainance = response.data.maintainance
        return response.data.maintainance
      else
        return null

#////////////////////////////////////////////////////////////////////
  return
)