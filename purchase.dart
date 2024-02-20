import 'cart.dart';

class Purchase { 
  DateTime date; 
  Cart cart;

  Purchase(this.date,this.cart);

  void printReceipt() {
    print('========== Receipt ==========');
    print('Date: $date');
    print('Items:');
    for (var item in cart.items) {
      print('${item.name}: ${item.quantity} x ${item.price}');
    }
    print('Total Price: ${cart.totalPrice}');
    print('============================');
  }
}