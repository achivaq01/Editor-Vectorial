import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'util_item_shape.dart';
import 'app_data.dart';
import 'layout_design_painter.dart';

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
              height: MediaQuery.of(context).size.height * 0.8,
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