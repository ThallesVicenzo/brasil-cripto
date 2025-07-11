enum UrlPaths {
  search('coins/markets'),
  chartData('coins/{id}/market_chart');

  final String serviceName;

  String get _defaultPath => 'https://api.coingecko.com/api/v3/';

  String get endPoint => '$_defaultPath$serviceName';

  const UrlPaths(this.serviceName);

  String buildUrl(Map<String, String> params) {
    String result = endPoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
