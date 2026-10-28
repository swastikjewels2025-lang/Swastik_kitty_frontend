/// Centralized static fixture datasets matching the FROZEN Backend Contract v1.0.
///
/// Contains realistic payloads for all 18 backend endpoints with:
/// - Whole integer rupees (e.g. 5000, 60000, 41036)
/// - 3-decimal gold precision (e.g. 5.482, 0.702)
/// - ISO-8601 UTC timestamps
/// - Canonical chit tokens (#SW-042)
/// - Realistic passbook combination (PAID, CURRENT, UPCOMING, BONUS, PRE_JOIN)
abstract final class MockFixtures {
  // ---------------------------------------------------------------------------
  // 1. Auth Fixtures
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> authSendOtpSuccessJson = <String, dynamic>{
    'success': true,
    'message': 'OTP sent successfully to mobile number.',
    'data': <String, dynamic>{
      'sessionId': 'sess_otp_88992211',
      'expiresInSeconds': 300,
    },
  };

  static const Map<String, dynamic> authVerifySuccessJson = <String, dynamic>{
    'success': true,
    'message': 'OTP verified successfully.',
    'data': <String, dynamic>{
      'token': 'mock_jwt_token_30_days_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
      'user': <String, dynamic>{
        'id': 'usr_654321abcdef',
        'name': 'Aarav Sharma',
        'phone': '+919876543210',
        'role': 'CUSTOMER',
        'tier': 'Tier 1 Verified Member',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'kyc': <String, dynamic>{
          'isVerified': true,
          'status': 'VERIFIED',
          'documentType': 'AADHAAR',
          'documentNumberMasked': 'XXXX XXXX 9012',
          'documentUrl': 'https://res.cloudinary.com/swastik/image/upload/kyc/sample.jpg',
        },
      },
    },
  };

  static const Map<String, dynamic> userProfileJson = <String, dynamic>{
    'success': true,
    'message': 'User profile retrieved.',
    'data': <String, dynamic>{
      'id': 'usr_654321abcdef',
      'name': 'Aarav Sharma',
      'phone': '+919876543210',
      'email': 'aarav.sharma@swastikjewel.in',
      'role': 'CUSTOMER',
      'tier': 'Tier 1 Verified Member',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'nomineeName': 'Sunita Sharma',
      'nomineeRelationship': 'Spouse',
      'kyc': <String, dynamic>{
        'isVerified': true,
        'status': 'VERIFIED',
        'documentType': 'AADHAAR',
        'documentNumberMasked': 'XXXX XXXX 9012',
        'documentUrl': 'https://res.cloudinary.com/swastik/image/upload/kyc/sample.jpg',
      },
    },
  };

  // ---------------------------------------------------------------------------
  // 2. KYC Fixtures
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> kycSubmitSuccessJson = <String, dynamic>{
    'success': true,
    'message': 'KYC submitted successfully and is under compliance verification.',
    'data': <String, dynamic>{
      'referenceId': 'KYC-849201',
      'status': 'PENDING',
      'documentType': 'AADHAAR',
      'documentNumberMasked': 'XXXX XXXX 9012',
      'documentUrl': 'https://res.cloudinary.com/swastik/image/upload/kyc/sample.jpg',
      'submittedAt': '2026-09-16T10:00:00.000Z',
    },
  };

