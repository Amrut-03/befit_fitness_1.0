import 'dart:async';

import 'package:flutter/widgets.dart';

/// Rebuilds every second with the current time. Timers in the session are
/// timestamps, so this only refreshes the display.
class Ticker extends StatefulWidget {
  const Ticker({super.key, required this.builder, this.clock});

  final Widget Function(BuildContext context, DateTime now) builder;
  final DateTime Function()? clock;

  @override
  State<Ticker> createState() => _TickerState();
}

class _TickerState extends State<Ticker> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, (widget.clock ?? DateTime.now)());
}

/// "4:05", or "1:02:09" from an hour up.
String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}
