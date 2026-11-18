class MarketplaceProduct {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String? content;
  final String featuredImage;
  final List<String> images;
  final double price;
  final double? compareAtPrice;
  final String currency;
  final String? sku;
  final String? brand;
  final String productType;
  final int inventory;
  final bool trackInventory;
  final String status;
  final bool isActive;
  final bool isFeatured;
  final String? sellerName;
  final String? badge;
  final double rating;
  final int reviewCount;
  final String? returnPolicy;
  final List<String> features;
  final Map<String, dynamic>? specifications;
  final Map<String, dynamic>? shippingInfo;
  final MarketplaceCategory? category;
  final MarketplaceVendor? vendor;

  MarketplaceProduct({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.content,
    required this.featuredImage,
    required this.images,
    required this.price,
    this.compareAtPrice,
    required this.currency,
    this.sku,
    this.brand,
    this.productType = 'PHYSICAL',
    this.inventory = 0,
    this.trackInventory = true,
    this.status = 'ACTIVE',
    this.isActive = true,
    this.isFeatured = false,
    this.sellerName,
    this.badge,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.returnPolicy,
    this.features = const [],
    this.specifications,
    this.shippingInfo,
    this.category,
    this.vendor,
  });

  static String resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    const base = 'https://api.notisboardglobalfoundation.org';
    return trimmed.startsWith('/') ? '$base$trimmed' : '$base/$trimmed';
  }

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final rawFeatured = json['featuredImage']?.toString() ?? '';
    final resolvedFeatured = resolveImageUrl(rawFeatured);

    final rawImages = json['images'];
    final List<String> imgList = [];
    if (resolvedFeatured.isNotEmpty) {
      imgList.add(resolvedFeatured);
    }
    if (rawImages is List) {
      for (final item in rawImages) {
        String? u;
        if (item is String) {
          u = item;
        } else if (item is Map && item['url'] != null) {
          u = item['url'].toString();
        }
        if (u != null && u.isNotEmpty) {
          final res = resolveImageUrl(u);
          if (!imgList.contains(res)) {
            imgList.add(res);
          }
        }
      }
    }

    final rawFeatures = json['features'];
    final List<String> featureList = [];
    if (rawFeatures is List) {
      for (final f in rawFeatures) {
        if (f != null && f.toString().trim().isNotEmpty) {
          featureList.add(f.toString().trim());
        }
      }
    }

    final double p = parsePrice(json['price']);
    final double? cp =
        json['compareAtPrice'] != null ? parsePrice(json['compareAtPrice']) : null;

    return MarketplaceProduct(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Artisan Product',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      content: json['content']?.toString(),
      featuredImage: resolvedFeatured,
      images: imgList,
      price: p,
      compareAtPrice: (cp != null && cp > p) ? cp : null,
      currency: json['currency']?.toString().toUpperCase() ?? 'CAD',
      sku: json['sku']?.toString(),
      brand: json['brand']?.toString(),
      productType: json['productType']?.toString() ?? 'PHYSICAL',
      inventory: (json['inventory'] is num)
          ? (json['inventory'] as num).toInt()
          : (int.tryParse(json['inventory']?.toString() ?? '0') ?? 0),
      trackInventory: json['trackInventory'] == true,
      status: json['status']?.toString() ?? 'ACTIVE',
      isActive: json['isActive'] != false,
      isFeatured: json['isFeatured'] == true,
      sellerName: json['sellerName']?.toString() ?? json['vendor']?['storeName']?.toString(),
      badge: json['badge']?.toString(),
      rating: json['rating'] != null ? parsePrice(json['rating']) : 5.0,
      reviewCount: (json['reviewCount'] is num)
          ? (json['reviewCount'] as num).toInt()
          : 0,
      returnPolicy: json['returnPolicy']?.toString(),
      features: featureList,
      specifications: json['specifications'] is Map<String, dynamic>
          ? json['specifications'] as Map<String, dynamic>
          : null,
      shippingInfo: json['shippingInfo'] is Map<String, dynamic>
          ? json['shippingInfo'] as Map<String, dynamic>
          : null,
      category: json['category'] is Map<String, dynamic>
          ? MarketplaceCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      vendor: json['vendor'] is Map<String, dynamic>
          ? MarketplaceVendor.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isInStock => !trackInventory || inventory > 0;
  bool get isOnSale => compareAtPrice != null && compareAtPrice! > price;
  int get discountPercent {
    if (!isOnSale || compareAtPrice == null || compareAtPrice! <= 0) return 0;
    return (((compareAtPrice! - price) / compareAtPrice!) * 100).round();
  }
}

class MarketplaceCategory {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? imageUrl;
  final int productCount;

  MarketplaceCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.imageUrl,
    this.productCount = 0,
  });

  factory MarketplaceCategory.fromJson(Map<String, dynamic> json) {
    return MarketplaceCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      imageUrl: MarketplaceProduct.resolveImageUrl(json['imageUrl']?.toString()),
      productCount: (json['_count'] is Map && json['_count']['products'] is num)
          ? (json['_count']['products'] as num).toInt()
          : 0,
    );
  }
}

class MarketplaceVendor {
  final String id;
  final String? businessName;
  final String storeName;
  final String slug;
  final double rating;
  final bool isVerified;
  final String? logo;
  final String? shippingPolicy;
  final String? refundPolicy;

