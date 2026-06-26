import 'dart:io';

import 'package:dio/dio.dart';

FormData buildMultipart(
  Map<String, Object?> fields,
  Map<String, File> singleFiles, {
  List<File>? mediaFiles,
  String mediafilesname='media'
}) {
  final formData = FormData();

  fields.forEach((key, value) {
    if (value == null) return;

    if (value is List) {
      for (final v in value) {
        formData.fields.add(MapEntry('$key[]', v.toString()));
      }
    } else if (value is Map) {
      value.forEach((k, v) {
        if (v != null) {
          formData.fields.add(
            MapEntry('$key[$k]', v.toString()),
          );
        }
      });
    } else {
      formData.fields.add(MapEntry(key, value.toString()));
    }
  });

  for (final entry in singleFiles.entries) {
    formData.files.add(
      MapEntry(
        entry.key,
        MultipartFile.fromFileSync(
          entry.value.path,
          filename: entry.value.path.split('/').last,
        ),
      ),
    );
  }

  if (mediaFiles != null && mediaFiles.isNotEmpty) {
    for (final file in mediaFiles) {
      formData.files.add(
        MapEntry(
          mediafilesname,
          MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }
  }

  return formData;
}
