import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/add_party_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/party_avatar_picker.dart';
import 'package:expense_tracker/features/dashboard/widgets/party_segmented_tabs.dart';
import 'package:expense_tracker/features/dashboard/widgets/additional_details_form.dart';
import 'package:expense_tracker/features/dashboard/widgets/party_form_fields.dart';
import 'package:expense_tracker/features/dashboard/widgets/party_type_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/party_balance_input.dart';
import 'package:expense_tracker/features/dashboard/widgets/party_save_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
          icon: Icon(LucideIcons.arrowLeft, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Party',
          style: AppTextStyles.h2.copyWith(color: theme.appBarTheme.titleTextStyle?.color),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      PartyAvatarPicker(
                        pickedImagePath: provider.pickedImagePath,
                        pickedImageBytes: provider.pickedImageBytes,
                        onImagePicked: (path, bytes) {
                          provider.setPickedImage(path, bytes);
                        },
                      ),
                      const SizedBox(height: 24),
                      PartyFormFields(
                        nameController: provider.nameController,
                        phoneController: provider.phoneController,
                        isNameNotEmpty: provider.isNameNotEmpty,
                      ),
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
                                  PartySegmentedTabs(
                                    activeIndex: provider.activeTabIndex,
                                    onTabChanged: (index) {
                                      provider.setTabIndex(index);
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: provider.activeTabIndex == 0
                                        ? Column(
                                            key: const ValueKey('credit_info_tab'),
                                            children: [
                                              PartyBalanceInput(
                                                balanceController: provider.balanceController,
                                                dateController: provider.dateController,
                                                currencySymbol: context.currencySymbol,
                                                onSelectDate: () => provider.selectDate(context),
                                              ),
                                              const SizedBox(height: 20),
                                              PartyTypeSelector(
                                                isReceive: provider.isReceive,
                                                onToggleChanged: (value) {
                                                  provider.setReceive(value);
                                                },
                                              ),
                                            ],
                                          )
                                        : AdditionalDetailsForm(
                                            key: const ValueKey('additional_details_tab'),
                                            emailController: provider.emailController,
                                            addressController: provider.addressController,
                                            vatController: provider.vatController,
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
            PartySaveButton(
              isEnabled: provider.isNameNotEmpty,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  provider.saveParty(context, debtProvider);
                }
              },
              primaryColor: theme.primaryColor,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}