  // ---------------------------------------------------------------------------
  // 3. Scheme & Offer Fixtures
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> activeSchemesJson = <String, dynamic>{
    'success': true,
    'message': 'Active schemes retrieved.',
    'data': <String, dynamic>{
      'schemes': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'sch_12month_suvarna',
          'name': 'Swastik Suvarna Varsha',
          'targetAmount': 60000,
          'durationMonths': 12,
          'monthlyInstallment': 5000,
          'maxCapacity': 100,
          'currentMembers': 42,
          'status': 'OPEN',
          'benefits': <String>[
            '1 Month Free: 11 Paid + 12th Month 100% Jeweler Bonus Deposit',
            '25% Flat Discount on Fine Jewellery Making Charges',
            'Accumulate 24K 999 Hallmark Purity Fine Gold Monthly',
          ],
          'bannerImageUrl': 'assets/images/kitty_banner_royal_gold.jpg',
          'isPopular': true,
        },
        <String, dynamic>{
          'id': 'sch_18month_dhanvarsha',
          'name': 'Dhanvarsha Gold Plan',
          'targetAmount': 90000,
          'durationMonths': 18,
          'monthlyInstallment': 5000,
          'maxCapacity': 100,
          'currentMembers': 68,
          'status': 'OPEN',
          'benefits': <String>[
            '1.5 Months Jeweler Bonus Contribution on Maturity',
            'Zero Wastage Charges on Selected Diamond Jewellery',
          ],
          'bannerImageUrl': 'assets/images/kitty_banner_gold_coins.jpg',
          'isPopular': false,
        },
        <String, dynamic>{
          'id': 'sch_6month_express',
          'name': 'Express Suvarna Savings',
          'targetAmount': 30000,
          'durationMonths': 6,
          'monthlyInstallment': 5000,
          'maxCapacity': 50,
          'currentMembers': 31,
          'status': 'OPEN',
          'benefits': <String>[
            'Fast-track 6-month gold accumulation for festive redemption',
            'Priority Showroom Concierge Access',
          ],
          'bannerImageUrl': 'assets/images/kitty_banner_diamond_solitaire.jpg',
          'isPopular': false,
        },
      ],
    },
  };

  static const Map<String, dynamic> activeOffersJson = <String, dynamic>{
    'success': true,
    'message': 'Promotional offers retrieved.',
    'data': <String, dynamic>{
      'offers': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'off_diwali_2026',
          'title': 'Diwali Festive Jewel Privilege',
          'description': 'Zero making charges on diamond necklaces for Suvarna scheme members.',
          'code': 'DIWALI2026',
          'discountPct': 100.0,
          'validUntil': '2026-11-30T23:59:59.000Z',
          'imageUrl': 'assets/images/banner_clean_bridal.jpg',
        },
        <String, dynamic>{
          'id': 'off_making_25',
          'title': '25% Making Charge Waiver',
          'description': 'Applicable on all 22K hallmarked temple jewellery designs.',
          'code': 'SWASTIK25',
          'discountPct': 25.0,
          'validUntil': '2026-12-31T23:59:59.000Z',
          'imageUrl': 'assets/images/banner_clean_bonus.jpg',
        },
      ],
    },
  };

  static const Map<String, dynamic> joinSchemeSuccessJson = <String, dynamic>{
    'success': true,
    'message': 'Enrolled in scheme successfully.',
    'data': <String, dynamic>{
      'membership': <String, dynamic>{
        'id': 'mem_994411',
        'userId': 'usr_654321abcdef',
        'schemeId': 'sch_12month_suvarna',
        'schemeName': 'Swastik Suvarna Varsha',
        'tokenNumber': 42,
        'tokenString': '#SW-042',
        'customMonthlyEmi': 5000,
        'targetAmount': 60000,
        'totalPaidAmount': 0,
        'status': 'ACTIVE',
        'joinedAtMonth': 1,
      },
    },
  };

  // ---------------------------------------------------------------------------
  // 4. Dashboard & Passbook Fixtures
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> dashboardActiveSuvarnaJson = <String, dynamic>{
    'success': true,
    'message': 'Dashboard data retrieved.',
    'data': <String, dynamic>{
      'hasActiveScheme': true,
      'dashboard': <String, dynamic>{
        'membershipId': 'mem_994411',
        'chitToken': '#SW-042',
        'schemeName': 'Swastik Swarna Varsha',
        'targetAmount': 60000,
        'customMonthlyEmi': 5000,
        'totalMonths': 12,
        'monthsPaid': 8,
        'totalPaidAmount': 40000,
        'remainingAmount': 15000,
        'accumulatedGoldGrams': 5.482,
        'currentValuation': 41036,
        'valuationGainPct': 2.59,
        'nextInstallment': <String, dynamic>{
          'month': 9,
          'amount': 5000,
          'dueDate': '2026-09-15T00:00:00.000Z',
          'daysRemaining': 5,
        },
        'passbook': <Map<String, dynamic>>[
          <String, dynamic>{
            'month': 1,
            'label': 'Month 1',
            'amount': 5000,
            'status': 'PAID',
            'paidAt': '2026-01-15T10:30:00.000Z',
            'paymentMethod': 'ONLINE',
            'transactionId': 'TXN-SW-10821',
            'goldGrams': 0.702,
            'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10821.pdf',
          },
          <String, dynamic>{
            'month': 2,
            'label': 'Month 2',
            'amount': 5000,
            'status': 'PAID',
            'paidAt': '2026-02-15T11:15:00.000Z',
            'paymentMethod': 'ONLINE',
            'transactionId': 'TXN-SW-10822',
            'goldGrams': 0.695,
            'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10822.pdf',
          },
          <String, dynamic>{
            'month': 3,
            'label': 'Month 3',
            'amount': 5000,
            'status': 'PAID',
            'paidAt': '2026-03-15T09:45:00.000Z',
            'paymentMethod': 'ONLINE',
            'transactionId': 'TXN-SW-10823',
            'goldGrams': 0.688,
            'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10823.pdf',
          },
          <String, dynamic>{
            'month': 4,
            'label': 'Month 4',
            'amount': 5000,
            'status': 'PAID',
            'paidAt': '2026-04-15T14:20:00.000Z',
            'paymentMethod': 'CASH',
            'transactionId': 'TXN-SW-10824',
            'goldGrams': 0.684,
            'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10824.pdf',
          },
          <String, dynamic>{
            'month': 5,
            'label': 'Month 5',
            'amount': 5000,
            'status': 'PAID',
            'paidAt': '2026-05-15T16:00:00.000Z',
            'paymentMethod': 'ONLINE',
            'transactionId': 'TXN-SW-10825',
            'goldGrams': 0.679,
            'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10825.pdf',
          },
          <String, dynamic>{
            'month': 6,
            'label': 'Month 6',
            'amount': 5000,
            'status': 'PAID',
            'paidAt': '2026-06-15T12:10:00.000Z',
            'paymentMethod': 'ONLINE',
            'transactionId': 'TXN-SW-10826',
            'goldGrams': 0.681,
            'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10826.pdf',
          },
          <String, dynamic>{
            'month': 7,
            'label': 'Month 7',
            'amount': 5000,
            'status': 'PAID',
            'paidAt': '2026-07-15T15:30:00.000Z',
            'paymentMethod': 'ONLINE',
            'transactionId': 'TXN-SW-10827',
            'goldGrams': 0.675,
            'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10827.pdf',
          },
          <String, dynamic>{
            'month': 8,
            'label': 'Month 8',
            'amount': 5000,
            'status': 'PAID',
            'paidAt': '2026-08-15T10:05:00.000Z',
            'paymentMethod': 'ONLINE',
            'transactionId': 'TXN-SW-10828',
            'goldGrams': 0.678,
            'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10828.pdf',
          },
          <String, dynamic>{
            'month': 9,
            'label': 'Month 9',
            'amount': 5000,
            'status': 'CURRENT',
            'dueDate': '2026-09-15T00:00:00.000Z',
          },
          <String, dynamic>{
            'month': 10,
            'label': 'Month 10',
            'amount': 5000,
            'status': 'UPCOMING',
            'dueDate': '2026-10-15T00:00:00.000Z',
          },
          <String, dynamic>{
            'month': 11,
            'label': 'Month 11',
            'amount': 5000,
            'status': 'UPCOMING',
            'dueDate': '2026-11-15T00:00:00.000Z',
          },
          <String, dynamic>{
            'month': 12,
            'label': 'Month 12',
            'amount': 5000,
            'status': 'BONUS',
            'bonusNote': '100% Jeweler Bonus Deposit on completion',
          },
        ],
      },
    },
  };

  static const Map<String, dynamic> dashboardEmptyJson = <String, dynamic>{
    'success': true,
    'message': 'No active scheme found for user.',
    'data': <String, dynamic>{
      'hasActiveScheme': false,
      'dashboard': null,
    },
  };

  // ---------------------------------------------------------------------------
  // 5. Payment Fixtures
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> paymentInitiateSuccessJson = <String, dynamic>{
    'success': true,
    'message': 'Payment order initiated.',
    'data': <String, dynamic>{
      'orderId': 'gokwik_ord_771829',
      'paymentId': 'pay_662819',
      'amount': 5000,
      'currency': 'INR',
      'merchantKey': 'mock_gokwik_mid_swastik',
    },
  };

  static const Map<String, dynamic> paymentStatusPendingJson = <String, dynamic>{
    'success': true,
    'message': 'Payment is under bank verification.',
    'data': <String, dynamic>{
      'orderId': 'gokwik_ord_771829',
      'status': 'PENDING',
      'transactionId': null,
      'receiptUrl': null,
      'totalPaidAmount': 40000,
      'monthsPaid': 8,
    },
  };

  static const Map<String, dynamic> paymentStatusSuccessJson = <String, dynamic>{
    'success': true,
    'message': 'Payment verified and credited to gold scheme vault.',
    'data': <String, dynamic>{
      'orderId': 'gokwik_ord_771829',
      'status': 'SUCCESS',
      'transactionId': 'TXN-SW-50291',
      'receiptUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_50291.pdf',
      'totalPaidAmount': 45000,
      'monthsPaid': 9,
    },
  };

  static const Map<String, dynamic> paymentStatusFailedJson = <String, dynamic>{
    'success': false,
    'message': 'Payment declined by bank or cancelled.',
    'data': <String, dynamic>{
      'orderId': 'gokwik_ord_771829',
      'status': 'FAILED',
      'transactionId': null,
      'receiptUrl': null,
      'totalPaidAmount': 40000,
      'monthsPaid': 8,
    },
  };

  static const Map<String, dynamic> paymentStatusCancelledJson = <String, dynamic>{
    'success': false,
    'message': 'Payment cancelled by patron.',
    'data': <String, dynamic>{
      'orderId': 'gokwik_ord_771829',
      'status': 'CANCELLED',
      'transactionId': null,
      'receiptUrl': null,
      'totalPaidAmount': 40000,
      'monthsPaid': 8,
    },
  };

  // ---------------------------------------------------------------------------
  // 6. Live Gold Rate Fixtures (3-Decimal Precision)
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> liveGoldRateJson = <String, dynamic>{
    'success': true,
    'message': 'Live gold rate retrieved.',
    'data': <String, dynamic>{
      'ratePerGram': 15268.000,
      'silverRatePerGram': 92.500,
      'purity': '24K (999)',
      'purityFraction': 0.999,
      'currency': 'INR',
      'change24h': -16.000,
      'changePct': -0.10,
      'isUp': false,
      'updatedAt': '2026-09-26T09:40:00.000Z',
    },
  };

  // ---------------------------------------------------------------------------
  // 7. Curated Products & Catalog Fixtures
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> curatedProductsJson = <String, dynamic>{
    'success': true,
    'message': 'Curated jewellery catalog retrieved.',
    'data': <String, dynamic>{
      'categories': <String>[
        'All',
        'Gold Necklaces',
        'Diamond Rings',
        'Bangles & Kadas',
        'Pendants',
        'Earrings',
      ],
      'products': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'prod_necklace_01',
          'title': 'Royal Mayura Gold Choker',
          'category': 'Gold Necklaces',
          'purity': '22K Hallmarked',
          'weightGrams': 28.450,
          'estimatedPrice': 218500,
          'makingDiscountPct': 25.0,
          'imageUrl': 'assets/images/cat_necklace.jpg',
          'isNew': true,
        },
        <String, dynamic>{
          'id': 'prod_ring_02',
          'title': 'Solitaire Diamond Band',
          'category': 'Diamond Rings',
          'purity': '18K Rose Gold & VVS Diamond',
          'weightGrams': 4.120,
          'estimatedPrice': 84900,
          'makingDiscountPct': 30.0,
          'imageUrl': 'assets/images/prod_solitaire_ring.jpg',
          'isNew': false,
        },
        <String, dynamic>{
          'id': 'prod_bangles_03',
          'title': 'Heritage Temple Bangles (Pair)',
          'category': 'Bangles & Kadas',
          'purity': '22K Antique Finish',
          'weightGrams': 42.100,
          'estimatedPrice': 324000,
          'makingDiscountPct': 20.0,
          'imageUrl': 'assets/images/prod_twisted_bangle.jpg',
          'isNew': true,
        },
        <String, dynamic>{
          'id': 'prod_pendant_04',
          'title': 'Ananya Emerald Pear Pendant',
          'category': 'Pendants',
          'purity': '22K Hallmark Gold • Zambian Emerald',
          'weightGrams': 6.250,
          'estimatedPrice': 46800,
          'makingDiscountPct': 20.0,
          'imageUrl': 'assets/images/prod_pear_pendant.jpg',
          'isNew': true,
        },
        <String, dynamic>{
          'id': 'prod_earrings_05',
          'title': 'Mayuri Royal Polki Jhumkas',
          'category': 'Earrings',
          'purity': '22K Handcrafted Kundan & Pearls',
          'weightGrams': 14.800,
          'estimatedPrice': 94500,
          'makingDiscountPct': 25.0,
          'imageUrl': 'assets/images/cat_earrings.jpg',
          'isNew': false,
        },
        <String, dynamic>{
          'id': 'prod_halo_06',
          'title': 'Celestial Halo Diamond Ring',
          'category': 'Diamond Rings',
          'purity': '18K White Gold • Solitaire & Halo',
          'weightGrams': 5.300,
          'estimatedPrice': 112000,
          'makingDiscountPct': 30.0,
          'imageUrl': 'assets/images/prod_halo_ring.jpg',
          'isNew': true,
        },
      ],
    },
  };

  // ---------------------------------------------------------------------------
  // 8. Notifications Fixtures
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> notificationsListJson = <String, dynamic>{
    'success': true,
    'message': 'Notifications retrieved.',
    'data': <String, dynamic>{
      'notifications': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'notif_001',
          'title': 'Month 8 Installment Verified 🎉',
          'message': '₹5,000 paid successfully. +0.678g 24K gold credited to your vault.',
          'type': 'TRANSACTION',
          'isRead': false,
          'createdAt': '2026-08-15T10:06:00.000Z',
          'actionRoute': '/passbook',
        },
        <String, dynamic>{
          'id': 'notif_002',
          'title': 'Month 9 EMI Due Reminder 🔔',
          'message': 'Your monthly installment of ₹5,000 is due on 15 Sep 2026.',
          'type': 'SCHEME',
          'isRead': false,
          'createdAt': '2026-09-10T08:00:00.000Z',
          'actionRoute': '/checkout',
        },
        <String, dynamic>{
          'id': 'notif_003',
          'title': 'Festive Making Charge Privileges ✨',
          'message': 'Avail flat 25% waiver on making charges this festive season.',
          'type': 'OFFER',
          'isRead': true,
          'createdAt': '2026-09-01T12:00:00.000Z',
          'actionRoute': '/offers',
        },
        <String, dynamic>{
          'id': 'notif_004',
          'title': 'Vault Security Verification 🛡️',
          'message': 'Biometric MPIN lock configured successfully for high-value vault transactions.',
          'type': 'SYSTEM',
          'isRead': false,
          'createdAt': '2026-08-20T14:30:00.000Z',
          'actionRoute': '/settings',
        },
        <String, dynamic>{
          'id': 'notif_005',
          'title': 'Annual Swastik Mahotsav Privileges 👑',
          'message': 'VIP priority pass and complimentary appraisal certificate for the upcoming exhibition.',
          'type': 'UNKNOWN',
          'isRead': true,
          'createdAt': '2026-08-01T09:15:00.000Z',
          'actionRoute': '/offers',
        },
      ],
    },
  };

  // ---------------------------------------------------------------------------
  // 9. Digital Receipt Fixtures
  // ---------------------------------------------------------------------------

  static const Map<String, dynamic> digitalReceiptJson = <String, dynamic>{
    'success': true,
    'message': 'Digital tax invoice receipt retrieved.',
    'data': <String, dynamic>{
      'receiptId': 'rec_10821',
      'invoiceNumber': 'INV-SW-2026-10821',
      'transactionId': 'TXN-SW-10821',
      'patronName': 'Aarav Sharma',
      'phone': '+919876543210',
      'schemeName': 'Swastik Suvarna Varsha (12 Months)',
      'chitToken': '#SW-042',
      'monthNumber': 1,
      'amount': 5000,
      'goldGramsAllocated': 0.327,
      'goldRatePerGram': 15268.000,
      'paymentMethod': 'ONLINE',
      'paidAt': '2026-01-15T10:30:00.000Z',
      'pdfUrl': 'https://res.cloudinary.com/swastik/image/upload/receipts/rec_10821.pdf',
      'cashierName': 'Swastik Jewellers Central Vault',
    },
  };
}
