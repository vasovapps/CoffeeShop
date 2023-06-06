import 'package:coffee_shop/base/app/coffee_shop.dart';
import 'package:coffee_shop/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'dart:isolate';

import '../exceptions/safe_run.dart';

Future<void> configureAppAndRun() async {
  _disableLogs(disableLogs: kReleaseMode);
  await _configureApp();

  try {
    if (kDebugMode) {
      //Log more in debug mode
      Logger.root.level = Level.FINE;
    }
    if (kReleaseMode) {
      Logger.root.level = Level.WARNING;
    }
    //Subscribe to log message
    Logger.root.onRecord.listen((record) {
      final message = '${record.level.name}: ${record.time}: '
          '${record.loggerName}: '
          '${record.message}';

      FirebaseCrashlytics.instance.log(message);

      if (record.level >= Level.SEVERE) {
        FirebaseCrashlytics.instance.recordError(
          message,
          filterStackTrace(StackTrace.current),
          fatal: true,
        );
      }
    });

    runApp(const CoffeeShop());
  } catch (error, stackTrace) {
    debugPrint('ERROR: $error\n\n'
        'STACK:$stackTrace');
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  }
}

void _disableLogs({bool disableLogs = false}) {
  if (!disableLogs) return;
  debugPrint = (String? message, {int? wrapWidth}) {};
}

Future<void> _configureApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await safeRun(() =>
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform));
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  catchFatalFrameworkErrors();
  catchFatalNonFrameworkErrors();
  catchFatalErrorsOutsideFlutter();
}

void catchFatalFrameworkErrors() {
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
}

void catchFatalNonFrameworkErrors() {
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

void catchFatalErrorsOutsideFlutter() {
  // To catch errors outside of the Flutter context, we attach an error
  // listener to the current isolate.
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
      fatal: true,
      printDetails: true,
    );
  }).sendPort);
}

@visibleForTesting
StackTrace filterStackTrace(StackTrace stackTrace) {
  try {
    final lines = stackTrace.toString().split('\n');
    final buffer = StringBuffer();
    for (final line in lines) {
      if (line.contains('crashlytics.dart') ||
          line.contains('_BroadcastStreamController.java') ||
          line.contains('logger.dart')) {
        continue;
      }
      buffer.writeln(line);
    }
    return StackTrace.fromString(buffer.toString());
  } catch (e) {
    debugPrint('Problem while filtering stack trace: $e');
  }

  // If there was an error while filtering,
  // return the original, unfiltered stack track.
  return stackTrace;
}
