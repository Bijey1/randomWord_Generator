import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'faves.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: mainScaf(),
    );
  }
}

class mainScaf extends StatefulWidget {
  const mainScaf({super.key});

  @override
  State<mainScaf> createState() => _mainScafState();
}

class _mainScafState extends State<mainScaf> {
  int currentIndex = 0;
  List<Widget> pages = [firstPage(), stfWrapper()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: naviBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class naviBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const naviBar({super.key, required this.currentIndex, required this.onTap});

  @override
  State<naviBar> createState() => _naviBarState();
}

Widget createIcon(Icon iconName) {
  return NavigationDestination(icon: iconName, label: "");
}

class _naviBarState extends State<naviBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: widget.currentIndex,
      onDestinationSelected: widget.onTap,
      destinations: [
        createIcon(Icon(Icons.home)),
        createIcon(Icon(Icons.favorite)),
      ],
    );
  }
}

String wordTrack = "First";
bool faved = false;
bool pressed = false;

class firstPage extends StatefulWidget {
  const firstPage({super.key});

  @override
  State<firstPage> createState() => _firstPageState();
}

class _firstPageState extends State<firstPage> {
  String cardNam = "PlaceHolder";

  Icon heartIcon = Icon(Icons.favorite_border);

  @override
  void initState() {
    //Runs when the page first loaded
    super.initState();
    setState(() {
      cardNam = wordTrack;
    });
    print(wordTrack);
  }

  Future<String> randomWordFecth() async {
    final url = Uri.parse(
      "https://random-words-api.kushcreates.com/api?language=en&words=4",
    ); //Parse the uri

    try {
      final response = await http.get(url); //Fetching the data from the link

      if (response.statusCode == 200) {
        //200 means good

        final data = jsonDecode(response.body);

        return data[0]["word"]; // Get jsut the word from the JSON
      }
    } catch (e) {
      print(e);
      return "Error Fetching";
    }

    return "Error Fetchin Data";
  }

  void popUp(String dialog) {
    //SnackBar
    final popup = SnackBar(
      content: Text(dialog),
      duration: Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(popup);
  }

  Future<void> pressedNext() async {
    final String fetchWord = await randomWordFecth(); //Get the word from API
    pressed = false;

    setState(() {
      cardNam = fetchWord;
      faved = false;
    });
    wordTrack = cardNam;
  }

  void pressedFavorite() {
    pressed = !pressed;
    if (pressed) {
      setState(() {
        faved = true;
        //Change the Icon to a filled heart Icon
      });
      favorites.storeWord(cardNam);
      popUp("Saved to Favorite");
    } else {
      setState(() {
        //Change the Icon to a hollow heart Icon
        faved = false;
      });
      favorites.removeWord();
      popUp("Removed to Favorite");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          myCard(cardName: cardNam),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                //favorite button
                onPressed: () {
                  // Counter to ensure only favorite per word
                  pressedFavorite();
                },
                label: Text("Favorite"),
                icon: Icon(faved ? Icons.favorite : Icons.favorite_border),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  pressedNext();

                  //WHERE THE API GOES
                },
                child: Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class myCard extends StatelessWidget {
  final String cardName;
  const myCard({super.key, required this.cardName});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      child: Padding(
        padding: EdgeInsetsGeometry.all(50),
        child: Text(
          cardName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class secondPage extends StatelessWidget {
  final int faveCount;
  const secondPage({super.key, required this.faveCount});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Hello page 2"));
  }
}

class stfWrapper extends StatefulWidget {
  const stfWrapper({super.key});

  @override
  State<stfWrapper> createState() => _stfWrapperState();
}

class _stfWrapperState extends State<stfWrapper> {
  int vaultCount = 0;
  @override
  void initState() {
    super.initState();
    vaultCount = favorites.countWords();
    favorites.showWords();
  }

  @override
  Widget build(BuildContext context) {
    return secondPage(faveCount: vaultCount);
  }
}
