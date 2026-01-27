import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../../data/datasources/places_remote_data_source.dart';
import '../ride_providers.dart';

class PlacesAutocompleteField extends ConsumerStatefulWidget {
  final String label;
  final Function(String address, double lat, double lng) onSelected;
  final TextEditingController controller;
  final IconData? prefixIcon;

  const PlacesAutocompleteField({
    super.key,
    required this.label,
    required this.onSelected,
    required this.controller,
    this.prefixIcon,
  });

  @override
  ConsumerState<PlacesAutocompleteField> createState() =>
      _PlacesAutocompleteFieldState();
}

class _PlacesAutocompleteFieldState
    extends ConsumerState<PlacesAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  final _uuid = const Uuid();
  String _sessionToken = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _sessionToken = _uuid.v4();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      if (input.isEmpty) {
        _removeOverlay();
        return;
      }

      final predictions = await ref
          .read(placesRepositoryProvider)
          .getAutocomplete(input, _sessionToken);

      if (mounted) {
        _showOverlay(predictions);
      }
    });
  }

  void _showOverlay(List<PlacePrediction> predictions) {
    _removeOverlay();
    if (predictions.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final prediction = predictions[index];
                return ListTile(
                  title: Text(prediction.description),
                  onTap: () async {
                    _removeOverlay();
                    widget.controller.text = prediction.description;

                    // Fetch details
                    final details = await ref
                        .read(placesRepositoryProvider)
                        .getPlaceDetails(prediction.placeId, _sessionToken);

                    if (details != null) {
                      widget.onSelected(
                        details.address,
                        details.lat,
                        details.lng,
                      );
                    }

                    _sessionToken = _uuid.v4(); // Reset session
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, size: 16)
              : null,
        ),
        validator: (v) => v?.isEmpty == true ? 'Required' : null,
      ),
    );
  }
}
