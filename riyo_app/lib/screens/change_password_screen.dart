import 'package:flutter/material.dart';
import 'package:riyo_app/riyo_api.dart';
import 'package:riyo_app/riyo_theme.dart';
import 'package:riyo_app/l10n/generated/app_localizations.dart';

/// Change Password Screen — X-style form for updating password
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final res = await RiyoApi.instance.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
        confirmPassword: _confirmController.text,
      );

      if (!mounted) return;

      if (res['status'] == 'success') {
        // Show success and navigate back to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ?? l10n.passwordChangedSuccess,
            ),
            backgroundColor: RiyoTheme.gray900,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        setState(() => _error = res['message']?.toString() ?? l10n.error);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: RiyoTheme.black,
      appBar: AppBar(
        title: Text(l10n.changePassword),
        backgroundColor: RiyoTheme.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(RiyoTheme.space6),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(RiyoTheme.space5),
                decoration: BoxDecoration(
                  color: RiyoTheme.gray900,
                  borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
                  border: Border.all(color: RiyoTheme.gray700, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: RiyoTheme.gray400,
                          size: 24,
                        ),
                        const SizedBox(width: RiyoTheme.space3),
                        Text(
                          l10n.changePassword,
                          style: RiyoTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: RiyoTheme.space3),
                    Text(
                      l10n.language == 'so'
                          ? 'Fadlan geli erayga sirta hadda jira, cusub, iyo hubinta. Ereyga cusub wuxuu u baahan yahay inuu ugu yaraan 6 xaraf ah.'
                          : 'Enter your current password, new password, and confirmation. The new password must be at least 6 characters.',
                      style: RiyoTheme.bodyMedium.copyWith(
                        color: RiyoTheme.gray400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: RiyoTheme.space6),

              // Current Password
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                style: RiyoTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: l10n.currentPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.allFieldsRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: RiyoTheme.space4),

              // New Password
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                style: RiyoTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: l10n.newPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  helperText: l10n.passwordTooShort,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.allFieldsRequired;
                  }
                  if (value.length < 6) {
                    return l10n.passwordTooShort;
                  }
                  return null;
                },
              ),

              const SizedBox(height: RiyoTheme.space4),

              // Confirm Password
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: RiyoTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: l10n.confirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.allFieldsRequired;
                  }
                  if (value != _newController.text) {
                    return l10n.passwordsMustMatch;
                  }
                  return null;
                },
              ),

              if (_error != null) ...[
                const SizedBox(height: RiyoTheme.space4),
                Container(
                  padding: const EdgeInsets.all(RiyoTheme.space4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: RiyoTheme.space3),
                      Expanded(
                        child: Text(
                          _error!,
                          style: RiyoTheme.bodyMedium.copyWith(
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: RiyoTheme.space6),

              // Submit Button
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: RiyoTheme.white,
                    foregroundColor: RiyoTheme.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(RiyoTheme.black),
                          ),
                        )
                      : Text(
                          l10n.changePassword,
                          style: RiyoTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: RiyoTheme.space4),

              // Security note
              Container(
                padding: const EdgeInsets.all(RiyoTheme.space4),
                decoration: BoxDecoration(
                  color: RiyoTheme.gray900,
                  borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
                  border: Border.all(color: RiyoTheme.gray700, width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: RiyoTheme.gray500,
                      size: 20,
                    ),
                    const SizedBox(width: RiyoTheme.space3),
                    Expanded(
                      child: Text(
                        l10n.passwordChangedSuccess,
                        style: RiyoTheme.bodySmall.copyWith(
                          color: RiyoTheme.gray400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
