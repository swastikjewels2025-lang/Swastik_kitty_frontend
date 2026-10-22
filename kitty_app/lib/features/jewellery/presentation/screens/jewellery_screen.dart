import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Showroom Jewellery In-App Web Bridge Screen (Phase 12).
///
/// Bridges the official Swastik Jewellers showroom and fine jewellery catalog
/// directly into the app via a secure, luxury-chrome native WebView.
///
/// Features:
/// - Official web catalog loading (`https://swastikjewel.in`)
/// - Navigation security enforcement (strict domain whitelisting)
/// - Top luxury App Bar with verified catalog badge
/// - Real-time animated gold progress bar
/// - Refresh, Showroom Concierge Helpline, and Share actions
/// - Native Android back handling via [PopScope] for web page history
/// - Offline/error fallback screen with actionable retry
class JewelleryScreen extends ConsumerStatefulWidget {
  const JewelleryScreen({
    super.key,
    this.initialUrl,
    this.controller,
    this.isTestMode = false,
    this.simulateError = false,
  });

  /// Optional override URL (defaults to [AppConstants.jewelleryCatalogUrl]).
  final String? initialUrl;

  /// Optional injected [WebViewController] for testing or advanced customization.
  final WebViewController? controller;

  /// Test mode flag to simulate browser chrome in headless widget test environments.
  final bool isTestMode;

  /// Simulate error state for testing error handling and retry workflows.
  final bool simulateError;

  @override
  ConsumerState<JewelleryScreen> createState() => _JewelleryScreenState();
}

class _JewelleryScreenState extends ConsumerState<JewelleryScreen> {
  WebViewController? _controller;
  int _loadingProgress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _canGoBack = false;
  String _currentUrl = AppConstants.jewelleryCatalogUrl;
  bool _isNativeWebViewReady = false;

