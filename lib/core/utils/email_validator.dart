import 'dart:convert';
import 'dart:io';

/// Validates emails beyond simple format checks before account creation.
///
/// Note: Major providers (Gmail, Yahoo, Outlook) do not reveal whether a
/// specific mailbox exists. For those domains we combine format, disposable,
/// MX, and gibberish/local-part heuristics. Final proof is still the
/// verification email link.
class EmailValidator {
  EmailValidator._();

  static final RegExp _formatRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  /// Common disposable / temporary email domains.
  static const Set<String> _disposableDomains = {
    'mailinator.com',
    'guerrillamail.com',
    'guerrillamail.net',
    'sharklasers.com',
    'grr.la',
    'tempmail.com',
    'temp-mail.org',
    'temp-mail.io',
    '10minutemail.com',
    '10minmail.com',
    'yopmail.com',
    'yopmail.fr',
    'trashmail.com',
    'getnada.com',
    'mailnesia.com',
    'maildrop.cc',
    'discard.email',
    'fakeinbox.com',
    'throwaway.email',
    'moakt.com',
    'emailondeck.com',
    'mintemail.com',
    'mytemp.email',
    'tmpmail.org',
    'tmpmail.net',
  };

  static EmailValidationResult validateFormat(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return EmailValidationResult.invalid(EmailValidationFailure.empty);
    }

    if (!_formatRegex.hasMatch(trimmed) || trimmed.contains('..')) {
      return EmailValidationResult.invalid(EmailValidationFailure.badFormat);
    }

    final parts = trimmed.split('@');
    if (parts.length != 2) {
      return EmailValidationResult.invalid(EmailValidationFailure.badFormat);
    }

    final local = parts[0];
    final domain = parts[1].toLowerCase();

    if (local.isEmpty ||
        domain.isEmpty ||
        local.startsWith('.') ||
        local.endsWith('.') ||
        domain.startsWith('.') ||
        domain.endsWith('.') ||
        !domain.contains('.')) {
      return EmailValidationResult.invalid(EmailValidationFailure.badFormat);
    }

    if (_disposableDomains.contains(domain)) {
      return EmailValidationResult.invalid(EmailValidationFailure.disposable);
    }

    if (_looksLikeFakeLocalPart(local)) {
      return EmailValidationResult.invalid(EmailValidationFailure.notReal);
    }

    return EmailValidationResult.valid(trimmed, domain);
  }

  /// Full async check: format + fake local-part + disposable + MX records.
  static Future<EmailValidationResult> validate(String email) async {
    final formatResult = validateFormat(email);
    if (!formatResult.isValid) return formatResult;

    final domain = formatResult.domain!;
    final hasMx = await _domainHasMxRecords(domain);
    if (!hasMx) {
      return EmailValidationResult.invalid(EmailValidationFailure.noMx);
    }

    return formatResult;
  }

  static bool _looksLikeFakeLocalPart(String local) {
    // Ignore plus-alias suffix (user+tag@gmail.com).
    final base = local.split('+').first.toLowerCase();
    final letters = base.replaceAll(RegExp(r'[^a-z]'), '');
    final digits = base.replaceAll(RegExp(r'[^0-9]'), '');

    // Long alphabetic local part with no vowels → keyboard mash (e.g. sdfsdfsdf).
    if (letters.length >= 6 && !RegExp(r'[aeiouy]').hasMatch(letters)) {
      return true;
    }

    // Only 1–2 unique letters repeated (aaaaaa, absabsabs with low variety).
    if (letters.length >= 6) {
      final unique = letters.split('').toSet();
      if (unique.length <= 2) return true;
    }

    // Repeating blocks: abcabcabc, sdfsdfsdf
    if (letters.length >= 6 &&
        RegExp(r'^(.{2,4})\1{2,}$').hasMatch(letters)) {
      return true;
    }

    // Consecutive keyboard rows
    const rows = [
      'qwertyuiop',
      'asdfghjkl',
      'zxcvbnm',
      'poiuytrewq',
      'lkjhgfdsa',
      'mnbvcxz',
    ];
    for (final row in rows) {
      if (letters.length >= 5 && row.contains(letters)) return true;
    }

    // Mostly random: high letter length, almost no digits/separators, and
    // consonant clusters that look non-name-like.
    if (letters.length >= 8 &&
        digits.isEmpty &&
        !base.contains('.') &&
        !base.contains('_') &&
        !base.contains('-') &&
        _consonantRatio(letters) > 0.85) {
      return true;
    }

    return false;
  }

  static double _consonantRatio(String letters) {
    if (letters.isEmpty) return 0;
    final consonants =
        letters.replaceAll(RegExp(r'[aeiouy]'), '').length;
    return consonants / letters.length;
  }

  /// Uses Google DNS-over-HTTPS to confirm the domain can receive mail.
  static Future<bool> _domainHasMxRecords(String domain) async {
    final client = HttpClient();
    try {
      final uri = Uri.https('dns.google', '/resolve', {
        'name': domain,
        'type': 'MX',
      });
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 8));
      request.headers.set(HttpHeaders.acceptHeader, 'application/dns-json');
      final response =
          await request.close().timeout(const Duration(seconds: 8));
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        // Network / API issue — don't block signup.
        return true;
      }
      final json = jsonDecode(body) as Map<String, dynamic>;
      final status = json['Status'];
      // Status 0 = NOERROR. Missing Answer with NOERROR often means no MX.
      final answers = json['Answer'];
      if (status == 0 && answers is List && answers.isNotEmpty) {
        return true;
      }
      // NXDOMAIN or empty answers → domain cannot receive mail.
      if (status == 3 || answers == null) {
        return false;
      }
      return answers is List && answers.isNotEmpty;
    } catch (_) {
      // Offline / timeout — allow format-valid emails through.
      return true;
    } finally {
      client.close(force: true);
    }
  }
}

enum EmailValidationFailure {
  empty,
  badFormat,
  disposable,
  notReal,
  noMx,
}

class EmailValidationResult {
  final bool isValid;
  final EmailValidationFailure? failure;
  final String? email;
  final String? domain;

  const EmailValidationResult._({
    required this.isValid,
    this.failure,
    this.email,
    this.domain,
  });

  factory EmailValidationResult.valid(String email, String domain) {
    return EmailValidationResult._(
      isValid: true,
      email: email,
      domain: domain,
    );
  }

  factory EmailValidationResult.invalid(EmailValidationFailure failure) {
    return EmailValidationResult._(isValid: false, failure: failure);
  }
}
