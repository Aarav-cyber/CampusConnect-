import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../domain/entities/event_entity.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<String> _categories = ['All', 'Technology', 'Hackathons', 'Workshops', 'Competitions'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().fetchEvents();
    });
  }

  void _showCreateEventDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locController = TextEditingController(text: 'University Auditorium');
    final capController = TextEditingController(text: '150');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusLarge),
        title: const Text('Host Campus Event', style: AppStyles.h3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: AppStyles.radiusMedium),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: AppStyles.radiusMedium),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Location / Venue',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: AppStyles.radiusMedium),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Capacity',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: AppStyles.radiusMedium),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              if (title.isNotEmpty && desc.isNotEmpty) {
                await context.read<EventsProvider>().createEvent(
                      title: title,
                      description: desc,
                      location: locController.text.trim(),
                      startTime: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
                      endTime: DateTime.now().add(const Duration(days: 7, hours: 4)).toIso8601String(),
                      capacity: int.tryParse(capController.text) ?? 100,
                      category: 'Technology',
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Publish Event', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsProv = context.watch<EventsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Campus Events', style: AppStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppColors.primaryLight),
            onPressed: _showCreateEventDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All, Registered, My Events)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildTabButton('All Events', 'all', eventsProv),
                const SizedBox(width: 8),
                _buildTabButton('Registered', 'registered', eventsProv),
                const SizedBox(width: 8),
                _buildTabButton('My Events', 'my', eventsProv),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Category Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = eventsProv.selectedCategory == cat;

                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.radiusPill,
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                  ),
                  onSelected: (_) => eventsProv.updateCategory(cat),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Events list
          Expanded(
            child: eventsProv.isLoading
                ? const LoadingView(message: 'Fetching campus events...')
                : eventsProv.events.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.event_busy_rounded,
                        title: 'No Events Found',
                        description: 'Check back soon or create your own event for the university!',
                      )
                    : RefreshIndicator(
                        onRefresh: () => eventsProv.fetchEvents(),
                        color: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: eventsProv.events.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final event = eventsProv.events[index];
                            final startDate = DateTime.tryParse(event.startTime);
                            final formattedDate = startDate != null
                                ? DateFormat('EEE, MMM d · h:mm a').format(startDate)
                                : event.startTime;

                            return CampusCard(
                              padding: EdgeInsets.zero,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(event: event),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Cover image with category badge
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(14)),
                                        child: event.coverImage != null
                                            ? Image.network(
                                                event.coverImage!,
                                                height: 140,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                height: 140,
                                                color: AppColors.primaryDark,
                                                child: const Center(
                                                    child: Icon(Icons.event, size: 48)),
                                              ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface.withOpacity(0.9),
                                            borderRadius: AppStyles.radiusPill,
                                          ),
                                          child: Text(
                                            event.category,
                                            style: const TextStyle(
                                                color: AppColors.accent,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            color: AppColors.primaryLight,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(event.title, style: AppStyles.h3),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined,
                                                size: 15, color: AppColors.textMuted),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                event.location,
                                                style: AppStyles.caption,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.how_to_reg_outlined,
                                                    size: 16, color: AppColors.accent),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${event.registeredCount} / ${event.capacity} registered',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                eventsProv.toggleRegister(event.id);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: event.isRegistered
                                                    ? AppColors.surfaceElevated
                                                    : AppColors.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: AppStyles.radiusPill,
                                                ),
                                                elevation: 0,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 18, vertical: 8),
                                              ),
                                              child: Text(
                                                event.isRegistered ? 'Registered' : 'Register',
                                                style: const TextStyle(
                                                    fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String filterKey, EventsProvider prov) {
    final isSelected = prov.selectedFilter == filterKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => prov.updateFilter(filterKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
            borderRadius: AppStyles.radiusMedium,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
