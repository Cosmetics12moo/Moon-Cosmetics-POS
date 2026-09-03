class ProductCategory {
  final String id, name;
  final bool active;
  const ProductCategory({required this.id,required this.name,this.active=true});
  factory ProductCategory.fromMap(Map<String,dynamic> m) => ProductCategory(id:m['id'].toString(),name:m['name'] as String,active:(m['is_active'] as bool?)??true);
}
