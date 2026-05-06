import 'package:flutter_application_1/models/checkin.dart';
import 'package:flutter_application_1/services/local_storage_service.dart';
import 'package:flutter_application_1/services/mongodb_service.dart';
import 'package:uuid/uuid.dart';

class SyncService {
  static const uuid = Uuid();

  static Future<Map<String, dynamic>> syncData() async {
    try {
      // Sync unsynced check-ins
      final unsyncedCheckIns = LocalStorageService.getUnsyncedCheckIns();

      if (unsyncedCheckIns.isEmpty) {
        return {
          'success': true,
          'message': 'No data to sync',
          'syncedCount': 0,
        };
      }

      // Group by event
      Map<String, List<CheckIn>> checkInsByEvent = {};
      for (var checkIn in unsyncedCheckIns) {
        if (!checkInsByEvent.containsKey(checkIn.eventId)) {
          checkInsByEvent[checkIn.eventId] = [];
        }
        checkInsByEvent[checkIn.eventId]!.add(checkIn);
      }

      int syncedCount = 0;
      for (var eventId in checkInsByEvent.keys) {
        final checkIns = checkInsByEvent[eventId]!;
        final checkInJsons =
            checkIns.map((c) => c.toJson()).toList();

        final result = await MongoDBService.syncCheckIns(
          eventId: eventId,
          checkIns: checkInJsons,
        );

        if (result['success']) {
          // Mark as synced
          for (var checkIn in checkIns) {
            await LocalStorageService.updateCheckInSyncStatus(checkIn.id);
            syncedCount++;
          }
        }
      }

      return {
        'success': true,
        'message': 'Sync completed',
        'syncedCount': syncedCount,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Sync failed: $e',
        'syncedCount': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> checkInParticipant({
    required String eventId,
    required String participantId,
    required bool isOnline,
  }) async {
    try {
      final checkInId = uuid.v4();

      // Check for duplicate locally
      final eventCheckIns = LocalStorageService.getEventCheckIns(eventId);
      final isDuplicate = eventCheckIns.any(
        (c) => c.participantId == participantId,
      );

      if (isDuplicate) {
        return {
          'success': false,
          'message': 'Participant already checked in for this event',
          'status': 'duplicate',
        };
      }

      // Check capacity
      if (eventCheckIns.length >= 100) {
        // This should come from event object
        return {
          'success': false,
          'message': 'Event is full',
          'status': 'full',
        };
      }

      // Save check-in locally
      final checkIn = CheckIn(
        id: checkInId,
        participantId: participantId,
        eventId: eventId,
        checkedInAt: DateTime.now(),
        status: 'success',
        synced: isOnline, // Mark as synced if online
        createdAt: DateTime.now(),
      );

      await LocalStorageService.saveCheckIn(checkIn);

      // If online, also sync to server
      if (isOnline) {
        final result = await MongoDBService.checkInParticipant(
          eventId: eventId,
          participantId: participantId,
        );

        if (result['success']) {
          return {
            'success': true,
            'message': 'Check-in successful',
            'status': 'success',
            'checkIn': checkIn,
          };
        } else {
          // Save locally as unsynced
          await LocalStorageService.saveCheckIn(
            checkIn.copyWith(synced: false),
          );
          return {
            'success': true,
            'message':
                'Check-in saved locally (will sync when online)',
            'status': 'success_offline',
            'checkIn': checkIn,
          };
        }
      }

      return {
        'success': true,
        'message': 'Check-in saved locally (offline mode)',
        'status': 'success_offline',
        'checkIn': checkIn,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'status': 'failed',
      };
    }
  }
}
