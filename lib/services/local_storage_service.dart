import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/participant.dart';
import 'package:flutter_application_1/models/checkin.dart';
import 'package:flutter_application_1/models/user.dart';

class LocalStorageService {
  static const String eventsBox = 'events';
  static const String participantsBox = 'participants';
  static const String checkInsBox = 'checkIns';
  static const String userBox = 'user';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(eventsBox);
    await Hive.openBox<Map>(participantsBox);
    await Hive.openBox<Map>(checkInsBox);
    await Hive.openBox<Map>(userBox);
  }

  // User
  static Future<void> saveUser(User user) async {
    final box = Hive.box<Map>(userBox);
    await box.put('currentUser', user.toJson());
  }

  static User? getUser() {
    final box = Hive.box<Map>(userBox);
    final userData = box.get('currentUser');
    if (userData != null) {
      return User.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  static Future<void> clearUser() async {
    final box = Hive.box<Map>(userBox);
    await box.clear();
  }

  // Events
  static Future<void> saveEvent(Event event) async {
    final box = Hive.box<Map>(eventsBox);
    await box.put(event.id, event.toJson());
  }

  static Event? getEvent(String eventId) {
    final box = Hive.box<Map>(eventsBox);
    final eventData = box.get(eventId);
    if (eventData != null) {
      return Event.fromJson(Map<String, dynamic>.from(eventData));
    }
    return null;
  }

  static List<Event> getAllEvents() {
    final box = Hive.box<Map>(eventsBox);
    return box.values
        .map((e) => Event.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> deleteEvent(String eventId) async {
    final box = Hive.box<Map>(eventsBox);
    await box.delete(eventId);
  }

  // Participants
  static Future<void> saveParticipant(Participant participant) async {
    final box = Hive.box<Map>(participantsBox);
    await box.put(participant.id, participant.toJson());
  }

  static Participant? getParticipant(String participantId) {
    final box = Hive.box<Map>(participantsBox);
    final pData = box.get(participantId);
    if (pData != null) {
      return Participant.fromJson(Map<String, dynamic>.from(pData));
    }
    return null;
  }

  static List<Participant> getEventParticipants(String eventId) {
    final box = Hive.box<Map>(participantsBox);
    return box.values
        .where((p) {
          final pData = Map<String, dynamic>.from(p);
          return pData['eventId'] == eventId;
        })
        .map((e) => Participant.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> deleteParticipant(String participantId) async {
    final box = Hive.box<Map>(participantsBox);
    await box.delete(participantId);
  }

  // CheckIns
  static Future<void> saveCheckIn(CheckIn checkIn) async {
    final box = Hive.box<Map>(checkInsBox);
    await box.put(checkIn.id, checkIn.toJson());
  }

  static CheckIn? getCheckIn(String checkInId) {
    final box = Hive.box<Map>(checkInsBox);
    final ciData = box.get(checkInId);
    if (ciData != null) {
      return CheckIn.fromJson(Map<String, dynamic>.from(ciData));
    }
    return null;
  }

  static List<CheckIn> getEventCheckIns(String eventId) {
    final box = Hive.box<Map>(checkInsBox);
    return box.values
        .where((c) {
          final cData = Map<String, dynamic>.from(c);
          return cData['eventId'] == eventId;
        })
        .map((e) => CheckIn.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<CheckIn> getUnsyncedCheckIns() {
    final box = Hive.box<Map>(checkInsBox);
    return box.values
        .where((c) {
          final cData = Map<String, dynamic>.from(c);
          return cData['synced'] == false;
        })
        .map((e) => CheckIn.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> updateCheckInSyncStatus(String checkInId) async {
    final box = Hive.box<Map>(checkInsBox);
    final ciData = box.get(checkInId);
    if (ciData != null) {
      final checkIn = CheckIn.fromJson(Map<String, dynamic>.from(ciData));
      final updatedCheckIn = checkIn.copyWith(synced: true);
      await box.put(checkInId, updatedCheckIn.toJson());
    }
  }

  static Future<void> deleteCheckIn(String checkInId) async {
    final box = Hive.box<Map>(checkInsBox);
    await box.delete(checkInId);
  }

  static Future<void> clearAllData() async {
    final eventsBox = Hive.box<Map>(LocalStorageService.eventsBox);
    final participantsBox = Hive.box<Map>(LocalStorageService.participantsBox);
    final checkInsBox = Hive.box<Map>(LocalStorageService.checkInsBox);
    await eventsBox.clear();
    await participantsBox.clear();
    await checkInsBox.clear();
  }
}
