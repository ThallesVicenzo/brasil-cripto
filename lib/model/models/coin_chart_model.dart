class CoinChartModel {
  final List<double> prices;
  final List<double> marketCaps;
  final List<int> totalVolumes;

  CoinChartModel({
    this.prices = const [],
    this.marketCaps = const [],
    this.totalVolumes = const [],
  });

  factory CoinChartModel.fromJson(Map<String, dynamic> json) {
    return CoinChartModel(
      prices: _extractPricesFromArray(json['prices']),
      marketCaps: _extractPricesFromArray(json['market_caps']),
      totalVolumes: _extractVolumesFromArray(json['total_volumes']),
    );
  }

  static List<double> _extractPricesFromArray(dynamic data) {
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((item) => (item[1] as num).toDouble())
        .toList();
  }

  static List<int> _extractVolumesFromArray(dynamic data) {
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((item) => (item[1] as num).toInt())
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'prices': prices,
      'market_caps': marketCaps,
      'total_volumes': totalVolumes,
    };
  }
}
