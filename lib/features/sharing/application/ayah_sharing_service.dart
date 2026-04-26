import '../../../shared/errors/app_error.dart';
import '../../../shared/errors/result.dart';
import '../../../shared/platform/share_gateway.dart';
import '../../quran/domain/quran_position.dart';
import '../../quran/infrastructure/quran_gateway.dart';
import '../domain/ayah_share_draft.dart';

class AyahSharingService {
  AyahSharingService({
    required QuranSelectionGateway selectionGateway,
    required ShareGateway shareGateway,
  }) : _selectionGateway = selectionGateway,
       _shareGateway = shareGateway;

  final QuranSelectionGateway _selectionGateway;
  final ShareGateway _shareGateway;

  Future<Result<String>> generateShareText(QuranPosition position) {
    return guardResult(
      () => _selectionGateway.buildShareText(position),
      code: AppErrorCode.sharing,
      message: 'تعذر إنشاء نص المشاركة.',
    );
  }

  Future<Result<void>> shareAyahText(QuranPosition position) {
    return guardResult(
      () async {
        final text = await _selectionGateway.buildShareText(position);
        await _shareGateway.shareText(text: text);
      },
      code: AppErrorCode.sharing,
      message: 'تعذر مشاركة نص الآية.',
    );
  }

  Future<Result<void>> shareAyahImage(AyahShareDraft draft) {
    return guardResult(
      () async {
        if (draft.lastGeneratedPathOrUri == null) {
          throw const AppError(
            code: AppErrorCode.sharing,
            message: 'لم يتم إنشاء صورة المشاركة بعد.',
          );
        }
        await _shareGateway.shareFiles(
          files: [
            ShareFile(
              path: draft.lastGeneratedPathOrUri!,
              mimeType: 'image/png',
            ),
          ],
        );
      },
      code: AppErrorCode.sharing,
      message: 'تعذر مشاركة صورة الآية.',
    );
  }
}
