import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/book_card.dart';
import '../../widgets/book_cover_placeholder.dart';
import '../../widgets/section_header.dart';
import '../../utils/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          children: [
            // ── Top bar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.heading.copyWith(fontSize: 22),
                      children: const [
                        TextSpan(text: 'leaf '),
                        TextSpan(
                          text: '&',
                          style: TextStyle(color: AppColors.gold),
                        ),
                        TextSpan(text: ' lore'),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => AppState.selectedTab.value = 1,   // Browse
                        icon: const Icon(Icons.search, color: AppColors.ink),
                      ),
                      IconButton(
                        onPressed: () => AppState.selectedTab.value = 3,   // Cart
                        icon: const Icon(Icons.shopping_bag_outlined,
                            color: AppColors.ink),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Greeting ────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'YOUR LITTLE CORNER OF STORIES',
                style: AppTextStyles.eyebrow,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.display,
                  children: const [
                    TextSpan(text: 'Good morning,\n'),
                    TextSpan(
                      text: 'reader.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.forest,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Hero card ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _heroCard(),
            ),

            const SizedBox(height: 32),

            // ── Editor's Picks ──────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                eyebrow: 'FEATURED BOOKS',
                title: "Editor's picks",
              ),
            ),
            const SizedBox(height: 16),
            _horizontalBooks(MockData.books.take(5).toList()),

            const SizedBox(height: 32),

            // ── Browse by mood ──────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                eyebrow: 'FOLLOW YOUR CURIOSITY',
                title: 'Browse by mood',
              ),
            ),
            const SizedBox(height: 16),
            _moodCards(),

            const SizedBox(height: 32),

            // ── The Reading Room ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _readingRoomCard(),
            ),

            const SizedBox(height: 32),

            // ── Bestsellers ─────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                eyebrow: 'READER FAVORITES',
                title: 'Bestsellers',
              ),
            ),
            const SizedBox(height: 16),
            _horizontalBooks(MockData.bestsellers()),

            const SizedBox(height: 32),

            // ── New arrivals ────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                eyebrow: 'FRESH OFF THE PRESS',
                title: 'New arrivals',
              ),
            ),
            const SizedBox(height: 16),
            _horizontalBooks(MockData.newArrivals()),

            const SizedBox(height: 32),

            // ── Newsletter ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _newsletterCard(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero card ──────────────────────────────────────────
  Widget _heroCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'THE JOY OF A GOOD BOOK',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.sage,
              letterSpacing: 1.5,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Find a story that',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 26,
                  color: AppColors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'stays with you.',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 26,
                  color: AppColors.gold,
                  fontStyle: FontStyle.italic,
                  height: 1.1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explore collection',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forest,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 14, color: AppColors.forest),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Horizontal book scroll ─────────────────────────────
  Widget _horizontalBooks(List books) {
    return SizedBox(
      height: 370,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => BookCard(
          book: books[i],
          width: 150,
        ),
      ),
    );
  }

  // ── Mood cards row ─────────────────────────────────────
  Widget _moodCards() {
    final moods = [
      {'label': 'Fiction', 'icon': Icons.auto_awesome},
      {'label': 'Mindfulness', 'icon': Icons.circle_outlined},
      {'label': 'Nature', 'icon': Icons.local_florist_outlined},
      {'label': 'Mystery', 'icon': Icons.nightlight_outlined},
      {'label': 'Romance', 'icon': Icons.favorite_border},
      {'label': 'Science', 'icon': Icons.star_outline},
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: moods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final m = moods[i];
          return Container(
            width: 130,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  m['icon'] as IconData,
                  color: AppColors.forest,
                  size: 22,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m['label'] as String,
                        style: AppTextStyles.title.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 16, color: AppColors.inkMuted),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── The Reading Room card ──────────────────────────────
  Widget _readingRoomCard() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'THE READING ROOM',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.forest,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Text(
                    'Some stories are\nworth sharing.',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                      height: 1.15,
                    ),
                  ),
                  Row(
                    children: const [
                      Text(
                        'Shop bestsellers',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forest,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward,
                          size: 14, color: AppColors.forest),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Transform.rotate(
              angle: 0.12,
              child: const Padding(
                padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: BookCoverPlaceholder(
                  title: 'The Art of Stillness',
                  author: 'Elena Marlowe',
                  width: 120,
                  height: 170,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Newsletter card ────────────────────────────────────
  Widget _newsletterCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.mail_outline, color: AppColors.gold, size: 24),
          SizedBox(height: 12),
          Text(
            'A little literary letter.',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 22,
              color: AppColors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'New reads, thoughtful notes, and bookish things.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.sage,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your email address',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.sage,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}