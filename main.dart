import 'dart:io';
import 'purchase.dart';
import 'cart.dart';
import 'grocery.dart';

void main() {
  List<GroceryItem> groceryItems = loadGroceryItem();
  Cart cart = Cart();

  while (true) {
    int choice = getMainMenuChoice();

    switch (choice) {
      case 1:
        adminMenu(groceryItems);
        break;
      case 2:
        customerMenu(groceryItems, cart);
        break;
      case 3:
        exit(0);
      default:
        print('Invalid input');
    }
  }
}

List <GroceryItem> loadGroceryItem(){
  List <GroceryItem> groceryItems = [];

  try {
    File file = File('groceries.txt');
    if (file.existsSync()) {
      List <String> lines = file.readAsLinesSync();
      for (String line in lines) {
        List <String> parts = line.split(',');
        if (parts.length == 3) {
          String name = parts[0];
          int quantity = int.parse(parts[1]);
          double price = double.tryParse(parts[2]) ?? 0.0;
          groceryItems.add(GroceryItem(name, quantity, price));
        }
      }
    }
  } catch (e){
    print("Error loading grocery items: $e");
  }

  return groceryItems;
}

Continue(){
  print("Do you want to continue? y/n: ");
  var input = stdin.readLineSync();

  if (input == "y" || input == "n") {
    return input;
  } else {
    print("Incorrect Entry!");
    Continue();
  }

  return input;
}

void displayMainMenu() {
  print('Welcome to the Supermarket Management System!');
  print('1. Admin');
  print('2. Customer');
  print('3. Exit');
}

int getMainMenuChoice() {
  displayMainMenu();
  return int.parse(stdin.readLineSync() ?? '0');
}

// admin interface

void adminMenu(List<GroceryItem> groceryItems) {
  print('Admin Menu');
  print('1. Add Grocery Item');
  print('2. Remove Grocery Item');
  print('3. Update Grocery Item');
  print('4. Go back');

  var input = stdin.readLineSync();
  switch (input) {
    case '1':
      addGroceryItem(groceryItems);
      break;
    case '2':
      removeGroceryItem(groceryItems);
      break;
    case '3':
      updateGroceryItem(groceryItems);
      break;
    case '4':
      break;
    default:
      print('Invalid input');
      adminMenu(groceryItems);
  }
}

void addGroceryItem(List<GroceryItem> groceryItems) {
  print('Enter the name of the grocery item:');
  var name = stdin.readLineSync() ?? '0';

  print('Enter the quantity:');
  var quantity = int.parse(stdin.readLineSync() ?? '1');

  print('Enter the price:');
  var price = double.parse(stdin.readLineSync() ?? '1000');

  groceryItems.add(GroceryItem(name, quantity, price));

  updateGroceryFile(groceryItems);

  var input = Continue();

  if (input == 'y') {
    addGroceryItem(groceryItems);
  }
}

void removeGroceryItem(List<GroceryItem> groceryItems) {
  print('Enter the name of the grocery item to remove:');
  var name = stdin.readLineSync();

  groceryItems.removeWhere((item) => item.name == name);

  updateGroceryFile(groceryItems);

  var input = Continue();

  switch (input) {
    case "y":
      addGroceryItem(groceryItems);
      break;
    case "n":
      print("Do you want to log out of administrative role? y/n");
      var input = stdin.readLineSync();
      switch (input){
        case "y":
          getMainMenuChoice();
        default:
          adminMenu(groceryItems);
      }
      break;
    default:
  }
}

updateGroceryItem(List <GroceryItem> groceryItems){
  print('Name of the grocery item you want to update: ');
  var name = stdin.readLineSync();

  for (var item in groceryItems) {
    if (name == item.name) {
      print('What do you want to update?');
      print('1. Name');
      print('2. Price');
      print('3. Quantity');

      var input = stdin.readLineSync();
      print('What do you want to change it to?');

      switch (input) {
        case '1':
          String newName = stdin.readLineSync() ?? '${item.name}';
          item.name = newName;
          break;
        case '2':
          double newPrice = double.parse(stdin.readLineSync() ?? '${item.price}');
          item.price == newPrice;
          break;
        case '3':
          int newQuantity = int.parse(stdin.readLineSync() ?? '${item.quantity}');
          item.quantity = newQuantity;
        default:
      }
    } else {
      print("No such grocery item was found :(");
      adminMenu(groceryItems);
    }
    break;
  }

  updateGroceryFile(groceryItems);
}

