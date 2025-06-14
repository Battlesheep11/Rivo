import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isLogin) {
                  ref.read(authViewModelProvider.notifier).signIn(
                      _emailController.text, _passwordController.text);
                } else {
                  ref.read(authViewModelProvider.notifier).signUp(
                      _emailController.text, _passwordController.text);
                }
              },
              child: Text(_isLogin ? 'Login' : 'Sign Up'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin
                  ? 'Don\'t have an account? Sign Up'
                  : 'Already have an account? Login'),
            ),
            const SizedBox(height: 20),
            authState.when(
              initial: () => const Text("Please sign in"), // <--- במקום container ריק
              loading: () => const CircularProgressIndicator(),
              authenticated: () => const Text("Authenticated successfully!"),
              error: (message) => Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
