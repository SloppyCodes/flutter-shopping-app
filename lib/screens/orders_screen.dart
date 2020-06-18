import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../providers/orders.dart' show Orders;
import './../widgets/order_item.dart';
import './../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routName = '/orders';

  // bool _isLoading = false;

  // @override
  // void initState() {
  // Future.delayed(Duration.zero).then((value) {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Provider.of<Orders>(context, listen: false).fetchAndSaveOrders().then(
  //     (value) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     },
  //   );
  // });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your order'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<Orders>(context, listen: false).fetchAndSaveOrders(),
        builder: (ctx, futureDataSnapshot) {
          if (futureDataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (futureDataSnapshot.error != null) {
              return Center(
                child: Text(futureDataSnapshot.error.toString()),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemBuilder: (ctx, i) => OrderItem(
                    orderData.orders[i],
                  ),
                  itemCount: orderData.orders.length,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
