import 'package:flutter/material.dart';

class CatalogSearchBar extends StatefulWidget {
  final void Function(String) onChanged;
  const CatalogSearchBar({Key? key, required this.onChanged}) : super(key: key);
  @override
  State<CatalogSearchBar> createState() => _CatalogSearchBarState();
}

class _CatalogSearchBarState extends State<CatalogSearchBar> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: '搜尋商品',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: widget.onChanged,
    );
  }
}
