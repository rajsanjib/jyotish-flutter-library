/// Enumeration of the 12 Rashi (Zodiac Signs).
enum Rashi {
  aries('Aries', 'Mesha', 0),
  taurus('Taurus', 'Vrishabha', 1),
  gemini('Gemini', 'Mithuna', 2),
  cancer('Cancer', 'Karka', 3),
  leo('Leo', 'Simha', 4),
  virgo('Virgo', 'Kanya', 5),
  libra('Libra', 'Tula', 6),
  scorpio('Scorpio', 'Vrishchika', 7),
  sagittarius('Sagittarius', 'Dhanu', 8),
  capricorn('Capricorn', 'Makara', 9),
  aquarius('Aquarius', 'Kumbha', 10),
  pisces('Pisces', 'Meena', 11);

  const Rashi(this.name, this.sanskritName, this.number);

  /// English name of the sign
  final String name;

  /// Sanskrit name of the sign
  final String sanskritName;

  /// 0-indexed position (Aries=0, Pisces=11)
  final int number;

  /// Returns the Rashi for a given longitude (0-360).
  static Rashi fromLongitude(double longitude) {
    final idx = (longitude / 30).floor() % 12;
    return Rashi.values[idx];
  }

  /// Returns the Rashi for a given index (0-11).
  static Rashi fromIndex(int index) {
    return Rashi.values[index % 12];
  }

  /// Whether this is an odd sign (Aries, Gemini, etc.)
  bool get isOdd => (number + 1) % 2 != 0;

  /// Whether this is an even sign (Taurus, Cancer, etc.)
  bool get isEven => !isOdd;

  @override
  String toString() => name;
}
