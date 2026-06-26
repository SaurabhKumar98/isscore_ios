import 'package:firstedu/data/models/api_models/merchandise_models/merchandisefetchclaimedmodels.dart';
import 'package:flutter/material.dart';

class ClaimCard extends StatelessWidget {
  final ClaimItem claim;

  const ClaimCard({super.key, required this.claim});

  Color getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;

      case "processing":
        return Colors.blue;

      case "shipped":
        return Colors.purple;

      case "delivered":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   claim.merchandiseName,
            //   style: const TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 16,
            //   ),
            // ),
            const SizedBox(height: 8),

            // Row(
            //   children: [
            //     const Icon(Icons.workspace_premium, size: 18),
            //     Text("${claim.pointsUsed} points"),
            //   ],
            // ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

              decoration: BoxDecoration(
                color: getStatusColor(claim.status).withOpacity(.15),

                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                claim.status.toUpperCase(),
                style: TextStyle(
                  color: getStatusColor(claim.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
