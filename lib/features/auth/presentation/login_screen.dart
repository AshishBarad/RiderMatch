import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final phone = _phoneController.text.trim();

    // Validate length
    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate first digit (must be 6, 7, 8, or 9 for Indian mobile numbers)
    if (!['6', '7', '8', '9'].contains(phone[0])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number must start with 6, 7, 8, or 9'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('🔄 Initiating login for $phone');
    await ref.read(authControllerProvider.notifier).login(phone);

    if (mounted) {
      final state = ref.read(authControllerProvider);
      if (!state.hasError) {
        debugPrint('✅ Login initiated successfully, navigating to OTP');
        context.push('/otp');
      } else {
        debugPrint('❌ Login failed in controller: ${state.error}');
        // Optional: show snackbar here if not shown by state listener
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to RiderMatch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
                prefixText: '+91 ',
                hintText: '9876543210',
                counterText: '',
                helperText: 'Enter 10-digit mobile number',
              ),
            ),
            const SizedBox(height: 16),
            if (state.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _onLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Send OTP'),
              ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
