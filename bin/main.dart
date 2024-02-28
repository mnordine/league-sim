import 'dart:io';
import 'package:league_sim/league_sim.dart';

void main(List<String> args) {
  const defaultCount = 1000;
  final count = args.isEmpty ? defaultCount : int.tryParse(args.first) ?? defaultCount;

  print('running league sim $count times...');

  final sink = File('output.txt').openWrite();

  var badCount = 0;
  for (final i in 1.to(count)) {
    final (teams, results) = sim();
    final place = teams.indexWhere((team) => team.name == 'TASA');
    if (place > 3) {
      badCount++;

      sink..writeln()..writeln('--------run $i-------');

      teams.summarize(sink);
      sink.writeln();

      results.forEach((result) => sink.writeln('$result'));
      sink..writeln()..writeln();
    }
  }

  print('done');

  final percent = (badCount / count) * 100;
  sink.writeln("We're out count: $badCount out of $count, ${percent.toStringAsFixed(2)}%");
}
