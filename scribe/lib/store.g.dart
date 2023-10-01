// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Transcripts on _Transcripts, Store {
  late final _$transcriptsAtom =
      Atom(name: '_Transcripts.transcripts', context: context);

  @override
  ObservableList<Transcript> get transcripts {
    _$transcriptsAtom.reportRead();
    return super.transcripts;
  }

  @override
  set transcripts(ObservableList<Transcript> value) {
    _$transcriptsAtom.reportWrite(value, super.transcripts, () {
      super.transcripts = value;
    });
  }

  late final _$loadAsyncAction =
      AsyncAction('_Transcripts.load', context: context);

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$addAsyncAction =
      AsyncAction('_Transcripts.add', context: context);

  @override
  Future<void> add(String name, DateTime time, String content) {
    return _$addAsyncAction.run(() => super.add(name, time, content));
  }

  @override
  String toString() {
    return '''
transcripts: ${transcripts}
    ''';
  }
}
