import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../data/services/firebase_config.dart';
import '../../../data/services/service_providers.dart';
import '../providers/admin_providers.dart';

class AdminGateScreen extends ConsumerStatefulWidget {
  const AdminGateScreen({super.key});

  @override
  ConsumerState<AdminGateScreen> createState() => _AdminGateScreenState();
}

class _AdminGateScreenState extends ConsumerState<AdminGateScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  var _mode = _AuthMode.signIn;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = ref.read(adminAuthServiceProvider);
      switch (_mode) {
        case _AuthMode.signIn:
          await auth.signInWithEmail(
            email: _email.text,
            password: _password.text,
          );
        case _AuthMode.bootstrap:
          await auth.bootstrapOwner(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          );
        case _AuthMode.registerInvite:
          await auth.registerFromInvite(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          );
      }
      if (mounted) context.go('/admin/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyAuthError(e));
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'Please enter a valid email address.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'Incorrect email or password.',
      'email-already-in-use' =>
        'That email is already registered. Use Sign in instead.',
      'weak-password' => 'Password should be at least 6 characters.',
      'too-many-requests' => 'Too many attempts. Wait a moment and try again.',
      'network-request-failed' =>
        'Network error. Check your internet connection.',
      _ => e.message ?? e.code,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final sessionAsync = ref.watch(adminAuthStateProvider);

    if (!FirebaseConfig.isConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Firebase not configured yet',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.brandPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Phase 2 admin CMS needs a Firebase project.\n\n'
                '1. Create a project at console.firebase.google.com\n'
                '2. Enable Email/Password Auth, Firestore, Storage\n'
                '3. From the project folder run:\n'
                '   firebase login\n'
                '   flutterfire configure\n'
                '4. Set FirebaseConfig.isConfigured = true in\n'
                '   lib/data/services/firebase_config.dart\n'
                '5. Update main.dart to use DefaultFirebaseOptions\n\n'
                'See FIREBASE_SETUP.md for full steps.',
              ),
            ],
          ),
        ),
      );
    }

    return sessionAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (session) {
        if (session != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/admin/home');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.go('/home'),
            ),
            title: Text(
              'Admin',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: colors.brandPrimary,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                switch (_mode) {
                  _AuthMode.signIn => 'Sign in',
                  _AuthMode.bootstrap => 'Create first owner',
                  _AuthMode.registerInvite => 'Accept invite',
                },
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.brandPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Admin tools stay off the main user navigation.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (_mode != _AuthMode.signIn) ...[
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: colors.brandPrimary)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        switch (_mode) {
                          _AuthMode.signIn => 'Sign in',
                          _AuthMode.bootstrap => 'Create owner',
                          _AuthMode.registerInvite => 'Register',
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _mode = _AuthMode.signIn),
                    child: const Text('Sign in'),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _mode = _AuthMode.bootstrap),
                    child: const Text('First owner'),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _mode = _AuthMode.registerInvite),
                    child: const Text('Accept invite'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _AuthMode { signIn, bootstrap, registerInvite }
