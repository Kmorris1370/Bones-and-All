import 'package:flutter/material.dart';
import '../api/blocks_api.dart';
import '../models/block.dart';
import '../theme.dart';
import '../utils/logger.dart';
import 'add_block_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'block_detail_screen.dart';
import 'manual_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Block> _blocks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  void _showAddBlockOptions() {
    final hasPain = _blocks.any((b) => b.blockType == 'pain');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F2EB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Section',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (!hasPain)
              ListTile(
                leading: const Icon(Icons.accessibility_new,
                    color: Color(0xFF4A6741)),
                title: const Text('Pain'),
                subtitle: const Text('Track pain location, type and scale'),
                onTap: () async {
                  Navigator.pop(context);
                  await BlocksApi.createBlock('Pain', 'pain');
                  _loadBlocks();
                },
              ),
            if (hasPain)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('All templates are already active.',
                    style: TextStyle(color: Colors.grey)),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle_outline,
                  color: Color(0xFF4A6741)),
              title: const Text('Create Custom Block'),
              subtitle: const Text('Build your own tracking section'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBlockScreen()),
                ).then((_) => _loadBlocks());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadBlocks() async {
    AppLogger.debug('MainScreen', 'Loading blocks');
    setState(() => _loading = true);
    try {
      final data = await BlocksApi.getBlocks();
      setState(() {
        _blocks = data.map((b) => Block.fromJson(b)).toList();
        _loading = false;
      });
      AppLogger.debug('MainScreen', 'Loaded ${_blocks.length} blocks');
    } catch (e) {
      AppLogger.error('MainScreen', 'Failed to load blocks', e);
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not connect to server. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteBlock(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Block'),
        content: const Text(
            'This will permanently delete this block and all its records. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    AppLogger.debug('MainScreen', 'Deleting block $id');
    await BlocksApi.deleteBlock(id);
    _loadBlocks();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Text(
                'Bones and All',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Manual / FAQ'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (_) => const ManualScreen()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Bones and All'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBlocks,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIndex, newIndex) async {
                      if (newIndex > oldIndex) newIndex--;
                      setState(() {
                        final block = _blocks.removeAt(oldIndex);
                        _blocks.insert(newIndex, block);
                      });
                      for (int i = 0; i < _blocks.length; i++) {
                        await BlocksApi.updateBlock(_blocks[i].id, {
                          'display_order': i,
                        });
                      }
                    },
                    children: [
                      if (_blocks.isEmpty)
                        const Padding(
                          key: ValueKey('empty'),
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No blocks added yet.\nTap "+ add section" to get started.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                      ..._blocks
                          .map(
                            (b) => Card(
                              key: ValueKey(b.id),
                              color: AppColors.surface,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.drag_handle),
                                title: Text(
                                  b.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () async {
                                        final ctrl = TextEditingController(text: b.name);
                                        final newName = await showDialog<String>(
                                          context: ctx,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Rename Block'),
                                            content: TextField(
                                              controller: ctrl,
                                              decoration: const InputDecoration(
                                                labelText: 'Block name',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  ctx,
                                                  ctrl.text.trim(),
                                                ),
                                                child: const Text(
                                                  'Save',
                                                  style: TextStyle(color: AppColors.primary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (newName != null && newName.isNotEmpty) {
                                          await BlocksApi.updateBlock(b.id, {'name': newName});
                                          _loadBlocks();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteBlock(b.id),
                                    ),
                                  ],
                                ),
                                onTap: () => Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => BlockDetailScreen(block: b),
                                  ),
                                ).then((_) => _loadBlocks()),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showAddBlockOptions(),
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: const Text(
                      'add section',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
