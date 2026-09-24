// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'i10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get screen_size_error => 'Screen size is too small.';

  @override
  String get admin => 'Admin';

  @override
  String get guest => 'Guest';

  @override
  String get role => 'Role';

  @override
  String get login => 'Login';

  @override
  String get first_name => 'First Name';

  @override
  String get last_name => 'Last Name';

  @override
  String get phone_number => 'Phone Number';

  @override
  String get email => 'Email';

  @override
  String get active => 'Active';

  @override
  String get authorities => 'Authorities';

  @override
  String get name => 'Name';

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';

  @override
  String get required_field => 'Required Field';

  @override
  String get min_length_2 => 'Field must be at least 2 characters long';

  @override
  String get min_length_3 => 'Field must be at least 3 characters long';

  @override
  String get min_length_4 => 'Field must be at least 4 characters long';

  @override
  String get min_length_5 => 'Field must be at least 5 characters long';

  @override
  String get max_length_10 => 'Field cannot be more than 10 characters long';

  @override
  String get max_length_20 => 'Field cannot be more than 20 characters long';

  @override
  String get max_length_50 => 'Field cannot be more than 50 characters long';

  @override
  String get max_length_100 => 'Field cannot be more than 100 characters long';

  @override
  String get max_length_250 => 'Field cannot be more than 250 characters long';

  @override
  String get max_length_500 => 'Field cannot be more than 500 characters long';

  @override
  String get max_length_1000 => 'Field cannot be more than 1000 characters long';

  @override
  String get max_length_4000 => 'Field cannot be more than 4000 characters long';

  @override
  String get required_range => 'Range is required';

  @override
  String get list => 'List';

  @override
  String get filter => 'Filter';

  @override
  String get list_user => 'List User';

  @override
  String get new_user => 'New User';

  @override
  String get edit_user => 'Edit User';

  @override
  String get view_user => 'View User';

  @override
  String get delete_user => 'Delete User';

  @override
  String get email_pattern => 'Email must be a valid email address';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

  @override
  String get create_user => 'Create User';

  @override
  String get save => 'Save';

  @override
  String get back => 'Back';

  @override
  String get delete_confirmation => 'Are you sure you want to delete?';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get change_password => 'Change Password';

  @override
  String get language_select => 'Select Language';

  @override
  String get logout => 'Logout';

  @override
  String get logout_sure => 'Are you sure you want to logout?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get warning => 'Warning';

  @override
  String get unsaved_changes => 'You have unsaved changes. Are you sure you want to leave?';

  @override
  String get no_changes_made => 'No changes made';

  @override
  String get no_data => 'No Data';

  @override
  String get login_user_name => 'Username';

  @override
  String get login_password => 'Password';

  @override
  String get current_password => 'Current Password';

  @override
  String get new_password => 'New Password';

  @override
  String get password_forgot => 'Forgot Password';

  @override
  String get register => 'Register';

  @override
  String get password_max_length => 'Password cannot be more than 6 characters long';

  @override
  String get password_min_length => 'Password must be at least 5 characters long';

  @override
  String get login_button => 'Login';

  @override
  String get loading => 'Loading...';

  @override
  String get email_send => 'Send Email';

  @override
  String translate_menu_title(String translate) {
    String _temp0 = intl.Intl.selectLogic(
      translate,
      {
        'account': 'Account',
        'userManagement': 'User Management',
        'settings': 'Settings',
        'logout': 'Logout',
        'info': 'Info',
        'language': 'Language',
        'theme': 'Theme',
        'new_user': 'New',
        'list_user': 'List',
        'other': 'Other',
      },
    );
    return '$_temp0';
  }

  @override
  String get login_with_email => 'Login with Email';

  @override
  String get send_otp_code => 'Send OTP Code';

  @override
  String get invalid_email => 'Invalid email address';

  @override
  String get resend_otp_code => 'Resend OTP Code';

  @override
  String get verify_otp_code => 'Verify OTP Code';

  @override
  String get only_numbers => 'Only numbers are allowed';

  @override
  String get otp_length => 'OTP must be 6 characters long';

  @override
  String get otp_code => 'OTP Code';

  @override
  String get otp_sent_to => 'OTP sent to';

  @override
  String get taskSaveScreenTitle => 'Task Save';

  @override
  String get taskName => 'Task Name';

  @override
  String get taskPrice => 'Task Price';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get refresh => 'Refresh';

  @override
  String get leads => 'Leads';

  @override
  String get customers => 'Customers';

  @override
  String get revenue => 'Revenue';

  @override
  String get chart_kpi_placeholder => 'Chart / KPI Placeholder';

  @override
  String get recent_activity => 'Recent Activity';

  @override
  String get sample_activity_item => 'Sample activity item';

  @override
  String get subtitle_context => 'Subtitle / Context';

  @override
  String get just_now => 'just now';

  @override
  String get quick_actions => 'Quick Actions';

  @override
  String get new_lead => 'New Lead';

  @override
  String get add_task => 'Add Task';

  @override
  String get new_deal => 'New Deal';

  @override
  String get send_email_action => 'Send Email';

  @override
  String get more => 'More';

  @override
  String get nav_overview => 'Overview';

  @override
  String get nav_manage => 'Manage';

  @override
  String get nav_apps => 'Apps';

  @override
  String get nav_build => 'Build';

  @override
  String get nav_orders => 'Orders';

  @override
  String get nav_customers => 'Customers';

  @override
  String get nav_products => 'Products';

  @override
  String get nav_inbox => 'Inbox';

  @override
  String get nav_board => 'Board';

  @override
  String get nav_calendar => 'Calendar';

  @override
  String get nav_chat => 'Chat';

  @override
  String get nav_components => 'Components';

  @override
  String get nav_forms => 'Forms';

  @override
  String get nav_wizard => 'Wizard';

  @override
  String get nav_profile => 'Profile';

  @override
  String get workspace_overview => 'Workspace overview';

  @override
  String get tasks => 'Tasks';

  @override
  String get apps => 'Apps';

  @override
  String get users => 'Users';
}
