import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ud_sass_app/core/config/environment.dart';
import 'package:ud_sass_app/core/forms/app_reactive_form.dart';
import 'package:ud_sass_app/core/forms/helper/entity_meta_helper.dart';
import 'package:ud_sass_app/core/forms/models/entity_meta.dart';
import 'package:ud_sass_app/core/navigation/app_navigation.dart';
import 'package:ud_sass_app/features/auth/auth.dart';
import 'package:ud_sass_app/routes/app_routes_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Map<String, dynamic> _schema = {
    'entityName': 'Sign in',
    'fields': [
      {
        'name': 'email',
        'label': 'Email',
        'type': 'email',
        'placeholder': 'you@example.com',
        'validationRules': {'required': true, 'email': true},
      },
      {
        'name': 'password',
        'label': 'Password',
        'type': 'password',
        'placeholder': 'Enter your password',
        'validationRules': {'required': true, 'minLength': 8},
      },
    ],
  };

  late final EntityMeta _meta = entityMetaFromJson(_schema);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AuthLoginBloc(AuthService(baseUrl: ProfileConstants.api.toString())),
      child: BlocConsumer<AuthLoginBloc, AuthLoginState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            context.go(ApplicationRoutesConstants.dashboard);
          }
        },
        builder: (context, state) => Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 44,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to manage your workspace.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 28),
                          if (state is AuthLoginError) ...[
                            _LoginError(message: state.message),
                            const SizedBox(height: 16),
                          ],
                          AppReactiveForm(
                            meta: _meta,
                            initialData: const {'email': 'demo@example.test'},
                            onSubmit: (data) async {
                              context.read<AuthLoginBloc>().add(
                                LoadAuthLoginEvent(
                                  request: LoginRequest(
                                    email: data['email']?.toString() ?? '',
                                    password:
                                        data['password']?.toString() ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Forgot password'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginError extends StatelessWidget {
  const _LoginError({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      ],
    ),
  );
}
