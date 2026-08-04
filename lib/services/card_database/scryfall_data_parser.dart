
import 'dart:io';
import 'dart:convert';

import 'scryfall_download.dart';

class ScryfallDataParser {
  Future<void> parseBulkData(String bulkDataType) async {
    // Get the json data for the bulk data type
    final bulkDataFilePath = await ScryfallDownloadService().getBulkDataFilePath(bulkDataType);
    final bulkDataFile = File(bulkDataFilePath);
    final bulkDataJson = await bulkDataFile.readAsString();
    final bulkData = json.decode(bulkDataJson) as Map<String, dynamic>;
  }
}