/// Material 3 spacing & shape tokens — strict 8-point grid.
///
/// Allowed spacing: 4, 8, 12, 16, 24, 32, 40, 48.
/// Allowed radii: 8, 12, 16, 24.
class AppSpacing {
  AppSpacing._();

  // ── Spacing scale ───────────────────────────────────────────────
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;

  // Padding aliases (same scale)
  static const double p4 = s4;
  static const double p8 = s8;
  static const double p12 = s12;
  static const double p16 = s16;
  static const double p24 = s24;
  static const double p32 = s32;
  static const double p40 = s40;
  static const double p48 = s48;

  // Margin aliases
  static const double m4 = s4;
  static const double m8 = s8;
  static const double m12 = s12;
  static const double m16 = s16;
  static const double m24 = s24;
  static const double m32 = s32;
  static const double m40 = s40;
  static const double m48 = s48;

  // Height / gap aliases
  static const double h4 = s4;
  static const double h8 = s8;
  static const double h12 = s12;
  static const double h16 = s16;
  static const double h24 = s24;
  static const double h32 = s32;
  static const double h40 = s40;
  static const double h48 = s48;

  // Width aliases
  static const double w4 = s4;
  static const double w8 = s8;
  static const double w12 = s12;
  static const double w16 = s16;
  static const double w24 = s24;
  static const double w32 = s32;
  static const double w40 = s40;
  static const double w48 = s48;

  /// Hairline border width (not part of the spacing scale).
  static const double w1 = 1.0;

  // ── Border radii (8 / 12 / 16 / 24 only) ─────────────────────────
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r24 = 24.0;

  static const double br8 = r8;
  static const double br12 = r12;
  static const double br16 = r16;
  static const double br24 = r24;

  // ── Semantic auth sizes (grid-aligned) ──────────────────────────
  /// Login / sign-up text field and primary button height.
  static const double authFieldHeight = h48;

  /// Shared corner radius for auth text fields and buttons.
  static const double authFieldBorderRadius = br8;

  /// Space between label+field groups on auth screens.
  static const double authFieldGroupGap = s16;
}
