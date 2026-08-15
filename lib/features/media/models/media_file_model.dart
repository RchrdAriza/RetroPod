import 'package:flutter/foundation.dart';

enum MediaFileType { photo, video }

@immutable
class MediaFileModel {
  final String path;
  final MediaFileType type;
  final String name;
  final DateTime? dateModified;
  final String? thumbnailPath;

  const MediaFileModel({
    required this.path,
    required this.type,
    required this.name,
    this.dateModified,
    this.thumbnailPath,
  });

  bool get isRemote => path.startsWith('http');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFileModel &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
