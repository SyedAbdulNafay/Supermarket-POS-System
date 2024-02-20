import 'grocery.dart';

class Cart { 
  List<GroceryItem> items = [];

  void addItem(GroceryItem item) { 
    items.add(item); 
  }

  void removeItem(GroceryItem item) {
    items.remove(item); 
  }

  void clear() { 
    items.clear(); 
  }

  double get totalPrice => items.fold(0, (total, item) => total + item.quantity * item.price); 
}