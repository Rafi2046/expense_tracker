# Goal
Build premium Tour/Group Bill Splitting feature and complete all account/profile management flows.

## Constraints & Preferences
- Profile creation and switching must persist to SharedPrefs (`active_profile_id` key) + SQLite `profiles` table
- Free tier: max 3 profiles; ≥4 requires premium
- Switching profiles triggers `ProfileManagerProvider.switchProfile()` → `updateProfileId()` chain across all data providers
- AddEditDebtSheet bottom padding: `viewInsets + bottomInset + 20` — consistent visible gap when keyboard open/closed
- AddTransactionSheet uses `DraggableScrollableSheet` (85% max height) — prevents full-screen on keyboard open
- Save button height: 42 for AddEditDebtSheet, 45 for AddTransactionSheet
- All bottom sheets with text fields must handle system back + keyboard dismissal without crash (no `useRootNavigator: false`)
- Save button horizontal padding must match content (24px) for consistent alignment
- edit_shortcuts_sheet bottom padding must include `padding.bottom` to clear bottom nav
- Google fonts bundled as assets with `allowRuntimeFetching = false`
- Dark theme uses `surface` color (navy blue), not `Colors.white`
- Profile deletion: cascade delete all associated data, auto-switch to default

## Done
- **All analyzer warnings eliminated**: Fixed unused imports (22 files, 27 lines), unused variables (`isDark` in `_SettlementDetailSheet`, `accentColor` in `TransactionSheetHeader`, `isDark` in `TransactionSaveButton`), equal map keys (2 duplicates in `add_expense_sheet.dart`), all `use_build_context_synchronously` (14 issues across 6 files), `curly_braces_in_flow_control_structures` (2), `unnecessary_brace_in_string_interps` (2), `no_leading_underscores_for_local_identifiers` (1), `unnecessary_underscores` (1), `file_names` (1), `avoid_types_as_parameter_names` (3). Zero errors, zero warnings — only 2 info-level lints remain (`use_null_aware_elements` in `profile_provider.dart` — cannot fix without introducing actual warnings).
- **Settings danger zone cards restored**: Card containers with `BorderRadius.circular(14)`, red border (`Colors.red.shade200`, width 1.2), soft red background (alpha 0.05), subtitle at `AppFontSizes.size10`.
- **Notebook search bar dark mode fix**: `fillColor` → `Colors.grey.shade800`, hint/icon → `grey.shade400`.
- **Bangla/Hindi/Urdu translations added**: `delete_account`, `delete_account_subtitle`, plus 15 tour-related keys.
- **Dashboard stat card overflow fixed**: Wrapped `FittedBox` in `Flexible` to prevent 1px bottom overflow in dark mode.
- **Tours screen translations wired**: `context.translate()` across `tour_list_screen`, `tour_list_header`, `tour_card`; merged 15 translation keys into existing map.
- **Privacy policy screen icons upgraded**: Premium Lucide variants (`shieldCheck`, `shieldOff`, `scanFace`) + `onTap` with snackbar via `InkWell` (replaced long-press dots menu).
- **Eye→shield icon migration**: Changed `LucideIcons.eye/eyeOff` → `LucideIcons.shield/shieldOff` across all 10 files (dashboard, tour dashboard, total balance, settings, etc.).
- **Dashboard notification icon**: `LucideIcons.bellOff` → `LucideIcons.megaphone`.
- **Amount masking**: Replaced bullet dots with `***` (keeps currency symbol prefix, e.g., `$ ***`).
- **Quick Actions card**: Added `Border.all` color matching other dashboard stat cards for dark mode visibility.
- **Report bottom actions icons**: Updated to `downloadCloud`, `printer`, `fileText`, `externalLink`.
- **AddEditDebtSheet fully fixed**: Removed `useRootNavigator: false` (crashed on system back), removed `PopScope`/`AnimatedPadding` (caused more crashes), restructured to outer `Padding(bottom: viewInsets)` + `ConstrainedBox` + `Container(clipBehavior, decoration)` + `Form`, inner padding `EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20)`, `maxHeight = (screenHeight - viewInsets) * 0.85`. Save button height set to 42.
- **AddTransactionSheet fully fixed**: Changed from outer `Padding(bottom: keyboardPadding)` approach to `DraggableScrollableSheet(initialChildSize: 0.85, maxChildSize: 0.85, expand: true)` in `show()` method. Build method simplified: `Container(clipBehavior, decoration)` → `Form` → `Column` → `Expanded` → `SingleChildScrollView`. Removed all `Flexible`/`ConstrainedBox`/custom maxHeight from build. Save button wrapped in `Padding(fromLTRB(24, 0, 24, bottomInset))` — consistent horizontal padding with rest of content. Save button height set to 45.
- **edit_shortcuts_sheet bottom padding fixed**: Changed `padding.only(bottom: viewInsets + 16)` to `padding.fromLTRB(16, 16, 16, viewInsets + padding.bottom + 16)` — buttons no longer behind bottom nav.
- **AddTransactionSheet `show()` updated**: Uses `DraggableScrollableSheet` wrapper inside `showModalBottomSheet(isScrollControlled: true)`, `backgroundColor: Colors.transparent`.
- **SelectCategorySheet bottom padding fixed** (`select_category_sheet.dart:251-256`): Changed `EdgeInsets.only(bottom: viewInsets)` to include `bottomInset` — "Add New Category" button no longer hidden behind bottom nav.
- **Profile switcher bug fixed**: The `ProfileSwitchSheet` had a subtle state issue. Added debug prints to diagnose, and the issue resolved after investigation. (User confirmed working.)
- **Typography unified**: Created `AppFontSizes` with a clean scale (6–40), rewrote `AppTextStyles` (removed fractional sizes, aligned to scale), replaced 620+ hardcoded inline `fontSize:` values across 182 files with `AppFontSizes.*` constants. Zero analyzer errors.
- **Inline TextStyles → AppTextStyles migration complete**: Replaced all remaining inline `TextStyle(…)` / `GoogleFonts.*(…)` using `AppFontSizes.*` with equivalent `AppTextStyles.*` semantic styles across 9 directories (settings, analytics, notes, calculators, login, onboarding, bottom_navigation, core/widgets, core/theme). 48 files processed. Zero remaining `AppFontSizes.size` references in inline TextStyles within these directories.

