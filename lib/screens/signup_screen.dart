import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/database_provider.dart';
import '../models/user.dart';
import '../models/theme_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';
  String _fullName = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      final existingUser = await dbProvider.getUserByUsername(_username);
      if (existingUser != null) {
        setState(() {
          _errorMessage = 'Username already exists';
          _isLoading = false;
        });
        return;
      }

      final newUser = User(
        username: _username,
        email: _email,
        password: _password,
        fullName: _fullName,
        createdAt: DateTime.now(),
      );

      await dbProvider.registerUser(newUser);

      // After successful registration, navigate back to login
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  onSaved: (value) => _username = value!.trim(),
                  validator: (value) => value == null || value.isEmpty ? 'Enter username' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _email = value!.trim(),
                  validator: (value) => value == null || value.isEmpty ? 'Enter email' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSaved: (value) => _password = value!.trim(),
                  validator: (value) => value == null || value.isEmpty ? 'Enter password' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  onSaved: (value) => _fullName = value!.trim(),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text('Sign Up'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
