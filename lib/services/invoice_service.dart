import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/config.dart';
class InvoiceService {
  Future<Uint8List> buildInvoice({required String invoiceNumber,required List<Map<String,dynamic>> items,required double subtotal,required double discount,required double total,required double paid}) async {
    final doc=pw.Document();
    final logo=await imageFromAssetBundle(PosConfig.logoAsset);
    doc.addPage(pw.Page(build:(_)=>pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.stretch,children:[pw.Center(child:pw.Image(logo,height:70)),pw.Center(child:pw.Text(PosConfig.shopName,style:pw.TextStyle(fontSize:16,fontWeight:pw.FontWeight.bold))),pw.SizedBox(height:8),pw.Text('Invoice: $invoiceNumber'),pw.Divider(),...items.map((i)=>pw.Row(children:[pw.Expanded(child:pw.Text('${i['name']}')),pw.Text('${i['qty']} x ${i['price']}')])),pw.Divider(),pw.Text('Subtotal: Rs. ${subtotal.toStringAsFixed(2)}'),pw.Text('Discount: Rs. ${discount.toStringAsFixed(2)}'),pw.Text('Total: Rs. ${total.toStringAsFixed(2)}'),pw.Text('Paid: Rs. ${paid.toStringAsFixed(2)}'),pw.Text('Due: Rs. ${(total-paid).toStringAsFixed(2)}'),pw.SizedBox(height:12),pw.Center(child:pw.Text('Thank you for shopping with us!'))])));
    return doc.save();
  }
  Future<void> printInvoice(Uint8List bytes)=>Printing.layoutPdf(onLayout:(_)=>bytes);
}
