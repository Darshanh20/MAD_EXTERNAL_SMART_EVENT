import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import 'checkin_screen.dart';

class EventSetupScreen extends StatefulWidget {
  const EventSetupScreen({super.key});

  @override
  State<EventSetupScreen> createState() => _EventSetupScreenState();
}

class _EventSetupScreenState extends State<EventSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _capacityController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  String? _dateTimeError;

  @override
  void dispose() {
    _eventNameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime.isBefore(now) ? now : _selectedDateTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time == null || !mounted) {
      return;
    }

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _selectedDateTime = selected;
      _dateTimeError = selected.isBefore(DateTime.now())
          ? 'Date and time cannot be in the past'
          : null;
    });
  }

  Future<void> _submit() async {
    final authProvider = context.read<AuthProvider>();
    final manager = authProvider.currentUser;
    if (manager == null) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    final pastError = _selectedDateTime.isBefore(DateTime.now())
        ? 'Date and time cannot be in the past'
        : null;

    setState(() {
      _dateTimeError = pastError;
    });

    if (!isValid || pastError != null) {
      return;
    }

    final event = Event(
      id: const Uuid().v4(),
      managerId: manager.id,
      name: _eventNameController.text.trim(),
      dateTime: _selectedDateTime,
      maxCapacity: int.parse(_capacityController.text.trim()),
      checkedInCount: 0,
    );

    await context.read<EventProvider>().createEvent(
      event,
      managerId: manager.id,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Event created successfully')));

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CheckinScreen(event: event)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formattedDate = DateFormat.yMMMMEEEEd().add_jm().format(
      _selectedDateTime,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('EVENTLY'), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your event',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set up your venue and start collecting check-ins.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _eventNameController,
                      decoration: const InputDecoration(
                        labelText: 'Event Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Event name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _capacityController,
                      decoration: const InputDecoration(
                        labelText: 'Max Capacity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null) {
                          return 'Capacity is required';
                        }
                        if (parsed < 1) {
                          return 'Capacity must be at least 1';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _pickDateTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Event Date & Time',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formattedDate,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _pickDateTime,
                              icon: const Icon(Icons.edit_calendar_outlined),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_dateTimeError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _dateTimeError!,
                        style: TextStyle(color: scheme.error, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.event_available_outlined),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Create Event'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
