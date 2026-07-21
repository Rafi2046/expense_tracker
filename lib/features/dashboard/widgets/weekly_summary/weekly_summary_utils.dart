import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WeeklySummaryUtils {
  static const namedCategoryColors = <String, Color>{
    'housing': Color(0xFF1EA97C),
    'food': Color(0xFF2EBD85),
    'transport': Color(0xFF80E2B9),
    'utilities': Color(0xFFD2F8E7),
    'entertainment': Color(0xFFE24361),
    'shopping': Color(0xFFF59E0B),
    'health': Color(0xFFEF4444),
    'education': Color(0xFF8B5CF6),
    'salary': Color(0xFF2EBD85),
    'investment': Color(0xFF6366F1),
  };

  static const namedCategoryIcons = <String, IconData>{
    'housing': LucideIcons.home,
    'food': LucideIcons.utensilsCrossed,
    'transport': LucideIcons.car,
    'utilities': LucideIcons.zap,
    'entertainment': LucideIcons.clapperboard,
    'shopping': LucideIcons.shoppingBag,
    'health': LucideIcons.heartPulse,
    'education': LucideIcons.graduationCap,
    'salary': LucideIcons.creditCard,
    'investment': LucideIcons.trendingUp,
  };

  static const colorPalette = [
    Color(0xFF1EA97C),
    Color(0xFF2EBD85),
    Color(0xFF80E2B9),
    Color(0xFFE24361),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF6366F1),
    Color(0xFF06B6D4),
  ];

  static Color getCategoryColor(String category, int index) {
    final key = category.toLowerCase().trim();
    return namedCategoryColors[key] ?? colorPalette[index % colorPalette.length];
  }

  static IconData getCategoryIcon(String category) {
    final key = category.toLowerCase().trim();
    return namedCategoryIcons[key] ?? LucideIcons.receipt;
  }

  static List<String> generateInsights({
    required BuildContext context,
    required double total,
    required double previousTotal,
    required String? topCategory,
    required double topAmount,
    required double highestAmount,
    required String highestDayLabel,
  }) {
    final List<String> insights = [];
    final locale = Localizations.localeOf(context).languageCode;

    // Comparative insight
    if (total > 0) {
      if (previousTotal > 0) {
        final percent = ((total - previousTotal) / previousTotal * 100).toStringAsFixed(1);
        if (total > previousTotal) {
          if (locale == 'bn') {
            insights.add("আপনি গত সপ্তাহের চেয়ে $percent% বেশি খরচ করেছেন। খরচ নিয়ন্ত্রণ করার চেষ্টা করুন।");
          } else if (locale == 'hi') {
            insights.add("आपने पिछले सप्ताह की तुलना में $percent% अधिक खर्च किया। बजट पर नियंत्रण रखें।");
          } else if (locale == 'ur') {
            insights.add("آپ نے پچھلے ہفتے کے مقابلے میں $percent% زیادہ خرچ کیا۔ بجট کو کنٹرول کریں۔");
          } else {
            insights.add("You spent $percent% more than last week. Consider setting budget alerts to keep costs in check.");
          }
        } else {
          if (locale == 'bn') {
            insights.add("আপনি গত সপ্তাহের চেয়ে $percent% কম খরচ করেছেন। দারুণ! 🎉");
          } else if (locale == 'hi') {
            insights.add("आपने पिछले सप्ताह की तुलना में $percent% কম খরচ کیا۔ बहुत बढ़िया! 🎉");
          } else if (locale == 'ur') {
            insights.add("آپ نے پچھلے ہفتے کے مقابلے میں $percent% কম خرچ کیا۔ بہترین! 🎉");
          } else {
            insights.add("Awesome job! You spent $percent% less than last week. Keep maintaining this healthy trend! 🎉");
          }
        }
      } else {
        if (locale == 'bn') {
          insights.add("আপনার এই সপ্তাহের খরচের হিসাব ঠিক আছে। আগামী সপ্তাহের সাথে তুলনা করার জন্য নিয়মিত ট্র্যাক করুন।");
        } else if (locale == 'hi') {
          insights.add("आपके इस सप्ताह का खर्च सही दिशा में है। अगले सप्ताह से तुलना के लिए इसे ट्रैक करते रहें।");
        } else if (locale == 'ur') {
          insights.add("آپ کے اس ہفتے کے اخراجات ٹھیک سمت میں ہیں۔ اگلے ہفتے سے موازنہ کرنے کے لیے باقاعدگی سے ٹریک کریں۔");
        } else {
          insights.add("Your total spending is on track. Try comparing with next week's activity to build consistent habits.");
        }
      }
    }

    // Top Category insight
    if (topCategory != null && topAmount > 0 && total > 0) {
      final share = (topAmount / total * 100).toStringAsFixed(0);
      if (locale == 'bn') {
        insights.add("আপনার সবচেয়ে বেশি খরচ হয়েছে $topCategory খাতে, যা মোট খরচের $share%।");
      } else if (locale == 'hi') {
        insights.add("आपका सबसे अधिक खर्च $topCategory में हुआ, जो बजट का $share% है।");
      } else if (locale == 'ur') {
        insights.add("آپ کا سب سے زیادہ خرچ $topCategory میں ہوا، جو بجٹ کا $share% ہے۔");
      } else {
        insights.add("$topCategory was your highest spending category, taking up $share% of your weekly budget.");
      }
    }

    // Peak day insight
    if (highestAmount > 0) {
      if (locale == 'bn') {
        insights.add("সপ্তাহের সবচেয়ে বেশি খরচ হয়েছে $highestDayLabel-এ, এদিন খরচ ছিল $highestAmount।");
      } else if (locale == 'hi') {
        insights.add("सप्ताह का उच्चतम खर्च $highestDayLabel को हुआ, जब एक दिन का खर्च $highestAmount तक पहुँच गया।");
      } else if (locale == 'ur') {
        insights.add("ہفتے کے اخراجات $highestDayLabel को عروج पर थे, যখন এক দিন का खर्च $highestAmount तक पहुंच गया।");
      } else {
        insights.add("Your weekly spending peaked on $highestDayLabel with single-day expenses reaching $highestAmount.");
      }
    }

    return insights;
  }
}
