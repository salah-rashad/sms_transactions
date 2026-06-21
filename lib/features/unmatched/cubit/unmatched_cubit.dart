import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_transactions/core/utils/logger.dart';
import 'package:sms_transactions/data/repositories/suppressed_sender_repository.dart';
import 'package:sms_transactions/data/repositories/unmatched_sms_repository.dart';
import 'package:sms_transactions/data/services/sms_scan_service.dart';
import 'package:sms_transactions/features/unmatched/cubit/unmatched_state.dart';

/// App-scoped cubit owning the unmatched queue and its count (R7). Shared by
/// the dashboard card and the unmatched list; teach/dismiss actions call back
/// into it so the count updates reactively (FR-003).
///
/// R9 (SC-005): on launch [loadCachedCount] emits the persisted queue count
/// instantly (card renders within ~1s); [runLaunchScan] then refreshes it once
/// the background scan completes (FR-024).
class UnmatchedCubit extends Cubit<UnmatchedState> {
  UnmatchedCubit({
    required this.scanService,
    required this.unmatchedRepository,
    required this.suppressedRepository,
  }) : super(const UnmatchedState());

  final SmsScanService scanService;
  final UnmatchedSmsRepository unmatchedRepository;
  final SuppressedSenderRepository suppressedRepository;

  /// Instant read of the persisted activeCount (R9, SC-005). Emits only the
  /// count without touching the SMS inbox.
  Future<void> loadCachedCount() async {
    try {
      final cached = await unmatchedRepository.activeCount();
      emit(state.copyWith(count: cached));
    } catch (e, st) {
      Logger.error('UnmatchedCubit.loadCachedCount', e, st);
    }
  }

  /// FR-024: runs the background scan and refreshes the queue + count.
  Future<void> runLaunchScan() async {
    emit(state.copyWith(status: UnmatchedStatus.scanning, clearError: true));
    try {
      await scanService.scan();
      await _reloadItems();
    } catch (e, st) {
      Logger.error('UnmatchedCubit.runLaunchScan', e, st);
      emit(state.copyWith(status: UnmatchedStatus.error, error: e.toString()));
    }
  }

  /// Reloads items + count from persistence (no inbox scan).
  Future<void> refresh() async => _reloadItems();

  /// US3 / FR-017: suppress the sender and drop its queue entries.
  Future<void> dismissSender(String senderId) async {
    await suppressedRepository.suppress(senderId);
    await unmatchedRepository.removeBySender(senderId);
    await _reloadItems();
  }

  Future<void> _reloadItems() async {
    try {
      final items = await unmatchedRepository.getActive();
      final count = items.length;
      emit(
        state.copyWith(
          items: items,
          count: count,
          status: UnmatchedStatus.ready,
          clearError: true,
        ),
      );
    } catch (e, st) {
      Logger.error('UnmatchedCubit._reloadItems', e, st);
      emit(state.copyWith(status: UnmatchedStatus.error, error: e.toString()));
    }
  }
}
