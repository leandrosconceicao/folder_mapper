import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folder_mapper/controllers.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final formKey = GlobalKey<FormState>();
  final remoteForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ps.getHostInfo();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapeador de pastas'),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => SelectionArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: hostInfo.value));
                                Get.rawSnackbar(
                                    message:
                                        'Dados do host copiados com sucesso');
                              },
                              icon: const Icon(Icons.copy)),
                          SizedBox(width: Get.height * 0.02,),
                          Column(
                            children: [
                              Text('Nome do computador: ${hostInfo.value}'),
                              Text('IP do computador: ${ipInfo.value}'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.02,),
              SizedBox(
                width: Get.height * 0.6,
                height: Get.height * 0.07,
                child: ElevatedButton(
                    onPressed: () async {
                      final p = await ps.shareFolder();
                      if (p.isNotEmpty) {
                        Get.dialog(AlertDialog(
                          content: Text(p),
                        ));
                      }
                    },
                    child: const Text('Compartilhar pasta')),
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              SizedBox(
                width: Get.height * 0.6,
                height: Get.height * 0.07,
                child: ElevatedButton(
                  onPressed: () async {
                    Get.dialog(AlertDialog(
                      scrollable: true,
                      title: const Text('Tipo de mapeamento'),
                      content: Obx(
                        () => Form(
                          key: remoteForm,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                      title: const Text('Remoto'),
                                      groupValue: isRemote.value,
                                      value: true,
                                      onChanged: (bool? value) =>
                                          isRemote.value = value,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile(
                                      title: const Text('Local'),
                                      groupValue: isRemote.value,
                                      value: false,
                                      onChanged: (bool? value) =>
                                          isRemote.value = value,
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                  visible: isRemote.value ?? false,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: remoteHostname,
                                        validator: isRemote.value ?? false
                                            ? (String? value) =>
                                                value?.isEmpty ?? true
                                                    ? 'Obrigatório'
                                                    : null
                                            : null,
                                        decoration: const InputDecoration(
                                            labelText:
                                                'Nome ou ip do computador'),
                                      ),
                                      SizedBox(
                                        height: Get.height * 0.02,
                                      ),
                                      TextFormField(
                                        controller: folderName,
                                        validator: isRemote.value ?? false
                                            ? (String? value) =>
                                                value?.isEmpty ?? true
                                                    ? 'Obrigatório'
                                                    : null
                                            : null,
                                        decoration: const InputDecoration(
                                            labelText: 'Nome da pasta'),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () async {
                              if (remoteForm.currentState!.validate()) {
                                if (isRemote.value ?? false) {
                                  loading();
                                  final req = await ps.mapFolder();
                                  Get.back();
                                  Get.back();
                                  Get.rawSnackbar(message: req);
                                } else {
                                  final path = await ps.selectFold() ?? '';
                                  if (path.isNotEmpty) {
                                    loading();
                                    final s = await ps.mapFolder();
                                    Get.back();
                                    Get.back();
                                    Get.rawSnackbar(message: s);
                                  }
                                }
                              }
                            },
                            child: const Text('Confirmar')),
                      ],
                    ));
                  },
                  child: const Text('Mapear pasta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loading() {
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
  }
}
