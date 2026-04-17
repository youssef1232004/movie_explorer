import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:movie_explorer/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      final data = _formKey.currentState!.value;
      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.register(data['email'], data['password']);

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final success = await context.read<AuthProvider>().signInWithGoogle();
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final Color accentColor = isDark ? const Color(0xFFE50914) : Colors.deepOrange;
    final Color fieldFill = isDark ? Colors.grey.shade800 : Colors.grey.shade50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.person_add_rounded, size: 80, color: accentColor),
                const SizedBox(height: 16),
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join us to track and search your favorite movies',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FormBuilderTextField(
                  name: 'email',
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.email, color: accentColor),
                    filled: true,
                    fillColor: fieldFill,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'password',
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock, color: accentColor),
                    filled: true,
                    fillColor: fieldFill,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(6, errorText: 'Password must be at least 6 characters'),
                  ]),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _submit,
                              child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('OR', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: _signInWithGoogle,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                 
                                  const Flexible(
                                    child: Text(
                                      'Sign Up with Google',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              "Already have an account? Login",
                              style: TextStyle(color: accentColor),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}