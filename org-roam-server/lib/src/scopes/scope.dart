class Scope {
  final String id;
  final String label;
  final String expr;

  const Scope({
    required this.id,
    required this.label,
    required this.expr,
  });

  factory Scope.fromJson(Map<String, dynamic> json) => Scope(
        id: json['id'],
        label: json['label'],
        expr: json['expr'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'expr': expr,
      };
}
