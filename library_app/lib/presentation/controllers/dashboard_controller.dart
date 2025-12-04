import 'package:get/get.dart';

class DashboardController extends GetxController {
  // 0 = Home, 1 = Activity, 2 = Profile
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}