extension MapExtension on Map {
  Map removeNulls() {
    removeWhere((key, value) => value == null);
    return this;
  }
}
