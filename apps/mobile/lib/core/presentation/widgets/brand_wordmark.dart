import 'package:flutter/material.dart';

import 'brand_mark.dart';
import 'brand_name.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({this.iconSize = 52, this.textSize = 22, super.key});

  final double iconSize;
  final double textSize;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Entre Huellas',
    child: ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(size: iconSize),
            SizedBox(width: iconSize >= 76 ? 16 : 7),
            BrandName(textSize: textSize),
          ],
        ),
      ),
    ),
  );
}
