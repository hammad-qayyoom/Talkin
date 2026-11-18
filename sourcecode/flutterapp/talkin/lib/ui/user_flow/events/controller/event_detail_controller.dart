import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/events/api/event_api.dart';
import 'package:notisboard/ui/user_flow/events/model/event_model.dart';

class EventDetailController extends GetxController {
  final isLoading = true.obs;
  final event = Rxn<FoundationEvent>();

  // Map of ticketId -> quantity
  final selectedTickets = <String, int>{}.obs;

  String slug = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is FoundationEvent) {
      event.value = args;
      slug = args.slug;
      isLoading.value = false;
      loadEventDetail();
    } else if (args is String) {
      slug = args;
      loadEventDetail();
    }
  }

  Future<void> loadEventDetail() async {
    if (slug.isEmpty) return;
    try {
      final res = await EventApi.fetchEventDetail(slug);
      if (res != null) {
        event.value = res;
      }
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  void incrementTicket(EventTicket ticket) {
    final current = selectedTickets[ticket.id] ?? 0;
    if (current < ticket.remaining) {
      selectedTickets[ticket.id] = current + 1;
    }
  }

  void decrementTicket(EventTicket ticket) {
    final current = selectedTickets[ticket.id] ?? 0;
    if (current > 1) {
      selectedTickets[ticket.id] = current - 1;
    } else {
      selectedTickets.remove(ticket.id);
    }
  }

  int get totalSelectedTickets {
    return selectedTickets.values.fold(0, (sum, qty) => sum + qty);
  }

  double get ticketsSubtotal {
    double total = 0.0;
    final ev = event.value;
    if (ev == null) return 0.0;
    for (final entry in selectedTickets.entries) {
      final t = ev.tickets.firstWhereOrNull((ticket) => ticket.id == entry.key);
      if (t != null) {
        total += t.price * entry.value;
      }
    }
    return total;
  }

  double get platformCommission {
    // 4% Foundation platform fee matching the website screenshot
    return (ticketsSubtotal * 0.04 * 100).round() / 100.0;
  }

  double get grandTotal {
    return ticketsSubtotal + platformCommission;
  }
}

