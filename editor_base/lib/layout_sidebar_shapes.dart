import 'package:editor_base/util_shape_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class LayoutSidebarShapes extends StatelessWidget {
  const LayoutSidebarShapes({super.key});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return SizedBox(
      width: double.infinity, // Estira el widget horitzontalment
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            const Text('List of shapes'),
            SizedBox(
              height: 800,
              child: ListView.builder(
                itemExtent: 110,
                itemCount: appData.shapesList.length,
                itemBuilder: (context, index) {
                  return ItemShape(
                      shapeIndex: index
                  );
                },
              ),

            ),
          ],
        ),
      ),
    );
  }
}
