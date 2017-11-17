angular.module "adminTools", ['adminMenu']
  .constant('statesAdminTools', [
    # {
    # name: "root.login",
    # data:
    #   allowedRoles: ['admin']
    # options:
    #   url: "/login"
    #   views:
    #     '@':
    #       templateUrl: "admin-tools/login/login.html"
    #       controller: "LoginCtrl"
    #       controllerAs: "loginController"
    #     'footer@':
    #       templateUrl: "footer/footer.html"
    #       controller: "FooterCtrl"
    #       controllerAs: "footerController"
    # }
    # {
    {
    name: "root.admin",
    data:
      allowedRoles: ['admin']
    options:
      url: "/admin"
      views:
        'container@':
          templateUrl: "admin-tools/admin-menu/admin-menu.html"
          controller: "AdminMenuCtrl"
          controllerAs: "adminMenuController"
    }
  ])
  .config(['$stateProvider', ($stateProvider) ->])