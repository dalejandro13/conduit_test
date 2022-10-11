import 'package:heroes/exportData.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/AdminDB.dart';

class WiFiManager extends ResourceController {

  WiFiManager() {
    connectDataBase();
  }
  
  DbCollection? collect, collect2;
  final admon = AdminDB();

  void connectDataBase() async {
    await admon.connectToDB().then((datab) {
      collect = datab.collection('devices');
      collect2 = datab.collection('vetoed');
    });
  }


  @Operation.get() //response true si el servidor esta funcionando
  Future<Response> getStatus() async {
    bool ready = false;
    int i;
    for (i = 0; i <= 1; i++) {
      ready = true;
    }
    await admon.close();
    return Response.ok({"OK": ready});
  }

  @Operation.put('id')
  Future<Response> getInfoDevice(@Bind.path('id') String id) async {
    Map<String, dynamic> body, frontal, lateral, posterior, bridge, front, lat, post, ctrl;
    body = {};
    frontal = {};
    lateral = {};
    posterior = {};
    bridge = {};
    front = {};
    lat = {};
    post = {};
    ctrl = {};
    body = await request!.body.decode();

    try{
      front = (await collect?.findOne(where.eq("frontal.ssid", body["frontal"].toString())))!;
      lat = (await collect?.findOne(where.eq("lateral.ssid", body["lateral"].toString())))!;
      post = (await collect?.findOne(where.eq("posterior.ssid", body["posterior"].toString())))!;
      ctrl = (await collect?.findOne(where.eq("control.ssid", body["control"].toString())))!;
    }
    catch(e){
      await admon.close();
      return Response.ok({"ERROR": e.toString()});
    }

    if(front.isNotEmpty){
      frontal = {
        "ssid": front["frontal"]["ssid"],
        "pass": front["frontal"]["pass"],
        "version": front["frontal"]["version"],
      };
    }
    if(lat.isNotEmpty){
      lateral = {
        "ssid": lat["lateral"]["ssid"],
        "pass": lat["lateral"]["pass"],
        "version": lat["lateral"]["version"],
      };
    }
    if(post.isNotEmpty){
      posterior = {
        "ssid": post["posterior"]["ssid"],
        "pass": post["posterior"]["pass"],
        "version": post["posterior"]["version"],
      };
    }
    if(ctrl.isNotEmpty){
      bridge = {
        "ssid": ctrl["control"]["ssid"],
        "version": ctrl["control"]["version"],
      };
    }

    await admon.close();
    return Response.ok({
      "frontal": frontal,
      "lateral": lateral,
      "posterior": posterior,
      "control": bridge,
    });
  }

  @Operation.put()
  Future<Response> updateInformation() async {
    Map<String, dynamic> body;
    bool respFrontal = false, respLateral = false, respPosterior = false, respControl = false;
    body = {};
    body = await request!.body.decode();

    if (body["frontal"].toString().isNotEmpty) {
      try{
        await collect?.update(where.eq("frontal.ssid", body["frontal"]), modify.set("frontal.version", body["version"]));
        respFrontal = true;
      }
      catch(e){
        print("");
      }
    }
    if (body["lateral"].toString().isNotEmpty) {
      try{
        await collect?.update(where.eq("lateral.ssid", body["lateral"]), modify.set("lateral.version", body["version"]));
        respLateral = true;
      }
      catch(e){
        print("");
      }
    }
    if (body["posterior"].toString().isNotEmpty) {
      try{
        await collect?.update(where.eq("posterior.ssid", body["posterior"]), modify.set("posterior.version", body["version"]));
        respPosterior = true;
      }
      catch(e){
        print("");
      }
    }
    if (body["control"].toString().isNotEmpty) {
      try{
        await collect?.update(where.eq("control.ssid", body["control"]), modify.set("control.version", body["version"]));
        respControl = true;
      }
      catch(e){
        print("");
      }
    }

    await admon.close();
    return Response.ok({
      "control": respControl,
      "frontal": respFrontal,
      "lateral": respLateral,
      "posterior": respPosterior
    });
  }

  @Operation.put('ssid') //almacena los nombres de red que van a ser vetadas
  Future<Response> putVetoed(@Bind.path('ssid') String ssid) async {
    bool found = false, empty = true;
    String status;
    DateTime? now;
    Map<String, dynamic>? value;
    status = "";
    value = {};
    try {
      if(ssid.contains("RFLX-") || ssid.contains("SFLX-")){
        value = await collect2?.findOne(where.eq("_id", 1).fields(["vetoed"]));
        if(value != null){
          if(value.isNotEmpty){
            empty = false;
            for (var vl in value["vetoed"]) {
              if (vl.toString().contains(ssid))
                found = true;
            }
          }
        }
      }
      else{
        empty = false;
        found = true;
      }
    } 
    catch(e) {
      await admon.close();
      return Response.ok({"ERROR": e.toString()});
    }

    now = DateTime.now();
    if(empty) { //esta vacio la coleccion
      try{
        final vv = await collect2?.insertOne({"_id": 1,"vetoed": ["$ssid,$now"]});
        if(vv!.isSuccess)
          status = "OK";
      }
      catch(e){
        await admon.close();
        return Response.ok({"ERROR": e.toString()});
      }
    } 
    else {
      if (!found) { //no lo encontro
        try{
          final vv = await collect2?.updateOne(where.eq("_id", 1), modify.push("vetoed", "$ssid,$now"));
          if (vv!.isSuccess) 
            status = "OK";
        }
        catch (e){
          await admon.close();
          return Response.ok({"ERROR": e.toString()});
        }
      }
    }
    await admon.close();
    return Response.ok({"status": status});
  }

  @Operation.get('name') //consulta los nombres de red que estan vetadas
  Future<Response> getVetoed(@Bind.path('name') String name) async {
    bool found = false;
    Map<String, dynamic>? value;
    value = {};
    try {
      value = await collect2?.find().first;
      if(value != null){
        if(value.isNotEmpty){
          for (var vl in value["vetoed"]) {
            if (vl.toString().contains(name)) 
              found = true;
          }
        }
      }
    } 
    catch (e) {
      await admon.close();
      return Response.ok({"ERROR": e.toString()});
    }
    await admon.close();
    return Response.ok({"status": found});
  }
}
