class PurchaseLine {
  String productId, productName;
  double quantity, purchaseCost, tradeOfferPct, purchaseDiscountPct, salePrice;
  PurchaseLine({required this.productId, required this.productName, this.quantity=1, this.purchaseCost=0, this.tradeOfferPct=0, this.purchaseDiscountPct=0, this.salePrice=0});
  double get gross => quantity * purchaseCost;
  double get discount => gross * purchaseDiscountPct / 100;
  double get net => gross - discount;
  double get bonusQuantity => quantity * tradeOfferPct / 100;
  double get receivedQuantity => quantity + bonusQuantity;
}
class PurchaseDraft {
  String? vendorId, vendorName, paymentAccountId, billNumber;
  DateTime date = DateTime.now();
  double billDiscountPct=0, expensesPct=0, paidAmount=0;
  final List<PurchaseLine> lines=[];
  double get subtotal => lines.fold(0,(s,l)=>s+l.net);
  double get billDiscount => subtotal * billDiscountPct/100;
  double get expenses => (subtotal-billDiscount) * expensesPct/100;
  double get total => subtotal-billDiscount+expenses;
  double get balance => total-paidAmount;
}
