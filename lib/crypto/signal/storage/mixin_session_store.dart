import 'package:flutter/foundation.dart';
import 'package:flutter_app/crypto/signal/dao/session_dao.dart';
import 'package:flutter_app/crypto/signal/signal_protocol.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../signal_database.dart';

class MixinSessionStore extends SessionStore {
  MixinSessionStore(SignalDatabase db) : super() {
    sessionDao = SessionDao(db);
  }

  late SessionDao sessionDao;

  @override
  Future<bool> containsSession(SignalProtocolAddress address) async {
    final session =
        await sessionDao.getSession(address.getName(), address.getDeviceId());
    if (session == null) {
      return false;
    }
    final sessionRecord = await loadSession(address);
    return sessionRecord.sessionState.hasSenderChain() &&
        sessionRecord.sessionState.getSessionVersion() ==
            CiphertextMessage.CURRENT_VERSION;
  }

  @override
  void deleteAllSessions(String name) async {
    final devices = await getSubDeviceSessions(name);
    await deleteSession(
        SignalProtocolAddress(name, SignalProtocol.defaultDeviceId));
    for (final device in devices) {
      await deleteSession(SignalProtocolAddress(name, device));
    }
  }

  @override
  Future deleteSession(SignalProtocolAddress address) async {
    final session =
        await sessionDao.getSession(address.getName(), address.getDeviceId());
    if (session != null) {
      await sessionDao.deleteSession(session);
    }
  }

  @override
  Future<List<int>> getSubDeviceSessions(String name) async {
    return sessionDao.getSubDevice(name);
  }

  @override
  Future<SessionRecord> loadSession(SignalProtocolAddress address) async {
    final session =
        await sessionDao.getSession(address.getName(), address.getDeviceId());
    if (session != null) {
      return SessionRecord.fromSerialized(session.record);
    }
    return SessionRecord();
  }

  @override
  Future storeSession(
      SignalProtocolAddress address, SessionRecord record) async {
    final session =
        await sessionDao.getSession(address.getName(), address.getDeviceId());
    if ((session == null) || !listEquals(session.record, record.serialize())) {
      await sessionDao.insert(Session(
          id: 0,
          address: address.getName(),
          device: address.getDeviceId(),
          record: record.serialize(),
          timestamp: DateTime.now().microsecond));
    }
  }
}
