
class GlobalSettings {
  static final GlobalSettings _instance = GlobalSettings._internal();

  // Private constructor
  GlobalSettings._internal();

  // Getter for the singleton instance
  static GlobalSettings get instance => _instance;

  // Global variable
  String language = 'en_US';
  String? ip;


  
}
