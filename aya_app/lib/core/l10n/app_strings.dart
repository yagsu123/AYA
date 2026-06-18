/// Minimal string localisation (EN · HI). Strings used on the dashboard.
/// More screens join as phases progress.
class AppStrings {
  AppStrings._();

  static const _en = {
    'goodMorning': 'Jai Jinendra',
    'goodAfternoon': 'Jai Jinendra',
    'goodEvening': 'Jai Jinendra',
    'tagline': 'Connecting Members Digitally',
    'quickAccess': 'Quick access',
    'todayBirthdays': "Today's birthdays",
    'todayAnniversaries': "Today's anniversaries",
    'completeProfile': 'Complete your profile',
    'upcoming': 'UPCOMING',
    'turnsToday': 'Turns {n} today',
    'birthdayToday': 'Birthday today',
    'anniversaryToday': 'Anniversary today',
    'yearsToday': '{n} years today',
    'members': 'Members',
    'events': 'Events',
    'birthdays': 'Birthdays',
    'gallery': 'Gallery',
    'vibhags': 'Vibhags',
    'aes': 'AES',
    'home': 'Home',
    'more': 'More',
    'comingSoon': 'Coming in a later phase',
  };

  static const _hi = {
    'goodMorning': 'जय जिनेन्द्र',
    'goodAfternoon': 'जय जिनेन्द्र',
    'goodEvening': 'जय जिनेन्द्र',
    'tagline': 'समुदाय से डिजिटल जुड़ाव',
    'quickAccess': 'त्वरित पहुंच',
    'todayBirthdays': 'आज के जन्मदिन',
    'todayAnniversaries': 'आज की वर्षगांठ',
    'completeProfile': 'अपनी प्रोफ़ाइल पूरी करें',
    'upcoming': 'आगामी',
    'turnsToday': 'आज {n} के हुए',
    'birthdayToday': 'आज जन्मदिन',
    'anniversaryToday': 'आज वर्षगांठ',
    'yearsToday': 'आज {n} वर्ष',
    'members': 'सदस्य',
    'events': 'कार्यक्रम',
    'birthdays': 'जन्मदिन',
    'gallery': 'गैलरी',
    'vibhags': 'विभाग',
    'aes': 'AES',
    'home': 'होम',
    'more': 'अधिक',
    'comingSoon': 'जल्द आ रहा है',
  };

  static String get(String locale, String key, {int? n}) {
    final map = locale == 'hi' ? _hi : _en;
    var s = map[key] ?? _en[key] ?? key;
    if (n != null) s = s.replaceAll('{n}', '$n');
    return s;
  }
}
