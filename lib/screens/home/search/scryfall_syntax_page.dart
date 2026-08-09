import 'package:flutter/material.dart';

class ScryfallSyntaxPage extends StatelessWidget {
  const ScryfallSyntaxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scryfall Syntax Guide"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Content",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}