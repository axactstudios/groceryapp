import 'package:flutter/material.dart';
import 'package:getwidget/components/search_bar/gf_search_bar.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../Classes/Shops.dart';
import '../Screens/ShopScreens/ShopMainScreen.dart';

class SearchBar extends StatefulWidget {
  List<Shops> shops;
  List<String> shopNames;
  State state;
  SearchBar(this.shops, this.shopNames, this.state);
  @override
  _SearchBarState createState() => _SearchBarState();
}

int flag = 0;

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return GFSearchBar(
      searchList: widget.shopNames,
      searchQueryBuilder: (query, list) {
        return list
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      },
      overlaySearchListItemBuilder: (item) {
        return Text(
          item,
          style: const TextStyle(fontSize: 18),
        );
      },
      onItemSelected: (item) {
        int i = 0;
        for (i = 0; i < widget.shops.length; i++) {
          if (widget.shops[i].name == item) {
            pushNewScreen(context,
                screen: ShopMainScreen(
                  shop: widget.shops[i],
                  category: widget.shops[i].category,
                  state: widget.state,
                ),
                withNavBar: false);
            flag = 1;
          }
        }
        if (flag == 0) print('Nai hua');
        setState(() {
          print('$item');
        });
      },
      hideSearchBoxWhenItemSelected: true,
    );
  }
}
