import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../core/db.dart';

class PurchaseLineInput {
  final String productId;
  final int quantity;
  final double purchaseCost;
  final double tradeOfferPercent;
  final double purchaseDiscountPercent;
  final double salePrice;
  const PurchaseLineInput({required this.productId,required this.quantity,required this.purchaseCost,required this.tradeOfferPercent,required this.purchaseDiscountPercent,required this.salePrice});
}

class PurchaseRepository {
  final _uuid = const Uuid();

  Future<List<Map<String,dynamic>>> products() async {
    final db = await PosDb.instance.connection;
    final rows = await db.execute('SELECT id,name,brand,barcode,purchase_price,retail_price FROM products WHERE is_active=TRUE ORDER BY name');
    return rows.map((r)=>r.toColumnMap()).toList();
  }

  Future<List<Map<String,dynamic>>> vendors(String search) async {
    final db = await PosDb.instance.connection;
    final rows = await db.execute(Sql.named('SELECT id,name,phone,opening_balance FROM suppliers WHERE name ILIKE @q ORDER BY name LIMIT 50'), parameters:{'q':'%${search.trim()}%'});
    return rows.map((r)=>r.toColumnMap()).toList();
  }

  Future<List<Map<String,dynamic>>> accounts() async {
    final db = await PosDb.instance.connection;
    final rows = await db.execute('SELECT id,name,balance FROM accounts ORDER BY name');
    return rows.map((r)=>r.toColumnMap()).toList();
  }

  Future<String> save({required String vendorName, required String billNumber, required String accountId, required DateTime date, required double billDiscountPercent, required double expensesPercent, required double paidAmount, required List<PurchaseLineInput> lines}) async {
    if (vendorName.trim().isEmpty) throw Exception('Vendor is required.');
    if (billNumber.trim().isEmpty) throw Exception('Bill Number is required.');
    if (accountId.isEmpty) throw Exception('Payment Account is required.');
    if (lines.isEmpty) throw Exception('Add at least one product.');
    if (lines.any((x)=>x.quantity<=0 || x.purchaseCost<0 || x.salePrice<0 || x.tradeOfferPercent<0 || x.purchaseDiscountPercent<0 || x.purchaseDiscountPercent>100 || x.tradeOfferPercent>100)) throw Exception('Invalid purchase values.');

    final db = await PosDb.instance.connection;
    final purchaseId = _uuid.v4();
    await db.runTx((ctx) async {
      final supplierRows = await ctx.execute(Sql.named('SELECT id FROM suppliers WHERE LOWER(name)=LOWER(@name) LIMIT 1'), parameters:{'name':vendorName.trim()});
      String supplierId;
      if (supplierRows.isEmpty) {
        supplierId = _uuid.v4();
        await ctx.execute(Sql.named('INSERT INTO suppliers(id,name) VALUES(@id,@name)'), parameters:{'id':supplierId,'name':vendorName.trim()});
      } else {
        supplierId = supplierRows.first.toColumnMap()['id'].toString();
      }
      final dup = await ctx.execute(Sql.named('SELECT id FROM purchases WHERE supplier_id=@sid AND bill_number=@bill LIMIT 1'), parameters:{'sid':supplierId,'bill':billNumber.trim()});
      if (dup.isNotEmpty) throw Exception('This bill number already exists for this vendor.');

      double subtotal=0, productDiscount=0;
      for (final x in lines) { final gross=x.quantity*x.purchaseCost; subtotal+=gross; productDiscount+=gross*x.purchaseDiscountPercent/100; }
      final afterProduct = subtotal-productDiscount;
      final billDiscountAmount=afterProduct*billDiscountPercent/100;
      final expensesBase=afterProduct-billDiscountAmount;
      final expensesAmount=expensesBase*expensesPercent/100;
      final total=expensesBase+expensesAmount;
      if (paidAmount<0 || paidAmount>total+0.005) throw Exception('Paid Amount cannot exceed Total Amount.');
      final balance=total-paidAmount;

      await ctx.execute(Sql.named('INSERT INTO purchases(id,supplier_id,bill_number,payment_account_id,bill_discount_percent,bill_discount_amount,expenses_percent,expenses_amount,subtotal,product_discount_amount,total_amount,paid_amount,balance_amount,date) VALUES(@id,@sid,@bill,@acc,@bdp,@bda,@ep,@ea,@sub,@pda,@total,@paid,@bal,@date)'), parameters:{'id':purchaseId,'sid':supplierId,'bill':billNumber.trim(),'acc':accountId,'bdp':billDiscountPercent,'bda':billDiscountAmount,'ep':expensesPercent,'ea':expensesAmount,'sub':subtotal,'pda':productDiscount,'total':total,'paid':paidAmount,'bal':balance,'date':date});

      for (final x in lines) {
        final gross=x.quantity*x.purchaseCost;
        final pdisc=gross*x.purchaseDiscountPercent/100;
        final net=gross-pdisc;
        final tradeQty=(x.quantity*x.tradeOfferPercent/100).round();
        final totalStockQty=x.quantity+tradeQty;
        final billAllocation=(afterProduct==0?0:(billDiscountAmount-expensesAmount)/afterProduct)*net;
        final effectiveTotal=net-billAllocation+ (afterProduct==0?0:expensesAmount*net/afterProduct);
        final effectiveUnit=totalStockQty>0?effectiveTotal/totalStockQty:0;
        final batchId=_uuid.v4();
        await ctx.execute(Sql.named('INSERT INTO product_batches(id,product_id,purchase_price,quantity,created_at,is_active) VALUES(@id,@pid,@price,@qty,@date,TRUE)'), parameters:{'id':batchId,'pid':x.productId,'price':effectiveUnit,'qty':totalStockQty,'date':date});
        await ctx.execute(Sql.named('INSERT INTO purchase_items(id,purchase_id,product_id,batch_id,quantity,purchase_price,total,trade_offer_percent,trade_offer_quantity,purchase_discount_percent,purchase_discount_amount,sale_price,net_cost) VALUES(@id,@purchase,@pid,@batch,@qty,@cost,@total,@tp,@tq,@dp,@da,@sale,@net)'), parameters:{'id':_uuid.v4(),'purchase':purchaseId,'pid':x.productId,'batch':batchId,'qty':x.quantity,'cost':x.purchaseCost,'total':gross,'tp':x.tradeOfferPercent,'tq':tradeQty,'dp':x.purchaseDiscountPercent,'da':pdisc,'sale':x.salePrice,'net':net});
        await ctx.execute(Sql.named('UPDATE products SET purchase_price=@p,retail_price=CASE WHEN @sale>0 THEN @sale ELSE retail_price END WHERE id=@id'), parameters:{'p':effectiveUnit,'sale':x.salePrice,'id':x.productId});
      }
      if (paidAmount>0) await ctx.execute(Sql.named('UPDATE accounts SET balance=balance-@amt WHERE id=@id'), parameters:{'amt':paidAmount,'id':accountId});
      await ctx.execute(Sql.named('INSERT INTO supplier_ledger(id,supplier_id,type,amount,reference_id,date,notes) VALUES(@id,@sid,\'PURCHASE\',@amount,@ref,@date,@notes)'), parameters:{'id':_uuid.v4(),'sid':supplierId,'amount':total,'ref':purchaseId,'date':date,'notes':'Vendor bill '+billNumber.trim()});
      if (paidAmount>0) await ctx.execute(Sql.named('INSERT INTO supplier_ledger(id,supplier_id,type,amount,reference_id,date,notes) VALUES(@id,@sid,\'PAYMENT\',@amount,@ref,@date,@notes)'), parameters:{'id':_uuid.v4(),'sid':supplierId,'amount':paidAmount,'ref':purchaseId,'date':date,'notes':'Payment for vendor bill '+billNumber.trim()});
      if (expensesAmount>0) await ctx.execute(Sql.named('INSERT INTO expenses(id,category,account_id,amount,date,description) VALUES(@id,\'Purchase Expenses\',@acc,@amount,@date,@desc)'), parameters:{'id':_uuid.v4(),'acc':accountId,'amount':expensesAmount,'date':date,'desc':'Expenses on vendor bill '+billNumber.trim()});
    });
    return purchaseId;
  }

