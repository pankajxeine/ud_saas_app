import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'i10n_en.dart';
import 'i10n_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i10n/i10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @screen_size_error.
  ///
  /// In en, this message translates to:
  /// **'Screen size is too small.'**
  String get screen_size_error;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get first_name;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get last_name;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @authorities.
  ///
  /// In en, this message translates to:
  /// **'Authorities'**
  String get authorities;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @required_field.
  ///
  /// In en, this message translates to:
  /// **'Required Field'**
  String get required_field;

  /// No description provided for @min_length_2.
  ///
  /// In en, this message translates to:
  /// **'Field must be at least 2 characters long'**
  String get min_length_2;

  /// No description provided for @min_length_3.
  ///
  /// In en, this message translates to:
  /// **'Field must be at least 3 characters long'**
  String get min_length_3;

  /// No description provided for @min_length_4.
  ///
  /// In en, this message translates to:
  /// **'Field must be at least 4 characters long'**
  String get min_length_4;

  /// No description provided for @min_length_5.
  ///
  /// In en, this message translates to:
  /// **'Field must be at least 5 characters long'**
  String get min_length_5;

  /// No description provided for @max_length_10.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be more than 10 characters long'**
  String get max_length_10;

  /// No description provided for @max_length_20.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be more than 20 characters long'**
  String get max_length_20;

  /// No description provided for @max_length_50.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be more than 50 characters long'**
  String get max_length_50;

  /// No description provided for @max_length_100.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be more than 100 characters long'**
  String get max_length_100;

  /// No description provided for @max_length_250.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be more than 250 characters long'**
  String get max_length_250;

  /// No description provided for @max_length_500.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be more than 500 characters long'**
  String get max_length_500;

  /// No description provided for @max_length_1000.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be more than 1000 characters long'**
  String get max_length_1000;

  /// No description provided for @max_length_4000.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be more than 4000 characters long'**
  String get max_length_4000;

  /// No description provided for @required_range.
  ///
  /// In en, this message translates to:
  /// **'Range is required'**
  String get required_range;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @list_user.
  ///
  /// In en, this message translates to:
  /// **'List User'**
  String get list_user;

  /// No description provided for @new_user.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get new_user;

  /// No description provided for @edit_user.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get edit_user;

  /// No description provided for @view_user.
  ///
  /// In en, this message translates to:
  /// **'View User'**
  String get view_user;

  /// No description provided for @delete_user.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get delete_user;

  /// No description provided for @email_pattern.
  ///
  /// In en, this message translates to:
  /// **'Email must be a valid email address'**
  String get email_pattern;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @create_user.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get create_user;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @delete_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get delete_confirmation;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @language_select.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get language_select;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_sure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_sure;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @unsaved_changes.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave?'**
  String get unsaved_changes;

  /// No description provided for @no_changes_made.
  ///
  /// In en, this message translates to:
  /// **'No changes made'**
  String get no_changes_made;

  /// No description provided for @no_data.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get no_data;

  /// No description provided for @login_user_name.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get login_user_name;

  /// No description provided for @login_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password;

  /// No description provided for @current_password.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get current_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @password_forgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get password_forgot;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @password_max_length.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be more than 6 characters long'**
  String get password_max_length;

  /// No description provided for @password_min_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 5 characters long'**
  String get password_min_length;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_button;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @email_send.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get email_send;

  /// No description provided for @translate_menu_title.
  ///
  /// In en, this message translates to:
  /// **'{translate, select, account{Account} userManagement{User Management} settings{Settings}  logout{Logout}  info{Info} language{Language}  theme{Theme}  new_user{New}  list_user{List} other{Other}}'**
  String translate_menu_title(String translate);

  /// No description provided for @login_with_email.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get login_with_email;

  /// No description provided for @send_otp_code.
  ///
  /// In en, this message translates to:
  /// **'Send OTP Code'**
  String get send_otp_code;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalid_email;

  /// No description provided for @resend_otp_code.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP Code'**
  String get resend_otp_code;

  /// No description provided for @verify_otp_code.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP Code'**
  String get verify_otp_code;

  /// No description provided for @only_numbers.
  ///
  /// In en, this message translates to:
  /// **'Only numbers are allowed'**
  String get only_numbers;

  /// No description provided for @otp_length.
  ///
  /// In en, this message translates to:
  /// **'OTP must be 6 characters long'**
  String get otp_length;

  /// No description provided for @otp_code.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otp_code;

  /// No description provided for @otp_sent_to.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to'**
  String get otp_sent_to;

  /// No description provided for @taskSaveScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Save'**
  String get taskSaveScreenTitle;

  /// No description provided for @taskName.
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get taskName;

  /// No description provided for @taskPrice.
  ///
  /// In en, this message translates to:
  /// **'Task Price'**
  String get taskPrice;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @leads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get leads;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @chart_kpi_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Chart / KPI Placeholder'**
  String get chart_kpi_placeholder;

  /// No description provided for @recent_activity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recent_activity;

  /// No description provided for @sample_activity_item.
  ///
  /// In en, this message translates to:
  /// **'Sample activity item'**
  String get sample_activity_item;

  /// No description provided for @subtitle_context.
  ///
  /// In en, this message translates to:
  /// **'Subtitle / Context'**
  String get subtitle_context;

  /// No description provided for @just_now.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get just_now;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @new_lead.
  ///
  /// In en, this message translates to:
  /// **'New Lead'**
  String get new_lead;

  /// No description provided for @add_task.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get add_task;

  /// No description provided for @new_deal.
  ///
  /// In en, this message translates to:
  /// **'New Deal'**
  String get new_deal;

  /// No description provided for @send_email_action.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get send_email_action;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @nav_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get nav_overview;

  /// No description provided for @nav_manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get nav_manage;

  /// No description provided for @nav_apps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get nav_apps;

  /// No description provided for @nav_build.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get nav_build;

  /// No description provided for @nav_orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get nav_orders;

  /// No description provided for @nav_customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get nav_customers;

  /// No description provided for @nav_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get nav_products;

  /// No description provided for @nav_inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get nav_inbox;

  /// No description provided for @nav_board.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get nav_board;

  /// No description provided for @nav_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get nav_calendar;

  /// No description provided for @nav_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get nav_chat;

  /// No description provided for @nav_components.
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get nav_components;

  /// No description provided for @nav_forms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get nav_forms;

  /// No description provided for @nav_wizard.
  ///
  /// In en, this message translates to:
  /// **'Wizard'**
  String get nav_wizard;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @workspace_overview.
  ///
  /// In en, this message translates to:
  /// **'Workspace overview'**
  String get workspace_overview;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @apps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get apps;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return SEn();
    case 'tr': return STr();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
