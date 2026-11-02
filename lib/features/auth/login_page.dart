// login_page.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/core/navigation/app_navigation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/widgets/reactive_shadcn_form/reactive_shadcn_input_fields.dart';
import 'package:ud_sass_app/features/auth/auth.dart';
import 'package:ud_sass_app/routes/app_routes_constants.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/components/card.dart';
import 'package:ud_sass_app/ui/dashcn/components/scaffold.dart';
import 'package:ud_sass_app/ui/dashcn/src/primitives/localizations/localizations.dart';

import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

import '../../core/widgets/reactive_shadcn_form/entity_meta.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Map<String, dynamic> _schema = {
    "entityName": "User",
    "fields": [
      {
        "name": "email",
        "label": "Email",
        "initialValue": "demo@example.test",
        "type": "email",
        "validationRules": {"required": true, "email": true},
        "features": {"showClearButton": true, "showCopyButton": true},
      },
      {
        "name": "password",
        "label": "Password",
        "initialValue": "DEMO_NOT_A_REAL_SECRET",
        "type": "password",
        "validationRules": {"required": true, "minLength": 8, "maxLength": 20},
      },
    ],
  };

  late final EntityMeta _meta = entityMetaFromJson(_schema);
  late final FormGroup _form = _meta.toFormGroup();

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AuthLoginBloc(AuthService(baseUrl: ProfileConstants.api.toString())),
      child: BlocConsumer<AuthLoginBloc, AuthLoginState>(
        listenWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go(ApplicationRoutesConstants.dashboard);
              }
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(BootstrapIcons.alarm, size: 44),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).typography.h3.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to manage your workspace.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).typography.medium,
                          ),
                          const SizedBox(height: 28),
                          ReactiveForm(
                            formGroup: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _meta.fields.length,
                                  itemBuilder: (context, index) {
                                    final field = _meta.fields[index];
                                    return ReactiveShadcnInputField(
                                      field: field,
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                ),
                                const SizedBox(height: 20),
                                if (state is AuthLoginError)
                                  Text(
                                    state.message,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colors.destructive,
                                    ),
                                  ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Button(
                                      variant: ButtonVariant.text,
                                      onPressed: () {},
                                      child: const Text('Forgot password'),
                                    ),
                                    Button(
                                      variant: ButtonVariant.primary,
                                      onPressed: () {
                                        _form.markAllAsTouched();
                                        if (_form.valid) {
                                          final formValue = _form.value;
                                          final request = LoginRequest(
                                            email: formValue['email'] as String,
                                            password:
                                                formValue['password'] as String,
                                          );
                                          context.read<AuthLoginBloc>().add(
                                            LoadAuthLoginEvent(
                                              request: request,
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        ComponentLocalizations.of(
                                          context,
                                        ).authSignIn,
                                      ),
                                      // child: state is AuthLoginLoading
                                      //     ? const BorderLoading(
                                      //         mode: BorderLoadingMode.tracer,
                                      //         tracer: BorderTracerSpec(
                                      //           lengthFraction: 0.12,
                                      //           dashCount: 2,
                                      //         ),
                                      //         spec: BorderGradientSpec(
                                      //           type: BorderGradientType.linear,
                                      //           colors: [
                                      //             Color(0xFF3B82F6),
                                      //             Color(0xFF22C55E),
                                      //           ],
                                      //         ),
                                      //         child: Padding(
                                      //           padding: EdgeInsets.symmetric(
                                      //             horizontal: 18,
                                      //             vertical: 12,
                                      //           ),
                                      //           child: Text('Logging...'),
                                      //         ),
                                      //       )
                                      //     : const Text('Submit'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