  Future<List<Map<String,dynamic>>> previousBills(String vendorName) async {
    final db=await PosDb.instance.connection;
    final rows=await db.execute(Sql.named('SELECT p.id,p.bill_number,p.date,p.total_amount,p.paid_amount,p.balance_amount,s.name vendor FROM purchases p LEFT JOIN suppliers s ON s.id=p.supplier_id WHERE (@name=\'\' OR s.name ILIKE @q) ORDER BY p.date DESC LIMIT 100'),parameters:{'name':vendorName.trim(),'q':'%${vendorName.trim()}%'});
    return rows.map((r)=>r.toColumnMap()).toList();
  }

  Future<Map<String,dynamic>> vendorSummary(String vendorName) async {
    final db=await PosDb.instance.connection;
    final rows=await db.execute(Sql.named('SELECT s.id,s.name,s.phone,s.opening_balance,COALESCE(SUM(p.total_amount),0) purchases,COALESCE(SUM(p.paid_amount),0) paid,COALESCE(SUM(p.balance_amount),0) balance FROM suppliers s LEFT JOIN purchases p ON p.supplier_id=s.id WHERE LOWER(s.name)=LOWER(@name) GROUP BY s.id,s.name,s.phone,s.opening_balance'),parameters:{'name':vendorName.trim()});
    if(rows.isEmpty) return {'name':vendorName,'opening_balance':0,'purchases':0,'paid':0,'balance':0};
    return rows.first.toColumnMap();
  }
}
