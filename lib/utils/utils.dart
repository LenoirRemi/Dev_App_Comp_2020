import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';
import 'package:workmanager/workmanager.dart';

const EMULATED_BLUETOOTH_MEETINGS = [
  {
    "i": 23,
    "hash": "7191ff36a587076f6327600715ddea71cb5632185ccfb7097855ea3c2c09be77d349ad42560aa892d0a7062d0aa5949d3fb0626b3c4996d28fcf6d66ae473c84"
  },
  {
    "i": 5,
    "hash": "60f07134c321ffab4ca5c0c7371081f443dd1f609edbb15060454f6d977d2ebf8d3f13c49fa1b7d8972fb97262196faecd776c647b4f87ba2dab288f2c6e91b5"
  },
  {
    "i": 1324,
    "hash": "54d5ad9ca1dc20580f9a203469be7583bba269c8197df36b89c1ac634d8451af3e76e8828336d89100c49c4ad9c9e01be91a32ab7a1b3fa2ad9969b78a11f45f"
  },
  {
    "i": 1,
    "hash": "fc8eff2a1588197d51220c5ea8204e81b855a1d296708f5519e1db3dcf63781850870105018f17bbf2c5aaadfbe8b453c45e83639507152f3248d5fa2e7bcdce"
  },
  {
    "i": 132,
    "hash": "084639242898ee2c7d0b7dc27d122dd9cf7510111304489aa2210dcd67c550bf9086a86ce9ab318b2b25bb972f06a4d61eebe844fbd1e823a2fe83e79b923915"
  },
  {
    "i": 12,
    "hash": "96c1b9ed32d94d133ade3115c087543ba3d7d92f306a1aaeeb23cf9777aea0acfcf6bbcc19983325c251d50dfa086a95a3d39dc29b96f6d2cd3f4d0ddf88e557"
  },
];

const EMULATED_BACKEND_LIST = [
  "5f3ec14b-e186-4ba5-a6c7-76994cfc7ddc",
  "5304f673-0aff-4efb-8359-71ebedf01529",
  "6ecdd034-8b19-4cbb-afc2-fd1677ac4f91",
  "84f0641e-63ab-4e9b-a81f-56a5d0dfc7e8", // <--- The one we encounter
  "ed04dff0-1d9c-4315-b2c8-a60d96dd9e01",
  "c64971e9-fb8e-4cc5-b057-a15ae47ef549"
];


final storage = FlutterSecureStorage();

// IDs Generation

String generateUUID() {
  var uuid = new Uuid();
  return uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
}

String generateTempID(String i, String hash) {
  var key = utf8.encode(hash);
  var bytes = utf8.encode(i);
  var hmac = new Hmac(sha512, key);
  return hmac.convert(bytes).toString();
}

Future<bool> manageUUID() async {
  var uuid = await getUUID();
  if (uuid == null) {
    var uuid_new = await generateUUID();
    var tid = await generateTempID(0.toString(), uuid_new);
    await saveLastTempID(tid);
    await saveUUID(uuid_new.toString());
    await saveI(0.toString());
  }
  return true;
}

Future<String> nextTempID() async {
  var i = await getI();
  var uuid = await getUUID();
  var inc = int.tryParse(i) + 1;
  var hash = generateTempID(inc.toString(), uuid);
  await saveI(inc.toString());
  await saveLastTempID(hash);
  return hash;
}

bool compareAllHash(){
  var risk = false;
  for(final y in EMULATED_BACKEND_LIST){
    for(final z in EMULATED_BLUETOOTH_MEETINGS){
    if(z["hash"] == generateTempID(z["i"].toString(), y)){
        risk = true;
      }
    }
  }
  return risk;
}

// Storage access

Future<void> saveUUID(String uuid) async {
  await storage.write(key: "uuid", value: uuid);
}

Future<String> getUUID() async {
  final uuid = await storage.read(key: "uuid");
  return uuid;
}

Future<void> saveI(String i) async {
  await storage.write(key: "i", value: i);
}

Future<String> getI() async {
  final i = await storage.read(key: "i");
  return i;
}

Future<void> saveLastTempID(String tid) async {
  await storage.write(key: "lastTID", value: tid);
}

Future<String> getLastTempID() async {
  final tid = await storage.read(key: "lastTID");
  return tid;
}

Future<bool> deleteAll() async{
  await storage.deleteAll();
  return true;
}

// background worker

void callbackDispatcher(){
  // Workmanager.registerPeriodicTask(uniqueName, taskName)
  Workmanager.executeTask((taskName, inputData) {
    print("ABC");
    return Future.value(true);
  });
}

void runWorker(){
  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true
  );
  Workmanager.registerOneOffTask("1", "task1");
}