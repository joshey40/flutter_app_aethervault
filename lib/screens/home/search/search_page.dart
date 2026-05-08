import 'package:flutter/material.dart';

import '../../../services/localization_service.dart';



// ---------------------------------------------------------------------------
// Search Page
// ---------------------------------------------------------------------------

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  void initState() {
    super.initState();
    
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = 
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('nav.search')),
        
      ),
      body: Column(
        
      ),
    );
  }
}
