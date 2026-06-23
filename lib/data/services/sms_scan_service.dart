import 'package:flutter/foundation.dart';
import 'package:sms_transactions/data/repositories/pattern_repository.dart';
import 'package:sms_transactions/data/repositories/suppressed_sender_repository.dart';
import 'package:sms_transactions/data/repositories/unmatched_sms_repository.dart';
import 'package:sms_transactions/data/services/sms_service.dart';
import 'package:sms_transactions/domain/models/pattern_match.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/domain/models/unmatched_sms.dart';
import 'package:sms_transactions/domain/sms/pattern_matcher.dart';

/// Summary of a scan run (research R3; FR-023/024/035/042).
class ScanResult {
  final int newMatches;
  final int unmatchedCount;

  /// smsIds that already had a transaction and were skipped (re-scan needs user
  /// confirmation before overwriting, FR-023).
  final List<PatternMatch> conflicts;

  const ScanResult({
    required this.newMatches,
    required this.unmatchedCount,
    this.conflicts = const [],
  });
}

class SmsScanService {
  SmsScanService({
    required this.smsService,
    required this.patternRepository,
    required this.patternMatchRepository,
    required this.unmatchedSmsRepository,
    required this.suppressedSenderRepository,
  });

  final SmsService smsService;
  final PatternRepository patternRepository;
  final PatternMatchRepository patternMatchRepository;
  final UnmatchedSmsRepository unmatchedSmsRepository;
  final SuppressedSenderRepository suppressedSenderRepository;

  /// Transient in-memory smsId→body cache (privacy I: bodies are NEVER
  /// persisted). Populated on each [scan] so the unmatched list and the
  /// authoring wizard can display/teach from the body without re-querying the
  /// inbox.
  final Map<String, String> _bodyCache = {};

  /// Returns the cached body for [smsId] from the last scan, or null.
  String? bodyFor(String smsId) => _bodyCache[smsId];

  /// Runs the launch/manual scan (research R3/R8 pass 3, FR-024/025/035/042):
  /// 1. Reads candidate SMS (alphanumeric senders + already-patterned, R2).
  /// 2. Matches each against learned patterns off the main isolate (R3).
  /// 3. Persists new [PatternMatch]es (idempotent on smsId unless [overwrite]).
  /// 4. Upserts [UnmatchedSmsRecords] when no learned pattern matches AND the
  ///     sender is alphanumeric + not suppressed (no hardcoded-parser exception,
  ///     FR-035).
  /// 5. Prunes orphaned unmatched records (FR-042).
  /// Zero network calls; no raw SMS bodies persisted (privacy I).
  Future<ScanResult> scan({bool overwrite = false}) async {
    final granted = await smsService.requestPermission();
    if (!granted) {
      return const ScanResult(newMatches: 0, unmatchedCount: 0);
    }

    final patterns = await patternRepository.getAll();
    final patternedSenders = patterns.map((p) => p.senderId).toSet();
    final suppressed = await suppressedSenderRepository.getAll();

    final messages = await smsService.getCandidateSms(patternedSenders);

    // Build the isolate input (plain sendable payloads). Cache bodies in-memory
    // for display + authoring (never persisted — privacy I).
    final smsInputs = <_SmsInput>[];
    for (final m in messages) {
      final id = m.id?.toString() ?? '';
      final body = m.body ?? '';
      if (id.isNotEmpty && body.isNotEmpty) {
        _bodyCache[id] = body;
      }
      smsInputs.add(_SmsInput(
        id: id,
        senderId: m.address ?? '',
        body: body,
        receivedMs: (m.date ?? DateTime.now()).millisecondsSinceEpoch,
      ));
    }

    // Heavy matching runs off the main isolate (R3).
    final matched = await compute(_runMatching, _IsolateInput(smsInputs, patterns));

    final existingBySmsId = <String, PatternMatch>{};
    for (final m in await patternMatchRepository.getAll()) {
      existingBySmsId[m.smsId] = m;
    }
    final existingUnmatchedIds = (await unmatchedSmsRepository.getActive())
        .map((u) => u.smsId)
        .toSet();

    var newMatches = 0;
    final conflicts = <PatternMatch>[];

    for (final match in matched.matches) {
      // Ignore-direction matches never enter the ledger; they just dismiss
      // the SMS and bump pattern confidence.
      if (match.direction == SmsDirection.ignore) {
        await unmatchedSmsRepository.removeBySmsId(match.smsId);
        if (match.patternId != null) {
          await patternRepository.recordAttempt(
            match.patternId!,
            success: true,
            matchedAt: match.matchedAt,
          );
        }
        continue;
      }

      final prior = existingBySmsId[match.smsId];
      if (prior != null) {
        // Already parsed → conflict (FR-023).
        conflicts.add(match);
        if (overwrite) {
          await patternMatchRepository.upsert(match);
        }
        continue;
      }
      await patternMatchRepository.upsert(match);
      // Remove from the unmatched queue if it was previously there (FR-035).
      await unmatchedSmsRepository.removeBySmsId(match.smsId);
      // Confidence counters: a genuinely new success (FR-020).
      if (match.patternId != null) {
        await patternRepository.recordAttempt(
          match.patternId!,
          success: true,
          matchedAt: match.matchedAt,
        );
      }
      newMatches += 1;
    }

    // Unmatched routing (R2/R8 pass 3, FR-035): alphanumeric + non-suppressed.
    final unmatchedToPersist = <UnmatchedSms>[];
    for (final sms in matched.unmatched) {
      if (sms.id.isEmpty) continue;
      final isAlphanumeric = SmsService.isAlphanumericSender(sms.senderId);
      if (!isAlphanumeric) continue; // phone-number senders excluded (R2)
      if (suppressed.contains(sms.senderId)) continue; // FR-017/US3

      // Confidence counters: a failed attempt for a patterned sender whose
      // patterns didn't resolve. Only count newly-seen smsIds (avoid inflation
      // on relaunch). Genuinely new failed attempts (FR-020).
      final isNewlySeen =
          !existingUnmatchedIds.contains(sms.id) &&
          !existingBySmsId.containsKey(sms.id);
      if (isNewlySeen) {
        for (final p in patterns.where((p) => p.senderId == sms.senderId)) {
          await patternRepository.recordAttempt(p.id, success: false);
        }
      }

      unmatchedToPersist.add(
        UnmatchedSms(
          smsId: sms.id,
          senderId: sms.senderId,
          receivedAt: DateTime.fromMillisecondsSinceEpoch(sms.receivedMs),
          body: sms.body,
        ),
      );
    }

    await unmatchedSmsRepository.upsertAll(unmatchedToPersist);

    // Orphan prune (FR-042): drop unmatched records for smsIds no longer present.
    final presentIds = <String>{for (final s in smsInputs) s.id};
    await unmatchedSmsRepository.pruneMissing(presentIds);

    final finalCount = await unmatchedSmsRepository.activeCount();
    return ScanResult(
      newMatches: newMatches,
      unmatchedCount: finalCount,
      conflicts: conflicts,
    );
  }

