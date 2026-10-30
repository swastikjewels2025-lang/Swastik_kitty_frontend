/// ============================================================================
/// SWASTIK KITTY SERVER CONFIGURATION
/// ============================================================================
/// Configure the backend server host and protocol for the Flutter mobile client.
/// ============================================================================

/// Set to `true` when connecting to your live Hostinger VPS / production domain.
/// Set to `false` when running against your local Node.js backend over Wi-Fi.
const bool kUseProductionServer = true;

/// ----------------------------------------------------------------------------
/// 1. Production Hostinger VPS / Domain Configuration
/// ----------------------------------------------------------------------------
/// Your Hostinger VPS IP: 187.127.142.29
/// If using IP directly without SSL yet: keep kUseHttps = false.
/// Once you point a domain (e.g. 'api.swastikjewel.com') and install SSL:
/// change kProductionHost to your domain and set kUseHttps = true.
const String kProductionHost = '187.127.142.29';
const bool kUseHttps = false; // Switch to true when SSL (https://) is configured

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
