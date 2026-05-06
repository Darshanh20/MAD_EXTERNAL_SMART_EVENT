import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/event_provider.dart';
import '../widgets/offline_banner.dart';

enum _ParticipantFilter { all, checkedIn, pending }

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key, required this.event, this.embedded = false});

  final Event event;
  final bool embedded;

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  _ParticipantFilter _filter = _ParticipantFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EventProvider>().loadParticipants(widget.event.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Widget> _buildFilterChips() {
    return [
      ChoiceChip(
        label: const Text('All'),
        selected: _filter == _ParticipantFilter.all,
        onSelected: (_) => setState(() => _filter = _ParticipantFilter.all),
      ),
      ChoiceChip(
        label: const Text('Checked In'),
        selected: _filter == _ParticipantFilter.checkedIn,
        onSelected: (_) =>
            setState(() => _filter = _ParticipantFilter.checkedIn),
      ),
      ChoiceChip(
        label: const Text('Pending'),
        selected: _filter == _ParticipantFilter.pending,
        onSelected: (_) => setState(() => _filter = _ParticipantFilter.pending),
      ),
    ];
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final queriedParticipants = provider.searchParticipantsForEvent(
          widget.event.id,
          _searchController.text,
        );
        final participants = queriedParticipants.where((participant) {
          switch (_filter) {
            case _ParticipantFilter.checkedIn:
              return participant.isCheckedIn;
            case _ParticipantFilter.pending:
              return !participant.isCheckedIn;
            case _ParticipantFilter.all:
              return true;
          }
        }).toList();

        if (participants.isEmpty) {
          return Center(
            child: Text(
              'No participants match your search.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: participants.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final participant = participants[index];
            final checkedIn = participant.isCheckedIn;
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                leading: Icon(
                  checkedIn ? Icons.verified_rounded : Icons.schedule_rounded,
                  color: checkedIn ? Colors.green : Colors.grey,
                ),
                title: Text(
                  participant.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  checkedIn
                      ? 'ID: ${participant.id}\nChecked in at ${DateFormat.jm().format(participant.checkInTime ?? DateTime.now())}'
                      : 'ID: ${participant.id}\nNot yet checked in',
                ),
                isThreeLine: true,
                trailing: Text(
                  checkedIn ? 'Checked in' : 'Pending',
                  style: TextStyle(
                    color: checkedIn ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by participant ID or name',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _buildFilterChips(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildBody(context)),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Column(
      children: [
        const OfflineBanner(),
        Expanded(
          child: Scaffold(
            appBar: AppBar(title: const Text('Logs'), centerTitle: false),
            body: content,
          ),
        ),
      ],
    );
  }
}
