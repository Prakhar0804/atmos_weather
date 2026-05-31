import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/models/location_model.dart';
import '../providers/saved_cities_provider.dart';
import '../widgets/dynamic_background.dart';

/// Screen to manage saved/favourite cities.
///
/// Displays a list of saved cities that the user can:
/// - Tap to view weather for that city
/// - Swipe to delete from saved list
///
/// If no cities are saved, shows a helpful empty state.
class SavedCitiesScreen extends ConsumerWidget {
  const SavedCitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCities = ref.watch(savedCitiesProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: DefaultBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text('Saved Cities', style: textTheme.displaySmall),
                  ],
                ),
              ),

              // ── City List ──
              Expanded(
                child: savedCities.isEmpty
                    ? _EmptyState(textTheme: textTheme)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: savedCities.length,
                        itemBuilder: (context, index) {
                          return _SavedCityTile(
                            location: savedCities[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state when no cities are saved.
class _EmptyState extends StatelessWidget {
  final TextTheme textTheme;

  const _EmptyState({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved cities',
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Search for a city and tap the bookmark\nicon to save it here.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// A saved city tile with swipe-to-delete.
class _SavedCityTile extends ConsumerWidget {
  final LocationModel location;

  const _SavedCityTile({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(location.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        onDismissed: (_) {
          ref.read(savedCitiesProvider.notifier).removeCity(location.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${location.name} removed'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          );
        },
        child: GlassContainer(
          opacity: 0.08,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.pop(context, {
                'latitude': location.latitude,
                'longitude': location.longitude,
                'name': location.name,
              });
            },
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location.name, style: textTheme.labelLarge),
                      const SizedBox(height: 2),
                      Text(
                        location.displayName,
                        style: textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
