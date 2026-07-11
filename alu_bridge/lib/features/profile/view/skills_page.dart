import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../cubit/profile_cubit.dart';
import '../models/skill.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final _customSkillController = TextEditingController();

  @override
  void dispose() {
    _customSkillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your skills')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) => previous.saveStatus != current.saveStatus,
        listener: (context, state) {
          if (state.saveStatus == ProfileSaveStatus.success) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (state.saveStatus == ProfileSaveStatus.failure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What can you help with?', style: AppTextStyles.h2),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in Skill.suggestions)
                      FilterChip(
                        label: Text(skill),
                        selected: state.skills.contains(skill),
                        onSelected: (_) => cubit.toggleSkill(skill),
                      ),
                    for (final skill in state.skills)
                      if (!Skill.suggestions.contains(skill))
                        FilterChip(
                          label: Text(skill),
                          selected: true,
                          onSelected: (_) => cubit.toggleSkill(skill),
                        ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customSkillController,
                        decoration:
                            const InputDecoration(hintText: 'Add another skill'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.navy),
                      onPressed: () {
                        final value = _customSkillController.text.trim();
                        if (value.isEmpty) return;
                        cubit.toggleSkill(value);
                        _customSkillController.clear();
                      },
                    ),
                  ],
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Finish',
                  loading: state.saveStatus == ProfileSaveStatus.saving,
                  onPressed: state.skills.isEmpty ? null : cubit.save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
