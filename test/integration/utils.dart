library integration_utils;

Map<String, List<String>> parseHeaders(String headers) {
  var headersMap = new Map<String, List<String>>();
  if (headers == null) {
    return headersMap;
  }
  headers.split('\n').forEach((String line) {
    if (!line.contains(': ')) {
      return;
    }
    List<String> pieces = line.split(': ');
    String header = pieces[0];
    List<String> values = pieces[1].replaceFirst('\n', '').split(', ');
    headersMap[header] = values;
  });
  return headersMap;
}