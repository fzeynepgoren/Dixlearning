import 'package:flutter/material.dart';
import '../../SIRALAMA_SORULARI/Asama3/soru1.dart';

class SortingActivitiesScreen extends StatelessWidget {
  const SortingActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stages = [
      '1. Aşama',
      '2. Aşama',
      '3. Aşama',
      '4. Aşama',
      '5. Aşama',
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sıralama Etkinlikleri'),
      ),
      body: ListView.builder(
        itemCount: stages.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ListTile(
              title: Text(
                stages[index],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Asama3Soru1(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yakında eklenecek!')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