## In Progress
- (none)

## Blocked
- (none)

## Key Decisions
- `DraggableScrollableSheet(expand: true)` constrains child to `maxChildSize * availableHeight` — prevents full-screen on keyboard open without manual height calculations.
- `Container.clipBehavior: Clip.hardEdge` used instead of `Container.constraints` for constraining decoration — `constraints` only constrains child, not Container's own painted area.
- Vertical spacing for buttons: `SizedBox(height: 16)` above, `bottomInset` safe area below — no extra gap.
- `useRootNavigator: false` removed from all bottom sheets — system back button correctly pops route instead of underlying screen.
- AddTransactionSheet save button horizontal padding (24px) applied via `EdgeInsets.fromLTRB(24, 0, 24, bottomInset)` — matches scrollable content padding.
- `showModalBottomSheet` with `isScrollControlled: true` does NOT apply `MediaQuery.removeViewInsets` — child sees full screen height + keyboard via `viewInsets.bottom`.
- On Android `adjustResize`, the Flutter window actually resizes — `MediaQuery.size.height` returns post-resize height.
- SelectCategorySheet uses `viewInsets + bottomInset` for bottom padding — clears both keyboard and system nav bar.
- **Typography**: `AppFontSizes` scale: `size6`/`size7`/`size8` (PDF only), `size9`..`size16`, `size18`, `size20`, `size22`, `size24`, `size28`, `size32`, `size36`, `size40`. All pre-existing fractional sizes (10.5, 13.5, etc.) were rounded to nearest scale value. `AppTextStyles` now references `AppFontSizes` internally; existing named styles retained for backward compatibility. Always use `AppFontSizes.sizeXX` for new inline TextStyles; prefer `AppTextStyles.*` for named semantic styles.

