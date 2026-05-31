import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/models/location_model.dart';
import '../providers/weather_provider.dart';
import '../providers/saved_cities_provider.dart';
import '../widgets/dynamic_background.dart';

/// City search screen with live autocomplete results.
///
/// ### Features:
/// - Debounced search (300ms delay) to avoid excessive API calls
/// - Glass-styled result tiles with city name, state, and country
/// - Tap to select → returns the city data to the home screen
/// - Option to save cities to favourites
///
/// ### Interview talking point:
/// The debounce pattern is important for search UIs. Without it, every
/// keystroke triggers an API call. With a 300ms debounce, we only fire
/// the request once the user pauses typing, saving bandwidth and reducing
/// rate-limit risk.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _currentQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Debounces the search to avoid rapid API calls.
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _currentQuery = query.trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: DefaultBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Search Bar ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    // Search input
                    Expanded(
                      child: GlassContainer(
                        borderRadius: 16,
                        padding: EdgeInsets.zero,
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: _onSearchChanged,
                          style: textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Search for a city...',
                            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _currentQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Results ──
              Expanded(
                child: _currentQuery.length < 2
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_city_rounded,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Search for a city name',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : _SearchResults(
                        query: _currentQuery,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays search results using the [citySearchProvider].
class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(citySearchProvider(query));
    final textTheme = Theme.of(context).textTheme;

    return searchResults.when(
      data: (locations) {
        if (locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded, size: 64, color: Colors.white30),
                const SizedBox(height: 16),
                Text('No cities found for "$query"', style: textTheme.bodyMedium),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            return _CityTile(location: locations[index]);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (error, _) => Center(
        child: Text(
          'Search failed. Please try again.',
          style: textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// A single city result tile with glass styling.
class _CityTile extends ConsumerWidget {
  final LocationModel location;

  const _CityTile({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isSaved = ref.watch(savedCitiesProvider.notifier).isCitySaved(location.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        opacity: 0.08,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Return the selected city to the home screen
            Navigator.pop(context, {
              'latitude': location.latitude,
              'longitude': location.longitude,
              'name': location.name,
            });
          },
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70),
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
              // Save/unsave button
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isSaved ? Colors.amber : Colors.white54,
                ),
                onPressed: () {
                  if (isSaved) {
                    ref.read(savedCitiesProvider.notifier).removeCity(location.id);
                  } else {
                    ref.read(savedCitiesProvider.notifier).addCity(location);
                  }
                },
                tooltip: isSaved ? 'Remove from saved' : 'Save city',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
