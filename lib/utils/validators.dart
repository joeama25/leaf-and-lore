class Validators {
  static String? email(String? v){
    if(v==null || v.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v){
    if(v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? v, String field){
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }
}