  /// After a user teaches/edits a pattern, apply ALL patterns for [senderId]
  /// against the still-unmatched messages from the same sender. Matches are
  /// persisted (or, for [SmsDirection.ignore], just dismissed) and removed
  /// from the queue. Returns the SMS that remained unmatched after this pass,
  /// so the caller can decide whether to keep teaching back-to-back.
  ///
  /// Bodies come from the transient [_bodyCache] populated by the last scan,
  /// plus any extra bodies the caller supplies via [extraBodies] (e.g. the
  /// SMS the user is currently teaching).
  Future<List<UnmatchedSms>> rematchSender(
    String senderId, {
    Map<String, String> extraBodies = const {},
  }) async {
    final unmatched = (await unmatchedSmsRepository.getActive())
        .where((u) => u.senderId == senderId)
        .toList();
    if (unmatched.isEmpty) return const [];

    final patterns = await patternRepository.getForSender(senderId);
    if (patterns.isEmpty) return unmatched;

    final smsInputs = <_SmsInput>[];
    final remaining = <UnmatchedSms>[];
    for (final u in unmatched) {
      final body = extraBodies[u.smsId] ?? _bodyCache[u.smsId] ?? u.body ?? '';
      if (body.isEmpty) {
        // Can't re-match without a body — leave in the queue for the next scan.
        remaining.add(u);
        continue;
      }
      smsInputs.add(_SmsInput(
        id: u.smsId,
        senderId: senderId,
        body: body,
        receivedMs: u.receivedAt.millisecondsSinceEpoch,
      ));
    }

    if (smsInputs.isEmpty) return remaining;

    final result =
        await compute(_runMatching, _IsolateInput(smsInputs, patterns));

    final matchedIds = <String>{};
    for (final match in result.matches) {
      matchedIds.add(match.smsId);
      await unmatchedSmsRepository.removeBySmsId(match.smsId);
      if (match.direction != SmsDirection.ignore) {
        await patternMatchRepository.upsert(match);
      }
      if (match.patternId != null) {
        await patternRepository.recordAttempt(
          match.patternId!,
          success: true,
          matchedAt: match.matchedAt,
        );
      }
    }

    for (final u in unmatched) {
      if (!matchedIds.contains(u.smsId) &&
          !remaining.any((r) => r.smsId == u.smsId)) {
        remaining.add(u);
      }
    }
    return remaining;
  }
}

// --- Isolate payloads (plain, sendable through SendPort) --------------------

class _IsolateInput {
  final List<_SmsInput> smsList;
  final List<SmsPattern> patterns;
  const _IsolateInput(this.smsList, this.patterns);
}

class _SmsInput {
  final String id;
  final String senderId;
  final String body;
  final int receivedMs;
  const _SmsInput({
    required this.id,
    required this.senderId,
    required this.body,
    required this.receivedMs,
  });
}

class _IsolateResult {
  final List<PatternMatch> matches;
  final List<_SmsInput> unmatched;
  const _IsolateResult(this.matches, this.unmatched);
}

/// Top-level isolate entry point: matches each SMS against that sender's
/// patterns in createdAt-ascending order (FR-034). Pure — no I/O.
_IsolateResult _runMatching(_IsolateInput input) {
  final matcher = PatternMatcher();
  final bySender = <String, List<SmsPattern>>{};
  for (final p in input.patterns) {
    bySender.putIfAbsent(p.senderId, () => []).add(p);
  }

  final matches = <PatternMatch>[];
  final unmatched = <_SmsInput>[];

  for (final sms in input.smsList) {
    if (sms.id.isEmpty || sms.body.isEmpty) {
      unmatched.add(sms);
      continue;
    }
    final senderPatterns = bySender[sms.senderId] ?? const <SmsPattern>[];
    final receivedAt = DateTime.fromMillisecondsSinceEpoch(sms.receivedMs);
    final match = matcher.matchAny(senderPatterns, sms.id, sms.body, receivedAt);
    if (match != null) {
      matches.add(match);
    } else {
      unmatched.add(sms);
    }
  }
  return _IsolateResult(matches, unmatched);
}
