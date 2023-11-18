import 'package:flutter/material.dart';
import 'package:medusa_admin/app/data/models/store/index.dart';
import 'package:medusa_admin/app/modules/components/simple_currency_format.dart';
import 'package:medusa_admin/core/utils/colors.dart';
import 'package:medusa_admin/core/utils/extension.dart';
import '../../../components/custom_expansion_tile.dart';
import 'draft_order_summery_card.dart';

class DraftOrderSummery extends StatelessWidget {
  const DraftOrderSummery(this.draftOrder, {Key? key, this.onExpansionChanged}) : super(key: key);
  final DraftOrder draftOrder;

  final void Function(bool)? onExpansionChanged;
  @override
  Widget build(BuildContext context) {
    const halfSpace = SizedBox(height: 6.0);
    final lightWhite = ColorManager.manatee;
    final mediumTextStyle = context.bodyMedium;
    final totalTextTheme =  Theme.of(context).textTheme.displayLarge;
    final currencyCode = draftOrder.cart?.region?.currencyCode;

    return CustomExpansionTile(
      onExpansionChanged: onExpansionChanged,
      controlAffinity: ListTileControlAffinity.leading,
      title: const Text('Summery'),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:draftOrder.cart!.items!.length ,
            itemBuilder: (context, index) => DraftOrderSummeryCard(item: draftOrder.cart!.items![index], currencyCode: currencyCode!)),
        const Divider(),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: mediumTextStyle),
                  Row(
                    children: [
                      Text(formatPrice(draftOrder.cart?.subTotal, currencyCode), style: mediumTextStyle),
                    ],
                  ),
                ],
              ),
            ),
            halfSpace,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Shipping', style: mediumTextStyle),
                  Row(
                    children: [
                      Text(formatPrice(draftOrder.cart!.shippingTotal, currencyCode), style: mediumTextStyle),
                      Text(' ${currencyCode?.toUpperCase() ?? ''}',
                          style: mediumTextStyle?.copyWith(color: lightWhite)),
                    ],
                  ),
                ],
              ),
            ),
            halfSpace,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax', style: mediumTextStyle),
                  Row(
                    children: [
                      Text(formatPrice(draftOrder.cart?.taxTotal, currencyCode), style: mediumTextStyle),
                      Text(' ${currencyCode?.toUpperCase() ?? ''}',
                          style: mediumTextStyle?.copyWith(color: lightWhite)),
                    ],
                  ),
                ],
              ),
            ),
            halfSpace,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: totalTextTheme),
                  Text(formatPrice(draftOrder.cart?.total, currencyCode), style: Theme.of(context).textTheme.displayLarge),
                ],
              ),
            ),
            halfSpace,
          ],
        ),
      ],
    );
  }


}
