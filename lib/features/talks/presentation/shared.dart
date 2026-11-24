import 'package:material_ui/material_ui.dart';

const ink = Color(0xFF143B34);
const paper = Color(0xFFFFFCF4);
const lime = Color(0xFFD9F49B);

class Sheet extends StatelessWidget {
  final List<Widget> children;
  const Sheet({super.key, required this.children});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: children,
        ),
      ),
    ),
  );
}

class Cover extends StatelessWidget {
  final String label, title, detail;
  const Cover(this.label, this.title, this.detail, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: ink,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: lime,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Semantics(
          header: true,
          child: Text(
            title,
            style: const TextStyle(
              color: paper,
              fontSize: 32,
              height: 1.12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(detail, style: const TextStyle(color: paper, fontSize: 16)),
      ],
    ),
  );
}

class FeedbackLine extends StatelessWidget {
  final String? error;
  const FeedbackLine(this.error, {super.key});
  @override
  Widget build(BuildContext context) => error == null
      ? const SizedBox.shrink()
      : Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
}

Future<T?> page<T>(BuildContext context, Widget child) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => child));

Future<bool> confirm(
  BuildContext context,
  String title,
  String detail,
  String action,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(detail),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
