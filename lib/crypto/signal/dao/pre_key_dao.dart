import 'package:moor/moor.dart';

import '../signal_database.dart';

part 'pre_key_dao.g.dart';

@UseDao(tables: [Prekeys])
class PreKeyDao extends DatabaseAccessor<SignalDatabase> with _$PreKeyDaoMixin {
  PreKeyDao(SignalDatabase db) : super(db);

  Future<Prekey?> getPreKeyById(int preKeyId) async =>
      (select(db.prekeys)..where((tbl) => tbl.prekeyId.equals(preKeyId)))
          .getSingleOrNull();

  Future<int> deleteByPreKeyId(int preKeyId) =>
      (delete(db.prekeys)..where((tbl) => tbl.prekeyId.equals(preKeyId))).go();

  Future insert(Prekey preKey) => into(db.prekeys).insert(preKey);
}
