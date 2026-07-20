import 'package:expense_tracker/features/calculators/widgets/glossary_label.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GlossaryEntries {
  GlossaryEntries._();

  static const principal = GlossaryEntry(
    icon: LucideIcons.coins,
    titleKey: 'glossary_principal_title',
    descriptionKey: 'glossary_principal_desc',
  );

  static const interestRate = GlossaryEntry(
    icon: LucideIcons.percent,
    titleKey: 'glossary_interest_rate_title',
    descriptionKey: 'glossary_interest_rate_desc',
  );

  static const timePeriod = GlossaryEntry(
    icon: LucideIcons.calendarDays,
    titleKey: 'glossary_time_period_title',
    descriptionKey: 'glossary_time_period_desc',
  );

  static const compoundingFrequency = GlossaryEntry(
    icon: LucideIcons.repeat2,
    titleKey: 'glossary_compounding_freq_title',
    descriptionKey: 'glossary_compounding_freq_desc',
  );

  static const simpleInterest = GlossaryEntry(
    icon: LucideIcons.trendingUp,
    titleKey: 'glossary_simple_interest_title',
    descriptionKey: 'glossary_simple_interest_desc',
  );

  static const compoundInterest = GlossaryEntry(
    icon: LucideIcons.lineChart,
    titleKey: 'glossary_compound_interest_title',
    descriptionKey: 'glossary_compound_interest_desc',
  );
}
