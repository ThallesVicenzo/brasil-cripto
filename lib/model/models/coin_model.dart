class CoinModel {
  final String id;
  final String name;
  final String? symbol;
  final String image;
  final double currentPrice;
  final double priceChangePercertage24h;
  final double marketCap;
  final int marketCapRank;

  CoinModel({
    required this.id,
    this.name = '',
    this.symbol = '',
    this.image = '',
    this.marketCapRank = 0,
    this.currentPrice = 0.0,
    this.priceChangePercertage24h = 0.0,
    this.marketCap = 0.0,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      image: json['image'] as String,
      marketCapRank: json['market_cap_rank'] as int,
      currentPrice: (json['current_price'] as num).toDouble(),
      priceChangePercertage24h:
          (json['price_change_percentage_24h'] as num).toDouble(),
      marketCap: (json['market_cap'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'symbol': symbol,
      'market_cap_rank': marketCapRank,
      'current_price': currentPrice,
      'price_change_percentage_24h': priceChangePercertage24h,
      'market_cap': marketCap,
    };
  }
}
