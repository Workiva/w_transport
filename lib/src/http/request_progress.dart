library w_transport.src.http.request_progress;

/// A representation of a progress event at a specific point in time
/// either for an HTTP request upload or download. Based on [ProgressEvent]
/// but with an additional [percent] property for convenience.
class RequestProgress {
  /// Amount of work already done.
  final int loaded;

  /// Total amount of work being performed. This only represents the content
  /// itself, not headers and other overhead.
  final int total;

  /// Indicates whether or not the progress is measurable.
  bool _lengthComputable;

  /// Percentage of work done.
  double _percent;

  RequestProgress([this.loaded = 0, this.total = -1]) {
    _lengthComputable = total != null && total > -1;
    if (!_lengthComputable) {
      _percent = 0.0;
    } else if (total == 0) {
      _percent = 100.0;
    } else {
      _percent = loaded * 100.0 / total;
    }
  }

  /// Indicates whether or not the progress is measurable.
  bool get lengthComputable => _lengthComputable;

  /// Percentage of work done.
  double get percent => _percent;
}
