import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  FileDownloader._();

  static Future<String?> downloadAndSave({
    required BuildContext context,
    required String url,
    required String fileName,
    Map<String, dynamic>? headers,
  }) async {
    AppToast.info(
      context,
      title: "Downloading",
      message: "Downloading $fileName...",
    );

    try {
      final dir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final filePath = '${dir.path}/$fileName';

      await Dio().download(
        url,
        filePath,
        options: Options(
          headers: {
            'Accept': '*/*',
            ...?headers,
          },
        ),
      );

      AppToast.success(
        context,
        title: "Download Complete",
        message: "$fileName saved successfully.",
      );

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        AppToast.warning(
          context,
          title: "Cannot Open File",
          message: result.message,
        );
      }

      return filePath;
    } catch (e) {
      AppToast.error(
        context,
        title: "Download Failed",
        message: e.toString(),
      );

      return null;
    }
  }

  static String fileNameFromUrl(
    String url, {
    String fallback = 'file',
  }) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      if (segments.isNotEmpty) {
        final last = segments.last;

        if (last.isNotEmpty) {
          return last;
        }
      }
    } catch (_) {}

    return fallback;
  }
}