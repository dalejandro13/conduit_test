import 'package:heroes/exportData.dart';
import 'package:heroes/models/AdminDB.dart';
import 'package:mongo_dart/mongo_dart.dart';

class NetworkManager extends ResourceController {

  NetworkManager(){
    connectDataBase();
  }

  DbCollection? collect;
  final admon = AdminDB();

  void connectDataBase() async {
    await admon.connectToDB().then((datab) {
      collect = datab.collection('devices');
    });
  }

  @Operation.get('ssid')
  Future<Response> getNetworks(@Bind.path('ssid') String ssid) async {
    Map<String, dynamic> info;
    info = {};
    if (ssid.isNotEmpty && ssid.contains("RFLX-B")) {
      try{
        info = (await collect?.findOne(where.eq('control.ssid', ssid).fields(['frontal', 'lateral', 'posterior', 'bus'])))!;
      }
      catch(e){
        await admon.close();
        return Response.ok({"ERROR": e.toString()});
      }
    }
    else{
      await admon.close();
      return Response.ok({"WARNING": "Bridge SSID is missing, please enter this information in the URL to query"});
    }

    await admon.close();
    return Response.ok({
      "bus": info["bus"],
      "frontal": info["frontal"]["ssid"],
      "lateral": info["lateral"]["ssid"],
      "posterior": info["posterior"]["ssid"]
    });
  }
}