import 'package:heroes/exportData.dart';
import 'controllers/designManger.dart';
import 'controllers/networkManager.dart';
import 'controllers/wifiManager.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://conduit.io/docs/http/channel/.
class HeroesChannel extends ApplicationChannel {

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();

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

