import 'dart:io';
import 'package:league_sim/league_sim.dart';

typedef Entry = ({List<Team> teams, List<Result> results, int run});

void main(List<String> args) {
  const defaultCount = 1000;
  final count = args.isEmpty ? defaultCount : int.tryParse(args.first) ?? defaultCount;

  print('running league sim $count times...');

  final badResults = 1.to(count).map((i) {
    final (teams, results) = sim();
    final place = teams.indexWhere((team) => team.name == 'TASA');
    return place > 3 ? (teams: teams, results: results, run: i) : null;
  }).nonNulls.toList();

  print('done');

  if (badResults.isEmpty) return;

  final percent = (badResults.length / count) * 100;

  final sink = File('output.txt').openWrite()
    ..writeln("We're out count: ${badResults.length} out of $count, ${percent.toStringAsFixed(2)}%")
    ..writeln();

  for (final Entry(:teams, :results, :run) in badResults) {
    sink..writeln()..writeln('--------run $run-------');

    teams.summarize(sink);
    sink.writeln();

    results.forEach((result) => sink.writeln('$result'));
    sink..writeln()..writeln();
  }
}
