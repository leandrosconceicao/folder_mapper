import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Center(child: ListTile(
                  title: const Text('Dados do computador'),
                  subtitle: Obx(() => Column(
                    children: [
                      SelectionArea(
                        child: Row(
                          children: [
                            Flexible(child: Text('Nome da sua máquina: ${hostInfo.value}\nIP: ${ipInfo.value}')),
                          ],
                        ),
                      ),
                      SizedBox(height: Get.height * 0.2,),
                      TextFormField(
                        validator: (String? value) => value?.isEmpty ?? true ? 'Preencha esse campo' : null,
                        controller: shareName,
                        decoration: const InputDecoration(
                          labelText: 'Nome do compartilhamento'
                        ),
                      )
                    ],
                  ))
                )),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        loading();
                        final p = await ps.run();
                        Get.back();
                        Get.dialog(AlertDialog(content: Text(p),));
                      }
                    }, child: const Text('Compartilhar pasta')),
                    SizedBox(height: Get.height * 0.02,),
                    ElevatedButton(
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
                                          onChanged: (bool? value) => isRemote.value = value,
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile(
                                          title: const Text('Local'),
                                          groupValue: isRemote.value,
                                          value: false,
                                          onChanged: (bool? value) => isRemote.value = value,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: isRemote.value ?? false,
                                    child: TextFormField(
                                      controller: remoteHostname,
                                      validator: isRemote.value ?? false ? (String? value) => value?.isEmpty ?? true ? 'Obrigatório' : null : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Nome do computador remoto'
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(onPressed: () async {
                              if (remoteForm.currentState!.validate()) {
                                if (isRemote.value ?? false) {
                                  loading();
                                  final s = await ps.mapFolder(remoteHostname.text);
                                } else {
                                  final path = await ps.selectFold();
                                  if (path != null) {
                                    loading();
                                    final s = await ps.mapFolder(path);
                                    Get.back();
                                    Get.dialog(AlertDialog(content: Text(s.toString()),));
                                  }
                                }
                              }
                            }, child: const Text('Confirmar')),
                          ],
                        ));
                      },
                      child: const Text('Mapear pasta'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loading() {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
  }
}