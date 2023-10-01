import 'package:mobx/mobx.dart';
import 'package:sqflite/sqflite.dart';

part 'store.g.dart';

late Database db;
var store = Transcripts();

Future<void> initDb() async {
  db = await openDatabase('transcripts.db', version: 1, onCreate: (db, version) {
    db.execute("""CREATE TABLE transcripts(id INTEGER PRIMARY KEY, 
      name TEXT NOT NULL,
      time INTEGER NOT NULL,
      content TEXT NOT NULL)""");
  });
}

class Transcripts = _Transcripts with _$Transcripts;

abstract class _Transcripts with Store {
  @observable
  ObservableList<Transcript> transcripts = ObservableList.of([]);

  @action
  Future<void> load() async {
    List<Transcript> ts = [];
    List<Map> res = await db.rawQuery('SELECT name, time, content FROM transcripts');
    for (var r in res) {
      final name = r['name'];
      final time = r['time'];
      final content = r['content'];
      final transcript = Transcript(name, DateTime.fromMillisecondsSinceEpoch(time), content);
      ts.add(transcript);
    }
    transcripts = ObservableList.of(ts);
  }

  @action
  Future<void> add(String name, DateTime time, String content) async {
    final transcript = Transcript(name, time, content);
    transcripts.add(transcript);
    await db.rawInsert("INSERT INTO transcripts(name, time, content) VALUES (?1, ?2, ?3)", 
    [name, time.millisecondsSinceEpoch, content]);
  }
}

class Transcript {
  final String name;
  final DateTime timestamp;
  final String content;

  Transcript(this.name, this.timestamp, this.content);
}
