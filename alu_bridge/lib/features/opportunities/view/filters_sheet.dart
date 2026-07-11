import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/discovery_bloc.dart';
import '../models/opportunity_filters.dart';

class FiltersSheet extends StatelessWidget {
  const FiltersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryBloc, DiscoveryState>(
      builder: (context, state) {
        final bloc = context.read<DiscoveryBloc>();
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Function', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final function in OpportunityFunction.options)
                    FilterChip(
                      label: Text(function),
                      selected: state.filters.functions.contains(function),
                      onSelected: (_) => bloc.add(DiscoveryFunctionToggled(function)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Type', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in OpportunityType.options)
                    FilterChip(
                      label: Text(type),
                      selected: state.filters.types.contains(type),
                      onSelected: (_) => bloc.add(DiscoveryTypeToggled(type)),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Show results',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}
