import 'package:equatable/equatable.dart';

sealed class ModuleCrudEvent extends Equatable {
  const ModuleCrudEvent();

  @override
  List<Object?> get props => const [];
}

class ModuleStarted extends ModuleCrudEvent {
  const ModuleStarted({this.recordId});

  final String? recordId;

  @override
  List<Object?> get props => [recordId];
}

class ModuleRefreshRequested extends ModuleCrudEvent {
  const ModuleRefreshRequested();
}

class ModuleSearchChanged extends ModuleCrudEvent {
  const ModuleSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ModuleFiltersChanged extends ModuleCrudEvent {
  const ModuleFiltersChanged(this.filters);

  final Map<String, dynamic> filters;

  @override
  List<Object?> get props => [filters];
}

class ModulePageChanged extends ModuleCrudEvent {
  const ModulePageChanged(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
}

class ModuleCreateRequested extends ModuleCrudEvent {
  const ModuleCreateRequested();
}

class ModuleDetailRequested extends ModuleCrudEvent {
  const ModuleDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ModuleEditRequested extends ModuleCrudEvent {
  const ModuleEditRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ModuleFormSubmitted extends ModuleCrudEvent {
  const ModuleFormSubmitted(this.data);

  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

class ModuleDeleteRequested extends ModuleCrudEvent {
  const ModuleDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ModuleBackRequested extends ModuleCrudEvent {
  const ModuleBackRequested();
}
