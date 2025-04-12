import "dart:convert";
import "package:flutter/services.dart";

Future<List> readDataFromJson({required String filePath}) async {
  try {
    String jsonString = await rootBundle.loadString(filePath);
    dynamic jsonData = json.decode(jsonString);
    return jsonData;
  } catch(error) {
    return [];
  }
}