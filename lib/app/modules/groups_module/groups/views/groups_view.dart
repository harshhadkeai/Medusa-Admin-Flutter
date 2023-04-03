import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:medusa_admin/app/data/models/store/customer_group.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/group_card.dart';
import '../controllers/groups_controller.dart';

class GroupsView extends GetView<GroupsController> {
  const GroupsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller.refreshController,
      onRefresh: () => controller.pagingController.refresh(),
      header: GetPlatform.isIOS ? const ClassicHeader(completeText: '') : const MaterialClassicHeader(),
      child: PagedListView(
        pagingController: controller.pagingController,
        builderDelegate: PagedChildBuilderDelegate<CustomerGroup>(
            itemBuilder: (context, customerGroup, index) => GroupCard(customerGroup: customerGroup, index: index),
            firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator.adaptive())),
        // separatorBuilder: (_, __) => const Divider(height: 0),
      ),
    );
  }
}