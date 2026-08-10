void main() {
  Map<String, String> stringMap = {'hello': 'world'};
  try {
    Map<String, dynamic> dynamicMap = stringMap as Map<String, dynamic>;
    print("Success");
  } catch (e) {
    print("Error: $e");
  }
}
