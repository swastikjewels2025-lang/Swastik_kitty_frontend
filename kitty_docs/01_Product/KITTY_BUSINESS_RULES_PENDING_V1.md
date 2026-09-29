# Kitty Business Rules & Decisions Pending V1

**Target Stakeholders**: Swastik Jewellers Executive Management, Legal Counsel, Lead Backend Architect  
**Document Status**: Official Business Policy & Decision Checklist (V1)  
**Effective Date**: 2026-09-29  

> [!WARNING]
> **STRICT DIRECTIVE FOR SOFTWARE ENGINEERS**:  
> The items cataloged in this document represent commercial, statutory, and legal policies of Swastik Jewellers.  
> **Neither the backend engineer nor the Flutter engineer is authorized to assume or invent these rules.**  
> Development on the dependent features (Future Reservation, Early Full Settlement, Non-Consecutive Payments) must remain blocked until formal sign-off is recorded in the table below.

---

## 1. Master Business Policy Sign-off Matrix

| # | Business Policy Area | Specific Question to Resolve | Options Available | Management Decision | Status |
| :-: | :--- | :--- | :--- | :--- | :---: |
| **BR-01** | **Kitty Group Capacity** | How many members constitute a single Kitty group? | **A**: Exactly 50 members.<br>**B**: Exactly 100 members.<br>**C**: Dynamic per scheme. | *Pending Sign-off* | 🟡 PENDING |
| **BR-02** | **Lucky Number Selection** | Can a patron pick any number, or is it strictly 1 to N? | **A**: Sequential 1 to Capacity (e.g. 1–50).<br>**B**: Custom alphanumeric tokens allowed. | *Pending Sign-off* | 🟡 PENDING |
| **BR-03** | **Reservation Deposit (₹100)** | Is the ₹100 token deposit for upcoming groups refundable? | **A**: Non-refundable administrative fee.<br>**B**: 100% refundable if cancelled 7 days prior.<br>**C**: Converted to showroom jewellery credit. | *Pending Sign-off* | 🔴 BLOCKED |
| **BR-04** | **Reservation Adjustment** | How is the ₹100 deposit adjusted when the group opens? | **A**: Deducted from Month 1 (pay ₹4,900 instead of ₹5,000).<br>**B**: Month 1 is full ₹5,000; ₹100 credited to making charges. | *Pending Sign-off* | 🔴 BLOCKED |
| **BR-05** | **Reservation Expiry** | How many days does a patron have to pay Month 1 once group launches? | **A**: 3 calendar days.<br>**B**: 5 calendar days (Recommended).<br>**C**: 7 calendar days. | *Pending Sign-off* | 🟡 PENDING |
| **BR-06** | **Consecutive Installments** | Can a customer pay Month 10 if Month 9 was missed? | **A**: Strictly No; must pay chronological arrears first.<br>**B**: Yes, arbitrary months can be paid. | *Recommendation: Strictly Option A* | 🟡 PENDING |
| **BR-07** | **Early Full Settlement Bonus** | If all 11 customer months are paid early (e.g. Month 8), does Swastik still pay the 12th-month bonus? | **A**: Yes, full bonus awarded upon total deposit.<br>**B**: Pro-rated bonus based on time elapsed.<br>**C**: No bonus if completed before Month 10. | *Pending Sign-off* | 🔴 BLOCKED |
| **BR-08** | **Jewellery Redemption Date** | If full balance is paid early, when can the customer claim jewellery from showroom? | **A**: Immediately next day.<br>**B**: Only after 12 calendar months have elapsed (BUDS statutory compliance). | *Legal Review Required* | 🔴 BLOCKED |
| **BR-09** | **Gold Allocation on Lump Sum** | When ₹15,000 is paid on a single day for 3 months, how is gold weight allocated? | **A**: All 3 months converted at today's 24K rate.<br>**B**: Cash held in escrow and converted on 5th of each remaining month. | *Pending Sign-off* | 🟡 PENDING |
| **BR-10** | **Concurrent Scheme Cap** | What is the maximum number of active Kitty schemes a single patron can hold? | **A**: Maximum 2 schemes.<br>**B**: Maximum 5 schemes (Recommended).<br>**C**: Unlimited. | *Pending Sign-off* | 🟡 PENDING |
| **BR-11** | **Doorstep Cash Pickup ("Pick Cash")** | What is the maximum cash limit per pickup without PAN requirement? | **A**: ₹49,999 (Indian Income Tax Rule 114B limit).<br>**B**: Showroom counter discretion. | *Strictly Option A (Statutory)* | 🟢 RESOLVED |
| **BR-12** | **Pick Cash Service Charge** | Is doorstep cash collection free or is there a nominal executive visit fee? | **A**: 100% Free VIP privilege for Swastik patrons.<br>**B**: Nominal ₹50 fee added to payment. | *Pending Sign-off* | 🟡 PENDING |

---

## 2. Executive Sign-Off Section

When management makes a formal determination on the pending items above, record the resolution date, decision, and signature here:

```text
Formal Approval Authority:
Name: _________________________________________
Title: Managing Director / Compliance Head, Swastik Jewellers
Date:  _________________________________________
Signature: _____________________________________
```
