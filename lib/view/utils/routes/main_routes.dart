enum MainRoutes {
  welcome('/welcome'),
  home('/home'),
  coinDetails('/coin-details'),
  favorites('/favorites');

  const MainRoutes(this.route);

  final String route;
}
