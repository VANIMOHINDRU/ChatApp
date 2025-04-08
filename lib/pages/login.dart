import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chat/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) {
      //instead of streambuilder bec we dont want constant updation of the ui,creates a stream subscription
      final session = event
          .session; //The session contains information about the authenticated user.
      if (session != null) {
        // user is authenticated.
        Navigator.of(context).pushReplacementNamed('/account');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(label: Text('Email')),
          ),
          const SizedBox(
            height: 18,
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  final email = _emailController.text.trim();
                  await supabase.auth.signInWithOtp(
                      email: email,
                      emailRedirectTo:
                          'io.supabase.flutterquickstart://login-callback/');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Mail sent successfully!')));
                  }
                } on AuthException catch (error) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error.message)));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Error occured! Please Retry')));
                }
              },
              child: const Text('Login'))
        ],
      ),
    );
  }
}
