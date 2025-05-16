import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'model/route_response.dart';

class InstructionsScreen extends StatefulWidget {
  final List<RouteInstruction> instructions;

  const InstructionsScreen({super.key, required this.instructions});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  Future<String> translateInstruction(String instruction) async {
    final translator = GoogleTranslator();
    String translatedMessage = "";

    final translation =
        await translator.translate(instruction, from: 'en', to: 'ar');
    translatedMessage = translation.text;
    return translatedMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Instructions'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: widget.instructions.length,
          itemBuilder: (context, index) {
            final step = widget.instructions[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: FutureBuilder<String>(
                    future: translateInstruction(step.instruction),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data!);
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 135),
                        child: SizedBox(
                          height: 30,
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step.name.isNotEmpty) Text('Street: ${step.name}'),
                    Text('المسافة: ${step.distance.toStringAsFixed(1)}  متر'),
                    Text(
                        'المدة: ${(step.duration / 60).toStringAsFixed(1)}  دقيقة'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
