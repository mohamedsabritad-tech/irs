String? optStr(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is String) return v;
  if (v is int) return v.toString();
  if (v is double) return v.toString();
  return null;
}

int? optInt(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}
