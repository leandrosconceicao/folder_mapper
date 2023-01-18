class HostnameInfo {
  String? ip;
  String? hostname;
  String? username;

  HostnameInfo.fromJson(Map json) {
    ip = json['ip'];
    hostname = json['hostname'];
    username = json['username'];
  }
}