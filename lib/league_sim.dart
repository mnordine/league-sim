import 'dart:io' show IOSink;
import 'dart:math' show Random;
import 'package:collection/collection.dart';

final _rand = Random.secure();

class Team {
  final String name;

  var games = 0;
  var wins = 0;
  var losses = 0;
  var ties = 0;
  var goalsFor = 0;
  var goalsAgainst = 0;

  Team(this.name, {this.wins = 0, this.losses = 0, this.ties = 0}) :
      games = wins + losses + ties;

  int get points => (wins * 2) + ties;

  double get goalDifferential => goalsFor / (goalsFor + goalsAgainst);
}

class Game {
  final Team team1;
  final Team team2;
  Result? _result;

  Game(this.team1, this.team2);

  Result sim() => Result(
    (team: team1, goals: _scoreWeights.random),
    (team: team2, goals: _scoreWeights.random),
  );

  Result? get result => _result;
}

class Result {
  final Score _score1;
  final Score _score2;

  Result(this._score1, this._score2) {
    _score1.team.goalsFor += _score1.goals;
    _score1.team.goalsAgainst += _score2.goals;

    _score2.team.goalsFor += _score2.goals;
    _score2.team.goalsAgainst += _score1.goals;
  }

  Team get team1 => _score1.team;
  Team get team2 => _score2.team;

  Team? get winner {
    if (tie) return null;

    return _score1.goals > _score2.goals
      ? _score1.team
      : _score2.team;
  }

  Team? get loser {
    if (tie) return null;

    return _score1.goals > _score2.goals
        ? _score2.team
        : _score1.team;
  }

  bool get tie => _score1.goals == _score2.goals;

  @override
  String toString() {
    if (tie) return '${team1.name} ${_score1.goals} - '
        '${team2.name} ${_score2.goals}';

    return '${winner!.name} ${[_score1.goals, _score2.goals].max} - '
        '${loser!.name} ${[_score1.goals, _score2.goals].min}';
  }
}

typedef Score = ({Team team, int goals});

final _scoreWeights = [
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  4, 4, 4, 4, 4, 4, 4,
  5, 5, 5, 5, 5, 5,
  6, 6, 6,
  7, 7,
  8,
  9,
  10,
];

(List<Team>, List<Result>) sim() {
  final tasa = Team('TASA');
  final bedfordWhite = Team('Bedford White');
  final halifax = Team('Halifax');
  final sackville = Team('Sackville');
  final coleharbour = Team('Cole Harbour');
  final bedfordBlue = Team('Bedford Blue');
  final dartmouth = Team('Dartmouth');
  final chebucto = Team('Chebucto');
  final eastHants = Team('East Hants');

  final teams = [
    tasa,
    bedfordWhite,
    halifax,
    sackville,
    coleharbour,
    bedfordBlue,
    dartmouth,
    chebucto,
    eastHants,
  ];

  final games = [
    Game(chebucto, eastHants),
    Game(halifax, bedfordWhite),
    Game(dartmouth, coleharbour),
    Game(bedfordWhite, bedfordBlue),
    Game(coleharbour, sackville),
    Game(eastHants, bedfordBlue),
    Game(bedfordBlue, dartmouth),
    Game(tasa, sackville),
    Game(coleharbour, halifax),
    Game(eastHants, dartmouth),
    Game(bedfordBlue, coleharbour),
    Game(dartmouth, sackville),
  ];

  final existingResults = [
    Result((team: bedfordBlue, goals: 2), (team: chebucto, goals: 1)),
    Result((team: bedfordBlue, goals: 0), (team: halifax, goals: 0)),
    Result((team: bedfordBlue, goals: 1), (team: tasa, goals: 4)),
    Result((team: bedfordBlue, goals: 2), (team: sackville, goals: 2)),

    Result((team: bedfordWhite, goals: 1), (team: coleharbour, goals: 0)),
    Result((team: bedfordWhite, goals: 5), (team: dartmouth, goals: 0)),
    Result((team: bedfordWhite, goals: 1), (team: sackville, goals: 1)),
    Result((team: bedfordWhite, goals: 2), (team: eastHants, goals: 1)),
    Result((team: bedfordWhite, goals: 4), (team: chebucto, goals: 0)),
    Result((team: bedfordWhite, goals: 1), (team: tasa, goals: 0)),

    Result((team: tasa, goals: 2), (team: eastHants, goals: 0)),
    Result((team: tasa, goals: 5), (team: chebucto, goals: 3)),
    Result((team: tasa, goals: 3), (team: halifax, goals: 1)),
    Result((team: tasa, goals: 5), (team: dartmouth, goals: 2)),
    Result((team: tasa, goals: 1), (team: coleharbour, goals: 5)),

    Result((team: halifax, goals: 3), (team: sackville, goals: 3)),
    Result((team: halifax, goals: 1), (team: eastHants, goals: 0)),
    Result((team: halifax, goals: 3), (team: chebucto, goals: 2)),
    Result((team: halifax, goals: 5), (team: dartmouth, goals: 2)),

    Result((team: sackville, goals: 4), (team: eastHants, goals: 1)),
    Result((team: sackville, goals: 2), (team: chebucto, goals: 0)),

    Result((team: coleharbour, goals: 3), (team: eastHants, goals: 1)),
    Result((team: coleharbour, goals: 0), (team: chebucto, goals: 3)),

    Result((team: dartmouth, goals: 3), (team: chebucto, goals: 1)),
  ];

  final playedResults = games.map((game) => game.sim()).toList();

  final results = existingResults + playedResults;

  for (final result in results) {
    result.team1.games++;
    result.team2.games++;

    if (result.tie) {
      result.team1.ties++;
      result.team2.ties++;
    } else {
      result.winner!.wins++;
      result.loser!.losses++;
    }
  }

  teams.sort((a, b) {
    if (a.points != b.points) return b.points.compareTo(a.points);

    final result = results.singleWhere((result) =>
      (result.team1 == a && result.team2 == b) || (result.team2 == a && result.team1 == b)
    );

    if (result.tie) return b.goalDifferential.compareTo(a.goalDifferential);

    return result.winner! == a ? -1 : 1;
  });
  return (teams, playedResults);
}

extension RandomExtension<E> on Iterable<E>{
  E get random => elementAt(_rand.nextInt(length));
}

extension TeamExtension on List<Team> {
  void summarize(IOSink sink) {
    for (final team in this) {
      sink.writeln('${team.name.padRight(18)}${team.games.toString().padRight(5)}'
          '${team.wins.toString().padRight(5)}'
          '${team.losses.toString().padRight(5)}'
          '${team.ties.toString().padRight(5)}'
          '${team.points.toString().padRight(5)}');
    }
  }
}

extension Range on int{
  /// both ends are inclusive
  Iterable<int> to(int end) sync* {
    if (this < end) {
      for (var i = this; i <= end; i++) {
        yield i;
      }
    } else {
      for (var i = this; i >= end; i--) {
        yield i;
      }
    }
  }
}
