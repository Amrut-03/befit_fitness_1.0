// import 'package:fitness_app/features/diet/data/models/diet_plan_model.dart';
// import 'package:hive/hive.dart';

// class DietLocalDataSource{

//   final Box box;

//   DietLocalDataSource(this.box);

//   static const String cacheKey = 'diet_plans';

//   Future<void> cacheDietPlans (List<DietPlanModel> plans) async {

//     final jsonList = plans
//         .map((e) => e.toJson())
//         .toList();

//     await box.put(
//       cacheKey,
//       jsonList,
//     );
//   }

//   Future<List<DietPlanModel>> getCachedDietPlans() async {

//   final data = box.get(cacheKey);

//   if (data == null) {
//     return [];
//   }

//   return (data as List)

//       .map((item) {

//         final map =
//             Map<String, dynamic>.from(
//               item as Map,
//             );

//         return DietPlanModel.fromJson(
//           map,
//         );
//       })

//       .toList();
// }
// }
