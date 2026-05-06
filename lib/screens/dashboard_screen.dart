import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/event_provider.dart';
import '../widgets/capacity_indicator.dart';
import '../widgets/offline_banner.dart';
import '../widgets/stat_card.dart';
import 'logs_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.event,
    this.embedded = false,
    this.onOpenLogs,
  });

  final Event event;
  final bool embedded;
  final VoidCallback? onOpenLogs;

  void _openLogs(BuildContext context) {
    if (onOpenLogs != null) {
      onOpenLogs!();
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LogsScreen(event: event)));
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final activeEvent =
            provider.getEventById(event.id) ??
            (provider.activeEvent?.id == event.id
                ? provider.activeEvent!
                : event);
        final capacity = activeEvent.maxCapacity;
        final checkedIn = activeEvent.checkedInCount;
        final remaining = (capacity - checkedIn).clamp(0, capacity);
        final ratio = capacity <= 0
            ? 0.0
            : (checkedIn / capacity).clamp(0.0, 1.0);
        final crowdColor = ratio < 0.6
            ? Colors.green
            : ratio < 0.9
            ? Colors.orange
            : Colors.red;
        final crowdLabel = ratio < 0.6
            ? 'Safe'
            : ratio < 0.9
            ? 'Moderate'
            : 'Full';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeEvent.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMMEEEEd().add_jm().format(
                        activeEvent.dateTime,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    CapacityIndicator(
                      checkedInCount: checkedIn,
                      maxCapacity: capacity,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 160,
                          child: StatCard(
                            label: 'Total Capacity',
                            value: '$capacity',
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: StatCard(
                            label: 'Checked In',
                            value: '$checkedIn',
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: StatCard(
                            label: 'Remaining',
                            value: '$remaining',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: ratio,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: crowdColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: crowdColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'Crowd Level: $crowdLabel',
                          style: TextStyle(
                            color: crowdColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openLogs(context),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Go to Logs'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);

    if (embedded) {
      return body;
    }

    return Column(
      children: [
        const OfflineBanner(),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              actions: [
                Consumer<EventProvider>(
                  builder: (context, provider, _) {
                    final activeEvent = provider.activeEvent ?? event;
                    return IconButton(
                      onPressed: () {
                        provider.loadParticipants(activeEvent.id);
                      },
                      icon: const Icon(Icons.refresh),
                    );
                  },
                ),
              ],
            ),
            body: body,
          ),
        ),
      ],
    );
  }
}
