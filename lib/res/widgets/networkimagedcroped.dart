import 'package:flutter/material.dart';

class NetworkImageAutoSize extends StatelessWidget {
  final String url;

  const NetworkImageAutoSize({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.contain, // ✅ never crop
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (_, __, ___) => const SizedBox(
        height: 200,
        child: Center(child: Icon(Icons.broken_image)),
      ),
    );
  }
}