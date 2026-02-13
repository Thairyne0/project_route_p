import 'package:flutter/foundation.dart';

enum PanelSection { notifications, chatbot }

class NotificationsPanelProvider extends ChangeNotifier {
  bool isOpen = false;
  PanelSection currentSection = PanelSection.notifications;

  void toggle(PanelSection section) {
    if (!isOpen || currentSection != section) {
      isOpen = true;
      currentSection = section;
    } else {
      isOpen = false;
    }
    notifyListeners();
  }

  void close() {
    isOpen = false;
    notifyListeners();
  }

  bool isCurrentSection(PanelSection section) => currentSection == section;
}
