enum MainRoutes {
  welcome('/welcome'),
  home('/home'),
  coinDetails('/coin-details');

  const MainRoutes(this.route);

  final String route;
}
