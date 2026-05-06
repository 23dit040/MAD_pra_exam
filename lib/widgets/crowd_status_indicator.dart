import 'package:flutter/material.dart';

class CrowdStatusIndicator extends StatelessWidget {
  final int capacityPercentage;

  const CrowdStatusIndicator({
    Key? key,
    required this.capacityPercentage,
  }) : super(key: key);

  String getStatus() {
    if (capacityPercentage <= 50) {
      return 'SAFE';
    } else if (capacityPercentage <= 80) {
      return 'MODERATE';
    } else {
      return 'FULL';
    }
  }

  Color getStatusColor() {
    if (capacityPercentage <= 50) {
      return Colors.green;
    } else if (capacityPercentage <= 80) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getStatus();
    final color = getStatusColor();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crowd Level',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  '$capacityPercentage%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
