import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

class AdminDB{
  Db dbRuteroDB = Db('mongodb://localhost:27017/batch');

  Future<Db> connectToDB() async {
    await dbRuteroDB.open();
    return dbRuteroDB;
  }

  Future<void> close() async {
    await dbRuteroDB.close();
  }

  Future<bool> statusConnection() async {
    return dbRuteroDB.isConnected;
  }
}