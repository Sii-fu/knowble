import 'package:flutter/material.dart';
import '../../../core/services/email_service.dart';

class EmailTestScreen extends StatefulWidget {
  const EmailTestScreen({super.key});

  @override
  State<EmailTestScreen> createState() => _EmailTestScreenState();
}

class _EmailTestScreenState extends State<EmailTestScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _result;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _testEmailSending() async {
    if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
      setState(() {
        _result = '❌ Please fill in both email and name fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      // Generate a test OTP
      final otp = EmailService.generateOTP();

      // Send the email
      final success = await EmailService.sendForgotPasswordOTP(
        recipientEmail: _emailController.text.trim(),
        recipientName: _nameController.text.trim(),
        otp: otp,
      );

      setState(() {
        _isLoading = false;
        if (success) {
          _result =
              '✅ Email sent successfully!\nOTP: $otp\nCheck your inbox at ${_emailController.text}';
        } else {
          _result =
              '❌ Failed to send email. Check the console for error details.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Service Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Gmail SMTP Service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will send a real email to the specified address using our Gmail SMTP configuration.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Recipient Email',
                hintText: 'Enter email address to test',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Recipient Name',
                hintText: 'Enter recipient name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoading ? null : _testEmailSending,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Sending Email...'),
                      ],
                    )
                  : const Text(
                      'Send Test Email',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 20),
              Card(
                color: _result!.startsWith('✅')
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Result:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _result!.startsWith('✅')
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!,
                        style: TextStyle(
                          color: _result!.startsWith('✅')
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Email Configuration',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• From: cloudezone121@gmail.com\n'
                      '• SMTP: smtp.gmail.com:587\n'
                      '• Security: TLS encryption\n'
                      '• Template: Beautiful HTML design',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
