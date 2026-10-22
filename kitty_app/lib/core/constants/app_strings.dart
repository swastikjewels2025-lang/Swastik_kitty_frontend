/// Centralized user-facing UI terminology and string constants for Kitty App.
///
/// Implements the approved terminology simplification audit:
/// - Replaces technical/institutional financial jargon with warm, simple terms.
/// - NOTE: Separates UI presentation text from technical/API/backend identifiers
///   (e.g., internal fields like `schemeId` remain untouched in data models).
abstract final class AppStrings {
  // ---------------------------------------------------------------------------
  // Brand & Application Names
  // ---------------------------------------------------------------------------

  /// Main application title.
  static const String appName = 'Swastik Jewellers Kitty';

  /// Brand short name.
  static const String brandName = 'Swastik Jewellers';

  // ---------------------------------------------------------------------------
  // Canonical Aligned UI Terminology (Redesign Audit Section 10)
  // ---------------------------------------------------------------------------

  /// "Monthly Payment" (replaces intimidating "EMI" or "Installment").
  static const String monthlyPayment = 'Monthly Payment';

  /// "Kitty Plan" (replaces abstract "Gold Scheme").
  static const String kittyPlan = 'Kitty Plan';

  /// "Kitty Plans" plural (replaces "Gold Schemes").
  static const String kittyPlans = 'Kitty Plans';

  /// "My Kitty" (replaces corporate "Dashboard" or "My Scheme").
  static const String myKitty = 'My Kitty';

  /// "Active Kitty" (replaces "Active Scheme").
  static const String activeKitty = 'Active Kitty';

  /// "Savings History" / "Passbook" (replaces "Passbook Ledger").
  static const String savingsHistory = 'Savings History';
  static const String passbook = 'Passbook';

  /// "Kitty Number" (replaces "Chit Token").
  static const String kittyNumber = 'Kitty Number';

  /// "Kitty ID" (replaces internal token identifier).
  static const String kittyId = 'Kitty ID';

  /// "Total Gold Goal" (replaces abstract "Target Amount").
  static const String totalGoldGoal = 'Total Gold Goal';

  /// "Total Gold Value" (financial valuation result).
  static const String totalGoldValue = 'Total Gold Value';

  /// "Start Kitty" (replaces formal "Enrol" / "Enrollment").
  static const String startKitty = 'Start Kitty';

  /// "Gold Value" (replaces complex "Valuation").
  static const String goldValue = 'Gold Value';

  /// "Checking with Bank" (replaces confusing "Reconciliation").
  static const String checkingWithBank = 'Checking with Bank';

  /// "Purity Seal & Packing" (replaces "Assay Packaging Fee").
  static const String puritySeal = 'Purity Seal & Packing';

  /// "Ready to Start" (replaces internal "Pre-Join").
  static const String readyToStart = 'Ready to Start';

  /// "ID Verification" (replaces intimidating "Statutory KYC").
  static const String idVerification = 'ID Verification';

  // ---------------------------------------------------------------------------
  // Navigation Destination Labels
  // ---------------------------------------------------------------------------

  static const String navHome = 'Home';
  static const String navLiveRates = 'Live Rates';
  static const String navMyKitty = 'My Kitty';
  static const String navKittyPlans = 'Kitty Plans';
  static const String navCalculator = 'Calculator';
  static const String navJewellery = 'Jewellery';
  static const String navCoins = 'Coins';

  // ---------------------------------------------------------------------------
  // Common Action Buttons & CTAs
  // ---------------------------------------------------------------------------

  static const String payNow = 'Pay Now';
  static const String payNextPayment = 'Pay Monthly Payment';
  static const String viewPassbook = 'View Savings History';
  static const String viewReceipt = 'View Receipt';
  static const String tryAgain = 'Try Again';
  static const String retry = 'Retry';
  static const String continueText = 'Continue';
  static const String confirm = 'Confirm';
  static const String cancel = 'Cancel';
  static const String close = 'Close';
  static const String viewAll = 'View All';
  static const String callConcierge = 'Call Concierge';

  // ---------------------------------------------------------------------------
  // Common Status Labels
  // ---------------------------------------------------------------------------

  static const String statusPaid = 'PAID';
  static const String statusDue = 'PAYMENT DUE';
  static const String statusCurrent = 'CURRENT';
  static const String statusUpcoming = 'UPCOMING';
  static const String statusBonus = '100% BONUS';
  static const String statusCompleted = 'COMPLETED';
  static const String statusFailed = 'FAILED';
  static const String statusAvailable = 'AVAILABLE';
  static const String statusSelected = 'SELECTED';
  static const String statusBooked = 'BOOKED';
  static const String statusVerified = 'VERIFIED';
}
