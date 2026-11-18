double _toDouble(dynamic val, [double fallback = 0.0]) {
  if (val == null) return fallback;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

int _toInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

class EventCategory {
  final String id;
  final String name;
  final String slug;

  EventCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class EventOrganizer {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? avatar;

  EventOrganizer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.avatar,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory EventOrganizer.fromJson(Map<String, dynamic> json) {
    return EventOrganizer(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}

class EventTicket {
  final String id;
  final String eventId;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final int quantity;
  final int soldCount;
  final bool isActive;

  EventTicket({
    required this.id,
    required this.eventId,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'CAD',
    this.quantity = 0,
    this.soldCount = 0,
    this.isActive = true,
  });

  int get remaining => (quantity - soldCount).clamp(0, 999999);
  bool get isSoldOut => remaining <= 0;

  factory EventTicket.fromJson(Map<String, dynamic> json) {
    return EventTicket(
      id: json['id']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'General Admission',
      description: json['description']?.toString(),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString() ?? 'CAD',
      quantity: _toInt(json['quantity']),
      soldCount: _toInt(json['soldCount']),
      isActive: json['isActive'] != false,
    );
  }
}

class FoundationEvent {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? content;
  final String? featuredImage;
  final String? venue;
  final String? address;
  final String? city;
  final String? country;
  final bool isOnline;
  final String? onlineUrl;
  final String? organizerName;
  final String? badge;
  final double priceFrom;
  final String currency;
  final String? startDateTime;
  final String? endDateTime;
  final String status;
  final EventCategory? category;
  final EventOrganizer? organizer;
  final List<EventTicket> tickets;

  FoundationEvent({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.content,
    this.featuredImage,
    this.venue,
    this.address,
    this.city,
    this.country,
    this.isOnline = false,
    this.onlineUrl,
    this.organizerName,
    this.badge,
    this.priceFrom = 0.0,
    this.currency = 'CAD',
    this.startDateTime,
    this.endDateTime,
    this.status = 'PUBLISHED',
    this.category,
    this.organizer,
    this.tickets = const [],
  });

  String get locationDisplay {
    if (isOnline) return 'Virtual Event';
    final parts = [venue, address, city, country]
        .where((p) => p != null && p.trim().isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Location TBA';
  }

  String get organizerDisplay {
    if (organizerName != null && organizerName!.trim().isNotEmpty) {
      return organizerName!.trim();
    }
    if (organizer != null && organizer!.fullName.isNotEmpty) {
      return organizer!.fullName;
    }
    return 'Foundation Events';
  }

  factory FoundationEvent.fromJson(Map<String, dynamic> json) {
    final ticketsRaw = json['tickets'];
    List<EventTicket> parsedTickets = [];
    if (ticketsRaw is List) {
      for (final t in ticketsRaw) {
        if (t is Map<String, dynamic>) {
          try {
            parsedTickets.add(EventTicket.fromJson(t));
          } catch (_) {}
        }
      }
    }

    return FoundationEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      content: json['content']?.toString(),
      featuredImage: json['featuredImage']?.toString(),
      venue: json['venue']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      isOnline: json['isOnline'] == true,
      onlineUrl: json['onlineUrl']?.toString(),
      organizerName: json['organizerName']?.toString(),
      badge: json['badge']?.toString(),
      priceFrom: _toDouble(json['priceFrom']),
      currency: json['currency']?.toString() ?? 'CAD',
      startDateTime: json['startDateTime']?.toString(),
      endDateTime: json['endDateTime']?.toString(),
      status: json['status']?.toString() ?? 'PUBLISHED',
      category: json['category'] is Map<String, dynamic>
          ? EventCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      organizer: json['organizer'] is Map<String, dynamic>
          ? EventOrganizer.fromJson(json['organizer'] as Map<String, dynamic>)
          : null,
      tickets: parsedTickets,
    );
  }
}

class EventRegistrationRecord {
  final String id;
  final String bookingReference;
  final String eventId;
  final String eventTitle;
  final String? eventImage;
  final String? eventDate;
  final String? venue;
  final bool isOnline;
  final String attendeeName;
  final String email;
  final int quantity;
  final double totalAmount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? ticketName;
  final String? createdAt;

  EventRegistrationRecord({
    required this.id,
    required this.bookingReference,
    required this.eventId,
    required this.eventTitle,
    this.eventImage,
    this.eventDate,
    this.venue,
    this.isOnline = false,
    required this.attendeeName,
    required this.email,
    required this.quantity,
    required this.totalAmount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.ticketName,
    this.createdAt,
  });

  factory EventRegistrationRecord.fromJson(Map<String, dynamic> json) {
    String ref = json['paymentId']?.toString() ?? '';
    if (ref.isEmpty && json['metadata'] is Map) {
      ref = json['metadata']['bookingReference']?.toString() ??
          json['metadata']['trackingNumber']?.toString() ??
          '';
    }
    if (ref.isEmpty) {
      ref = 'NTB-TKT-${json['id']?.toString().substring(0, 8).toUpperCase()}';
    }

    String evTitle = 'Event Pass';
    String? evImage;
    String? evDate;
    String? evVenue;
    bool online = false;

    if (json['event'] is Map<String, dynamic>) {
      final ev = json['event'] as Map<String, dynamic>;
      evTitle = ev['title']?.toString() ?? evTitle;
      evImage = ev['featuredImage']?.toString();
      evDate = ev['startDateTime']?.toString();
      evVenue = ev['venue']?.toString();
      online = ev['isOnline'] == true;
    }

    final firstName = json['firstName']?.toString() ?? '';
    final lastName = json['lastName']?.toString() ?? '';
    final name = '$firstName $lastName'.trim();

    return EventRegistrationRecord(
      id: json['id']?.toString() ?? '',
      bookingReference: ref,
      eventId: json['eventId']?.toString() ?? '',
      eventTitle: evTitle,
      eventImage: evImage,
      eventDate: evDate,
      venue: evVenue,
      isOnline: online,
      attendeeName: name.isNotEmpty ? name : 'Attendee',
      email: json['email']?.toString() ?? '',
      quantity: _toInt(json['quantity'], 1),
      totalAmount: _toDouble(json['totalAmount']),
      currency: json['currency']?.toString() ?? 'CAD',
      paymentMethod: json['paymentMethod']?.toString() ??
          (json['metadata'] is Map ? json['metadata']['paymentMethod']?.toString() : null) ??
          'Online',
      status: json['status']?.toString() ?? 'CONFIRMED',
      ticketName: json['ticket'] is Map ? (json['ticket'] as Map)['name']?.toString() : null,
      createdAt: json['createdAt']?.toString(),
    );
  }
}

