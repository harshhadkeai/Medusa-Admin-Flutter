import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medusa_admin/app/modules/components/adaptive_back_button.dart';
import 'package:medusa_admin/app/modules/components/adaptive_button.dart';
import 'package:medusa_admin/app/modules/components/bottom_nav_bar_button.dart';

import '../../../../data/models/store/order.dart';
import '../../orders/components/payment_status_label.dart';
import '../components/order_status_label.dart';
import '../controllers/order_details_controller.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 12.0);
    final mediumTextStyle = Theme.of(context).textTheme.titleMedium;
    return GetBuilder<OrderDetailsController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            leading: const AdaptiveBackButton(),
            title: const Text('Order Details'),
            centerTitle: true,
          ),
          bottomNavigationBar: controller.state != null &&
                  controller.state!.status != OrderStatus.canceled
              ? BottomNavigationBarButton(
                  onPress: controller.state != null
                      ? () async {
                          final order = controller.state!;
                          final result = await showTextAnswerDialog(
                            title: 'Cancel order',
                            message:
                                'Are you sure you want to cancel the order? \n Type the name "order #${order.displayId!}" to confirm.',
                            retryMessage:
                                'Make sure to type the name "order #${order.displayId!}" to confirm order deletion.',
                            retryOkLabel: 'Retry',
                            context: context,
                            keyword: 'order #${order.displayId!}',
                            isDestructiveAction: true,
                            hintText: 'order #${order.displayId!}',
                            okLabel: 'Yes, confirm',
                          );
                          if (result) {
                            // Delete order
                          }
                        }
                      : null,
                  label: 'Cancel Order',
                  buttonColor: Colors.redAccent)
              : null,
          body: SafeArea(
            child: controller.obx(
              (order) => ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                children: [
                  buildOrderOverview(context, order!),
                  space,
                  buildSummeryExpansionTile(order, mediumTextStyle!, context),
                  space,
                  buildPaymentExpansionTile(order, context),
                  space,
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      child: ExpansionTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Fulfillment'),
                        trailing: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz)),
                      ),
                    ),
                  ),
                  space,
                  buildCustomerExpansionTile(order, context),
                  space,
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      child: ExpansionTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Timeline'),
                        trailing: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz)),
                      ),
                    ),
                  ),
                ],
              ),
              onEmpty: const Center(child: Text('No order details found')),
              onError: (e) =>
                  const Center(child: Text('Error loading order details')),
              onLoading: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildCustomerExpansionTile(Order order, BuildContext context) {
    final mediumTextStyle = Theme.of(context).textTheme.titleMedium;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        child: ExpansionTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Customer'),
          trailing: IconButton(
              onPressed: () async {
                // ignore: unused_result
                await showModalActionSheet(
                    context: context,
                    actions: <SheetAction>[
                      const SheetAction(
                          label: 'Go to Customer', icon: Icons.person),
                      const SheetAction(label: 'Transfer Ownership'),
                      const SheetAction(label: 'Edit Shipping Address'),
                      const SheetAction(label: 'Edit Billing Address'),
                      const SheetAction(label: 'Edit Email Address'),
                    ]);
              },
              icon: const Icon(Icons.more_horiz)),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(child: Text(order.email![0])),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${order.shippingAddress?.firstName ?? ''} ${order.shippingAddress?.lastName ?? ''}',
                                style: mediumTextStyle),
                            Text(
                                '${order.shippingAddress?.province ?? ''}, ${order.shippingAddress?.countryCode?.toUpperCase() ?? ''}',
                                style: mediumTextStyle)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.email!,
                          style: Theme.of(context).textTheme.titleMedium),
                      if (order.billingAddress != null &&
                          order.billingAddress!.phone != null)
                        Text(order.billingAddress!.phone.toString(),
                            style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shipping', style: mediumTextStyle),
                      const SizedBox(height: 5.0),
                      Text(
                          '${order.shippingAddress?.address1 ?? ''} ${order.shippingAddress?.address2 ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                          '${order.shippingAddress?.postalCode ?? ''} ${order.shippingAddress?.province ?? ''} ${order.shippingAddress?.countryCode ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const VerticalDivider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Billing', style: mediumTextStyle),
                      const SizedBox(height: 5.0),
                      Text(
                          '${order.billingAddress?.address1 ?? ''} ${order.billingAddress?.address2 ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                          '${order.billingAddress?.postalCode ?? ''} ${order.billingAddress?.province ?? ''} ${order.billingAddress?.countryCode ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentExpansionTile(Order order, BuildContext context) {
    final mediumTextStyle = Theme.of(context).textTheme.titleMedium;
    const halfSpace = SizedBox(height: 6.0);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        child: ExpansionTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Payment'),
          trailing:
              AdaptiveButton(onPressed: () {}, child: const Text('Refund')),
          // : CupertinoButton(
          //     padding: EdgeInsets.zero, child: const Text('Refund', style: TextStyle(fontSize: 14)), onPressed: () {}),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.payments!.first.id!,
                  style: mediumTextStyle,
                ),
                halfSpace,
                if (order.payments != null &&
                    order.payments!.isNotEmpty &&
                    order.payments!.first.capturedAt != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                            'on ${DateFormat.MEd().format(order.payments!.first.capturedAt!)} at ${DateFormat.jm().format(order.payments!.first.capturedAt!)}',
                            style: mediumTextStyle!.copyWith(
                                color: Get.isDarkMode
                                    ? Colors.white54
                                    : Colors.black54)),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: PaymentStatusLabel(
                              paymentStatus: order.paymentStatus)),
                    ],
                  )
              ],
            ),
            // space,
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: mediumTextStyle!.copyWith(fontSize: 20)),
                Text(order.payments!.first.amount!.toString(),
                    style: mediumTextStyle.copyWith(fontSize: 20))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildOrderOverview(BuildContext context, Order? order) {
    Color lightWhite = Get.isDarkMode ? Colors.white54 : Colors.black54;
    final smallTextStyle = Theme.of(context).textTheme.titleSmall;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        color: Theme.of(context).expansionTileTheme.backgroundColor,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('#${order!.displayId!}',
                          style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.copy, size: 14))
                    ],
                  ),
                  if (order.cart != null && order.cart!.completedAt != null)
                    Text(
                      'on ${DateFormat.MEd().format(order.cart!.completedAt!)} at ${DateFormat.jm().format(order.cart!.completedAt!)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Order Status', style: smallTextStyle!.copyWith(color: lightWhite)),
                  const SizedBox(height: 6.0),
                  OrderStatusLabel(orderStatus: order.status),
                ],
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.email!,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (order.billingAddress != null &&
                        order.billingAddress!.phone != null)
                      Text(order.billingAddress!.phone.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Payment',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.grey)),
                  Text('Manual',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildSummeryExpansionTile(
      Order order, TextStyle mediumTextStyle, BuildContext context) {
    const space = SizedBox(height: 5.0);
    final smallTextStyle = Theme.of(context).textTheme.titleSmall;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        child: ExpansionTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Summery'),
            trailing: AdaptiveButton(
                onPressed: () {}, child: const Text('Edit Order')),
            // : CupertinoButton(
            //     padding: EdgeInsets.zero,
            //     child: const Text('Edit Order', style: TextStyle(fontSize: 14)),
            //     onPressed: () {}),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items!.length,
                  itemBuilder: (context, index) {
                    final item = order.items![index];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                              height: 50,
                              width: 50,
                              child: CachedNetworkImage(
                                  imageUrl: item.thumbnail!)),
                          const SizedBox(width: 6.0),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.title!,
                                    style: mediumTextStyle,
                                  ),
                                ),
                                if (item.variant != null)
                                  const SizedBox(height: 6.0),
                                Flexible(
                                  child: Text(
                                    item.variant?.title ?? '',
                                    style: smallTextStyle,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        order.currency!.symbol.toString() +
                                            item.unitPrice!.toString(),
                                        style: smallTextStyle),
                                    Text(' x ${item.quantity!}',
                                        style: smallTextStyle),
                                  ],
                                ),
                                const Divider(height: 1),
                                Text(
                                    order.currency!.symbol.toString() +
                                        item.total!.toString(),
                                    style: mediumTextStyle),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: mediumTextStyle),
                      Row(
                        children: [
                          Text(order.currency!.symbol!, style: mediumTextStyle),
                          Text(order.subTotal!.toString(),
                              style: mediumTextStyle),
                          Text(' ${order.currency!.code!.toUpperCase()}',
                              style: mediumTextStyle),
                        ],
                      ),
                    ],
                  ),
                  space,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shipping', style: mediumTextStyle),
                      Row(
                        children: [
                          Text(order.currency!.symbol!, style: mediumTextStyle),
                          Text(order.shippingTotal!.toString(),
                              style: mediumTextStyle),
                          Text(' ${order.currency!.code!.toUpperCase()}',
                              style: mediumTextStyle),
                        ],
                      ),
                    ],
                  ),
                  if (order.taxTotal != null && order.taxTotal! != 0) space,
                  if (order.taxTotal != null && order.taxTotal! != 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tax', style: mediumTextStyle),
                        Row(
                          children: [
                            Text(order.currency!.symbol!,
                                style: mediumTextStyle),
                            Text(order.taxTotal!.toString(),
                                style: mediumTextStyle),
                            Text(' ${order.currency!.code!.toUpperCase()}',
                                style: mediumTextStyle),
                          ],
                        ),
                      ],
                    ),
                  space,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: mediumTextStyle.copyWith(fontSize: 25)),
                      Row(
                        children: [
                          Text(order.currency!.symbol!,
                              style: mediumTextStyle.copyWith(fontSize: 25)),
                          Text(order.total!.toString(),
                              style: mediumTextStyle.copyWith(fontSize: 25)),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ]),
      ),
    );
  }
}