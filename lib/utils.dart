String formatDuration (Duration duration) {
  int m = duration.inMinutes;
  int s = duration.inSeconds - m * Duration.secondsPerMinute;
  String mstr = m < 10 ? '0$m' : m.toString();
  String sstr = s < 10 ? '0$s' : s.toString();
  return '$mstr:$sstr';
}