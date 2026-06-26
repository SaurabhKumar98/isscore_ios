class ApiEndpoint {
  static const String appBaseUrl = "https://api.iscorre.com/user";
  // static const String appBaseUrl = "http://192.168.88.31:8000/user";

  static const String socketurl = "https://api.iscorre.com/support";
  static const String websocket = "https://api.iscorre.com";
  static const String signup = "$appBaseUrl/signup";
  static const String login = "$appBaseUrl/login";
  static const String sendLoginOtp = '$appBaseUrl/send-otp';
  static const String verifyLoginOtp = '$appBaseUrl/verify-otp';
  static const String requestotp = "$appBaseUrl/forgot-password/request";
  static const String verifyOtp = '$appBaseUrl/forgot-password/verify';
  static const String resetPassword = '$appBaseUrl/forgot-password/reset';
  static const String testsAndBundles = '$appBaseUrl/tests-and-bundles';
  static const String categories = "$appBaseUrl/categories";
  static const String courseDownloads = "$appBaseUrl/courses";
  static const String downloads = "$appBaseUrl/my-courses";
  static const String userForums = "$appBaseUrl/forums";
  static const String userProfile = "$appBaseUrl/profile";
  static const String updateProfile = "$appBaseUrl/update-profile";
  static const String changePassword = "$appBaseUrl/change-password";
  static const String mentors = "$appBaseUrl/teachers";
  static const String workshop = "$appBaseUrl/workshops";
  static const String olympiad = "$appBaseUrl/olympiads";
  static const String logout = "$appBaseUrl/logout";
  static const String initiateStorePayment = "$appBaseUrl/tests";
  static const String examhall = "$appBaseUrl/examhall";
  static const String merchandise = "$appBaseUrl/merchandise";
  static const String leaderboard = "$appBaseUrl/leaderboard";
  static const String tournament = "$appBaseUrl/tournaments";
  static const String competitions = "$appBaseUrl/categories";
  static const String challengeYourself = '$appBaseUrl/challenge-yourself';
  static const String deleteAccount = "$appBaseUrl/delete-account";
  static const String myCourses = '$appBaseUrl/my-courses';

  static const String socketBaseUrl = "https://api.iscorre.com";

  static String? cachedToken;
}
