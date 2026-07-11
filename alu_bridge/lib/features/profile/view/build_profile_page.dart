import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../cubit/profile_cubit.dart';
import 'skills_page.dart';

class BuildProfilePage extends StatelessWidget {
  const BuildProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Build your profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Tell ventures about yourself', style: AppTextStyles.h2),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Headline',
                hintText: 'e.g. Second-year CS student',
                onChanged: cubit.headlineChanged,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Programme',
                hintText: 'e.g. BSc Software Engineering',
                onChanged: cubit.programmeChanged,
              ),
              const SizedBox(height: 16),
              Text('Year of study', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (var year = 1; year <= 4; year++)
                    ChoiceChip(
                      label: Text('Year $year'),
                      selected: state.yearOfStudy == year,
                      onSelected: (_) => cubit.yearOfStudyChanged(year),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Bio',
                hintText: 'A few sentences about your interests and goals',
                onChanged: cubit.bioChanged,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Next: skills',
                onPressed:
                    state.headline.trim().isEmpty || state.programme.trim().isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: cubit,
                                  child: const SkillsPage(),
                                ),
                              ),
                            ),
              ),
            ],
          );
        },
      ),
    );
  }
}
