import 'package:flutter/material.dart' hide Card;

import 'package:ud_sass_app/ui/shadcn/components/layout/card/card.dart';
// import '../../../routes/app_routes_constants.dart';
import 'login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const Card(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  padding: EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [LoginForm()],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
