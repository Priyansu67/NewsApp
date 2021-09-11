import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'model/news_model.dart';
import 'package:desktop_window/desktop_window.dart';

void main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  NewsModel? newsmodel;
  List<Articles>? articles;
  TabController? _controller;
  String category = "technology";
  bool showLoading = true;

  Future _setWindowSize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await DesktopWindow.setMinWindowSize(const Size(600, 1000));
      await DesktopWindow.setMaxWindowSize(const Size(600, 1000));
      await DesktopWindow.setFullScreen(false);
    }
  }

  fetchNews() async {
    setState(() {
      showLoading = true;
    });
    final response = await http.get(Uri.parse(
        "https://newsapi.org/v2/top-headlines?country=in&category=$category&apiKey=$YourKeyHere"));
    if (response.statusCode == 200) {
      showLoading = false;
      newsmodel = NewsModel.fromJson(jsonDecode(response.body));
      setState(() {
        articles = newsmodel!.articles;
      });
      print("Testing: " + articles![0].author.toString());
    } else {
      articles = null;
    }
  }

  Future<void> _launchInWebViewWithJavaScript(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    _setWindowSize();
    fetchNews();
    _controller = TabController(vsync: this, length: 6)
      ..addListener(() {
        if (_controller!.index.toDouble() == _controller!.animation!.value) {
          switch (_controller!.index) {
            case 0:
              category = "technology";
              fetchNews();
              break;
            case 1:
              category = "business";
              fetchNews();
              break;
            case 2:
              category = "entertainment";
              fetchNews();
              break;
            case 3:
              category = "health";
              fetchNews();
              break;
            case 4:
              category = "science";
              fetchNews();
              break;
            case 5:
              category = "sports";
              fetchNews();
              break;
          }
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Headliner',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                      "${DateTime.now().day.toString()}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year.toString().padLeft(2, '0')}"),
                ),
                const Center(
                  child: Text(
                    'Headliners',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Theme(
                  data: ThemeData(
                    highlightColor: Colors.transparent,
                  ),
                  child: TabBar(
                      controller: _controller,
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      indicatorPadding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey[900]),
                      tabs: const [
                        Tab(
                          text: "Technology",
                        ),
                        Tab(
                          text: 'Business',
                        ),
                        Tab(
                          text: 'Entertainment',
                        ),
                        Tab(
                          text: 'Health',
                        ),
                        Tab(
                          text: 'Science',
                        ),
                        Tab(
                          text: 'Sports',
                        ),
                      ]),
                ),
                Expanded(
                  child: showLoading
                      ? Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ListView.builder(
                          primary: false,
                          itemCount: articles!.length,
                          // scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return Hero(
                              tag: 'newspreview',
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    _launchInWebViewWithJavaScript(
                                        articles![index].url.toString());
                                  },
                                  child: Card(
                                    color: Colors.black,
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Container(
                                      height: 400,
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  articles![index]
                                                      .urlToImage
                                                      .toString(),
                                                  scale: 1.0),
                                              fit: BoxFit.fitHeight,
                                              colorFilter: ColorFilter.mode(
                                                  Colors.black.withOpacity(0.3),
                                                  BlendMode.darken))),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 0, 15, 20),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            articles![index].title.toString(),
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.grey[100],
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
