import 'dart:developer';

import 'package:mc_dashboard/core/models/db_helper/constant_strings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static var db,
      userCollection,
      rgDevicesCollection,
      devicesCollection,
      passToolsCollection,
      clientInformationCollection,
      personalOdcCollection;
  static connect() async {
    db = await Db.create(mongo_conn_url);
    await db.open();
    inspect(db);
    userCollection = db.collection(user_collection);
    rgDevicesCollection = db.collection(rg_devices_collection);
    devicesCollection = db.collection(devices_collection);
    passToolsCollection = db.collection(pass_tools_collection);
    clientInformationCollection = db.collection(client_information_collection);
    personalOdcCollection = db.collection(personal_odc_collection);
  }
}
