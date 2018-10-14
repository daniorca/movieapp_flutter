import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './models/movieModel.dart';
import './models/tmdb.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'movieDetails.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie App',
      theme: ThemeData.dark(),
      home: MyMovieApp(),
    ));

class MyMovieApp extends StatefulWidget {
  @override
  _MyMovieApp createState() => new _MyMovieApp();
}

class _MyMovieApp extends State<MyMovieApp> {
  Movie nowPlayingMovies;
  Movie upcomingMovies;
  Movie popularMovies;
  Movie topRatedMovies;
  int heroTag = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchNowPlayingMovies();
    _fetchUpcomingMovies();
    _fetchPopularMovies();
    _fetchTopRatedMovies();
  }

  void _fetchNowPlayingMovies() async {
    var response = await http.get(Tmdb.nowPlayingUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      nowPlayingMovies = Movie.fromJson(decodeJson);
    });
  }

  void _fetchUpcomingMovies() async {
    var response = await http.get(Tmdb.upcomingUrl);
    var decodedJson = jsonDecode(response.body);
    setState(() {
      upcomingMovies = Movie.fromJson(decodedJson);
    });
  }

  void _fetchPopularMovies() async {
    var response = await http.get(Tmdb.popularUrl);
    var decodedJson = jsonDecode(response.body);
    setState(() {
      popularMovies = Movie.fromJson(decodedJson);
    });
  }

  void _fetchTopRatedMovies() async {
    var response = await http.get(Tmdb.topRatedUrl);
    var decodedJson = jsonDecode(response.body);
    setState(() {
      topRatedMovies = Movie.fromJson(decodedJson);
    });
  }

  Widget _buildCarouselSlider() => CarouselSlider(
        items: nowPlayingMovies == null
            ? <Widget>[Center(child: CircularProgressIndicator())]
            : nowPlayingMovies.results
                .map((movieItem) => _buildMovieItem(movieItem))
                .toList(),
        autoPlay: false,
        height: 240.0,
        viewportFraction: 0.5,
      );

  Widget _buildMovieItem(Results movieItem) {
    heroTag += 1;
    movieItem.heroTag = heroTag;
    return Material(
        elevation: 15.0,
        child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MovieDetail(movie: movieItem,)
              ));
            },
            child: Hero(
              tag: heroTag,
              child: Image.network(
                  "${Tmdb.baseImagesUrl}w342${movieItem.posterPath}",
                  fit: BoxFit.cover),
            )));
  }

  Widget _buildMovieListItem(Results movieItem) => Material(
      child: Container(
          width: 128.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(6.0),
                  child: _buildMovieItem(movieItem)),
              Padding(
                padding: EdgeInsets.only(left: 6.0, top: 2.0),
                child: Text(
                  movieItem.title,
                  style: TextStyle(fontSize: 8.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 6.0, top: 2.0),
                  child: Text(
                    DateFormat('yyyy')
                        .format(DateTime.parse(movieItem.releaseDate)),
                    style: TextStyle(fontSize: 8.0),
                  ))
            ],
          )));

  Widget _buildMoviesListView(Movie movie, String movieListTitle) => Container(
        height: 258.0,
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 7.0, bottom: 7.0),
              child: Text(movieListTitle,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400])),
            ),
            Flexible(
                child: ListView(
              scrollDirection: Axis.horizontal,
              children: movie == null
                  ? <Widget>[Center(child: CircularProgressIndicator())]
                  : movie.results
                      .map((movieItem) => Padding(
                            padding: EdgeInsets.only(left: 6.0, right: 2.0),
                            child: _buildMovieListItem(movieItem),
                          ))
                      .toList(),
            ))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            'Movies App',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('NOW PLAYING',
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                expandedHeight: 290.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: <Widget>[
                      Container(
                        child: Image.network(
                          "${Tmdb.baseImagesUrl}w500/2uNW4WbgBXL25BAbXGLnLqX71Sw.jpg",
                          fit: BoxFit.cover,
                          width: 1000.0,
                          colorBlendMode: BlendMode.dstATop,
                          color: Colors.blue.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 35.0),
                          child: _buildCarouselSlider())
                    ],
                  ),
                ),
              )
            ];
          },
          body: ListView(
            children: <Widget>[
              _buildMoviesListView(upcomingMovies, 'COMING SOON'),
              _buildMoviesListView(popularMovies, 'POPULAR'),
              _buildMoviesListView(topRatedMovies, 'TOP RATED'),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          fixedColor: Colors.lightBlue,
          currentIndex: _currentIndex,
          onTap: (int index){
           setState(() {
             _currentIndex = index;
           });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_movies),
              title: Text('All Movies'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag_faces),
              title: Text('Tickets'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Account'),
            )
          ],
        ));
  }
}
