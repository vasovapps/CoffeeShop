import 'package:auto_route/auto_route.dart';
import 'package:coffee_shop/features/splash/splash_page.dart';



@AdaptiveAutoRouter(
  replaceInRouteName:'Page,Route',
  routes:<AutoRoute>[
    AutoRoute(page:SplashPage,initial:true,),
  ],
  )
class $Router {}