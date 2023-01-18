import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:folder_mapper/model.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';

final ps = FileService();
RxString ipInfo = ''.obs;
RxString hostInfo = ''.obs;
RxString userName = ''.obs;
final shareName = TextEditingController();

class FileService {
  Future<String> run() async {
    final path = await selectFold();
    if (path != null) {
      try {
        String command = 'NET SHARE ${shareName.text}=$path /grant:${userName.value},FULL';
        final r = await Process.run(command, [], runInShell: true);
        if (r.exitCode == 2) {
          return 'Necessário executar a aplicação como administrador';
        } else if (r.exitCode == 0) {
          return 'Processo finalizado com sucesso!';
        } else {
          return '${r.exitCode} - ${r.stdout} ${r.stderr}';
        }
      } catch (e) {
        return 'Ocorreu um erro $e';
      }
    } else {
      return '';
    }
  }

  Future<HostnameInfo> getHostInfo() async {
    Map<String, String?> dt = {};
    const key = 'userdomain';
    const userKey = 'username';
    final net = NetworkInfo();
    final ip = await net.getWifiIP();
    if (ip != null) {
      dt['ip'] = ip;
    }
    if (Platform.environment.containsKey(key)) {
      dt['hostname'] = Platform.environment[key];
    }
    if (Platform.environment.containsKey(userKey)) {
      dt['username'] = Platform.environment[userKey];
    }
    final info =  HostnameInfo.fromJson(dt);
    ipInfo.value = info.ip ?? '';
    hostInfo.value = info.hostname ?? '';
    userName.value = info.username ?? '';
    return info;
  }

  Future<String?> selectFold() async {
    final f = await FilePicker.platform.getDirectoryPath();
    return f;
  }

  Future<String> mapFolder(String path) async {
    String command = 'NET USE T: /DELETE /YES \n NET USE T: $path /user:${userName.value}';
    final r = await Process.run(command, [], runInShell: true);
    return '${r.exitCode} - ${r.stdout} ${r.stderr}';
  }
}