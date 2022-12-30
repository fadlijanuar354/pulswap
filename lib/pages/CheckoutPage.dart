import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:pulswap/LandingPage.dart';
import 'package:web3dart/web3dart.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Client? httpClient;
  Web3Client? ethClient;
  final sellerAddress = "0x2E6559665f3beB4e0eF2227Da70d89920e570dA3";
  bool loading = false;
  var voucher;

  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://goerli.infura.io/v3/a105a0c5d84740c3a0b07658d4f7f6be",
        httpClient!);
    generateVoucher(sellerAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x355B198Ff0bF74d2adc14A575581E012487A7846";
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, "Pulswapv2"),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient!
        .call(contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> generateVoucher(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    loading = true;
    setState(() {});
    List<dynamic> result = await query("voucher", []);
    voucher = int.parse(result[0].toString());
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenHeight = MediaQuery.of(context).size.height;
    dynamic screenwidth = MediaQuery.of(context).size.width;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: screenwidth * .5,
                      height: screenHeight * .75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "THANK YOU FOR PURCHASING",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Lottie.network(
                                "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json",
                                width: screenwidth * .12),
                            Text("YOUR VOUCHER CODE"),
                            loading
                                ? CircularProgressIndicator()
                                : Text(
                                    // "1234 5678 91011",
                                    voucher.toString(),
                                    style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                    textAlign: TextAlign.center,
                                  ),
                            Image(
                              image: AssetImage("assets/images/howto.png"),
                              width: screenwidth * .2,
                            ),
                            AnimatedButton(
                              width: screenwidth * .2,
                              height: screenHeight * .06,
                              color: Colors.green,
                              child: Text(
                                'BUY AGAIN ?',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LandingPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 30,
                ),
              ],
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
