library w_transport.src.http.w_progress;

/// A representation of a progress event at a specific point in time
/// either for an HTTP request upload or download. Based on [ProgressEvent]
/// but with an additional [percent] property for convenience.
class WProgress {
  /// Amount of work already done.
  final int loaded;

  /// Total amount of work being performed. This only represents the content
  /// itself, not headers and other overhead.
  final int total;

  /// Indicates whether or not the progress is measurable.
  bool _lengthComputable;

  /// Percentage of work done.
  double _percent;

  WProgress([this.loaded = 0, this.total = -1]) {
    _lengthComputable = total > -1;
    _percent = lengthComputable ? loaded * 100.0 / total : 0.0;
  }

  /// Indicates whether or not the progress is measurable.
  bool get lengthComputable => _lengthComputable;

  /// Percentage of work done.
  double get percent => _percent;
}
