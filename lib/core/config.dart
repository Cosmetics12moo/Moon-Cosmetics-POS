class PosConfig {
  static const host = String.fromEnvironment('POS_DB_HOST', defaultValue: '127.0.0.1');
  static const port = int.fromEnvironment('POS_DB_PORT', defaultValue: 5432);
  static const database = String.fromEnvironment('POS_DB_NAME', defaultValue: 'moon_cosmetics');
  static const username = String.fromEnvironment('POS_DB_USER', defaultValue: 'postgres');
  static const password = String.fromEnvironment('POS_DB_PASSWORD', defaultValue: '');
  static const shopName = 'Moon Cosmetics & Beauty Shop';
  static const logoAsset = 'assets/moon_logo.png';
}
