import 'package:share_plus/share_plus.dart';

import '../errors/app_error.dart';

abstract interface class ShareGateway {
  Future<ShareResult> shareText({
    required String text,
    String? subject,
    String? title,
  });

  Future<ShareResult> shareFiles({
    required List<ShareFile> files,
    String? text,
    String? subject,
    String? title,
  });
}

class ShareFile {
  const ShareFile({required this.path, this.mimeType, this.fileNameOverride});

  final String path;
  final String? mimeType;
  final String? fileNameOverride;
}

class SharePlusGateway implements ShareGateway {
  SharePlusGateway({SharePlus? sharePlus})
    : _sharePlus = sharePlus ?? SharePlus.instance;

  final SharePlus _sharePlus;

  @override
  Future<ShareResult> shareText({
    required String text,
    String? subject,
    String? title,
  }) async {
    if (text.trim().isEmpty) {
      throw const AppError(
        code: AppErrorCode.validation,
        message: 'لا يمكن مشاركة نص فارغ.',
      );
    }

    return _sharePlus.share(
      ShareParams(text: text, subject: subject, title: title),
    );
  }

  @override
  Future<ShareResult> shareFiles({
    required List<ShareFile> files,
    String? text,
    String? subject,
    String? title,
  }) async {
    if (files.isEmpty) {
      throw const AppError(
        code: AppErrorCode.validation,
        message: 'يلزم ملف واحد على الأقل للمشاركة.',
      );
    }

    final fileNameOverrides =
        files.every((file) => file.fileNameOverride != null)
        ? files.map((file) => file.fileNameOverride!).toList(growable: false)
        : null;

    return _sharePlus.share(
      ShareParams(
        files: files
            .map((file) => XFile(file.path, mimeType: file.mimeType))
            .toList(growable: false),
        fileNameOverrides: fileNameOverrides,
        text: text,
        subject: subject,
        title: title,
      ),
    );
  }
}
