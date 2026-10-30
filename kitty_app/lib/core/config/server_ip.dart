/// ============================================================================
/// SWASTIK KITTY SERVER CONFIGURATION
/// ============================================================================
/// Configure the backend server host and protocol for the Flutter mobile client.
/// ============================================================================

/// Set to `true` when connecting to your live Hostinger VPS / production domain.
/// Set to `false` when running against your local Node.js backend over Wi-Fi.
const bool kUseProductionServer = true;

/// ----------------------------------------------------------------------------
/// 1. Production Hostinger VPS Domain Configuration
/// ----------------------------------------------------------------------------
/// Swastik Kitty Production Subdomain:
const String kProductionHost = 'kitty.swastikjewel.in';
const bool kUseHttps = true; // Enabled with Let's Encrypt SSL

/// ----------------------------------------------------------------------------
/// 2. Local Development Configuration (Wi-Fi LAN)
/// ----------------------------------------------------------------------------
/// Run `ipconfig getifaddr en0` on your Mac terminal to find your local IP.
const String kLocalServerIp = '192.168.29.76';
const String kLocalServerPort = '5001';

/// ----------------------------------------------------------------------------
/// Active Base URL
/// ----------------------------------------------------------------------------
/// Authoritative base URL used across all network calls (DioClient).
const String kDefaultBaseUrl = kUseProductionServer
    ? (kUseHttps ? 'https://$kProductionHost' : 'http://$kProductionHost')
    : 'http://$kLocalServerIp:$kLocalServerPort';
