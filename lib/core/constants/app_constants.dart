class AppConstants {
  static const String appName = 'MediCare+';
  static const String appTagline = 'Your Health, Our Priority';
  static const String defaultCity = 'Jaipur';
  static const String currency = '₹';

  // Available Cities
  static const List<String> availableCities = [
    'Jaipur',
    'Delhi NCR',
    'Mumbai',
    'Bengaluru',
    'Hyderabad',
    'Pune',
    'Chennai',
    'Kolkata',
  ];

  // Languages for consultation
  static const List<String> consultationLanguages = [
    'English',
    'हिंदी',
    'मराठी',
    'ગુજરાતી',
    'తెలుగు',
    'தமிழ்',
  ];

  // Coupon codes
  static const Map<String, double> couponCodes = {
    'HEALTH50': 50.0,    // ₹50 off
    'MEDICARE100': 100.0, // ₹100 off
    'FIRSTFREE': 200.0,  // ₹200 off first consultation
  };

  // Curated professional doctor avatar images (legal Unsplash public domain / direct avatars)
  static const String doctorAvatar1 =
      'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80';
  static const String doctorAvatar2 =
      'https://images.unsplash.com/photo-1594824813622-6e2161b96a84?w=400&auto=format&fit=crop&q=80';
  static const String doctorAvatar3 =
      'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400&auto=format&fit=crop&q=80';
  static const String doctorAvatar4 =
      'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&auto=format&fit=crop&q=80';
  static const String doctorAvatar5 =
      'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80';
  static const String doctorAvatar6 =
      'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&auto=format&fit=crop&q=80';

  // Patient Avatar
  static const String patientAvatar =
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80';

  // Agora Real-Time Communication Credentials
  static const String agoraAppId = '2d1a79eb047e4bcb93dadfacc4abe0a3';
  static const String agoraAppCertificate = 'a0d6634f5dda439e8d4aee0e7135db8f';
  static const String agoraAppBuilderId = 'appbuilder-18d042b8a93f08e894cf';
  static const String agoraDefaultChannel = 'appbuilder-18d042b8a93f08e894cf';
}

