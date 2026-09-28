import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../domain/entities/event_entity.dart';
import '../providers/events_provider.dart';

class EventDetailScreen extends StatefulWidget {
  final EventEntity event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventEntity? _detailedEvent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventDetail();
  }

  void _loadEventDetail() async {
    final evt = await context.read<EventsProvider>().getEventDetails(widget.event.id);
    if (mounted) {
      setState(() {
        _detailedEvent = evt ?? widget.event;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsProv = context.watch<EventsProvider>();
    final activeEvent = eventsProv.events.firstWhere(
      (e) => e.id == widget.event.id,
      orElse: () => _detailedEvent ?? widget.event,
    );

    final startDate = DateTime.tryParse(activeEvent.startTime);
    final endDate = DateTime.tryParse(activeEvent.endTime);
    final dateString = startDate != null
        ? DateFormat('EEEE, MMMM d, yyyy').format(startDate)
        : activeEvent.startTime;
    final timeString = (startDate != null && endDate != null)
        ? '${DateFormat('h:mm a').format(startDate)} - ${DateFormat('h:mm a').format(endDate)}'
        : 'All Day';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                activeEvent.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
              background: activeEvent.coverImage != null
                  ? Image.network(activeEvent.coverImage!, fit: BoxFit.cover)
                  : Container(color: AppColors.primaryDark),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timing & Registration Card
                  CampusCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: AppStyles.radiusMedium,
                              ),
                              child: const Icon(Icons.calendar_month_rounded,
                                  color: AppColors.primaryLight, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dateString, style: AppStyles.h3),
                                  const SizedBox(height: 2),
                                  Text(timeString, style: AppStyles.bodySecondary),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.15),
                                borderRadius: AppStyles.radiusMedium,
                              ),
                              child: const Icon(Icons.location_on_rounded,
                                  color: AppColors.accent, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Location', style: AppStyles.caption),
                                  const SizedBox(height: 2),
                                  Text(activeEvent.location, style: AppStyles.body),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              eventsProv.toggleRegister(activeEvent.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(activeEvent.isRegistered
                                      ? 'Cancelled registration'
                                      : 'Successfully registered for ${activeEvent.title}!'),
                                  backgroundColor: activeEvent.isRegistered
                                      ? AppColors.textMuted
                                      : AppColors.success,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeEvent.isRegistered
                                  ? AppColors.surfaceElevated
                                  : AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppStyles.radiusMedium,
                              ),
                            ),
                            child: Text(
                              activeEvent.isRegistered
                                  ? 'Cancel Registration'
                                  : 'Register for Event (${activeEvent.registeredCount}/${activeEvent.capacity})',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Event Description
                  CampusCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Event Overview', style: AppStyles.h3),
                        const SizedBox(height: 8),
                        Text(activeEvent.description, style: AppStyles.body),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Participants
                  CampusCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Registered Participants', style: AppStyles.h3),
                            Text(
                              '${activeEvent.registeredCount} Students',
                              style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        else if (_detailedEvent?.participants.isEmpty ?? true)
                          const Text('Be the first to register for this campus event!',
                              style: AppStyles.bodySecondary)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _detailedEvent!.participants.length,
                            separatorBuilder: (_, __) => const Divider(color: AppColors.border),
                            itemBuilder: (context, idx) {
                              final p = _detailedEvent!.participants[idx];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.surfaceElevated,
                                  backgroundImage: p.profileImage != null
                                      ? NetworkImage(p.profileImage!)
                                      : null,
                                  child: p.profileImage == null
                                      ? Text(p.fullName[0].toUpperCase())
                                      : null,
                                ),
                                title: Text(p.fullName, style: AppStyles.body),
                                trailing: const Icon(Icons.verified_rounded,
                                    size: 18, color: AppColors.success),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
