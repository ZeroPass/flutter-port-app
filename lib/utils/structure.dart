class StringUtil {
  static String getWithoutTypeName<T>(T value){
    String str = value.toString();
    return str.substring(str.indexOf('.')+1, str.length);
  }
}

class EnumUtil {
  static T fromStringEnum<T>(Iterable<T> values, String stringType) {
    return values.firstWhere(
            (f)=> "${f.toString().substring(f.toString().indexOf('.')+1)}".toString()
            == stringType, orElse: () => null);
  }
}