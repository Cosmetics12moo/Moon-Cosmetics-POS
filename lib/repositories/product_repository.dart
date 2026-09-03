import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../core/db.dart';
import '../models/product.dart';
class ProductRepository {
  final _uuid=const Uuid();
  Future<List<Product>> all() async { final db=await PosDb.instance.connection; final rows=await db.execute('SELECT id,name,brand,category_id,barcode,purchase_price,retail_price,wholesale_price,min_stock,is_active FROM products WHERE is_active=TRUE ORDER BY name'); return rows.map((r)=>Product.fromMap(r.toColumnMap())).toList(); }
  Future<void> add({required String name,String? brand,String? categoryId,String? barcode,double purchasePrice=0,double retailPrice=0,double wholesalePrice=0,int minStock=0}) async { final db=await PosDb.instance.connection; await db.execute(Sql.named('INSERT INTO products(id,name,brand,category_id,barcode,purchase_price,retail_price,wholesale_price,min_stock) VALUES(@id,@name,@brand,@category_id,@barcode,@purchase,@retail,@wholesale,@min_stock)'),parameters:{'id':_uuid.v4(),'name':name.trim(),'brand':brand,'category_id':categoryId,'barcode':barcode,'purchase':purchasePrice,'retail':retailPrice,'wholesale':wholesalePrice,'min_stock':minStock}); }
}
