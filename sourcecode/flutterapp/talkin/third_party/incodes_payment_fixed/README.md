# InCodes Payment

This project integrates multiple payment gateways into Flutter.  
Each section explains the **gateway name**, **methods included**, and **how they work**.

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

## 🚀 Stripe Payment Integration

This module provides integration with **Stripe** using the [`flutter_stripe`](https://pub.dev/packages/flutter_stripe) package.

It allows you to create payment intents, open the Stripe PaymentSheet, and handle success/failure callbacks with optional custom toast/snackbar messages.

---

### 🔑 Features
- Initialize Stripe in **test** or **live** mode.
- Create **PaymentIntent** with Stripe’s REST API.
- Open **Stripe PaymentSheet** (supports Apple Pay & Google Pay).
- Handle **success** and **failure** with callbacks.
- Default or custom toast/snackbar handling.

---

### ⚙️ Methods

#### 1. `init({required bool isTest, required String publishableKey})`
Initializes the Stripe SDK.

**Parameters:**
- `isTest`: `true` for test mode, `false` for live mode.
- `publishableKey`: Your Stripe **Publishable Key**.

---

#### 2. `stripePay({...})`
Opens the Stripe payment flow.

**Parameters:**
- `amount`: Amount in the **smallest currency unit** (e.g. cents for USD).
- `currency`: Currency code (e.g. `"USD"`, `"INR"`).
- `secretKey`: Your Stripe **Secret Key** (used to create PaymentIntent).
- `merchantCountryCode`: Country code (for Apple Pay/Google Pay).
- `merchantDisplayName`: Merchant/business name displayed in payment sheet.
- `paymentGatewayName`: Gateway name for logging/toast (default `"Stripe"`).
- `description`: (Optional) Payment description.
- `onShowToast`: (Optional) Custom toast/snackbar/dialog function.
- `onPaymentSuccess`: (Optional) Callback when payment succeeds.
- `onPaymentFailure`: (Optional) Callback when payment fails.

---

### 🔄 Flow of Stripe Payment

1. **Initialize Stripe** with publishable key.
2. **Create PaymentIntent** via Stripe API using secret key.
3. **Initialize PaymentSheet** with PaymentIntent client secret.
4. **Present PaymentSheet** to complete the transaction.
5. Handle response:
    - ✅ Success → `IncodesListener().onSuccess()`
    - ❌ Failure/Cancel → `IncodesListener().onFailure()`

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

## 💳 Razorpay Payment Integration  

This module integrates **Razorpay** using the [`razorpay_flutter`](https://pub.dev/packages/razorpay_flutter) package.  

It manages checkout flow, success/failure handling, and external wallet selection with both **default toast (via `IncodesListener`)** and **custom user-provided callbacks**.  

---

### 🔑 Features  
- Open **Razorpay Checkout** with user details (email, phone).  
- Handle events:  
  - ✅ Payment Success  
  - ❌ Payment Failure  
  - 💼 External Wallet Selection (Paytm, PhonePe, Mobikwik, etc.)  
- Custom or default toast/snackbar support.  
- Exposes callbacks for API calls after events.  
- Dispose listeners safely to avoid memory leaks.  

---

### ⚙️ Methods  

#### 1. `openRazorpay({...})`  
Opens Razorpay checkout.  

**Parameters:**  
- `contactNumber`: Customer phone number (prefilled).  
- `emailId`: Customer email address (prefilled).  
- `razorpayKey`: Your Razorpay **Public Key**.  
- `currency`: Your Razorpay **USD**.  
- `amount`: Payment amount in **USD** (converted to USD internally).  
- `appName`: Business/app display name.  
- `description`: (Optional) Payment/order description.  
- `colorCode`: (Optional) Theme color (default: green `#0CA72F`).  
- `paymentGatewayName`: Name for logs/toast (default `"Razorpay"`).  
- `onShowToast`: (Optional) Custom toast/snackbar/dialog handler.  
- `onPaymentSuccess`: (Optional) Called after successful payment.  
- `onPaymentFailure`: (Optional) Called after failed payment.  
- `onExternalWallet`: (Optional) Called when user selects an external wallet.  

---

#### 2. `dispose()`  
Cleans up Razorpay listeners.  
Should be called when the screen is disposed to prevent memory leaks.  

---

### 🔄 Flow of Razorpay Payment  

1. **Setup checkout options** (key, amount, user info, theme, wallets).  
2. **Open Razorpay Checkout**.  
3. Handle events:  
   - ✅ Success → `IncodesListener().onSuccess()`  
   - ❌ Failure → `IncodesListener().onFailure()`  
   - 💼 External Wallet → `IncodesListener().onSuccess()` with wallet details  
4. Callbacks (`onPaymentSuccess`, `onPaymentFailure`, `onExternalWallet`) are triggered if provided.

---

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

## 🅿️ PayPal Payment Integration

This module integrates **PayPal** using the [`flutter_paypal_payment`](https://pub.dev/packages/flutter_paypal_payment) package.

It manages checkout with PayPal, handles success/failure/cancel events, and provides default or custom toast/snackbar handling.

---

### 🔑 Features
- Open **PayPal Checkout** with clientId, secretKey, and transaction details.
- Supports **sandbox** and **live** mode.
- Handle events:
    - ✅ Payment Success
    - ❌ Payment Failure
    - 🚫 Payment Cancel
- Custom or default toast/snackbar handling.
- Exposes callbacks for API calls after payment events.

---

### ⚙️ Methods

#### 1. `openPaypal({...})`
Opens the PayPal checkout screen.

**Parameters:**
- `context`: Flutter **BuildContext** (required for navigation).
- `clientId`: PayPal **Client ID**.
- `secretKey`: PayPal **Secret Key**.
- `transactions`: List of transactions to be paid.
- `sandboxMode`: `true` for sandbox (default), `false` for live mode.
- `note`: (Optional) Note to show in checkout.
- `paymentGatewayName`: Gateway name for logs/toast (default `"PayPal"`).
- `onShowToast`: (Optional) Custom toast/snackbar/dialog handler.
- `onPaymentSuccess`: (Optional) Callback when payment succeeds.
- `onPaymentFailure`: (Optional) Callback when payment fails.
- `onPaymentCancel`: (Optional) Callback when payment is cancelled.

---

### 🔄 Flow of PayPal Payment

1. **Navigate to PayPal Checkout View** with given credentials and transactions.
2. **Process Payment** via PayPal UI.
3. Handle events:
    - ✅ Success → `IncodesListener().onSuccess()`
    - ❌ Failure → `IncodesListener().onFailure()`
    - 🚫 Cancel → `IncodesListener().onFailure()`
4. Callbacks (`onPaymentSuccess`, `onPaymentFailure`, `onPaymentCancel`) are triggered if provided.

---

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

## 💰 Paystack Payment Integration

This module integrates **Paystack** using the [`pay_with_paystack`](https://pub.dev/packages/pay_with_paystack) package.

It manages checkout with Paystack, handles success/failure, and provides default or custom toast/snackbar handling.

---

### 🔑 Features
- Open **Paystack Checkout** with customer details and amount.
- Supports transactions in **NGN** (default) or other currencies.
- Handle events:
    - ✅ Payment Success
    - ❌ Payment Failure
- Generates a **unique transaction reference** automatically.
- Custom or default toast/snackbar handling.
- Exposes callbacks for API calls after events.

---

### ⚙️ Methods

#### 1. `openPaystack({...})`
Opens the Paystack checkout screen.

**Parameters:**
- `context`: Flutter **BuildContext** (required for navigation).
- `secretKey`: Paystack **Secret Key**.
- `customerEmail`: Customer email ID.
- `amount`: Payment amount in **kobo** (₦200 = `20000`).
- `currency`: (Optional) Currency code (default `"NGN"`).
- `callbackUrl`: (Optional) Callback URL (default: `"https://google.com"`).
- `paymentGatewayName`: Gateway name for logs/toast (default `"Pay stack"`).
- `onShowToast`: (Optional) Custom toast/snackbar/dialog handler.
- `onPaymentSuccess`: (Optional) Callback when payment succeeds.
- `onPaymentFailure`: (Optional) Callback when payment fails.

---

### 🔄 Flow of Paystack Payment

1. **Generate unique transaction reference**.
2. **Open Paystack Checkout** with amount, currency, and customer details.
3. Handle events:
    - ✅ Success → `IncodesListener().onSuccess()` with payment reference.
    - ❌ Failure → `IncodesListener().onFailure()` with error reason.
4. Callbacks (`onPaymentSuccess`, `onPaymentFailure`) are triggered if provided.

---

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

## 🌍 Flutterwave Payment Integration

This module integrates **Flutterwave** using the [`flutterwave_standard`](https://pub.dev/packages/flutterwave_standard) package.

It manages checkout with Flutterwave, supports multiple payment options, and handles success/failure with default or custom toast/snackbar handling.

---

### 🔑 Features
- Open **Flutterwave Checkout** with customer details and amount.
- Supports **multiple payment methods**: USSD, Card, Barter, Pay Attitude, etc.
- Handle events:
    - ✅ Payment Success
    - ❌ Payment Failure
- Generates a **unique transaction reference** automatically.
- Works in **Test Mode** or **Live Mode**.
- Custom or default toast/snackbar handling.
- Exposes callbacks for API calls after events.

---

### ⚙️ Methods

#### 1. `openFlutterWave({...})`
Opens the Flutterwave checkout screen.

**Parameters:**
- `context`: Flutter **BuildContext** (required for navigation).
- `publicKey`: Flutterwave **Public Key**.
- `currency`: Currency code (e.g., `"NGN"`, `"USD"`).
- `amount`: Payment amount as a string.
- `customerName`: Full name of the customer.
- `customerEmail`: Customer email address.
- `customerPhone`: (Optional) Customer phone number.
- `redirectUrl`: (Optional) Callback redirect URL (default `"https://www.google.com/"`).
- `paymentOptions`: Payment methods (default `"ussd, card, barter, pay attitude"`).
- `title`: Title displayed on the checkout screen (default `"Payment SDK"`).
- `paymentGatewayName`: Gateway name for logs/toast (default `"Flutter wave"`).
- `isTestMode`: (Optional) Boolean to enable **test mode** (default `true`).
- `onShowToast`: (Optional) Custom toast/snackbar/dialog handler.
- `onPaymentSuccess`: (Optional) Callback when payment succeeds.
- `onPaymentFailure`: (Optional) Callback when payment fails.

---

### 🔄 Flow of Flutterwave Payment

1. **Create Customer object** with name, email, phone.
2. **Generate unique transaction reference (TX-...)**.
3. **Open Flutterwave Checkout** with payment options and amount.
4. Handle events:
    - ✅ Success → `IncodesListener().onSuccess()` with transaction ID.
    - ❌ Failure → `IncodesListener().onFailure()` with error reason.
5. Callbacks (`onPaymentSuccess`, `onPaymentFailure`) are triggered if provided.

---

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

## 💳 Cashfree Payment Integration

This module integrates **Cashfree** using the [`flutter_cashfree_pg_sdk`](https://pub.dev/packages/flutter_cashfree_pg_sdk) package.

It creates a payment session with Cashfree API, opens checkout with multiple payment modes, and handles success/failure events.

---

### 🔑 Features
- Open **Cashfree Checkout** with customer details and amount.
- Supports multiple payment modes: **Card, UPI, NetBanking**.
- Generates a **unique session & order ID** via Cashfree API.
- Customizable **checkout theme**.
- Handles events:
    - ✅ Payment Success
    - ❌ Payment Failure
- Sandbox and Production environments supported.
- Custom or default toast/snackbar handling.
- Exposes callbacks for API calls after events.

---

### ⚙️ Methods

#### 1. `openCashfree({...})`
Opens the Cashfree checkout screen.

**Parameters:**
- `context`: Flutter **BuildContext** (required for navigation).
- `clientId`: Cashfree **Client ID**.
- `clientSecret`: Cashfree **Client Secret**.
- `amount`: Payment amount (double).
- `currency`: Currency code (e.g., `"INR"`).
- `customerName`: Full name of the customer.
- `customerEmail`: Customer email address.
- `customerPhone`: Customer phone number.
- `returnUrl`: (Optional) Redirect URL after payment.
- `paymentGatewayName`: Gateway name for logs/toast (default `"Cashfree"`).
- `isSandbox`: Boolean to enable sandbox mode (default `true`).
- `onShowToast`: (Optional) Custom toast/snackbar/dialog handler.
- `onPaymentSuccess`: (Optional) Callback when payment succeeds.
- `onPaymentFailure`: (Optional) Callback when payment fails.

---

### 🔄 Flow of Cashfree Payment

1. **Create Payment Session** using `clientId` and `clientSecret` (API call to Cashfree).
2. If session created successfully → proceed, else return failure.
3. **Configure Payment Components** (Card, UPI, NetBanking).
4. **Set Checkout Theme** (colors, fonts).
5. **Build Checkout Payment** object.
6. **Set Callbacks**:
    - ✅ Success → `IncodesListener().onSuccess()` with order ID.
    - ❌ Failure → `IncodesListener().onFailure()` with error message.
7. **Start Payment** → Cashfree checkout opens for user.


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

## 🛒 In-App Purchase (IAP) Integration

This module integrates **In-App Purchases** for both **Android (Google Play)** and **iOS (App Store)** using the [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) plugin.

It manages subscriptions, restores purchases, validates receipts (especially for iOS), and handles success/error states.

---

### 🔑 Features
- Supports **subscriptions & consumables**.
- Works on **Android & iOS**.
- Handles purchase states:
    - ⏳ Pending
    - ✅ Success
    - ❌ Error / Canceled
    - 🔄 Restored purchases
- **Receipt validation**:
    - iOS → Verified with **Apple’s production/sandbox servers**.
    - Android → Direct purchase validation (with Google).
- Provides callbacks via `IAPCallback`.
- Restores already purchased items.
- Handles **expired** and **invalid receipts**.
- Includes **custom error handling** and toast messages.

---

### ⚙️ Key Classes & Methods

#### 1. `IAPCallback`
Defines callback methods for purchase events:
- `onLoaded(bool initialized)` → Store initialized.
- `onPending(PurchaseDetails product)` → Purchase pending.
- `onSuccessPurchase(PurchaseDetails product)` → Successful purchase.
- `onBillingError(dynamic error)` → Error occurred.

---

#### 2. `InAppPurchaseHelper`
Singleton class to handle all IAP operations.

**Important Methods:**

- `init({...})` → Initialize with amount, userId, product IDs, etc.
- `initialize()` → Setup IAP (Android/iOS).
- `getAlreadyPurchaseItems(IAPCallback)` → Attach listener for existing & new purchases.
- `initStoreInfo()` → Loads product details from Play Store/App Store.
- `buySubscription(ProductDetails, Map purchases)` → Initiates subscription purchase.
- `getPastPurchases(List purchases)` → Restores already purchased items.
- `deliverProduct(PurchaseDetails)` → Marks product as delivered after verification.
- `clearTransactions()` → Clears pending iOS transactions.
- `finishTransaction()` → Completes pending transactions on iOS.
- `_verifyProductReceipts()` → iOS receipt validation with Apple servers.
- `_getReceiptStatusMessage(int)` → Maps Apple receipt error codes to messages.
- `_listenToPurchaseUpdated(List purchases)` → Main listener for purchase state changes.

---

### 🔄 Flow of In-App Purchase

1. **Initialize IAP** using `initialize()`.
2. **Fetch Product Details** from the store using `initStoreInfo()`.
3. **Start Listener** with `getAlreadyPurchaseItems(callback)`.
4. **Buy Subscription/Consumable** → triggers `buySubscription()`.
5. **Listen for Events**:
    - ⏳ Pending → `onPending()`
    - ✅ Success → Verify receipt → `onSuccessPurchase()`
    - ❌ Error → `onBillingError()`
    - 🔄 Restored → `getPastPurchases()`
6. **iOS Receipt Validation**:
    - First tries **Production** server.
    - If error `21007` → retry with **Sandbox**.
    - Processes receipt data & checks subscription validity.
7. **Deliver Product** → If valid, adds purchase to stream & completes transaction.
8. **Clear Pending Transactions** for iOS using `clearTransactions()`.

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>