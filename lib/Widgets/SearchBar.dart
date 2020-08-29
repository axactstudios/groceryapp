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
        return Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            item,
            style: const TextStyle(fontSize: 18),
          ),
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
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 15),
    //   child: Container(
    //     decoration: BoxDecoration(
    //         color: Color(0xFFF0F5F9),
    //         border: Border.all(width: 1, color: Color(0xFFd3dbd5)),
    //         borderRadius: BorderRadius.circular(15)),
    //     child: ListTile(
    //         trailing: IconButton(
    //             onPressed: () {
    //               print("Search Pressed");
    //             },
    //             icon: Icon(
    //               Icons.search,
    //               size: 30,
    //               color: Colors.blueGrey,
    //             )),
    //         title: TextField(
    //             cursorColor: Color(0xffF26016),
    //             decoration: InputDecoration(
    //                 hintText: "Search Shops",
    //                 hintStyle:
    //                     TextStyle(color: Colors.blueGrey, letterSpacing: 0.5),
    //                 border: InputBorder.none))),
    //   ),
    // );
  }
}
