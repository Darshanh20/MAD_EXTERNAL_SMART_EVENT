import 'dart:convert';
import 'dart:io';

class RepoDataExportServicePlatform {
  RepoDataExportServicePlatform._();

  static final RepoDataExportServicePlatform instance =
      RepoDataExportServicePlatform._();

  Future<void> appendRecord(Map<String, Object?> record) async {
    final file = File('local_data/repo_data.hive');
    await file.parent.create(recursive: true);
    final line = jsonEncode(record);
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }
}
