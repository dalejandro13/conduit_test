import 'package:heroes/exportData.dart';

import 'controllers/designManger.dart';
import 'controllers/networkManager.dart';
import 'controllers/wifiManager.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://conduit.io/docs/http/channel/.
class HeroesChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://conduit.io/docs/http/request_controller/
    // router.route("/example").linkFunction((request) async {
    //   return Response.ok({"key": "value"});
    // });


    router.route("/status").link(() => WiFiManager());

    // Actualizo la version principal
    router.route("/mainVersion").link(() => DesingManager());

    // Consulta si ya ha sido actualizado
    router.route("/isUpdated/0/:num").link(() => DesingManager());

    //Obtiene la version principal
    router.route("/getMainVersion/:num").link(() => DesingManager());

    // Enlace para orden de conectarse a las redes ingresadas, puede ser: frontal, lateral, posterior y bridge. Buscará en mongo la contraseña de cada red
    router.route("/getDevice/:id").link(() => WiFiManager());

    // actualizar informacion del servidor
    router.route("/information/update").link(() => WiFiManager());

    //ingresar comandos para vetar
    router.route("/putVetoed/:ssid").link(() => WiFiManager());

    //consultar comandos si estan vetados
    router.route("/getVetoed/:name").link(() => WiFiManager());

    //consulta los SSID del frontal, lateral, posterior y el nombre del bus asociado
    router.route("/getNetworks/:ssid").link(() => NetworkManager());



    return router;
  }
}

