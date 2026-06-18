import 'package:flutter/material.dart';

/// Global messenger so services/providers can show snackbars
/// without a BuildContext (e.g. forced logout from the Dio interceptor).
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showGlobalSnackBar(String message) {
  rootScaffoldMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
