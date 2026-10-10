
import 'package:flutter/material.dart';


import '../../services/auth_service.dart';

import '../../services/wishlist_service.dart';


class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _loading = true;
  String? _error;
  List<WishlistItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = await AuthService().currentUserId();

      if (userId == null) {
        if (!mounted) return;
        setState(() {
          _items = [];
          _loading = false;
        });
        return;
      }

      final items = await WishlistService.instance.getItems(userId);

      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your wishlist.';
        _loading = false;
      });
    }
  }

  Future<void> _removeItem(WishlistItem item) async {
    try {
      await WishlistService.instance.remove(item.userId, item.bookId);

      if (!mounted) return;
      setState(() {
        _items.removeWhere((saved) => saved.bookId == item.bookId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book removed from wishlist')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove this book')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadWishlist,
              child: const Text('Try again'),
            ),
          ],
        ),
      )
          : _items.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 56),
              SizedBox(height: 12),
              Text(
                'Your wishlist is empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Save books you love and they will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadWishlist,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _items.length,
          separatorBuilder: (_, _) =>
          const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _items[index];

            return Card(
              child: ListTile(
                leading: const Icon(
                  Icons.menu_book,
                  size: 36,
                ),
                title: Text(item.title),
                subtitle: Text(
                  '${item.author}\n'
                      '${item.genre} • '
                      '₦${item.price.toStringAsFixed(2)}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: 'Remove from wishlist',
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  onPressed: () => _removeItem(item),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
