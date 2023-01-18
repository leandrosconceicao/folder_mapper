import 'package:flutter/material.dart';
import 'package:folder_mapper/controllers.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final formKey = GlobalKey<FormState>();

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
                            Text('Hostname: ${hostInfo.value}'),
                            SizedBox(width: Get.height * 0.02,),
                            Text('IP: ${ipInfo.value}')
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
                        final path = await ps.selectFold();
                        if (path != null) {
                          final s = await ps.mapFolder(path);
                          loading();
                          Get.back();
                          Get.dialog(AlertDialog(content: Text(s.toString()),));
                        }
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