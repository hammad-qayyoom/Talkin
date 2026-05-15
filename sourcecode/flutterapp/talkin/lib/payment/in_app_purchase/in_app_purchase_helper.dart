import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:notisboard/main.dart';

import 'iap_callback.dart';

class InAppPurchaseHelper {
  static final InAppPurchaseHelper _inAppPurchaseHelper =
      InAppPurchaseHelper._internal();

  InAppPurchaseHelper._internal();

  factory InAppPurchaseHelper() {
    return _inAppPurchaseHelper;
  }

  num discountAmount = 0;
  num discountPercentage = 0;
  String date = "";
  String time = "";
  double rupee = 0;
  int withoutTaxRupee = 0;
  String serviceId = "";
  String expertId = "";
  String userId = "";
  String paymentType = "";
  Callback onComplete = () {};
  List<String> productId = [];

  init({
    required double rupee,
    required String userId,
    required String paymentType,
    required List<String> productKey,
    required Callback callBack,
  }) {
    this.rupee = rupee;
    this.userId = userId;
    this.paymentType = paymentType;
    productId = productKey;
    onComplete = () => callBack.call();
  }

  final InAppPurchase _connection = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  IAPCallback? _iapCallback;
  static Future<void> _storeOperationQueue = Future<void>.value();

  void setCallback(IAPCallback iapCallback) {
    _iapCallback = iapCallback;
  }

