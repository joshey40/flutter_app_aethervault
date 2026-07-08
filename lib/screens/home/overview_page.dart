import 'package:flutter/material.dart';

import '../../models/vault_user.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.user});

  final VaultUser user;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Overview Page',
        ),
      ),
    );
  }
}
