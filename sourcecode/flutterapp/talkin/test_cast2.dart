void main() {
  Map<dynamic, dynamic> dynamicMap = {'a': 'b'};
  try {
    Map<String, dynamic> stringMap = dynamicMap as Map<String, dynamic>;
    print("Success");
  } catch (e) {
    print("Error: $e");
  }
}
