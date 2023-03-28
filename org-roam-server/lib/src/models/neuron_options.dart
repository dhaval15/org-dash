class NeuronOptions {
  final bool insertGhostNodes;
  final List<String>? linkTypes;

  const NeuronOptions({
    required this.insertGhostNodes,
    this.linkTypes,
  });

  static const defaultOptions = NeuronOptions(
    insertGhostNodes: false,
  );

  factory NeuronOptions.fromJson(Map<String, dynamic> json) => NeuronOptions(
        insertGhostNodes: json['insertGhostNodes'] ?? false,
        linkTypes: json['linkTypes'],
      );

  Map<String, dynamic> toJson() => {
        'insertGhostNodes': insertGhostNodes,
        'linkTypes': linkTypes,
      };
}
