import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;

  void _enter(String email, {String? name}) {
    context.read<AppState>().login(email, name: name);
    Navigator.of(context).pushAndRemoveUntil(slideRoute(const ShellScreen()), (r) => false);
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _key,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.shopping_bag_rounded, color: AppColors.citron),
                  ),
                  const SizedBox(height: 24),
                  Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('Log in to pick up where you left off.', style: TextStyle(color: AppColors.slate)),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email address' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pass,
                    obscureText: _hide,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_hide ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => push(context, const ForgotPasswordScreen()), child: const Text('Forgot password?')),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      if (_key.currentState!.validate()) _enter(_email.text.trim());
                    },
                    child: const Text('Log in'),
                  ),
                  const SizedBox(height: 18),
                  Row(children: const [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(color: AppColors.slate))),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => _enter('guest@gmail.com', name: 'Guest'),
                    icon: Container(
                      width: 22, height: 22, alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFDDDDDD))),
                      child: const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                      const Text('New to Verra?', style: TextStyle(color: AppColors.slate)),
                      TextButton(onPressed: () => push(context, const RegisterScreen()), child: const Text('Create an account')),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _key,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Create your account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('It takes less than a minute.', style: TextStyle(color: AppColors.slate)),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email address' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pass,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded)),
                    validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm password', prefixIcon: Icon(Icons.lock_outline_rounded)),
                    validator: (v) => v != _pass.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      if (!_key.currentState!.validate()) return;
                      context.read<AppState>().login(_email.text.trim(), name: _name.text.trim());
                      Navigator.of(context).pushAndRemoveUntil(slideRoute(const ShellScreen()), (r) => false);
                    },
                    child: const Text('Create account'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.mark_email_read_rounded, size: 64, color: AppColors.success),
                  const SizedBox(height: 16),
                  Text('Check your inbox', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('We sent a reset link to ${_email.text.trim()}.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.slate)),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Back to log in')),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Reset your password', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('Enter your email and we will send you a reset link.', style: TextStyle(color: AppColors.slate)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      if (_email.text.contains('@')) {
                        setState(() => _sent = true);
                      } else {
                        snack(context, 'Enter a valid email address');
                      }
                    },
                    child: const Text('Send reset link'),
                  ),
                ]),
        ),
      ),
    );
  }
}
