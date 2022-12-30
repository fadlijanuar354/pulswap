import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulswap/pages/HomePage.dart';
import 'package:pulswap/pages/CheckoutPage.dart';
import 'package:pulswap/pages/DepositPage.dart';
import 'package:pulswap/provider/metamask.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

List<String> pages = [
  'home',
  'deposit',
  'checkout',
];
List<IconData> icons = [
  Icons.wifi_2_bar_rounded,
  Icons.attach_money_sharp,
  Icons.info_outline_rounded,
];

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green, Colors.blue],
        ),
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Menu(),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.04,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            pageController.animateToPage(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn);
                          },
                          icon: Icon(
                            Icons.home,
                            color: Colors.white,
                          ),
                          iconSize: 25,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        IconButton(
                          onPressed: () {
                            pageController.animateToPage(1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn);
                          },
                          icon: Icon(
                            Icons.monetization_on,
                            color: Colors.white,
                          ),
                          iconSize: 25,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    height: 300,
                    child: PageView(
                      controller: pageController,
                      children: [
                        HomePage(),
                        DepositPage(),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Footer(),
      ),
    );
  }
}

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Logo(),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ButtonConnect(),
          ]),
        ],
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image(
            image: AssetImage("assets/images/logo.png"),
          )
        ],
      ),
    );
  }
}

Widget ButtonConnect() {
  return Consumer<MetamaskProvider>(builder: (context, provider, child) {
    late final String text;
    text = provider.account;

    if (provider.isConnected) {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  "ETH",
                  style: TextStyle(
                      color: Color.fromARGB(255, 101, 101, 101),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(width: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  '${text.substring(0, 7)}...${text.substring(text.length - 4, text.length)}',
                  style: TextStyle(
                      color: Color.fromARGB(255, 101, 101, 101),
                      fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () {
                    FlutterClipboard.copy(text)
                        .then((value) => print('copied'));
                  },
                  icon: Icon(Icons.content_copy_rounded),
                  color: Color.fromARGB(255, 164, 164, 164),
                )
              ],
            ),
          ),
        ],
      );
    } else if (provider.isConnected && !provider.isInOperatingChain) {
      "Wrong Chain, Please Connect to ${MetamaskProvider.operatingChain}";
    } else if (provider.isEnabled && !provider.isConnected) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(18),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          onPressed: () => context.read<MetamaskProvider>().connect(),
          child: Text(
            "Connect Metamask",
            style: TextStyle(
                color: Color.fromARGB(255, 164, 164, 164),
                fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else {
      "Please use a web3 supported browser";
    }
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.purple, Colors.blue, Colors.red],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  });
}

class Footer extends StatelessWidget {
  const Footer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40.0,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (Text(
              'SYF Projects',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                  color: Colors.white),
            )),
            (Text(
              'Copyright ©2022, All Rights Reserved.',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.0,
                  color: Colors.white),
            )),
          ],
        ));
  }
}
