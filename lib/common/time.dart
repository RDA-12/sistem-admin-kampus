import 'package:equatable/equatable.dart';

/// Represent a time in hour and minute
class Time extends Equatable {
  /// Creates new [Time]
  const new({required this.hour, required this.minute});

  /// Hour at this point of time
  final int hour;

  /// Minute at this point of time
  final int minute;

  @override
  List<Object?> get props => [hour, minute];
}

/// Represent date and time for an event
class EventDateTime extends Equatable {
  /// Creates new [EventDateTime]
  ///
  /// It useful for defining start and end date time of an event
  const new({
    required this.date,
    required this.time,
  });

  /// Date of the event
  final DateTime date;

  /// Time of the event
  final Time time;

  @override
  List<Object?> get props => [date, time];
}
