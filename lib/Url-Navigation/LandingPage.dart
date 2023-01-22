import 'package:flutter/material.dart';
import 'package:timoti_project/Url-Navigation/Routes.dart';
import 'package:timoti_project/Url-Navigation/pages/About.dart';
import 'package:timoti_project/Url-Navigation/pages/Help.dart';
import 'package:timoti_project/Url-Navigation/pages/HomePage.dart';
import 'package:timoti_project/Url-Navigation/pages/ProfilePage.dart';
import 'package:timoti_project/Url-Navigation/pages/SettingsPage.dart';

class LandingPage extends StatefulWidget {
  final String pageName;
  final String? detailsPageName;

  const LandingPage({Key? key, required this.pageName, this.detailsPageName})
      : super(key: key);
  @override
  _LandingPageState createState() => _LandingPageState();
}

List<String> pages = [
  'home',
  'About-Page', // <-- Adjusted
  'Profile-Page', // <-- Adjusted
  'settings',
  'help',
];

List<IconData> icons = [
  Icons.home,
  Icons.pages_rounded,
  Icons.person_rounded,
  Icons.settings_rounded,
  Icons.help_rounded,
];

String aboutParam = '/Steven';
String profileParam = '/ProfileDetails';

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: icons.map((e) {
                  return NavItem(
                    selected:
                        icons.indexOf(e) == pages.indexOf(widget.pageName),
                    icon: e,
                    onTap: () {
                      /// About Page
                      if (icons.indexOf(e) == 1) {
                        /// /base url + /pages + /param
                        Navigator.pushNamed(
                          context,
                          MyFluroRouterClass.baseURL +
                              '${About.routeName}' +
                              aboutParam,
                          arguments: AboutDetailsArgument(
                            details: 'HIIIII',
                            id: '10',
                          ),
                        );
                      }

                      /// Profile Page
                      else if (icons.indexOf(e) == 2) {
                        /// /base url + /pages + /param
                        Navigator.pushNamed(
                          context,
                          MyFluroRouterClass.baseURL +
                              '${Profile.routeName}' +
                              profileParam,
                        );
                      } else {
                        Navigator.pushNamed(
                            context,
                            MyFluroRouterClass.baseURL +
                                '/${pages[icons.indexOf(e)]}');
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Center(
                child: IndexedStack(
                  index: pages.indexOf(widget.pageName),
                  children: [
                    Home(),
                    About(widget.detailsPageName ?? "null"),
                    Profile(widget.detailsPageName ?? "null"),
                    Settings(),
                    Help(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatefulWidget {
  final IconData icon;
  final bool selected;
  final Function onTap;

  const NavItem(
      {Key? key,
      required this.icon,
      required this.selected,
      required this.onTap})
      : super(key: key);
  @override
  _NavItemState createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 375),
          width: double.infinity,
          height: 60.0,
          color: widget.selected ? Colors.black87 : Colors.white,
          child: Icon(
            widget.icon,
            color: widget.selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
