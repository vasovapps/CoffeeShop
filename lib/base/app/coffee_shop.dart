import 'package:flutter/material.dart';
import '../routers/router.gr.dart' as router;

class CoffeeShop extends StatelessWidget {
  const CoffeeShop({super.key});

  @override
  Widget build(BuildContext context) => const _CoffeeShop();
}

class _CoffeeShop extends StatefulWidget{
  const _CoffeeShop();

  @override 
  State<_CoffeeShop> createState()=> _CoffeeShopState();
}

class _CoffeeShopState extends State<_CoffeeShop>{
  late final router.Router _router;

   @override
  void initState() {
    _router = router.Router();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
       routeInformationParser: _router.defaultRouteParser(),
          routerDelegate: _router.delegate(
            navigatorObservers: () => [],
          ),
    );
  }
}