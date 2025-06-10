import 'dart:developer';

import 'package:mc_dashboard/core/models/db_helper/constant_strings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static var db, userCollection;
  static connect() async {
    db = await Db.create(mongo_conn_url);
    await db.open();
    inspect(db);
    userCollection = db.collection(user_collection);
  }
}
