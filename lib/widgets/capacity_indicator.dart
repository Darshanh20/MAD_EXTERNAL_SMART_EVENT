import 'package:flutter/material.dart';

class CapacityIndicator extends StatelessWidget {
  const CapacityIndicator({
    super.key,
    required this.checkedInCount,
    required this.maxCapacity,
  });

  final int checkedInCount;
  final int maxCapacity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = maxCapacity <= 0
        ? 0.0
        : (checkedInCount / maxCapacity).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capacity Progress',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: progress,
                backgroundColor: scheme.surfaceContainerHighest,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$checkedInCount of $maxCapacity checked in',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
