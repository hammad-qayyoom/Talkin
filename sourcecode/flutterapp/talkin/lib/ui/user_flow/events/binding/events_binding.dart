import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/events/controller/event_booking_controller.dart';
import 'package:notisboard/ui/user_flow/events/controller/event_detail_controller.dart';
import 'package:notisboard/ui/user_flow/events/controller/events_controller.dart';
import 'package:notisboard/ui/user_flow/events/controller/my_tickets_controller.dart';

class EventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventsController>(() => EventsController(), fenix: true);
    Get.lazyPut<EventDetailController>(() => EventDetailController(), fenix: true);
    Get.lazyPut<EventBookingController>(() => EventBookingController(), fenix: true);
    Get.lazyPut<MyTicketsController>(() => MyTicketsController(), fenix: true);
  }
}
