import 'package:flutter/material.dart';
import 'package:playtime/src/pages/index.dart';
import 'package:playtime/src/pages/login.dart';
import 'package:playtime/src/pages/registro.dart';
import 'package:playtime/src/pages/complex_list_page.dart';
import 'package:playtime/src/widget/tapbar.dart';

//import 'package:playtime/src/pages/home_page.dart';
//Se genera un método que regresa un string y un widget builder
Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => const WelcomeScreen(),
    'login': (BuildContext context) => const LoginPage(),
    'registro': (BuildContext context) => const RegistroPage(),
    'home': (BuildContext context) => const TapbarPage(), // Changed this line
    'complexes': (BuildContext context) => const ComplexListPage(),
  };
}