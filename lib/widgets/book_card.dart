
import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../screens/catalog/book_details_screen.dart';
import '../services/auth_service.dart';
import '../services/wishlist_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/auth_guard.dart';
import 'book_cover_placeholder.dart';

class BookCard extends StatefulWidget {
final BookModel book;
final double width;
final VoidCallback? onTap;

const BookCard({
super.key,
required this.book,
this.width = 150,
this.onTap,
});

@override
State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
bool _wishlisted = false;
bool _wishlistLoading = false;

@override
void initState() {
super.initState();
_checkWishlist();
}

Future<void> _checkWishlist() async {
try {
final id = await AuthService().currentUserId();

if (id == null || widget.book.id == null) return;

final saved = await WishlistService.instance.isWishlisted(
id,
widget.book.id!,
);

if (!mounted) return;

setState(() {
_wishlisted = saved;
});
} catch (_) {
// Keep the default wishlist state if checking fails.
}
}

Future<void> _toggleWishlist() async {
if (_wishlistLoading) return;

final ok = await AuthGuard.requireLogin(context);
if (!ok || !mounted) return;

setState(() {
_wishlistLoading = true;
});

try {
final id = await AuthService().currentUserId();

if (id == null) {
if (!mounted) return;
return;
}

await WishlistService.instance.toggle(id, widget.book);

if (!mounted) return;

setState(() {
_wishlisted = !_wishlisted;
});
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Unable to update wishlist. Please try again.'),
),
);
} finally {
if (mounted) {
setState(() {
_wishlistLoading = false;
});
}
}
}

void _openBook() {
if (widget.onTap != null) {
widget.onTap!();
return;
}

Navigator.push(
context,
MaterialPageRoute(
builder: (_) => BookDetailsScreen(book: widget.book),
),
);
}

@override
Widget build(BuildContext context) {
final book = widget.book;

return SizedBox(
width: widget.width,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisSize: MainAxisSize.min,
children: [
Stack(
children: [
GestureDetector(
onTap: _openBook,
child: AspectRatio(
aspectRatio: 1 / 1.45,
child: BookCoverPlaceholder(
title: book.title,
author: book.author,
background: _coverColor(book.genre),
imagePath: book.coverImage.isNotEmpty
? book.coverImage
    : null,
),
),
),
if (book.badge.isNotEmpty)
Positioned(
top: 10,
left: 10,
child: _badge(book.badge),
),
Positioned(
top: 8,
right: 8,
child: GestureDetector(
onTap: _toggleWishlist,
child: Container(
width: 32,
height: 32,
decoration: BoxDecoration(
color: AppColors.white.withValues(alpha: 0.9),
shape: BoxShape.circle,
),
child: _wishlistLoading
? const Padding(
padding: EdgeInsets.all(9),
child: CircularProgressIndicator(
strokeWidth: 2,
),
)
    : Icon(
_wishlisted
? Icons.favorite
    : Icons.favorite_border,
size: 16,
color: _wishlisted
? AppColors.danger
    : AppColors.ink,
),
),
),
),
],
),
const SizedBox(height: 10),
Text(
book.genre.toUpperCase(),
style: AppTextStyles.eyebrow,
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 4),
SizedBox(
height: 44,
child: Text(
book.title,
style: AppTextStyles.title,
maxLines: 2,
overflow: TextOverflow.ellipsis,
),
),
const SizedBox(height: 4),
Text(
'by ${book.author}',
style: AppTextStyles.small,
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 8),
Row(
children: [
Text(
'\$${book.price.toStringAsFixed(2)}',
style: AppTextStyles.body.copyWith(
fontWeight: FontWeight.w600,
),
),
const Spacer(),
const Icon(
Icons.star,
color: AppColors.gold,
size: 14,
),
const SizedBox(width: 3),
Text(
book.rating.toStringAsFixed(1),
style: AppTextStyles.small,
),
],
),
],
),
);
}

Widget _badge(String badge) {
final normalized = badge.toLowerCase();

final label = normalized == 'bestseller'
? 'BESTSELLER'
    : normalized == 'new'
? 'NEW'
    : "EDITOR'S PICK";

return Container(
padding: const EdgeInsets.symmetric(
horizontal: 8,
vertical: 4,
),
color: AppColors.forest,
child: Text(
label,
style: const TextStyle(
fontFamily: 'Inter',
fontSize: 8,
fontWeight: FontWeight.w600,
color: AppColors.white,
letterSpacing: 1,
),
),
);
}

Color _coverColor(String genre) {
switch (genre) {
case 'Mindfulness':
return AppColors.tan;
case 'Fiction':
return AppColors.forest;
case 'Science':
return const Color(0xFF2A3D4F);
case 'Nature':
return const Color(0xFFE8E4D0);
case 'Mystery':
return const Color(0xFF1B2838);
case 'Romance':
return const Color(0xFFE3C7C7);
default:
return AppColors.tan;
}
}
}
