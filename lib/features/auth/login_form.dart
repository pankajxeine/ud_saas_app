import 'package:flutter/material.dart' hide Form, FormField, TextField;
import 'package:go_router/go_router.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/i10n/i10n.dart';
import 'package:ud_sass_app/ui/shadcn/components/form/text_field/text_field.dart';
import 'auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ud_sass_app/ui/shadcn/components/form/form/form.dart';
import 'package:ud_sass_app/ui/shadcn/components/control/button/_impl/variants/button_variants.dart';
import 'package:ud_sass_app/ui/shadcn/components/display/text/text.dart';
import '../../routes/app_routes_constants.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameKey = const TextFieldKey('username');
  final _passwordKey = const TextFieldKey('password');

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context)!;

    return BlocProvider(
        create: (_) => AuthLoginBloc(
              AuthService(baseUrl: ProfileConstants.api.toString()),
            ),
        // The State object's build context is above this BlocProvider. Create a
        // descendant context before reading the bloc in the submit callback.
        child: Builder(
          builder: (context) => BlocListener<AuthLoginBloc, AuthLoginState>(
            listener: (context, state) {
              if (state is AuthLoginSuccess) {
                context.go(ApplicationRoutesConstants.dashboard);
              }
            },
            child: Form(
              onSubmit: (context, values) {
                context.read<AuthLoginBloc>().add(
                      LoadAuthLoginEvent(
                        request: LoginRequest(
                          email: values.getValue(_usernameKey) ?? '',
                          password: values.getValue(_passwordKey) ?? '',
                          audience: 'admin',
                        ),
                      ),
                    );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandMark(),
                  const SizedBox(height: 22),
                  Text(localization.login_with_email).h3().semiBold(),
                  const SizedBox(height: 6),
                  Text(localization.workspace_overview).muted(),
                  const SizedBox(height: 28),
                  FormField(
                    key: _usernameKey,
                    label: Text(localization.login_user_name),
                    hint: Text(localization.email),
                    validator: const LengthValidator(min: 4),
                    child: TextField(
                      placeholder: Text(localization.email),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                    ),
                  ),
                  const SizedBox(height: 18),
                  FormField(
                    key: _passwordKey,
                    label: Text(localization.login_password),
                    trailingLabel: LinkButton(
                      onPressed: () => context.go(
                        ApplicationRoutesConstants.forgotPassword,
                      ),
                      child: Text(localization.password_forgot),
                    ),
                    validator: const LengthValidator(min: 8),
                    child: TextField(
                      placeholder: Text(localization.login_password),
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      features: const [InputFeature.passwordToggle()],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthLoginBloc, AuthLoginState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoginLoading;
                      final serverError =
                          state is AuthLoginError ? state.message : null;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (serverError != null) ...[
                            Text(
                              serverError,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          FormErrorBuilder(
                            builder: (context, errors, child) {
                              return PrimaryButton(
                                onPressed: errors.isEmpty && !isLoading
                                    ? () => context.submitForm()
                                    : null,
                                child: Text(
                                  isLoading
                                      ? localization.loading
                                      : localization.login_button,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.auto_awesome, color: colors.onPrimary),
        ),
        const SizedBox(width: 12),
        const Text('NEXUS').semiBold().xLarge(),
      ],
    );
  }
}