// customer interface

void customerMenu(List<GroceryItem> groceryItems, Cart cart) {
  print('Customer Menu');
  print('1. Add item to cart');
  print('2. Remove item from cart');
  print('3. Checkout');
  print('4. Go back');

  var input = stdin.readLineSync();
  switch (input) {
    case '1':
      addItemToCart(groceryItems, cart);
      break;
    case '2':
      removeItemFromCart(groceryItems, cart);
      break;
    case '3':
      checkout(groceryItems, cart);
      break;
    case '4':
      break;
    default:
      print('Invalid input');
      customerMenu(groceryItems, cart);
  }
}

void addItemToCart(List<GroceryItem> groceryItems, Cart cart) {
  for (var item in groceryItems) {
    print('${item.name} (Quantity: ${item.quantity}, Price: ${item.price})');
  }

  print('Enter the name of the item to add to cart:');
  var name = stdin.readLineSync();
  var selectedItem;
  try {
   selectedItem = groceryItems.firstWhere((item) => item.name == name);
  } catch(e){
    selectedItem = null;
  }
  

  if (selectedItem != null) {
    print('Enter the quantity to add:');
    var quantity = int.parse(stdin.readLineSync() ?? '0');
    // checks if we have enough quantity
    if (quantity < selectedItem.quantity) {
      cart.addItem(GroceryItem(selectedItem.name, quantity, selectedItem.price)); //adds item into cart
      selectedItem.quantity -= quantity;
    } else {
      print("Insufficient quantity");
    }
  } else {
    print('Item not found');
  }

  updateGroceryFile(groceryItems);

  var input = Continue();

  if (input == "y") {
    addItemToCart(groceryItems, cart);
  }
}

void removeItemFromCart(List<GroceryItem> groceryItems, Cart cart) {
  for (var item in cart.items) {
    print('${item.name}: ${item.quantity}'); 
  }

  print('Enter the name of the item to remove from cart:'); 
  var name = stdin.readLineSync();
  print('How much do you want to remove? ');
  var quantity;
  var selectedItem;

  try{
    quantity = int.parse(stdin.readLineSync() ?? '0');

    selectedItem = cart.items.firstWhere((item) => item.name == name);
    var listItem = groceryItems.firstWhere((item) => item.name == name);

    if (quantity == selectedItem.quantity){
      cart.removeItem(selectedItem);
      listItem.quantity += int.parse(selectedItem.quantity); // add the quantity of items taken back into the file
  
      print('Item removed');
    } else if(quantity < selectedItem.quantity){
      selectedItem.quantity -= quantity;
    } else {
      print('Not enough quantity of grocery items in your cart');
    }
    
  } catch(e){
    print('Item not found in list');
  }
}

void checkout(List<GroceryItem> groceryItems, Cart cart) { 
  if (cart.items.isEmpty) { 
    print('Cart is empty'); 
    return; 
  }

  print('Checkout'); 
  print('Items:');

  for (var item in cart.items) { 
    print('${item.name}: ${item.quantity}'); 
  }

  print('Total price: ${cart.totalPrice}');

  print('Do you want to proceed with the purchase? (y/n)'); 
  var input = stdin.readLineSync();

  if (input == 'y') { 
    // Save the purchase data to a file 
    var date = DateTime.now(); 
    var purchase = Purchase(date, cart);

    File('purchases.txt').writeAsStringSync('${date.toString()}, ${cart.totalPrice}\n', mode: FileMode.append);
    print('Purchase saved!');

    print('Do you want to print your recepit? y/n');
    String input = stdin.readLineSync() ?? 'n';

    if (input == 'y') {
      purchase.printReceipt();
    }

    // Clear the cart
    cart.clear();
  }
} 

void updateGroceryFile(List<GroceryItem> groceryItems){
  var file = File('groceries.txt');
  var lines = <String>[];

  for (var item in groceryItems) {
    var existingItemIndex = lines.indexWhere((line) => line.split(',')[0] == item.name);
    if (existingItemIndex != -1) {
      lines[existingItemIndex] = '${item.name}, ${item.quantity}, ${item.price}';
    } else {
    lines.add('${item.name}, ${item.quantity}, ${item.price}');
    }
  }

  file.writeAsStringSync(lines.join('\n'));
}