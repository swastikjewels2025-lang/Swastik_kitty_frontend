# In-App Notifications Specification

**Project**: Swastik Jewellers Kitty Savings App  
**Location**: `kitty_frontend/kitty_docs/04_API/NOTIFICATIONS_SPECIFICATION.md`  
**Status**: Complete Specification  

---

## 1. Domain Concept

The **Notifications Feed** delivers real-time operational, transactional, and promotional alerts to patrons:
1. **EMI Due Reminders**: Prompting patrons 5 days and 1 day prior to the 15th of the month due date.
2. **Payment & Receipt Receipts**: Immediate confirmation when a monthly installment is successfully credited.
3. **Monthly Lucky Draw Announcements**: Real-time notification when lucky winners are selected during monthly chit draws.
4. **Bullion Market Alerts**: Daily morning notification when gold rates shift favorably.
5. **System / Compliance Alerts**: Reminders to submit or update KYC documentation.

---

## 2. Endpoints Specification

### 2.1 Get Notifications Feed
* **Endpoint**: `GET /api/v1/notifications`
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Notifications retrieved.",
    "data": {
      "unreadCount": 2,
      "notifications": [
        {
          "id": "NTF-101",
          "title": "Monthly Installment Due",
          "body": "Month 9 installment of ₹10,000 for Swastik Royal Gold is due on Oct 15.",
          "type": "EMI_DUE",
          "isRead": false,
          "actionRoute": "/checkout",
          "createdAt": "2026-10-06T09:00:00.000Z"
        },
        {
          "id": "NTF-102",
          "title": "Payment Received",
          "body": "₹10,000 credited for Month 8. 1.336 grams gold added to your passbook.",
          "type": "PAYMENT_SUCCESS",
          "isRead": false,
          "actionRoute": "/passbook",
          "createdAt": "2026-09-14T11:20:00.000Z"
        }
      ]
    }
  }
  ```

### 2.2 Mark Single Notification Read
* **Endpoint**: `PATCH /api/v1/notifications/:id/read`
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Path Parameter**: `id` (e.g. `NTF-101`).
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Notification marked as read.",
    "data": { "unreadCount": 1 }
  }
  ```

### 2.3 Mark All Notifications Read
* **Endpoint**: `PATCH /api/v1/notifications/read-all`
* **Implementation Status**: `[REQUIRED / NOT CURRENTLY IMPLEMENTED IN SWASTIK_KITTY_BACKEND]`
* **Auth Required**: Yes (`Authorization: Bearer <TOKEN>`)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "All notifications marked as read.",
    "data": { "unreadCount": 0 }
  }
  ```

---

## 3. Frontend Usage

* **Screen**: `lib/features/notifications/presentation/screens/notifications_screen.dart`
* **Badge Trigger**: `lib/shared/widgets/navigation/header_nav_bar.dart` (Top-right bell icon with red unread count badge).
* **Mock Provider**: Currently bound to `MockNotificationRepository`; ready for drop-in remote Dio integration once backend adds `/notifications` routes.