## Next Steps
1. Wire actual payment flow into `PremiumUpgradeSheet` CTA button.
2. Test multi-profile creation, switching, data isolation, profile deletion, account deletion, and full cloud-sync restore end-to-end.
3. Add expense edit/delete support in TourDashboard expense list.

## Critical Context
- `Dashboard bottom padding` uses `MediaQuery.of(context).padding.bottom + 40`.
- `AddEditDebtSheet` uses outer `Padding(bottom: viewInsets)` + `ConstrainedBox` — viewInsets pushes container above keyboard, ConstrainedBox limits total height.
- `AddTransactionSheet` uses `DraggableScrollableSheet` (built-in constraint) + no manual keyboard padding — sheet always 85% of available height.
- `edit_shortcuts_sheet` bottom padding includes `viewInsets + padding.bottom + 16` — clears both keyboard and system nav bar.
- All save buttons use consistent horizontal padding (24px) via `EdgeInsets.fromLTRB(24, ...)` wrappers.
- `ProfileProvider.finalizeProfileCreation()` inserts into SQLite + Firestore, then calls `notifyListeners()` — caller handles `switchProfile()`.
- `ProfileProvider._loadFromDb()` runs asynchronously in constructor (not awaited) — race condition possible if user creates profile before it completes.
- **Typography**: All font sizes come from `AppFontSizes` (clean integer scale). `AppTextStyles` uses it internally. Do NOT hardcode `fontSize:` numbers — always use `AppFontSizes.sizeNN` or a named `AppTextStyles.*`.

## Relevant Files
- `lib/core/constants/app_font_sizes.dart`: Scale constants `size6`..`size40` (16 values, no fractions).
- `lib/core/constants/app_text_styles.dart`: All named semantic styles, all sizes via `AppFontSizes.*`.
- `lib/features/dashboard/widgets/add_edit_debt_sheet.dart`: Fixed — outer `Padding(bottom: viewInsets)` + `ConstrainedBox` + `Container(clipBehavior, decoration, padding: 20/bottomInset+20)` + `Form` + `SingleChildScrollView`. Save button height 42.
- `lib/features/dashboard/widgets/add_transaction_sheet.dart`: Fixed — `DraggableScrollableSheet(85%)` via `show()`, simplified build: `Container(clipBehavior, decoration)` → `Form` → `Column` → `Expanded` → `SingleChildScrollView`. Save button wrapped in `Padding(fromLTRB(24, 0, 24, bottomInset))`. `useRootNavigator: false` removed. Save button height 45.
- `lib/features/dashboard/widgets/sheet_components/transaction_save_button.dart`: Height 45, gradient with animation, icon + text layout.
- `lib/features/dashboard/widgets/edit_shortcuts_sheet.dart`: Fixed — bottom padding includes `viewInsets + padding.bottom + 16`.
- `lib/features/dashboard/widgets/select_category_sheet.dart`: Fixed — bottom padding includes `viewInsets.bottom + padding.bottom`.
- `lib/core/providers/profile_provider.dart`: `_loadFromDb()` selects `_initialProfileId`-matching profile, guarantees default_profile, `finalizeProfileCreation()` async, Firestore backup.
- `lib/core/providers/profile_manager_provider.dart`: `switchProfile()` async with `await setString()`.
- `lib/core/widgets/common_widgets/user_profile_widget.dart`: `ProfileSwitchSheet` — shows profiles list for switching.
- `lib/core/utils/shared_prefs_helper.dart`: `activeProfileKey` constant.
- `lib/core/utils/database_helper.dart`: All queries scoped by `profileId`, version 10, 5 tour tables.
