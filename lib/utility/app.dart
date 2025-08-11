import 'package:complaint_management_system/pages/admin_page.dart';
import 'package:complaint_management_system/pages/complaint_details_page.dart';
import 'package:complaint_management_system/pages/complaint_id.dart';
import 'package:complaint_management_system/pages/complaint_list_page.dart';
import 'package:complaint_management_system/pages/complaint_status.dart';
import 'package:complaint_management_system/pages/forgot_password.dart';
import 'package:complaint_management_system/pages/login.dart';
import 'package:complaint_management_system/pages/main_complaint.dart';
import 'package:complaint_management_system/pages/new_complaint.dart';
import 'package:complaint_management_system/pages/notification_page.dart';
import 'package:complaint_management_system/pages/profile_page.dart';
import 'package:complaint_management_system/pages/register.dart';
import 'package:complaint_management_system/pages/settings_page.dart';
import 'package:complaint_management_system/pages/start_page.dart';
import 'package:complaint_management_system/pages/view_complaints.dart';
import 'package:complaint_management_system/utility/about.dart';
import 'package:complaint_management_system/utility/app.dart';
import 'package:complaint_management_system/utility/help.dart';
import 'package:flutter/material.dart';
import 'package:complaint_management_system/pages/announcement_page.dart';

class AppRoutes {
  static const String Login = "LoginPage";
  static const String Register = "RegisterPage";
  static const String MainPage = "ComplaintHomePage";
  static const String NewComplain = "NewComplaintPage";
  static const String Details = "ComplaintDetailsPage";
  static const String Id = "ComplaintIDPage";
  static const String List = "ComplaintListPage";
  static const String Status = "ComplaintStatusPage";
  static const String View = "ViewComplaintsPage";
  static const String Start = "StartPage";
  static const String forgortPassword = "ForgotPasswordPage";
  static const String ProfilePage = "Profile_Page";
  static const String Profile = "ProfilePage";
  static const String Settings = "SettingsPage";
  static const String notification = "NotificationPage";
  static const String about = "AboutPage";
  static const String help = "HelpSupportPage";
  static const String Admin = "AdminPage";
  static const String announcement = '/announcement';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.Login:
        return MaterialPageRoute(
          builder: (c) {
            return LoginPage();
          },
        );
      case AppRoutes.help:
        return MaterialPageRoute(
          builder: (c) {
            return HelpSupportPage();
          },
        );
      case AppRoutes.about:
        return MaterialPageRoute(
          builder: (c) {
            return AboutPage();
          },
        );
      case AppRoutes.Register:
        return MaterialPageRoute(
          builder: (c) {
            return RegisterPage();
          },
        );
      case AppRoutes.notification:
        return MaterialPageRoute(
          builder: (c) {
            return NotificationPage();
          },
        );
      case AppRoutes.MainPage:
        return MaterialPageRoute(
          builder: (c) {
            return ComplaintHomePage();
          },
        );
      case AppRoutes.NewComplain:
        return MaterialPageRoute(
          builder: (c) {
            return NewComplaintPage();
          },
        );
      case AppRoutes.Details:
        return MaterialPageRoute(
          builder: (c) {
            return ComplaintDetailsPage(
              id: '',
              serialNumber: 0,
            );
          },
        );
      case AppRoutes.Id:
        return MaterialPageRoute(
          builder: (c) {
            return ComplaintIDPage();
          },
        );
      case AppRoutes.List:
        return MaterialPageRoute(
          builder: (c) {
            return ComplaintListPage();
          },
        );
      case AppRoutes.Status:
        return MaterialPageRoute(
          builder: (c) {
            return ComplaintStatusPage();
          },
        );
      case AppRoutes.View:
        return MaterialPageRoute(
          builder: (c) {
            return ViewComplaintsPage();
          },
        );
      case AppRoutes.Start:
        return MaterialPageRoute(
          builder: (c) {
            return StartPage();
          },
        );
      case AppRoutes.forgortPassword:
        return MaterialPageRoute(
          builder: (c) {
            return ForgotPasswordPage();
          },
        );
      case AppRoutes.ProfilePage:
        return MaterialPageRoute(
          builder: (c) {
            return Profile_Page();
          },
        );
      case AppRoutes.Profile:
        return MaterialPageRoute(
          builder: (c) {
            return Profile_Page();
          },
        );
      case AppRoutes.Settings:
        return MaterialPageRoute(
          builder: (c) {
            return SettingsPage();
          },
        );
      case AppRoutes.Admin:
        return MaterialPageRoute(
          builder: (c) {
            return AdminPage();
          },
        );
      case AppRoutes.announcement:
        return MaterialPageRoute(builder: (_) => const AnnouncementPage());
    }
    return MaterialPageRoute(
      builder: (c) {
        return LoginPage();
      },
    );
  }
}
