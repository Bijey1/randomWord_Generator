import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:google_cert/dictionary.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'faves.dart';
import 'word.dart';

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
        textTheme: TextTheme(
          titleMedium: TextStyle(
            color: Colors.white,
            fontSize: 15,
            overflow: TextOverflow.ellipsis,
          ),
          titleSmall: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontStyle: FontStyle.italic,
            overflow: TextOverflow.ellipsis,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 15,
            overflow: TextOverflow.ellipsis,
          ),

          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontStyle: FontStyle.italic,
          ),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 20),
        ),
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
      "https://random-words-api.kushcreates.com/api?language=en&words=4&category=animals",
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
    final popupMes = SnackBar(
      content: Text(dialog),
      duration: Duration(seconds: 1),
    );

    ScaffoldMessenger.of(context).showSnackBar(popupMes);
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

  List<String> wordStored = favorites.wordVault;

  Future<void> fetchWordMeaning() async {
    String tempW = cardNam;
    print("Finding the Meanign of $cardNam");

    final uri = Uri.parse(
      "https://api.dictionaryapi.dev/api/v2/entries/en/${tempW}",
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print("HERE");
        final data = jsonDecode(response.body);
        print("HERE1");
        Word word = Word.getFromJson(data[0]);
        print("HERE2");
        word.transferToDictionary();
        print("HERE3");
        Dictionary.seeDictContent();
      }
    } catch (e) {
      print("Error in finding the desciption of words");
    }
  }

  void pressedFavorite() async {
    pressed = !pressed;
    if (pressed) {
      setState(() {
        faved = true;
        //Change the Icon to a filled heart Icon
      });
      favorites.storeWord(cardNam);

      await fetchWordMeaning(); // Get the meaning of the faved word
      popUp("Saved to Favorite");
    } else {
      setState(() {
        //Change the Icon to a hollow heart Icon
        faved = false;
      });
      Dictionary.deletePage(); //Remove the last word that faved
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
  final VoidCallback refresh;

  const secondPage({
    super.key,
    required this.faveCount,
    required this.refresh,

    //When you call refresh()
    //setState will happen to the stfWrapper
  });

  @override
  Widget build(BuildContext context) {
    return faveCount == 0
        ? Center(child: Text("No Favorites"))
        : Padding(
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                crossAxisCount: 2, //How many items in a row
              ),
              itemCount:
                  faveCount, //How many items you want to show in the grid
              itemBuilder:
                  (
                    context,
                    index,
                  ) // Context for pointing where this widget is in the widgetTree
                  {
                    return faveCard(
                      faveName:
                          Dictionary.pageContent[index][0]["word"] ?? "Error",
                      pho:
                          Dictionary.pageContent[index][0]["phonetic"] ??
                          "Error",
                      partOf:
                          Dictionary.pageContent[index][0]["partOfSpeech"] ??
                          "Error",
                      meaning:
                          Dictionary.pageContent[index][0]["meaning"] ??
                          "Error",
                      refresh: refresh, // Another widget that is a
                      //Messenger for the stfWrapper to setState
                    );
                  },
            ),
          );
  }
}

class faveCard extends StatelessWidget {
  final String faveName;
  final String pho;
  final String partOf;
  final String meaning;
  final VoidCallback refresh;
  //Here is the refresh that is transferred
  // stfWrapper (Original) -> secondPage -> faveCard (Current)

  const faveCard({
    super.key,
    required this.faveName,
    required this.pho,
    required this.partOf,
    required this.meaning,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.red,
      child: InkWell(
        onTap: () => bigCard(context), //Passed the context of this widget
        child: Padding(
          padding: const EdgeInsets.only(
            top: 5.0,
            left: 15,
            right: 15,
            bottom: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              Text(
                faveName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(pho, maxLines: 1),
                  Expanded(
                    child: Text(
                      " - $partOf",

                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Text(
                meaning,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> bigCard(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.red,
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(faveName, style: Theme.of(context).textTheme.titleLarge),

                  Row(
                    children: [
                      Text(pho, style: Theme.of(context).textTheme.labelLarge),
                      Text(
                        " - $partOf",

                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Text(
                    meaning,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 3,
                  ),
                  SizedBox(height: 30),

                  ElevatedButton.icon(
                    label: Text("Remove", style: TextStyle(fontSize: 15)),
                    onPressed: () => {
                      Dictionary.deleteFrom(faveName),
                      print("HI"),
                      Navigator.pop(context),
                      refresh(),

                      //I use this to use setState even tho im stateless
                      //By calling the function stfWrapper(stfWidget, which is the parent
                      //This now causes a chain reaction from here to the stfWrapper

                      // faveCard (current) -> secondPage -> stfWrapper (original) -> use refresh()=> setState

                      //VoidCallback refresh;
                      //refresh: () => setState(()}),
                    },
                    icon: Icon(Icons.favorite),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class stfWrapper extends StatefulWidget {
  const stfWrapper({super.key});

  @override
  State<stfWrapper> createState() => _stfWrapperState();
}

class _stfWrapperState extends State<stfWrapper> {
  int vaultCount = favorites.countWords();

  Map<String, String> dictionary = {};

  @override
  void initState() {
    super.initState();
    Dictionary.seeDictContent;
    favorites.printWords();

    print("Words in valut: $vaultCount");
    print("That ");
  }

  @override
  Widget build(BuildContext context) {
    return secondPage(
      faveCount: vaultCount,
      refresh: () => setState(() {
        //Callback to refresh itself
        vaultCount = favorites.countWords();
        print("valut Counts is $vaultCount");
      }),
    );
  }
}
