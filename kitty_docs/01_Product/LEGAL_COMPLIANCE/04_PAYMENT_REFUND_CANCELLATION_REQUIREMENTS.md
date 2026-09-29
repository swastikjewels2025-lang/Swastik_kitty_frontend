# Payment, Refund & Cancellation Requirements — Kitty App

**Project**: Swastik Jewellers Kitty App (Sub-Brand: Kitty Vault)  
**Primary Codebase**: `D:\kitty_app\`  
**Document Status**: Synchronized with Current Implementation  
**Last Audit Date**: 2026-09-23  

---

## 1. RBI e-Mandate & Payment Gateway Guidelines

The application integrates with GoKwik for processing customer payments. Compliance with Reserve Bank of India (RBI) circulars on recurring payments and e-mandates requires:

1. **Pre-Debit Notifications**:
   - For recurring auto-debit payments (UPI AutoPay), patrons must receive an SMS/WhatsApp reminder at least 24 hours prior to the installment debit date.
2. **One-Time Mandate Registration (AFA)**:
   - Registration of recurring mandates requires Additional Factor of Authentication (AFA/OTP).
3. **Transparent Payment Fees**:
   - No hidden convenience fees or gateway surcharges may be levied without explicit itemized disclosure on the checkout sheet.

---

## 2. Cancellation & Refund Policy

1. **No Cash Refunds on Advance Gold Purchases**:
   - To prevent violation of the BUDS Act 2019 and deposit acceptance rules, customer advances are non-refundable in cash once accumulated into gold weight.
   - Refunds are issued strictly in the form of **Swastik Jewellers Store Credit / Jewelry Purchase Vouchers**.
2. **Early Exit Before Month 11**:
   - If a customer chooses to terminate enrollment prematurely:
     - All deposited principal is fully credited towards jewelry purchases.
     - The Month 12 jeweler bonus is forfeited.
3. **Failed / Double-Debit Reconciliation**:
   - If a customer's bank account is debited but the gateway reports a timeout or failure, the funds are automatically reversed by the acquiring bank within T+3 business days per RBI turnaround guidelines.

---

## 3. Doorstep Cash Pickup ("Pick Cash") Terms & Disclosures

1. **Statutory Non-Negotiable Cash Limit**:
   - Cash collections are strictly capped at **₹1,99,999** per transaction per day per patron in accordance with Section 269ST of the Income Tax Act.
2. **Mandatory Identity & OTP Handover**:
   - Cash will be collected only from the verified patron or an authorized adult representative at the registered address.
   - The patron must inspect the Swastik official photo ID badge of the security executive and communicate the **6-digit Handover OTP** to execute physical custody transfer.
3. **Official Digital Acknowledgement**:
   - Upon courier OTP confirmation, an instant digital receipt is generated in the patron's passbook. Patrons must not hand over physical currency without receiving the in-app confirmation.
4. **No Cash Refund Principle**:
   - In accordance with BUDS Act 2019 compliance, cash collected for kitty scheme installments is credited towards the patron's gold purchase advance and is non-refundable in cash.

