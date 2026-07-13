import 'package:flutter/material.dart';

class MarketHeader extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final String searchHint;

  const MarketHeader({
    super.key,
    required this.onSearchChanged,
    this.searchHint = 'Buscar producto',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff2D006B),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.notifications_none,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }
}
