import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'events_list_screen.dart';
import 'role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _errorMessage = null);

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email and password are required');
      return;
    }

    final success = await context.read<AuthProvider>().login(
      email: email,
      password: password,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (context) => const EventsListScreen()),
        (route) => false,
      );
    } else if (mounted) {
      setState(() => _errorMessage = 'Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Login to your EVENTLY account',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (context) => const RoleSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
