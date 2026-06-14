String? optStr(Map<String, dynamic> json, String key) {
  final v = json[key];
  return v is String ? v : null;
}

int? optInt(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}
