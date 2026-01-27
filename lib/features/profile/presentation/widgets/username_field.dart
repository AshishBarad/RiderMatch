import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../profile_providers.dart';

class UsernameField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String? initialUsername;

  const UsernameField({
    super.key,
    required this.controller,
    this.initialUsername,
  });

  @override
  ConsumerState<UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends ConsumerState<UsernameField> {
  Timer? _debounce;
  bool _isChecking = false;
  bool? _isAvailable;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onUsernameChanged);
    super.dispose();
  }

  void _onUsernameChanged() {
    final username = widget.controller.text;

    // Cancel previous timer
    _debounce?.cancel();

    // Reset state
    setState(() {
      _isChecking = false;
      _isAvailable = null;
      _errorMessage = null;
    });

    if (username.isEmpty) {
      return;
    }

    // Validate format first
    final formatError = _validateFormat(username);
    if (formatError != null) {
      setState(() {
        _errorMessage = formatError;
        _isAvailable = false;
      });
      return;
    }

    // If it's the same as initial username, it's available (user's own username)
    if (widget.initialUsername != null &&
        username.toLowerCase() == widget.initialUsername!.toLowerCase()) {
      setState(() {
        _isAvailable = true;
      });
      return;
    }

    // Debounce the availability check
    setState(() {
      _isChecking = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkAvailability(username);
    });
  }

  String? _validateFormat(String username) {
    if (username.length > 15) {
      return 'Max 15 characters';
    }

    final regex = RegExp(r'^[a-z0-9_]+$');
    if (!regex.hasMatch(username)) {
      return 'Only lowercase letters, numbers, and underscore';
    }

    if (username.startsWith(RegExp(r'[0-9_]'))) {
      return 'Cannot start with number or underscore';
    }

    const reserved = [
      'admin',
      'administrator',
      'system',
      'support',
      'help',
      'root',
      'moderator',
      'mod',
      'official',
    ];

    if (reserved.contains(username.toLowerCase())) {
      return 'This username is reserved';
    }

    return null;
  }

  Future<void> _checkAvailability(String username) async {
    try {
      final checkUseCase = ref.read(checkUsernameUseCaseProvider);
      final isAvailable = await checkUseCase(username);

      if (mounted) {
        setState(() {
          _isChecking = false;
          _isAvailable = isAvailable;
          if (!isAvailable) {
            _errorMessage = 'Username already taken';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _isAvailable = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'your_username',
        border: const OutlineInputBorder(),
        helperText: 'Lowercase letters, numbers, and underscore (max 15)',
        helperMaxLines: 2,
        errorText: _errorMessage,
        suffixIcon: _buildSuffixIcon(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Username is required';
        }
        if (_errorMessage != null) {
          return _errorMessage;
        }
        if (_isAvailable == false) {
          return 'Username not available';
        }
        return null;
      },
      onChanged: (value) {
        // Convert to lowercase automatically
        final lowercase = value.toLowerCase();
        if (value != lowercase) {
          widget.controller.value = widget.controller.value.copyWith(
            text: lowercase,
            selection: TextSelection.collapsed(offset: lowercase.length),
          );
        }
      },
    );
  }

  Widget? _buildSuffixIcon() {
    if (_isChecking) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_isAvailable == true) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    if (_isAvailable == false && _errorMessage != null) {
      return const Icon(Icons.cancel, color: Colors.red);
    }

    return null;
  }
}
