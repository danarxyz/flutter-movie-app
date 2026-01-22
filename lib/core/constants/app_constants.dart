class AppConstants {
  // Network
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  
  // Titles
  static const String appName = 'Watchly';
  static const String trendingTitle = 'Trending Now';
  static const String popularMoviesTitle = 'Popular Movies';
  static const String popularTVTitle = 'Popular TV Shows';
  static const String popularAnimeTitle = 'Popular Anime';
  static const String topRatedMoviesTitle = 'Top Rated Movies';
  static const String topTVTitle = 'Top TV Series';
  static const String topAnimeTitle = 'Top Anime';
  static const String forYouTitle = 'For You';
  static const String seeAll = 'See all';

  // Categories / API Keys
  static const String catTrendingMovie = 'trending_movie';
  static const String catTrendingTV = 'trending_tv';
  static const String catPopularMovie = 'popular_movie';
  static const String catPopularTV = 'popular_tv';
  static const String catAnime = 'anime';
  static const String catTopRatedMovie = 'top_rated_movie';

  // Routes
  static const String routeList = '/list';
  static const String routeProfile = '/profile';
  
  // Image Base URL
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String imageLowResUrl = 'https://image.tmdb.org/t/p/w300';
}

enum ContentFilter {
  movies(0, 'Movies'),
  tvShows(1, 'TV Shows'),
  anime(2, 'Anime');

  final int id;
  final String label;

  const ContentFilter(this.id, this.label);
}
