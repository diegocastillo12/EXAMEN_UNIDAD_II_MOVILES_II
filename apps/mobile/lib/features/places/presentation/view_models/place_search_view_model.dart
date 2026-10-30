import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/failures/place_search_failure.dart';
import '../../domain/cancellation/place_search_cancellation.dart';
import '../../providers/places_providers.dart';
import '../state/place_search_state.dart';

final placeSearchByModeViewModelProvider = NotifierProvider.autoDispose
    .family<PlaceSearchViewModel, PlaceSearchState, bool>(
      PlaceSearchViewModel.new,
    );
final placeSearchViewModelProvider = placeSearchByModeViewModelProvider(false);

class PlaceSearchViewModel extends Notifier<PlaceSearchState> {
  PlaceSearchViewModel(this.citiesOnly);
  final bool citiesOnly;
  int _generation = 0;
  Timer? _debounce;
  String _input = '';
  PlaceSearchCancellation? _activeCancellation;
  String? _activeQuery;

  void _cancelSearch() {
    _activeCancellation?.cancel();
    _activeCancellation = null;
    _activeQuery = null;
  }

  @override
  PlaceSearchState build() {
    _generation++;
    _debounce?.cancel();
    _cancelSearch();
    _input = '';
    ref.watch(placesSessionProvider);
    ref.onDispose(() {
      _generation++;
      _debounce?.cancel();
      _cancelSearch();
    });
    return const PlaceSearchState();
  }

  void clear() {
    _generation++;
    _debounce?.cancel();
    _cancelSearch();
    _input = '';
    state = PlaceSearchState(noticeId: state.noticeId);
  }

  void queryChanged(String query) {
    final normalized = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized == _input) return;
    _input = normalized;
    _generation++;
    _debounce?.cancel();
    _cancelSearch();
    state = PlaceSearchState(noticeId: state.noticeId);
    if (normalized.runes.length < 3 || normalized.runes.length > 120) return;
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (ref.mounted) unawaited(search(normalized, automatic: true));
    });
  }

  Future<void> search(String query, {bool automatic = false}) async {
    final normalized = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (_activeQuery == normalized.toLowerCase()) return;
    _debounce?.cancel();
    _cancelSearch();
    _input = normalized;
    final cancellation = PlaceSearchCancellation();
    _activeCancellation = cancellation;
    _activeQuery = normalized.toLowerCase();
    final g = ++_generation, id = state.noticeId;
    state = PlaceSearchState(busy: true, noticeId: id);
    try {
      if (ref.read(placesSessionProvider).asData?.value == null) {
        throw const PlaceSearchFailure(PlaceSearchFailureKind.forbidden);
      }
      final places = await ref.read(searchPlacesProvider)(
        normalized,
        citiesOnly: citiesOnly,
        cancellation: cancellation,
      );
      if (!ref.mounted || g != _generation) return;
      state = PlaceSearchState(
        places: places,
        notice: places.isEmpty && !automatic
            ? 'No encontramos esa ubicación. Prueba con otra ubicación.'
            : null,
        noticeId: id + 1,
      );
    } catch (e) {
      if (!ref.mounted || g != _generation) return;
      state = PlaceSearchState(
        notice:
            e is PlaceSearchFailure && e.kind == PlaceSearchFailureKind.invalid
            ? 'Escribe entre 2 y 120 caracteres para buscar.'
            : 'No pudimos buscar la ubicación. Puedes reintentar o elegirla en el mapa.',
        noticeId: id + 1,
      );
    } finally {
      if (identical(_activeCancellation, cancellation)) {
        _activeCancellation = null;
        _activeQuery = null;
      }
      cancellation.cancel();
    }
  }
}
