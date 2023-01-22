import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<bool> checkCacheDataExist(
  String fileName,
) async {
  /// Cache Directory
  var cacheDir = await getTemporaryDirectory();

  /// Check if SignIn Method Exist
  if (await File(cacheDir.path + "/" + fileName).exists()) {
    print("Exist");
    return true;
  }

  /// Not Exist
  else {
    print("Cache data not exist");
    return false;
  }
}

Future<void> createCacheData(
  String fileName,
  String data,
) async {
  /// Cache Directory
  var cacheDir = await getTemporaryDirectory();

  /// If Cache data NOT exist
  if (await File(cacheDir.path + "/" + fileName).exists() == false) {
    print("Creating cache data (" + fileName + ")" + ": " + data);

    // CacheUser cacheUser = File(cacheDir.path + "/" + fileName);

    File file = new File(cacheDir.path + "/" + fileName);
    file.writeAsString(data, flush: true, mode: FileMode.write);
  }

  /// Overwrite existing cache data
  else {
    print("AGAIN Creating cache data (" + fileName + ")" + ": " + data);
    File file = new File(cacheDir.path + "/" + fileName);
    file.writeAsString(data, flush: true, mode: FileMode.write);
  }
}

Future<void> deleteCacheData(
  String fileName,
) async {
  /// Cache Directory
  var cacheDir = await getTemporaryDirectory();

  /// If Cache data exist
  if (await File(cacheDir.path + "/" + fileName).exists()) {
    print("Deleting cache data " + fileName);

    // CacheUser cacheUser = File(cacheDir.path + "/" + fileName);
    cacheDir.delete(recursive: true);
    print("Deleted cache data");
  }

  /// Else Not exist
  else {
    print("No Cache data");
  }
}
