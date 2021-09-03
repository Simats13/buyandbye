import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERIDKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "USERDISPLAYNAME";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfilePicKey = "USERPROFILEKEY";
  static String userLocationLatitudeKey = "USERLATITUDEKEY";
  static String userLocationLongitudeKey = "USERLONGITUDEKEY";
  static String userAddressKey = "USERADDRESSKEY";
  static String userSliderkey = "UserSliderKey";
  static String userSliderLabelkey = "UserSliderLabelKey";
  static String userCityKey = "UserCityKey";
  static String userCreated = "UserCreated";
  //save data
  Future<bool> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, userName);
  }

  Future<bool> saveUserEmail(String getUseremail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUseremail);
  }

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveDisplayName(String getDisplayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(displayNameKey, getDisplayName);
  }

  Future<bool> saveUserProfileUrl(String getUserProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userProfilePicKey, getUserProfile);
  }

  Future<bool> saveUserLatitude(double getLatitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(userLocationLatitudeKey, getLatitude);
  }

  Future<bool> saveUserLongitude(double getLongitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(userLocationLongitudeKey, getLongitude);
  }

  Future<bool> saveUserAddress(String getAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userAddressKey, getAddress);
  }

  Future<bool> saveUserCreated(bool getUserCreated) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(userAddressKey, getUserCreated);
  }

  Future<bool> saveUserCity(String getCity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userCityKey, getCity);
  }

  Future<bool> saveUserSlider(double getSlider) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(userLocationLongitudeKey, getSlider);
  }

  //get data
  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String> getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displayNameKey);
  }

  Future<String> getUserProfileUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfilePicKey);
  }

  Future<double> getUserLatitude() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(userLocationLatitudeKey);
  }

  Future<double> getUserLongitude() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(userLocationLongitudeKey);
  }

  Future<String> getUserAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userAddressKey);
  }

  Future<String> getUserCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userCityKey);
  }

  Future<double> getUserSlider() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(userSliderkey);
  }

  Future<String> getLabelSliderUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userSliderLabelkey);
  }

  Future<bool> getUserCreated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userCreated);
  }
}
