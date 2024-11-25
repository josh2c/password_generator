import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart'; // Import for clipboard functionality

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
      ),
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: PasswordGeneratorScreen(),
    );
  }
}

class PasswordGeneratorScreen extends StatefulWidget {
  @override
  _PasswordGeneratorScreenState createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final _passwordLengthController = TextEditingController();
  String _generatedPassword = '';
  int _passwordLength = 12;

  bool _includeSpecialChars = true;
  bool _includeNumbers = true;
  bool _includeLowercase = true;
  bool _includeUppercase = true;

  bool _isPin = false; // Option for PIN vs Random password

  // Function to generate a password
  String _generatePassword() {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const specialChars = '!@#\$%^&*()_+[]{}|;:,.<>?';

    String availableChars = '';

    if (_isPin) {
      // If it's a PIN, only numbers are allowed
      return List.generate(_passwordLength,
          (index) => numbers[Random().nextInt(numbers.length)]).join();
    }

    // For random password generation, use the selected options
    if (_includeLowercase) availableChars += lowercase;
    if (_includeUppercase) availableChars += uppercase;
    if (_includeNumbers) availableChars += numbers;
    if (_includeSpecialChars) availableChars += specialChars;

    // If no characters are selected, default to lowercase letters
    if (availableChars.isEmpty) availableChars = lowercase;

    Random random = Random();
    return List.generate(_passwordLength,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();
  }

  // Function called when the user presses the "Generate" button
  void _generate() {
    setState(() {
      _generatedPassword = _generatePassword();
    });
  }

  // Function to copy the password to clipboard
  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Generator'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for the password length input
            Text(
              'Password Length: $_passwordLength',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              min: 4,
              max: 20,
              value: _passwordLength.toDouble(),
              onChanged: (value) {
                setState(() {
                  _passwordLength = value.toInt();
                });
              },
            ),
            SizedBox(height: 20),
            // Password type selection (Random or PIN)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: _isPin,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPin = value ?? false;
                    });
                  },
                ),
                Text('Random'),
                SizedBox(width: 20),
                Radio<bool>(
                  value: true,
                  groupValue: _isPin,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPin = value ?? true;
                    });
                  },
                ),
                Text('PIN'),
              ],
            ),
            SizedBox(height: 20),
            // Option to toggle the password settings
            if (!_isPin) ...[
              _buildToggleOption('Include Lowercase Letters', _includeLowercase,
                  (value) {
                setState(() {
                  _includeLowercase = value ?? true;
                });
              }),
              _buildToggleOption('Include Uppercase Letters', _includeUppercase,
                  (value) {
                setState(() {
                  _includeUppercase = value ?? true;
                });
              }),
              _buildToggleOption('Include Numbers', _includeNumbers, (value) {
                setState(() {
                  _includeNumbers = value ?? true;
                });
              }),
              _buildToggleOption(
                  'Include Special Characters', _includeSpecialChars, (value) {
                setState(() {
                  _includeSpecialChars = value ?? true;
                });
              }),
            ],
            SizedBox(height: 20),
            // Display the title for the generated password
            if (_generatedPassword.isNotEmpty) ...[
              Text(
                'Generated Password:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SelectableText(
                _generatedPassword,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
            SizedBox(height: 20),
            // Buttons for Generate and Copy to Clipboard placed under the generated password
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _generate,
                  icon: Icon(Icons.refresh),
                  label: Text('Generate'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: 20), // Space between the buttons
                ElevatedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: Icon(Icons.copy),
                  label: Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to build each toggle option (checkbox style)
  Widget _buildToggleOption(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
