import 'package:flutter/foundation.dart';

enum MediaFileType { photo, video }

@immutable
class MediaFileModel {
  final String path;
  final MediaFileType type;
  final String name;
  final DateTime? dateModified;

  const MediaFileModel({
    required this.path,
    required this.type,
    required this.name,
    this.dateModified,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFileModel &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
