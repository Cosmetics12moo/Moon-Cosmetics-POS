import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../core/db.dart';
import '../models/category.dart';
class CategoryRepository {
  final _uuid=const Uuid();
  Future<List<ProductCategory>> all() async { final db=await PosDb.instance.connection; final rows=await db.execute('SELECT id,name,is_active FROM categories WHERE is_active=TRUE ORDER BY name'); return rows.map((r)=>ProductCategory.fromMap(r.toColumnMap())).toList(); }
  Future<void> add(String name) async { final db=await PosDb.instance.connection; await db.execute(Sql.named('INSERT INTO categories(id,name) VALUES(@id,@name)'),parameters:{'id':_uuid.v4(),'name':name.trim()}); }
  Future<void> rename(String id,String name) async { final db=await PosDb.instance.connection; await db.execute(Sql.named('UPDATE categories SET name=@name WHERE id=@id'),parameters:{'id':id,'name':name.trim()}); }
  Future<void> deactivate(String id) async { final db=await PosDb.instance.connection; await db.execute(Sql.named('UPDATE categories SET is_active=FALSE WHERE id=@id'),parameters:{'id':id}); }
}
