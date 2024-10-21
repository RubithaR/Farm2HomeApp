class Step {
  final String htmlInstructions;
  final Distance distance;
  final Duration duration;

  Step({
    required this.htmlInstructions,
    required this.distance,
    required this.duration,
  });
}

class Distance {
  final String text;

  Distance({required this.text});
}

class Duration {
  final String text;

  Duration({required this.text});
}
