import 'package:flutter/material.dart';

class PhotoAddTile extends StatelessWidget {
  const PhotoAddTile({
    required this.size,
    required this.onTap,
    required this.semanticLabel,
    this.invalid = false,
    super.key,
  });
  final double size;
  final VoidCallback? onTap;
  final String semanticLabel;
  final bool invalid;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFF5F5F7),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(
        color: invalid ? const Color(0xFFB53F48) : const Color(0xFFE5E5EA),
        width: invalid ? 3.5 : 1,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Semantics(
          label: semanticLabel,
          button: true,
          child: Center(
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: invalid
                  ? const Color(0xFFB53F48)
                  : const Color(0xFF6E6E73),
            ),
          ),
        ),
      ),
    ),
  );
}
