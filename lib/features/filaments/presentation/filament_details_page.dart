import 'package:filament_os/features/filaments/presentation/filament_by_id_provider.dart';
import 'package:filament_os/features/filaments/presentation/filament_color_label.dart';
import 'package:filament_os/shared/presentation/error_message_view.dart';
import 'package:filament_os/shared/presentation/weight_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detalhe de um filamento, alcançada por `/filaments/<id>`.
///
/// Recebe o `id`, e não o `Filament`, para funcionar por deep link. Id
/// inexistente chega como `null` em `data`: não achar não é falha.
/// Ver ADR 0006.
class FilamentDetailsPage extends StatelessWidget {
  final String id;

  const FilamentDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(id)),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final filament = ref.watch(filamentByIdProvider(id));
            return filament.when(
              data: (data) => data == null
                  ? Center(
                      child: Text(
                        'Filamento indisponível',
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Text(data.name),
                        const Divider(),
                        Text(data.color.label),
                        const Divider(),
                        Text(data.weight.label),
                      ],
                    ),
              error: (err, stack) => ErrorMessageView(error: err),
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
