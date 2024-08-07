import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Presentation/Screens/StudyDashBoard.dart';

class RouteNavigation {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (context) {
            return StudyDashboard();
          },
        );

      default:
        return null;
    }
  }
}
