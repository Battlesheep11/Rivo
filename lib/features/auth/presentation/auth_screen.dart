import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'auth_provider.dart';
//import 'auth_state.dart';


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
 // final authState = ref.watch(authViewModelProvider);
final authState = AsyncValue.data(null);

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
  data: (_) => Container(),
  loading: () => const CircularProgressIndicator(),
  error: (e, st) => Text(e.toString()),
)
,
        ],
      ),
    ),
  );
}

}
