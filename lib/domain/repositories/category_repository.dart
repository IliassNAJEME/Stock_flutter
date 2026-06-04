import '../models/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories(String clientId);
  Future<Category> addCategory({
    required String clientId,
    required String name,
  });
}
