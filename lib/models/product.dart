class Product {
  final String id, name;
  final String? brand, categoryId, barcode;
  final double purchasePrice, retailPrice, wholesalePrice;
  final int minStock;
  final bool active;
  const Product({required this.id,required this.name,this.brand,this.categoryId,this.barcode,required this.purchasePrice,required this.retailPrice,required this.wholesalePrice,this.minStock=0,this.active=true});
  factory Product.fromMap(Map<String,dynamic> m) => Product(id:m['id'].toString(),name:m['name'] as String,brand:m['brand'] as String?,categoryId:m['category_id'] as String?,barcode:m['barcode'] as String?,purchasePrice:(m['purchase_price'] as num?)?.toDouble()??0,retailPrice:(m['retail_price'] as num?)?.toDouble()??0,wholesalePrice:(m['wholesale_price'] as num?)?.toDouble()??0,minStock:(m['min_stock'] as num?)?.toInt()??0,active:(m['is_active'] as bool?)??true);
}
