import 'repo_data_export_service_stub.dart'
    if (dart.library.io) 'repo_data_export_service_io.dart';

class RepoDataExportService {
  RepoDataExportService._();

  static final RepoDataExportService instance = RepoDataExportService._();

  Future<void> appendRecord(Map<String, Object?> record) {
    return RepoDataExportServicePlatform.instance.appendRecord(record);
  }
}
