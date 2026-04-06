class CategoryModel {
  final int categoryId;
  final String name;

  CategoryModel({required this.categoryId, required this.name});

  @override
  String toString() {
    return 'CategoryModel{categoryId: $categoryId, name: $name}';
  }
}
