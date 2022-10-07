import 'package:heroes/exportData.dart';
import 'package:heroes/models/AdminDB.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DesingManager extends ResourceController{
  
  DesingManager() {
    connectDataBase();
  }

  DbCollection? collect, collect2;
  final admon = AdminDB();

  void connectDataBase() async {
    await admon.connectToDB().then((datab) {
      collect = datab.collection('devices');
      collect2 = datab.collection('versions');
    });
  }

  @Operation.put()
  Future<Response> getSystemVersion() async {
    Map<String, dynamic> body, value;
    String newVersion, actualVersion, status;
    bool empty = true, found = false;
    newVersion = "";
    actualVersion = "";
    status = "La nueva version debe ser superior a la anterior";
    body = await request!.body.decode();
    newVersion = body["version"].toString();
    value = {};
    try{
      value = (await collect2?.findOne(where.eq("_id", 1).fields(["version"])))!;
      if(value.isNotEmpty){
        empty = false;
        actualVersion = value["version"].toString();
        if(actualVersion.isNotEmpty)
          found = true;
      }
    }
    catch(e){
      return Response.ok({"ERROR": e.toString()});
    }
    
    if(empty){ //esta vacio la coleccion
      actualVersion = "v0.0.0";
      await collect2?.insertOne({"_id": 1, "version": actualVersion});
      await Future.delayed(const Duration(seconds: 2));
      final rsl = await compareVersion(newVersion, actualVersion);
      if(rsl){
        final vv = await collect2?.updateOne(where.eq("_id", 1), modify.set("version", newVersion));
        if(vv!.isSuccess)
          status = "Nueva version establecida";
      }
    }
    else{
      if(found){
        final rsl = await compareVersion(newVersion, actualVersion);
        if(rsl){
          final vv = await collect2?.updateOne(where.eq("_id", 1), modify.set("version", newVersion));
          if(vv!.isSuccess)
            status = "Nueva version establecida";
        }
      }
    }    
    return Response.ok({"response": status});
  }

  @Operation.put('num')
  Future<Response> getIsUpdate() async {
    Map<String, dynamic> body;
    Map<String, dynamic> data;
    body = await request!.body.decode();
    bool frontal = false, lateral = false, posterior = false, comando = false;
    try{
      if(body["control"] == null || body["control"] == "")
        comando = false;
      else{
        data = {};
        data = (await collect?.findOne(where.eq("control.ssid", body["control"].toString())))!;
        if(data.isNotEmpty){
          if(data["control"]["ssid"] != null){
            if(data["control"]["version"] != null){
              if(data["control"]["version"] == body["version"].toString()){
                comando = true;
              }
            }
          }
        }
      }

      if(body["frontal"] == null || body["frontal"] == "")
        frontal = false;
      else{
        data = {};
        data = (await collect?.findOne(where.eq("frontal.ssid", body["frontal"].toString())))!;
        if(data.isNotEmpty){
          if(data["frontal"]["ssid"] != null){
            if(data["frontal"]["version"] != null){
              if(data["frontal"]["version"] == body["version"].toString()){
                frontal = true;
              }
            }
          }
        }
      }
      
      if(body["lateral"] == null || body["lateral"] == "")
        lateral = false;
      else{
        data = {};
        data = (await collect?.findOne(where.eq("lateral.ssid", body["lateral"].toString())))!;
        if(data.isNotEmpty){
          if(data["lateral"]["ssid"] != null){
            if(data["lateral"]["version"] != null){
              if(data["lateral"]["version"] == body["version"].toString()){
                lateral = true;
              }
            }
          }
        }
      }

      if(body["posterior"] == null || body["posterior"] == "")
        posterior = false;
      else{
        data = {};
        data = (await collect?.findOne(where.eq("posterior.ssid", body["posterior"].toString())))!;
        if(data.isNotEmpty){
          if(data["posterior"]["ssid"] != null){
            if(data["posterior"]["version"] != null){
              if(data["posterior"]["version"] == body["version"].toString()){
                posterior = true;
              }
            }
          }
        }
      }
    }
    catch(e){
      return Response.ok({"ERROR": e.toString()});
    }
    
    return Response.ok({
        "frontal": frontal,
        "lateral": lateral,
        "posterior": posterior,
        "control": comando,
    });
  }

  @Operation.get('num')
  Future<Response> getMainVersion(@Bind.path('num') String num) async {
    String version;
    Map<String, dynamic>? data;
    version = "";
    try{
      data = await collect2?.find().first;
      if(data != null){
        if(data.isNotEmpty){
          version = data["version"].toString();
        }
      }
    }
    catch(e){
      return Response.ok({"ERROR": e.toString()});
    }
    return Response.ok({"version": version});
  }

  Future<bool> compareVersion(String newVersion, String actualVersion) async {
    List<String> currentV;
    List<String> newV;
    currentV = [];
    newV = [];
    currentV = actualVersion.replaceAll("v", "").split(".");
    newV = newVersion.replaceAll("v", "").split(".");
    bool ready = false;
    if(newV.isNotEmpty){
      for(int i = 0; i < newV.length; i++){
        ready = int.parse(newV[i]) > int.parse(currentV[i]);
        if(int.parse(newV[i]) != int.parse(currentV[i]))
          break;
      }
    }
    return ready;
  }
}