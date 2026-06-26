class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      PaginationMeta(
        page: json['page'] ?? 1,
        limit: json['limit'] ?? 20,
        total: json['total'] ?? 0,
        pages: json['pages'] ?? 1,
      );

  bool get hasMore => page < pages;
}