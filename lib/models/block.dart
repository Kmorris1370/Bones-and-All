class Block {
  final String id;
  final String name;
  final String blockType;
  final int displayOrder;

  Block({
    required this.id,
    required this.name,
    required this.blockType,
    required this.displayOrder,
  });

  factory Block.fromJson(Map<String, dynamic> j) => Block(
    id: j['id'],
    name: j['name'],
    blockType: j['block_type'],
    displayOrder: j['display_order'] ?? 0,
  );
}