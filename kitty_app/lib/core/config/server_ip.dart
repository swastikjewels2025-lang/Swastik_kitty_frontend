/// ============================================================================
/// SWASTIK KITTY SERVER CONFIGURATION
/// ============================================================================
/// If your computer's Wi-Fi IP address changes, simply change this IP string!
/// To check your current IP on Mac, run in terminal: ipconfig getifaddr en0
/// ============================================================================
const String kServerIp = '192.168.29.41';
const String kServerPort = '5000';

/// Default API Base URL pointing to your local Node.js backend
const String kDefaultBaseUrl = 'http://$kServerIp:$kServerPort';
