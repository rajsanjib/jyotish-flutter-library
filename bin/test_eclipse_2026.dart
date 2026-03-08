import 'package:jyotish/jyotish.dart';

String _fmt(DateTime? dt) {
  if (dt == null) return 'N/A';
  final local = dt.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  final s = local.second.toString().padLeft(2, '0');
  return '$h:$m:$s IST';
}

String _fmtDuration(Duration? d) {
  if (d == null) return 'N/A';
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '${h}h ${m}m ${s}s';
}

void main() async {
  final ephemService = EphemerisService();
  await ephemService.initialize(ephemerisPath: 'ephe');

  // New Delhi coordinates
  final delhi = GeographicLocation(
    latitude: 28.6139,
    longitude: 77.2090,
    altitude: 216,
  );

  print('=' * 60);
  print('  Lunar Eclipse  New Delhi  03 March 2026');
  print('=' * 60);

  final eclipse = await ephemService.getEclipseData(
    date: DateTime(2026, 3, 3),
    location: delhi,
    eclipseType: EclipseType.lunar,
  );

  if (eclipse == null) {
    print('No lunar eclipse found on this date.');
  } else {
    print('Type              : ${eclipse.eclipseType.name}');
    print('Magnitude (Umbral): ${eclipse.magnitude.toStringAsFixed(4)}   '
        '[Ref: 1.14]');
    print(
        'Magnitude (Penum) : ${eclipse.penumbralMagnitude?.toStringAsFixed(4)} '
        '[Ref: 2.18]');

    print('\n--- Global Phase Contact Times (IST) ---');
    print(
        'P1  Penumbral Starts  : ${_fmt(eclipse.penumbralStartTime)}  [Ref: 14:16]');
    print(
        'U1  Umbral Starts     : ${_fmt(eclipse.partialStartTime)}    [Ref: 15:21]');
    print(
        'U2  Total Begins      : ${_fmt(eclipse.totalStartTime)}      [Ref: 16:35]');
    print(
        'Max Eclipse            : ${_fmt(eclipse.maxEclipseTime)}      [Ref: 17:04]');
    print(
        'U3  Total Ends        : ${_fmt(eclipse.totalEndTime)}        [Ref: 17:33]');
    print(
        'U4  Umbral Ends       : ${_fmt(eclipse.partialEndTime)}      [Ref: 18:46]');
    print(
        'P4  Penumbral Ends    : ${_fmt(eclipse.penumbralEndTime)}    [Ref: 19:52]');

    print('\n--- Durations ---');
    final penumDur =
        eclipse.penumbralEndTime != null && eclipse.penumbralStartTime != null
            ? eclipse.penumbralEndTime!.difference(eclipse.penumbralStartTime!)
            : null;
    final totDur =
        eclipse.totalEndTime != null && eclipse.totalStartTime != null
            ? eclipse.totalEndTime!.difference(eclipse.totalStartTime!)
            : null;
    print(
        'Penumbral Duration     : ${_fmtDuration(penumDur)}  [Ref: 05h 35m 45s]');
    print(
        'Partial Phase          : ${_fmtDuration(eclipse.duration)}  [Ref: 03h 25m 17s]');
    print(
        'Total Phase            : ${_fmtDuration(totDur)}  [Ref: 00h 57m 27s]');

    print('\n--- Observer Location (New Delhi) ---');
    print('Moonrise               : ${_fmt(eclipse.moonrise)}   [Ref: 18:26]');
    print('Moonset                : ${_fmt(eclipse.moonset)}');
    print(
        'Local Eclipse Start    : ${_fmt(eclipse.localStartTime)}   [Ref: 18:26]');
    print(
        'Local Eclipse End      : ${_fmt(eclipse.localEndTime)}     [Ref: 18:46]');
    print(
        'Local Duration         : ${_fmtDuration(eclipse.localDuration)}  [Ref: 00h 20m 28s]');

    print('\n--- Sutak / Religious Timings ---');
    print(
        'Sutak Begins (Adults)  : ${_fmt(eclipse.sutakStartTime)}  [Ref: 09:39]');
    print(
        'Sutak Ends             : ${_fmt(eclipse.sutakEndTime)}    [Ref: 18:46]');
    print(
        'Sutak (Kids/Old/Sick)  : ${_fmt(eclipse.sutakForSensitive)}  [Ref: 15:28]');
  }

  ephemService.dispose();
  print('\n' + '=' * 60);
}
