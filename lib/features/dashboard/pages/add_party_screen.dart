import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/add_party_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/party_avatar_picker.dart';
import 'package:expense_tracker/features/dashboard/widgets/party_segmented_tabs.dart';
import 'package:expense_tracker/features/dashboard/widgets/credit_info_form.dart';
import 'package:expense_tracker/features/dashboard/widgets/additional_details_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddPartyScreen extends StatelessWidget {
  const AddPartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddPartyProvider(),
      child: const AddPartyForm(),
    );
  }
}

class AddPartyForm extends StatefulWidget {
  const AddPartyForm({super.key});

  @override
  State<AddPartyForm> createState() => _AddPartyFormState();
}

class _AddPartyFormState extends State<AddPartyForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddPartyProvider>();
    final debtProvider = context.read<DebtProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Party',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.titleTextStyle?.color,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerTheme.color, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Picture Picker Widget
                      PartyAvatarPicker(
                        pickedImagePath: provider.pickedImagePath,
                        pickedImageBytes: provider.pickedImageBytes,
                        onImagePicked: (path, bytes) {
                          provider.setPickedImage(path, bytes);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Party Name Field
                      TextFormField(
                        controller: provider.nameController,
                        style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Party Name',
                          hintStyle: AppTextStyles.partyFormHint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a party name';
                          }
                          return null;
                        },
                      ),

                      // Progressive Disclosure Form Animation (Secondary inputs slide/fade in)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return SizeTransition(
                                sizeFactor: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                        child: provider.isNameNotEmpty
                            ? Column(
                                key: const ValueKey('expanded_inputs'),
                                children: [
                                  const SizedBox(height: 12),
                                  // Phone Number Field
                                  TextFormField(
                                    controller: provider.phoneController,
                                    style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: 'Phone Number',
                                      hintStyle: AppTextStyles.partyFormHint,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                      filled: true,
                                      fillColor: theme.cardColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.dividerTheme.color ?? Colors.grey.shade100,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.dividerTheme.color ?? Colors.grey.shade200,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Sliding Segmented Tabs
                                  PartySegmentedTabs(
                                    activeIndex: provider.activeTabIndex,
                                    onTabChanged: (index) {
                                      provider.setTabIndex(index);
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Tab View Form Sections
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: provider.activeTabIndex == 0
                                        ? CreditInfoForm(
                                            key: const ValueKey(
                                              'credit_info_tab',
                                            ),
                                            balanceController:
                                                provider.balanceController,
                                            dateController:
                                                provider.dateController,
                                            isReceive: provider.isReceive,
                                            currencySymbol:
                                                context.currencySymbol,
                                            onToggleChanged: (value) {
                                              provider.setReceive(value);
                                            },
                                            onSelectDate: () =>
                                                provider.selectDate(context),
                                          )
                                        : AdditionalDetailsForm(
                                            key: const ValueKey(
                                              'additional_details_tab',
                                            ),
                                            emailController:
                                                provider.emailController,
                                            addressController:
                                                provider.addressController,
                                            vatController:
                                                provider.vatController,
                                          ),
                                  ),
                                ],
                              )
                            : const SizedBox(key: ValueKey('collapsed_inputs')),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Save Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: MouseRegion(
                  cursor: provider.isNameNotEmpty
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.isNameNotEmpty
                            ? theme.primaryColor
                            : (isDark ? Colors.white10 : const Color(0xFFF1F2F4)),
                        elevation: provider.isNameNotEmpty ? 1.5 : 0,
                        shadowColor: theme.primaryColor.withValues(
                          alpha: 0.25,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: provider.isNameNotEmpty
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                provider.saveParty(context, debtProvider);
                              }
                            }
                          : null,
                      child: Text(
                        'Add New Party',
                        style: AppTextStyles.partySubmitButtonText.copyWith(
                          fontSize: 15,
                          color: provider.isNameNotEmpty
                              ? Colors.white
                              : (isDark ? Colors.white30 : const Color(0xFFC1C7D0)),
                        ),
                      ),
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
