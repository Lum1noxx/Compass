class Util {
  static String formatDuration(double seconds) {
    int hrs = (seconds / 3600).floor();
    seconds = seconds % 3600;
    int mins = (seconds / 60).floor();
    int secs = (seconds % 60).round();
    StringBuffer res = StringBuffer();
    if (hrs > 0) {
      res.write("${hrs.toString().padLeft(2)} hr ");
    }
    if (mins > 0) {
      res.write("${mins.toString().padLeft(2)} min ");
    }
    if (secs > 0) {
      res.write("${secs.toString().padLeft(2)} s ");
    }
    return res.toString().trimRight();

  }
}