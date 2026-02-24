import 'dart:io' show Platform;

/// Sur émulateur Android, 127.0.0.1 pointe vers l'émulateur.
/// 10.0.2.2 est l'alias pour le PC host.
String getApiHost() {
  return Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
}
