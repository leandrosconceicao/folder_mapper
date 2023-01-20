import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:folder_mapper/model.dart';
import 'package:get/get.dart';

final ps = FileService();
RxString ipInfo = ''.obs;
RxString hostInfo = ''.obs;
RxString userName = ''.obs;
final shareName = TextEditingController();
final remoteHostname = TextEditingController();
final folderName = TextEditingController();
final RxnBool isRemote = RxnBool(null);

class FileService {
  Future<String> shareFolder() async {
    final path = await selectFold();
    if (path != null) {
      try {
        String command = 'NET SHARE ${path.split('\\').last}=$path /grant:${userName.value},FULL';
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
    const key = 'computername';
    const userKey = 'username';
    late final String ip;
    try {
      final req = await Process.run('ipconfig | findstr /C:IPv4', [], runInShell: true);
      ip = req.stdout.trim().split(' . :')[1].trim();
    } catch (e) {
      ip = '';
    }
    dt['ip'] = ip;
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

  Future<String> mapFolder() async {
    String command = 'NET USE T: ${_buildPath()} /user:${userName.value}';
    final r = await Process.run(command, [], runInShell: true);
    if (r.exitCode == 0) {
      return 'Processo concluido com sucesso';
    }
    return '${r.exitCode} - ${r.stdout} ${r.stderr}';
  }

  String _buildPath() {
    return "\\\\${remoteHostname.value.text}\\${folderName.value.text}";
  }
}