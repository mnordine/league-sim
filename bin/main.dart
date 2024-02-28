import 'dart:io';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:league_sim/league_sim.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('count', abbr: 'c', help: 'simulation count', defaultsTo: '1000')
    ..addOption('team', abbr: 't', help: 'team to analyze', mandatory: true)
    ..addOption('place', abbr: 'p', help: 'minimum place to check', defaultsTo: '4');

  final results = parser.parse(args);
  final count = int.tryParse(results['count'] as String) ?? 1000;
  final teamName = results['team'] as String;
  final inputPlace = int.tryParse(results['place'] as String) ?? 4;

  print('running league sim $count times...');

  final sink = File('output.txt').openWrite();

  final goodCounts = {
    for (final name in teamNames)
      name: 0
  };

  var badCount = 0;
  for (final i in 1.to(count)) {
    final (teams, results) = sim();

    for (final team in teams.take(inputPlace)) {
      final count = goodCounts[team.name]!;
      goodCounts[team.name] = count + 1;
    }

    final place = teams.indexWhere((team) => team.name == teamName);
    if (place > (inputPlace - 1)) {
      badCount++;

      sink..writeln()..writeln('--------run $i-------');

      teams.summarize(sink);
      sink.writeln();

      results.forEach((result) => sink.writeln('$result'));
      sink..writeln()..writeln();
    }
  }

  print('done');

  // Sort by good counts
  final sorted = goodCounts.entries.sortedByCompare((entry) => entry, (a, b) => b.value.compareTo(a.value));
  for (final MapEntry(:key, value: goodCount) in sorted) {
    final inPercent = (goodCount / count) * 100;
    print('$key: ${inPercent.toStringAsFixed(2)}%');
  }

  final outPercent = (badCount / count) * 100;
  sink.writeln('$teamName out count: $badCount out of $count, ${outPercent.toStringAsFixed(2)}%');

  final inPercent = ((count - badCount) / count) * 100;
  print('in ${inPercent.toStringAsFixed(2)}');
}
