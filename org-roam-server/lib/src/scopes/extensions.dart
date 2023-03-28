import 'scope.dart';

extension ScopeListExtension on List<Scope> {
  List<Map<String, dynamic>> toJson() => this.map((e) => e.toJson()).toList();
}
