import '../models/book_model.dart';

class MockData {
  static final List<BookModel> books = [
    BookModel(
      id:1,
      title: 'The Art of Stillness',
      author: 'Elena Marlowe',
      genre: 'Mindfulness',
      description:
      'An invitation to slow down, notice the small things, and find '
          'wonder in the spaces between.',
      coverImage: '',
      price: 24.99, rating: 4.9, reviewCount: 128,
      badge: 'bestseller', publishedDate: 'March 2025',
    ),
    BookModel(
      id:2,
      title: 'Between the Pines',
      author: 'Noah Reid',
      genre: 'Fiction',
      description: 'A quiet novel about returning home.',
      coverImage: '',
      price: 18.50, rating: 4.7, reviewCount: 96,
      badge: 'editors_pick', publishedDate: 'January 2025',
    ),
    BookModel(
      id:3,
      title: 'The Quiet Universe',
      author: 'Daniel Cho',
      genre: 'Science',
      description: 'A luminous exploration of the cosmos.',
      coverImage: '',
      price: 25.00, rating: 4.9, reviewCount: 128,
      publishedDate: 'January 2025',
    ),
    BookModel(
      id:4,
      title: 'A Field Guide to Wonder',
      author: 'Mara Finch',
      genre: 'Nature',
      description: 'A gentle companion for a more intentional life.',
      coverImage: '',
      price: 21.99, rating: 4.8, reviewCount: 82,
      badge: 'new', publishedDate: 'March 2025',
    ),
    BookModel(
      id:5,
      title: 'Small Rituals',
      author: 'Clara West',
      genre: 'Mindfulness',
      description: 'Everyday practices for a slower, kinder life.',
      coverImage: '',
      price: 16.99, rating: 4.8, reviewCount: 64,
      badge: 'new', publishedDate: 'April 2025',
    ),
    BookModel(
      id:6,
      title: 'The Night Archive',
      author: 'Julian Bell',
      genre: 'Mystery',
      description: 'A librarian discovers a hidden collection.',
      coverImage: '',
      price: 27.00, rating: 4.6, reviewCount: 110,
      publishedDate: 'February 2025',
    ),
    BookModel(
      id:7,
      title: 'Wildflower Season',
      author: 'Sophie Hart',
      genre: 'Romance',
      description: 'A slow-burn love story set in a coastal town.',
      coverImage: '',
      price: 19.99, rating: 4.7, reviewCount: 91,
      badge: 'bestseller', publishedDate: 'May 2025',
    ),
    BookModel(
      id:8,
      title: 'The Shape of Tomorrow',
      author: 'Iris Bennett',
      genre: 'Fiction',
      description: 'Speculative short stories about the near future.',
      coverImage: '',
      price: 22.00, rating: 4.5, reviewCount: 74,
      publishedDate: 'June 2025',
    ),
  ];

  static List<BookModel> byGenre(String genre) =>
      genre == 'All' ? books : books.where((b) => b.genre == genre).toList();

  static List<BookModel> bestsellers() =>
      books.where((b) => b.badge == 'bestseller').toList();

  static List<BookModel> newArrivals() =>
      books.where((b) => b.badge == 'new').toList();
}