import 'package:heroes/exportData.dart';

Future main() async {
  final app = Application<HeroesChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8888;

  await app.startOnCurrentIsolate();

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");

  // COMANDO PARA ACTIVAR EL SERVIDOR: "conduit serve" ó "flutter pub global run conduit serve -n 1" 
  // donde "-n 1" es el numero de veces que se va a instanciar la base de datos
}