  /// Strict domain whitelist to protect customers from arbitrary navigation.
  static const List<String> _allowedDomains = <String>[
    'swastikjewel.in',
    'www.swastikjewel.in',
    'swastikjewel.com',
    'www.swastikjewel.com',
  ];

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl ?? AppConstants.jewelleryCatalogUrl;
    _initializeWebController();
  }

  void _initializeWebController() {
    if (widget.simulateError) {
      _hasError = true;
      _isLoading = false;
      _errorMessage = 'Network connection timed out.';
      _isNativeWebViewReady = false;
      return;
    }

    if (widget.controller != null) {
      _controller = widget.controller;
      _isNativeWebViewReady = true;
      return;
    }

    if (widget.isTestMode) {
      // In headless test mode, skip native platform view instantiation
      _isNativeWebViewReady = false;
      _isLoading = false;
      return;
    }

    try {
      final WebViewController controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress;
                  if (progress >= 100) {
                    _isLoading = false;
                  }
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _errorMessage = '';
                  _currentUrl = url;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _currentUrl = url;
                });
                _updateNavigationState();
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                // If it is a main frame error, present the luxury error card
                if (error.isForMainFrame ?? true) {
                  setState(() {
                    _hasError = true;
                    _isLoading = false;
                    _errorMessage = error.description;
                  });
                }
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              final Uri? uri = Uri.tryParse(request.url);
              if (uri == null) {
                return NavigationDecision.prevent;
              }

              // Handle phone links (e.g. showroom direct call)
              if (uri.scheme == 'tel') {
                _launchExternalUri(uri);
                return NavigationDecision.prevent;
              }

              // Handle mailto links
              if (uri.scheme == 'mailto') {
                _launchExternalUri(uri);
                return NavigationDecision.prevent;
              }

              // Enforce domain whitelist
              if (_isDomainAllowed(uri.host)) {
                return NavigationDecision.navigate;
              }

              // Prevent untrusted external navigation & alert user
              _notifyDisallowedDomain(uri.host);
              return NavigationDecision.prevent;
            },
          ),
        )
        ..loadRequest(Uri.parse(_currentUrl));

      _controller = controller;
      _isNativeWebViewReady = true;
    } catch (_) {
      // Graceful fallback for environments where platform views are unavailable
      _isNativeWebViewReady = false;
      _isLoading = false;
    }
  }

  bool _isDomainAllowed(String host) {
    final String cleanHost = host.toLowerCase().trim();
    for (final String allowed in _allowedDomains) {
      if (cleanHost == allowed || cleanHost.endsWith('.$allowed')) {
        return true;
      }
    }
    return false;
  }

  Future<void> _updateNavigationState() async {
    if (_controller == null) return;
    try {
      final bool canBack = await _controller!.canGoBack();
      if (mounted) {
        setState(() {
          _canGoBack = canBack;
        });
      }
    } catch (_) {}
  }

  Future<void> _launchExternalUri(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open external link: ${uri.toString()}'),
            backgroundColor: AppColors.espressoCharcoal,
          ),
        );
      }
    }
  }

  void _notifyDisallowedDomain(String host) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Navigation to external domain ($host) is restricted for security.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.espressoCharcoal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _reload() {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _loadingProgress = 15;
    });

    if (_controller != null) {
      _controller!.reload();
    } else {
      // In test mode, simulate reload
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadingProgress = 100;
          });
        }
      });
    }
  }

  void _showConciergeModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.warmTaupeBrown.withValues(alpha: 0.3),
                  borderRadius: AppRadius.border8,
                ),
              ),
              const SizedBox(height: 20),

              // Concierge Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.champagneFoil.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.honeyGoldAccent.withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 28,
                  color: AppColors.deepForestCharcoal,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Swastik Showroom Concierge',
                style: AppTypography.cardTitle(color: AppColors.espressoCharcoal),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Experience personalized fine jewellery consultation or inquire about our chit scheme redemption.',
                style: AppTypography.bodyRegular(color: AppColors.warmTaupeBrown),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Helpline Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmLinenInset,
                  borderRadius: AppRadius.border16,
                  border: Border.all(color: AppColors.surfaceCardBorder),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(Icons.phone_in_talk_rounded, color: AppColors.primaryEmerald, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Helpline: ${AppConstants.showroomContactPhone}',
                            style: AppTypography.bodyBold(color: AppColors.espressoCharcoal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.location_on_outlined, color: AppColors.honeyGoldAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '108 Swastik Heritage Towers, Main Ring Road, New Delhi, India',
                            style: AppTypography.caption(color: AppColors.warmTaupeBrown),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Call CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('btn_concierge_call_now'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _launchExternalUri(Uri.parse('tel:${AppConstants.showroomContactPhone}'));
                  },
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Call Showroom Concierge', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareCatalog() {
    Clipboard.setData(ClipboardData(text: _currentUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('snackbar_jewellery_share'),
        backgroundColor: AppColors.espressoCharcoal,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: <Widget>[
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.honeyGoldAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Showroom catalog URL copied to clipboard!',
                style: AppTypography.bodyRegular(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (_controller != null && await _controller!.canGoBack()) {
          await _controller!.goBack();
          await _updateNavigationState();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.homeCanvasBg,
        appBar: AppBar(
          backgroundColor: AppColors.pureWhite,
          elevation: 0.5,
          scrolledUnderElevation: 1.0,
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Swastik Showroom',
                style: AppTypography.cardTitle(color: AppColors.espressoCharcoal).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.verified_rounded,
                    size: 13,
                    color: AppColors.primaryEmerald,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'swastikjewel.in · Official Web Catalog',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(color: AppColors.primaryEmerald).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            // Refresh Button
            IconButton(
              key: const Key('btn_jewellery_refresh'),
              tooltip: 'Refresh Catalog',
              icon: const Icon(Icons.refresh_rounded, color: AppColors.espressoCharcoal),
              onPressed: _reload,
            ),

            // Concierge Phone Button
            IconButton(
              key: const Key('btn_jewellery_concierge'),
              tooltip: 'Showroom Concierge',
              icon: const Icon(Icons.phone_in_talk_outlined, color: AppColors.deepForestCharcoal),
              onPressed: _showConciergeModal,
            ),

            // Share Button
            IconButton(
              key: const Key('btn_jewellery_share'),
              tooltip: 'Share Catalog',
              icon: const Icon(Icons.share_outlined, color: AppColors.espressoCharcoal),
              onPressed: _shareCatalog,
            ),
            const SizedBox(width: 4),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3.0),
                  child: LinearProgressIndicator(
                    key: const Key('jewellery_loading_progress_bar'),
                    value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.honeyGoldAccent),
                    minHeight: 3.0,
                  ),
                )
              : null,
        ),
        body: _hasError
            ? _buildErrorView()
            : _isNativeWebViewReady && _controller != null
                ? WebViewWidget(
                    key: const Key('jewellery_webview_widget'),
                    controller: _controller!,
                  )
                : _buildFallbackPreview(),
      ),
    );
  }

  /// Luxury error / offline fallback state with action buttons.
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.champagneFoil.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.honeyGoldAccent.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 38,
                color: AppColors.deepUmberBronze,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Showroom Catalog Offline',
              style: AppTypography.cardTitle(color: AppColors.espressoCharcoal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.isNotEmpty
                  ? 'Unable to connect to the catalog: $_errorMessage.\nPlease verify your internet connection and try again.'
                  : 'Unable to connect to the Swastik Jewellers showroom catalog. Please check your internet connection and try again.',
              style: AppTypography.bodyRegular(color: AppColors.warmTaupeBrown),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  key: const Key('btn_jewellery_retry'),
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry Connection', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  key: const Key('btn_jewellery_call_concierge_offline'),
                  onPressed: _showConciergeModal,
                  icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primaryEmerald),
                  label: Text('Concierge', style: AppTypography.bodyBold(color: AppColors.primaryEmerald)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryEmerald),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Luxury preview frame rendered when native platform views are unavailable (e.g. tests).
  Widget _buildFallbackPreview() {
    return Container(
      key: const Key('jewellery_fallback_preview'),
      color: AppColors.homeCanvasBg,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.creamIvoryCard,
              borderRadius: AppRadius.border20,
              border: Border.all(color: AppColors.surfaceCardBorder),
              boxShadow: AppShadows.cardSubtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                        borderRadius: AppRadius.border12,
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primaryEmerald,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Swastik Jewellers Official Catalog',
                            style: AppTypography.cardTitle(color: AppColors.espressoCharcoal),
                          ),
                          Text(
                            _currentUrl,
                            style: AppTypography.caption(color: AppColors.warmTaupeBrown),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Explore our full collection of BIS Hallmarked 22K/24K Gold, IGI Certified Solitaires, Wedding Bridal Chokers, Bangles, and temple jewellery directly redeemable against your active Kitty Chit savings.',
                  style: AppTypography.bodyRegular(color: AppColors.espressoCharcoal).copyWith(height: 1.5),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton.icon(
                        key: const Key('btn_open_external_catalog'),
                        onPressed: () => _launchExternalUri(Uri.parse(_currentUrl)),
                        icon: const Icon(Icons.open_in_browser_rounded),
                        label: const Text('Open in Browser', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: AppColors.primaryEmerald,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _showConciergeModal,
                      icon: const Icon(Icons.phone_rounded, color: AppColors.primaryEmerald),
                      label: Text('Concierge', style: AppTypography.bodyBold(color: AppColors.primaryEmerald)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: const BorderSide(color: AppColors.primaryEmerald),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.border12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
