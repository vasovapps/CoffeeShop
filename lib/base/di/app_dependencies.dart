
import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';

class AppDependencies {
static AppDependencies? _instance;

AppDependencies._internal();

factory AppDependencies.of(BuildContext context) =>
   _instance != null ? _instance! : _instance = AppDependencies._internal();

List<SingleChildWidget> get providers=>[];
}