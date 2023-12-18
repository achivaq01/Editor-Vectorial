import 'package:flutter/cupertino.dart';

class LayoutSidebarShapes extends StatelessWidget {
  const LayoutSidebarShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Estira el widget horitzontalment
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: const Column(
          children: [
            Text('List of shapes'),
          ],
        ),
      ),
    );
  }
}
