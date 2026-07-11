import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bootstrap.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/models/skill.dart';
import '../../ventures/models/venture.dart';
import '../bloc/opportunity_form_bloc.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';
import '../models/opportunity_filters.dart';

class PostRolePage extends StatelessWidget {
  const PostRolePage({required this.venture, this.existing, super.key});

  final Venture venture;
  final Opportunity? existing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OpportunityFormBloc(
        opportunityRepository: sl<OpportunityRepository>(),
        ventureId: venture.id,
        ventureName: venture.name,
        ventureLogoUrl: venture.logoUrl,
        verified: venture.isVerified,
        existing: existing,
      ),
      child: _PostRoleView(existing: existing),
    );
  }
}

class _PostRoleView extends StatefulWidget {
  const _PostRoleView({this.existing});

  final Opportunity? existing;

  @override
  State<_PostRoleView> createState() => _PostRoleViewState();
}

class _PostRoleViewState extends State<_PostRoleView> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _commitmentController = TextEditingController();
  final _durationController = TextEditingController();
  final _stipendController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibilityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController.text = existing.title;
      _locationController.text = existing.location;
      _commitmentController.text = existing.commitment;
      _durationController.text = existing.duration;
      _stipendController.text = existing.stipend;
      _descriptionController.text = existing.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _commitmentController.dispose();
    _durationController.dispose();
    _stipendController.dispose();
    _descriptionController.dispose();
    _responsibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Post a role' : 'Edit role')),
      body: BlocConsumer<OpportunityFormBloc, OpportunityFormState>(
        listenWhen: (previous, current) => previous.submitStatus != current.submitStatus,
        listener: (context, state) {
          if (state.submitStatus == OpportunityFormSubmitStatus.failure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.submitStatus == OpportunityFormSubmitStatus.success) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final bloc = context.read<OpportunityFormBloc>();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppTextField(
                label: 'Role title',
                controller: _titleController,
                onChanged: (v) =>
                    bloc.add(OpportunityFormFieldChanged(OpportunityFormField.title, v)),
              ),
              const SizedBox(height: 16),
              Text('Function', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final function in OpportunityFunction.options)
                    ChoiceChip(
                      label: Text(function),
                      selected: state.function == function,
                      onSelected: (_) => bloc.add(
                        OpportunityFormFieldChanged(OpportunityFormField.function, function),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Type', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in OpportunityType.options)
                    ChoiceChip(
                      label: Text(type),
                      selected: state.type == type,
                      onSelected: (_) => bloc.add(
                        OpportunityFormFieldChanged(OpportunityFormField.type, type),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Location',
                hintText: 'e.g. Kigali or Remote',
                controller: _locationController,
                onChanged: (v) =>
                    bloc.add(OpportunityFormFieldChanged(OpportunityFormField.location, v)),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Commitment',
                hintText: 'e.g. 10 hrs/week',
                controller: _commitmentController,
                onChanged: (v) => bloc
                    .add(OpportunityFormFieldChanged(OpportunityFormField.commitment, v)),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Duration',
                hintText: 'e.g. 3 months',
                controller: _durationController,
                onChanged: (v) =>
                    bloc.add(OpportunityFormFieldChanged(OpportunityFormField.duration, v)),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Stipend',
                hintText: 'e.g. Unpaid or RWF 50,000/month',
                controller: _stipendController,
                onChanged: (v) =>
                    bloc.add(OpportunityFormFieldChanged(OpportunityFormField.stipend, v)),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                controller: _descriptionController,
                onChanged: (v) => bloc
                    .add(OpportunityFormFieldChanged(OpportunityFormField.description, v)),
              ),
              const SizedBox(height: 16),
              Text('Responsibilities', style: AppTextStyles.label),
              const SizedBox(height: 8),
              for (final responsibility in state.responsibilities)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(responsibility, style: AppTextStyles.body),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        bloc.add(OpportunityFormResponsibilityRemoved(responsibility)),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _responsibilityController,
                      decoration: const InputDecoration(hintText: 'Add a responsibility'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      final value = _responsibilityController.text.trim();
                      if (value.isEmpty) return;
                      bloc.add(OpportunityFormResponsibilityAdded(value));
                      _responsibilityController.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Required skills', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final skill in Skill.suggestions)
                    FilterChip(
                      label: Text(skill),
                      selected: state.requiredSkills.contains(skill),
                      onSelected: (_) => bloc.add(OpportunityFormSkillToggled(skill)),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.submitStatus == OpportunityFormSubmitStatus.submitting
                          ? null
                          : () => bloc.add(const OpportunityFormSubmitted(asDraft: true)),
                      child: const Text('Save as draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Publish',
                      loading: state.submitStatus == OpportunityFormSubmitStatus.submitting,
                      onPressed: () =>
                          bloc.add(const OpportunityFormSubmitted(asDraft: false)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