  void ensurePurchaseListener() {
    if (_subscription != null) return;

    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _connection.purchaseStream;
    _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) {
          if (purchaseDetailsList.isNotEmpty) {
            purchaseDetailsList.sort(_comparePurchaseEvents);

            if (purchaseDetailsList.every(
                (purchase) => purchase.status == PurchaseStatus.restored)) {
              getPastPurchases(purchaseDetailsList);
            } else {
              _listenToPurchaseUpdated(purchaseDetailsList);
            }
          }
        },
        cancelOnError: false,
        onDone: () {
          _subscription?.cancel();
          _subscription = null;
        },
        onError: (error) {
          log("Purchase stream error: $error");
          handleError(error);
        });
  }

  initialize() {
    if (Platform.isAndroid) {
      // FIXED: The enablePendingPurchases() method has been deprecated and removed
      // Pending purchases are now enabled by default in newer versions
      // No action needed for Android initialization
      log("Android IAP initialized - pending purchases enabled by default");
    } else {
      log("iOS IAP initialized");
    }
  }

  ProductDetails? getProductDetail(String productID) {
    for (ProductDetails item in _products) {
      if (item.id == productID) {
        return item;
      }
    }
    return null;
  }

  List<String> getAvailableProducts() {
    return _products.map((product) => product.id).toList();
  }

  Future<void> debugProductLoading() async {
    log("=== IAP Debug Info ===");
    log("Product IDs to query: $productId");

    final bool isAvailable = await _connection.isAvailable();
    log("Store available: $isAvailable");

    if (!isAvailable) return;

    Set<String> productIds = productId.toSet();
    ProductDetailsResponse response =
        await _queryProductDetailsWithRetry(productIds);

    log("Query error: ${response.error}");
    log("Products found: ${response.productDetails.length}");
    log("Not found product IDs: ${response.notFoundIDs}");

    for (var product in response.productDetails) {
      log("Found product: ${product.id} - ${product.title} - ${product.price}");
    }

    for (var notFound in response.notFoundIDs) {
      log("Not found product: $notFound");
    }
  }

  getAlreadyPurchaseItems(IAPCallback iapCallback) {
    setCallback(iapCallback);
    ensurePurchaseListener();
    restorePurchases(iapCallback);
  }

  Future<bool> initStoreInfo({bool restoreExistingPurchases = false}) async {
    if (restoreExistingPurchases) {
      await _restorePurchasesOnly();
      return true;
    }

    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      _products = [];
      _purchases = [];
      _iapCallback?.onBillingError("Store not available");
      return false;
    }

    // Fixed: Convert List to Set properly
    Set<String> productIds = productId.toSet();

    ProductDetailsResponse productDetailResponse =
        await _queryProductDetailsWithRetry(productIds);

    if (productDetailResponse.error != null) {
      _products = [];
      _purchases = [];
      _iapCallback?.onBillingError(productDetailResponse.error);
      return false;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      _products = [];
      _purchases = [];
      _iapCallback?.onBillingError("No products found");
      return false;
    } else {
      _products = productDetailResponse.productDetails;
      _purchases = [];
      log("Products loaded: ${_products.length}");
    }

    return true;
  }

  Future<void> restorePurchases(IAPCallback iapCallback) async {
    setCallback(iapCallback);
    ensurePurchaseListener();
    await _restorePurchasesOnly();
  }

  Future<void> _restorePurchasesOnly() {
    return _runStoreOperation(() async {
      final bool isAvailable = await _connection.isAvailable();
      if (!isAvailable) {
        _purchases = [];
        _iapCallback?.onBillingError("Store not available");
        return;
      }

      await _connection.restorePurchases();
    });
  }

  Future<ProductDetailsResponse> _queryProductDetailsWithRetry(
      Set<String> productIds) async {
    ProductDetailsResponse? lastResponse;

    for (var attempt = 0; attempt < 2; attempt++) {
      final response = await _runStoreOperation(
          () => _connection.queryProductDetails(productIds));
      lastResponse = response;

      final shouldRetry = response.productDetails.isEmpty &&
          (response.error == null || _isStoreKitNoResponse(response.error));
      if (!shouldRetry || attempt == 1) return response;

      await Future<void>.delayed(const Duration(milliseconds: 700));
    }

    return lastResponse!;
  }

  Future<T> _runStoreOperation<T>(Future<T> Function() operation) {
    final completer = Completer<T>();

    _storeOperationQueue =
        _storeOperationQueue.catchError((_) {}).then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }

  bool _isStoreKitNoResponse(dynamic error) {
    final text = error.toString().toLowerCase();
    return text.contains('storekit_no_response') ||
        text.contains('storekit_platform_no_response') ||
        text.contains('failed to get response from platform');
  }

  int _purchaseStatusPriority(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        return 0;
      case PurchaseStatus.pending:
        return 1;
      case PurchaseStatus.canceled:
        return 2;
      case PurchaseStatus.error:
        return 3;
    }
  }

  int _comparePurchaseEvents(PurchaseDetails a, PurchaseDetails b) {
    final priority = _purchaseStatusPriority(a.status)
        .compareTo(_purchaseStatusPriority(b.status));
    if (priority != 0) return priority;

    return (a.transactionDate ?? '').compareTo(b.transactionDate ?? '');
  }

  Future<void> getPastPurchases(List<PurchaseDetails> verifiedPurchases) async {
    verifiedPurchases.sort(
        (a, b) => (a.transactionDate ?? '').compareTo(b.transactionDate ?? ''));

    if (verifiedPurchases.isNotEmpty) {
      _purchases = verifiedPurchases;
      log("You have already Purchased :::::::::::::::::::=>");

      for (var element in _purchases) {
        MyApp.purchaseStreamController.add(element);
        _iapCallback?.onSuccessPurchase(element);
      }
    } else {
      log("You have not Purchased :::::::::::::::::::=>");
      _iapCallback?.onBillingError(
          "You haven't purchase our product, so we can't restore.");
    }
  }

  Map<String, PurchaseDetails> getPurchases() {
    Map<String, PurchaseDetails> purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _connection.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    return purchases;
  }

  Future<void> finishTransaction() async {
    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();

      if (transactions.isNotEmpty) {
        for (final transaction in transactions) {
          try {
            if (transaction.transactionState !=
                SKPaymentTransactionStateWrapper.purchasing) {
              await SKPaymentQueueWrapper().finishTransaction(transaction);
              if (transaction.originalTransaction != null) {
                await SKPaymentQueueWrapper()
                    .finishTransaction(transaction.originalTransaction!);
              }
            }
          } catch (e) {
            log("Error finishing transaction: $e");
            _iapCallback?.onBillingError(e);
          }
        }
      }
    }
  }

  Future<bool> buySubscription(ProductDetails productDetails,
      Map<String, PurchaseDetails> purchases) async {
    PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      final oldSubscription = _getOldSubscription(productDetails, purchases);

      purchaseParam = GooglePlayPurchaseParam(
          productDetails: productDetails,
          applicationUserName: null,
          changeSubscriptionParam: (oldSubscription != null)
              ? ChangeSubscriptionParam(
                  oldPurchaseDetails: oldSubscription,
                )
              : null);
    } else {
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
    }

    try {
      return await _runStoreOperation(
        () => _connection.buyNonConsumable(purchaseParam: purchaseParam),
      );
    } on PlatformException catch (error) {
      handleError(error);
      log("Purchase error: $error");
      return false;
    } catch (error) {
      handleError(error);
      log("Purchase error: $error");
      return false;
    }
  }

  Future<void> clearTransactions() async {
    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final transaction in transactions) {
        try {
          if (transaction.transactionState !=
              SKPaymentTransactionStateWrapper.purchasing) {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
            if (transaction.originalTransaction != null) {
              await SKPaymentQueueWrapper()
                  .finishTransaction(transaction.originalTransaction!);
            }
          }
        } catch (e) {
          _iapCallback?.onBillingError(e);
          log("Error clearing transaction: $e");
        }
      }
    }
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    /// IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    _purchases.add(purchaseDetails);
    MyApp.purchaseStreamController.add(purchaseDetails);
    _iapCallback?.onSuccessPurchase(purchaseDetails);
  }

  void handleError(dynamic error) {
    log("IAP Error: $error");
    _iapCallback?.onBillingError(error);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    /// IMPORTANT!! Always verify a purchase before delivering the product.
    /// For the purpose of an example, we directly return true.
    /// In production, implement proper server-side verification
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    /// handle invalid purchase here if _verifyPurchase failed.
    log("Invalid purchase: ${purchaseDetails.productID}");
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    final sortedPurchaseDetails = [...purchaseDetailsList]
      ..sort(_comparePurchaseEvents);
    var handledSuccessfulPurchase = false;

    for (PurchaseDetails detailsPurchase in sortedPurchaseDetails) {
      if (detailsPurchase.status == PurchaseStatus.pending) {
        _iapCallback?.onPending(detailsPurchase);
      } else {
        if (detailsPurchase.status == PurchaseStatus.error) {
          if (handledSuccessfulPurchase) {
            log("Ignoring trailing StoreKit error after a successful purchase event: ${detailsPurchase.error}");
          } else {
            handleError(detailsPurchase.error);
          }
        } else if (detailsPurchase.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(detailsPurchase);
          if (valid) {
            handledSuccessfulPurchase = true;
            deliverProduct(detailsPurchase);
          } else {
            _handleInvalidPurchase(detailsPurchase);
            return;
          }
        } else if (detailsPurchase.status == PurchaseStatus.canceled) {
          _iapCallback?.onBillingError("Purchase canceled");
        } else if (detailsPurchase.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(detailsPurchase);
          if (valid) {
            handledSuccessfulPurchase = true;
            onComplete.call();
            deliverProduct(detailsPurchase);
          } else {
            _handleInvalidPurchase(detailsPurchase);
            return;
          }
        }
      }

      if (detailsPurchase.pendingCompletePurchase) {
        await _connection.completePurchase(detailsPurchase);
        await finishTransaction();
      }
    }
    await clearTransactions();
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    return purchases[productDetails.id] as GooglePlayPurchaseDetails?;
  }
}
