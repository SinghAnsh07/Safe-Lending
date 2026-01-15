import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../services/storage_service.dart';
import '../crypto/rsa_service.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  String _diagnosticResult = 'Tap "Run Diagnostics" to check system status';
  bool _isRunning = false;

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _diagnosticResult = 'Running diagnostics...\n\n';
    });

    final buffer = StringBuffer();
    buffer.writeln('=== Safe Lending Diagnostics ===\n');

    // Check authentication
    final authService = context.read<AuthService>();
    buffer.writeln('1. Authentication Status:');
    buffer.writeln('   - Authenticated: ${authService.isAuthenticated}');
    buffer.writeln('   - User ID: ${authService.currentUser?.uid ?? "N/A"}');
    buffer.writeln('   - Email: ${authService.currentUser?.email ?? "N/A"}');
    buffer.writeln(
        '   - User Model Loaded: ${authService.currentUserModel != null}');
    buffer.writeln();

    // Check storage
    buffer.writeln('2. Secure Storage Status:');
    final privateKey = await StorageService.getPrivateKey();
    final publicKey = await StorageService.getPublicKey();
    final userId = await StorageService.getUserId();
    final hasKeys = await StorageService.hasKeys();

    buffer.writeln('   - Has Keys: $hasKeys');
    buffer.writeln('   - Private Key Exists: ${privateKey != null}');
    if (privateKey != null) {
      buffer.writeln('   - Private Key Length: ${privateKey.length} chars');
      buffer.writeln(
          '   - Private Key Preview: ${privateKey.substring(0, 50)}...');
    }
    buffer.writeln('   - Public Key Exists: ${publicKey != null}');
    if (publicKey != null) {
      buffer.writeln('   - Public Key Length: ${publicKey.length} chars');
    }
    buffer.writeln('   - Stored User ID: ${userId ?? "N/A"}');
    buffer.writeln();

    // Test key parsing
    buffer.writeln('3. Key Parsing Test:');
    if (privateKey != null) {
      try {
        final parsedPrivateKey = RSAService.privateKeyFromPem(privateKey);
        buffer.writeln('   - Private Key Parsing: ✓ SUCCESS');
        buffer.writeln('   - Key Modulus: ${parsedPrivateKey.modulus}');
      } catch (e) {
        buffer.writeln('   - Private Key Parsing: ✗ FAILED');
        buffer.writeln('   - Error: $e');
      }
    } else {
      buffer.writeln('   - Private Key Parsing: SKIPPED (no key)');
    }

    if (publicKey != null) {
      try {
        final parsedPublicKey = RSAService.publicKeyFromPem(publicKey);
        buffer.writeln('   - Public Key Parsing: ✓ SUCCESS');
        buffer.writeln('   - Key Modulus: ${parsedPublicKey.modulus}');
      } catch (e) {
        buffer.writeln('   - Public Key Parsing: ✗ FAILED');
        buffer.writeln('   - Error: $e');
      }
    } else {
      buffer.writeln('   - Public Key Parsing: SKIPPED (no key)');
    }
    buffer.writeln();

    // Recommendations
    buffer.writeln('4. Recommendations:');
    if (!hasKeys) {
      buffer.writeln('   ⚠ CRITICAL: No cryptographic keys found!');
      buffer.writeln('   → You need to log out and log in again, or');
      buffer.writeln('   → Register a new account on this device');
    } else if (privateKey == null) {
      buffer.writeln('   ⚠ WARNING: Private key missing!');
      buffer.writeln('   → Cannot sign contracts without private key');
    } else {
      buffer.writeln('   ✓ All systems operational');
    }

    setState(() {
      _diagnosticResult = buffer.toString();
      _isRunning = false;
    });
  }

  Future<void> _regenerateKeys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Keys'),
        content: const Text(
          'This will generate new cryptographic keys for your account. '
          'You will be able to sign new contracts, but this may affect '
          'verification of existing contracts.\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final keyPair = RSAService.generateKeyPair();
      final publicKeyPem = RSAService.publicKeyToPem(keyPair.publicKey);
      final privateKeyPem = RSAService.privateKeyToPem(keyPair.privateKey);

      await StorageService.savePrivateKey(privateKeyPem);
      await StorageService.savePublicKey(publicKeyPem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keys regenerated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Re-run diagnostics
      _runDiagnostics();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to regenerate keys: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Diagnostics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isRunning ? null : _runDiagnostics,
              icon: _isRunning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text('Run Diagnostics'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isRunning ? null : _regenerateKeys,
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate Keys (Advanced)'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _diagnosticResult,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
