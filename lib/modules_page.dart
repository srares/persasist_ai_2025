import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_ai_assistant/hive_adapters/module.dart';
import 'package:personal_ai_assistant/widgets/common_widgets.dart';

class ModulesPage extends StatefulWidget {
  @override
  _ModulesPageState createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
  List<Module> modules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadModules();
  }

  Future<void> loadModules() async {
    try {
      // Make sure the box is open
      if (!Hive.isBoxOpen('modules')) {
        await Hive.openBox<Module>('modules');
      }

      var modulesBox = Hive.box<Module>('modules');
      debugPrint("Number of modules in box: ${modulesBox.length}");

      setState(() {
        modules = modulesBox.values.toList();
        isLoading = false;
      });

      // Print module titles for debugging
      for (var module in modules) {
        debugPrint("Module title: ${module.title}");
      }
    } catch (e) {
      debugPrint("Error loading modules: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Module de Studiu"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : modules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Nu există module disponibile.",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          loadModules();
                        },
                        child: const Text("Reîncarcă"),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Text(
                          modules[index].title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(modules[index].information),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