  MarketplaceVendor({
    required this.id,
    this.businessName,
    required this.storeName,
    required this.slug,
    this.rating = 5.0,
    this.isVerified = true,
    this.logo,
    this.shippingPolicy,
    this.refundPolicy,
  });

  factory MarketplaceVendor.fromJson(Map<String, dynamic> json) {
    double parseRating(dynamic val) {
      if (val == null) return 5.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 5.0;
    }

    return MarketplaceVendor(
      id: json['id']?.toString() ?? '',
      businessName: json['businessName']?.toString(),
      storeName: json['storeName']?.toString() ??
          json['businessName']?.toString() ??
          'Ethical Artisan',
      slug: json['slug']?.toString() ?? '',
      rating: parseRating(json['rating']),
      isVerified: json['isVerified'] != false,
      logo: MarketplaceProduct.resolveImageUrl(json['logo']?.toString()),
      shippingPolicy: json['shippingPolicy']?.toString(),
      refundPolicy: json['refundPolicy']?.toString(),
    );
  }
}

class CartItem {
  final MarketplaceProduct product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get unitPrice => product.price;
  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toOrderItemPayload() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }
}

class MarketplaceOrder {
  final String id;
  final String orderNumber;
  final String status;
  final String currency;
  final double subtotal;
  final double discountAmount;
  final double shippingAmount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final String? paymentId;
  final DateTime createdAt;
  final String? customerName;
  final String? customerEmail;
  final List<MarketplaceOrderItem> items;
  final List<MarketplaceVendorOrder> vendorOrders;

  MarketplaceOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.currency,
    required this.subtotal,
    required this.discountAmount,
    required this.shippingAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    this.paymentId,
    required this.createdAt,
    this.customerName,
    this.customerEmail,
    required this.items,
    required this.vendorOrders,
  });

  factory MarketplaceOrder.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final rawItems = json['items'];
    final List<MarketplaceOrderItem> itemList = [];
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map<String, dynamic>) {
          itemList.add(MarketplaceOrderItem.fromJson(it));
        }
      }
    }

    final rawVendorOrders = json['vendorOrders'];
    final List<MarketplaceVendorOrder> voList = [];
    if (rawVendorOrders is List) {
      for (final vo in rawVendorOrders) {
        if (vo is Map<String, dynamic>) {
          voList.add(MarketplaceVendorOrder.fromJson(vo));
        }
      }
    }

    final fn = json['firstName']?.toString() ?? '';
    final ln = json['lastName']?.toString() ?? '';
    final fullName = '$fn $ln'.trim();

    return MarketplaceOrder(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      currency: json['currency']?.toString() ?? 'CAD',
      subtotal: parseAmount(json['subtotal']),
      discountAmount: parseAmount(json['discountAmount']),
      shippingAmount: parseAmount(json['shippingAmount']),
      taxAmount: parseAmount(json['taxAmount']),
      totalAmount: parseAmount(json['totalAmount']),
      paymentMethod: json['paymentMethod']?.toString() ?? 'credit_card',
      paymentId: json['paymentId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      customerName: fullName.isNotEmpty ? fullName : null,
      customerEmail: json['email']?.toString(),
      items: itemList,
      vendorOrders: voList,
    );
  }
}

class MarketplaceOrderItem {
  final String id;
  final String productTitle;
  final String? productFeaturedImage;
  final int quantity;
  final double unitPrice;
  final double total;
  final String? vendorName;

  MarketplaceOrderItem({
    required this.id,
    required this.productTitle,
    this.productFeaturedImage,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.vendorName,
  });

  factory MarketplaceOrderItem.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    String? featImg;
    if (json['product'] is Map && json['product']['featuredImage'] != null) {
      featImg = MarketplaceProduct.resolveImageUrl(json['product']['featuredImage'].toString());
    }

    return MarketplaceOrderItem(
      id: json['id']?.toString() ?? '',
      productTitle: json['productTitle']?.toString() ??
          json['product']?['title']?.toString() ??
          'Item',
      productFeaturedImage: featImg,
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 1,
      unitPrice: parseAmount(json['unitPrice']),
      total: parseAmount(json['total']),
      vendorName: json['vendor']?['storeName']?.toString() ??
          json['vendor']?['businessName']?.toString(),
    );
  }
}

class MarketplaceVendorOrder {
  final String id;
  final String subOrderNumber;
  final String status;
  final String? trackingNumber;
  final String? shippingCarrier;
  final String? storeName;

  MarketplaceVendorOrder({
    required this.id,
    required this.subOrderNumber,
    required this.status,
    this.trackingNumber,
    this.shippingCarrier,
    this.storeName,
  });

  factory MarketplaceVendorOrder.fromJson(Map<String, dynamic> json) {
    return MarketplaceVendorOrder(
      id: json['id']?.toString() ?? '',
      subOrderNumber: json['subOrderNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      trackingNumber: json['trackingNumber']?.toString(),
      shippingCarrier: json['shippingCarrier']?.toString(),
      storeName: json['vendor']?['storeName']?.toString() ??
          json['vendor']?['businessName']?.toString(),
    );
  }
}

