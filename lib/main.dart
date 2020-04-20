import 'package:covid19/bloc/covid_bloc.dart';
import 'package:covid19/model/Timeline.dart';
import 'package:covid19/model/covid_country.dart';
import 'package:covid19/model/covid_historical_data.dart';
import 'package:covid19/model/key_value.dart';
import 'package:covid19/util/sharedpref_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:search_widget/search_widget.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:screenshot_and_share/screenshot_share.dart';

import 'model/covid_world.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
      ),
      //darkTheme: ThemeData(brightness: Brightness.dark),
      home: MyHomePage(title: 'Covid-19'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CovidBloc _bloc = CovidBloc();

  String _country = "USA";
  String _home;
  final _formatter = new NumberFormat("#,###");
  final _dateFormatter = new DateFormat("MMMM dd, yyyy h:mm:ss a");
  final divider = Divider();

  List<KeyValuePair> _lastDays = <KeyValuePair>[
    KeyValuePair(name: 'All', value: 0),
    KeyValuePair(name: '5 Days', value: 6),
    KeyValuePair(name: '10 Days', value: 11),
    KeyValuePair(name: '15 Days', value: 16),
    KeyValuePair(name: '20 Days', value: 21),
    KeyValuePair(name: '25 Days', value: 26),
    KeyValuePair(name: '30 Days', value: 31),
  ];

  _fetchData() async {
    _bloc.daysController.sink.add(_lastDays[0]);

    await _getHomeCountry();
    await _bloc.fetchCountry(_country);
    await _bloc.fetchCountries();
    await _bloc.fetchHistory(_country, 0);
    await _setHColor();

    return true;
  }

  _setHColor() async {
    _bloc.colorController.sink.add(_home == _country);
  }

  _setHomeCountry(String country) async {
    await preferences.setData("home", country);
    _bloc.colorController.sink.add(true);
  }

  _getHomeCountry() async {
    _home = await preferences.getData("home");
    if (_home != null && _home.trim().length > 0) {
      _country = _home;
    }
  }

  _onSelectCountry(String value) async {
    _country = value;
    _bloc.countryController.sink.add(null);
    _bloc.historyController.sink.add(null);
    _bloc.colorController.sink.add(null);
    _bloc.daysController.sink.add(_lastDays[0]);
    await _bloc.fetchCountry(_country);
    await _bloc.fetchHistory(_country, 0);
    await _setHColor();
  }

  DateTime _formatDate(String rawDate) {
    List<String> d = rawDate.split('/');
    return DateTime.utc(int.parse('20${d[2]}'), int.parse(d[0]), int.parse(d[1]));
  }

  List<KeyValuePair> _createDailyCasesHistory(final List<KeyValuePair> cases) {
    List<KeyValuePair> newCases = [];

    cases.sublist(1).forEach((i) {
      newCases.add(KeyValuePair.fromJson(i.toJson()));
    });

    for (var i = 0; i < newCases.length; i++) {
      newCases[i].value -= cases[i].value;
    }

    return newCases;
  }

  List<charts.Series<KeyValuePair, DateTime>> _createHistoricalData(Timeline timeline) {
    return [
      new charts.Series<KeyValuePair, DateTime>(
          id: 'Cases',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (KeyValuePair item, _) => _formatDate(item.name),
          measureFn: (KeyValuePair item, _) => item.value,
          data: timeline.cases != null ? timeline.cases : List<KeyValuePair>(),
          displayName: 'Cases'),
      new charts.Series<KeyValuePair, DateTime>(
        id: 'Mortality',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (KeyValuePair item, _) => _formatDate(item.name),
        measureFn: (KeyValuePair item, _) => item.value,
        data: timeline.deaths != null ? timeline.deaths : List<KeyValuePair>(),
      ),
      new charts.Series<KeyValuePair, DateTime>(
        id: 'Recovered',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (KeyValuePair item, _) => _formatDate(item.name),
        measureFn: (KeyValuePair item, _) => item.value,
        data: timeline.recovered != null ? timeline.recovered : List<KeyValuePair>(),
      ),
    ];
  }

  _showForcast(Timeline timeline) {
    // get the average for the past x days
    // for active cases, recovered, deaths
    // forecast the average for the day
  }

  void _showAsBottomSheet() async {
    _bloc.worldController.sink.add(null);
    await showSlidingBottomSheet(context, builder: (context) {
      return SlidingSheetDialog(
        elevation: 8,
        cornerRadius: 16,
        snapSpec: const SnapSpec(
          snap: true,
          snappings: [0.7],
          positioning: SnapPositioning.relativeToAvailableSpace,
        ),
        builder: (context, state) {
          return Material(
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
                      image: ExactAssetImage("assets/images/world.png"))),
              child: Center(
                  child: StreamBuilder<CovidWorld>(
                      stream: _bloc.world,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          _bloc.fetchWorld();
                          return CircularProgressIndicator();
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              'Covid-19 Global Count',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                            ),
                            divider,
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                    child: Text(
                                      "Total Cases",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "${_formatter.format(snapshot.data.cases)}",
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink),
                                    ),
                                  ),
                                  Center(
                                      child: Text(
                                          "Last Updated on ${_dateFormatter.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.updated))}")),
                                ],
                              ),
                            ),
                            Divider(
                              indent: 10,
                              endIndent: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text("Active Cases", style: TextStyle(fontSize: 14)),
                                      Text("${_formatter.format(snapshot.data.active)}",
                                          style:
                                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink))
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text("Cases Today", style: TextStyle(fontSize: 14)),
                                      Text("${_formatter.format(snapshot.data.todayCases)}",
                                          style:
                                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink))
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text("Mortality Today", style: TextStyle(fontSize: 14)),
                                      Text("${_formatter.format(snapshot.data.todayDeaths)}",
                                          style:
                                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              indent: 10,
                              endIndent: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text("Recovered", style: TextStyle(fontSize: 14)),
                                      Text("${_formatter.format(snapshot.data.recovered)}",
                                          style: TextStyle(
                                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text("Critical", style: TextStyle(fontSize: 14)),
                                      Text("${_formatter.format(snapshot.data.critical)}",
                                          style: TextStyle(
                                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text("Total Mortality", style: TextStyle(fontSize: 14)),
                                      Text("${_formatter.format(snapshot.data.deaths)}",
                                          style:
                                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            divider,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Tests Performed", style: TextStyle(fontSize: 14)),
                                Text("${_formatter.format(snapshot.data.tests)}",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                              ],
                            ),
                          ],
                        );
                      })),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _fetchData();
    return Scaffold(
        floatingActionButton: Opacity(
          opacity: 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                mini: true,
                heroTag: null,
                onPressed: () {
                  ScreenshotShare.takeScreenshotAndShare();
                },
                child: Icon(
                  Icons.share,
                  size: 30,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  await _showAsBottomSheet();
                },
                child: Icon(
                  Icons.public,
                  size: 50,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                mini: true,
                heroTag: null,
                onPressed: () async {
                  _bloc.countriesController.sink.add(null);
                  _bloc.countryController.sink.add(null);
                  await _fetchData();
                },
                child: Icon(
                  Icons.refresh,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder<List<CovidCountry>>(
                      stream: _bloc.countries,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return SearchWidget<CovidCountry>(
                            dataList: snapshot.data,
                            hideSearchBoxWhenItemSelected: false,
                            listContainerHeight: MediaQuery.of(context).size.height,
                            queryBuilder: (String query, List<CovidCountry> list) {
                              return list
                                  .where(
                                      (CovidCountry item) => item.country.toLowerCase().contains(query.toLowerCase()))
                                  .toList();
                            },
                            popupListItemBuilder: (CovidCountry item) {
                              return ListTile(
                                trailing: Text(
                                  "${_formatter.format(item.cases)}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                leading: CircleAvatar(backgroundImage: NetworkImage(item.countryInfo.flag)),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      item.country,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    divider,
                                  ],
                                ),
                              );
                            },
                            selectedItemBuilder: (selectedItem, deleteSelectedItem) {
                              _onSelectCountry(selectedItem.country);
                              return Container();
                            },
                          );
                        }

                        return Container();
                      }),
                  StreamBuilder<CovidCountry>(
                      stream: _bloc.country,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8, right: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          colorFilter:
                                              new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                                          image: NetworkImage(snapshot.data.countryInfo.flag))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          "Total Cases",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "${_formatter.format(snapshot.data.cases)}",
                                          style:
                                              TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink),
                                        ),
                                      ),
                                      Center(
                                          child: Text(
                                              "Last Updated on ${_dateFormatter.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.updated))}")),
                                      Center(
                                          child: Text(
                                        snapshot.data.country.toUpperCase(),
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ))
                                    ],
                                  ),
                                ),
                              ),
                              StreamBuilder<bool>(
                                  stream: _bloc.color,
                                  builder: (context, snapshot) {
                                    return Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Align(
                                        child: IconButton(
                                          icon: Icon(Icons.home),
                                          iconSize: 35,
                                          color: ((snapshot.data != null) ? snapshot.data : false)
                                              ? Colors.green
                                              : Colors.grey,
                                          onPressed: () {
                                            _setHomeCountry(_country);
                                          },
                                        ),
                                        alignment: Alignment.centerRight,
                                      ),
                                    );
                                  }),
                            ],
                          );
                        }
                        return Container(); //Center(child: CircularProgressIndicator());
                      }),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                  ),
                  StreamBuilder<CovidCountry>(
                      stream: _bloc.country,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text("Active Cases", style: TextStyle(fontSize: 14)),
                                    Text("${_formatter.format(snapshot.data.active)}",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink))
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text("Cases Today", style: TextStyle(fontSize: 14)),
                                    Text("${_formatter.format(snapshot.data.todayCases)}",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink))
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text("Mortality Today", style: TextStyle(fontSize: 14)),
                                    Text("${_formatter.format(snapshot.data.todayDeaths)}",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      }),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                  ),
                  StreamBuilder<CovidCountry>(
                      stream: _bloc.country,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text("Recovered", style: TextStyle(fontSize: 14)),
                                    Text("${_formatter.format(snapshot.data.recovered)}",
                                        style:
                                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text("Critical", style: TextStyle(fontSize: 14)),
                                    Text("${_formatter.format(snapshot.data.critical)}",
                                        style:
                                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text("Total Mortality", style: TextStyle(fontSize: 14)),
                                    Text("${_formatter.format(snapshot.data.deaths)}",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return  Container();//Center(child: CircularProgressIndicator());
                      }),
                  Divider(
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 70),
                        child: StreamBuilder<List<CovidCountry>>(
                            stream: _bloc.countries,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        trailing: Text(
                                          "${_formatter.format(snapshot.data[index].cases)}",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        leading: CircleAvatar(
                                            backgroundImage: NetworkImage(snapshot.data[index].countryInfo.flag)),
                                        title: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Text(
                                              snapshot.data[index].country,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            divider,
                                          ],
                                        ),
                                        onTap: () async {
                                          await _onSelectCountry(snapshot.data[index].country);
                                        },
                                      );
                                    });
                              }
                              return Center(child: CircularProgressIndicator());
                            }),
                      ))
                ],
              ),
              SlidingSheet(
                duration: const Duration(milliseconds: 800),
                //color: Colors.white,
                elevation: 12,
                cornerRadius: 16,
                cornerRadiusOnFullscreen: 0.0,
                closeOnBackdropTap: true,
                closeOnBackButtonPressed: true,
                addTopViewPaddingOnFullscreen: true,
                isBackdropInteractable: true,
                snapSpec: const SnapSpec(
                  snap: true,
                  snappings: const [
                    SnapSpec.headerFooterSnap,
                    0.4, 0.7, 1.0,
                    SnapSpec.expanded,
                  ],
                  positioning: SnapPositioning.relativeToSheetHeight
                ),
                builder: (context, state) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.white,
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        children: <Widget>[
                          StreamBuilder<CovidCountry>(
                              stream: _bloc.country,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Image(
                                        image: NetworkImage(snapshot.data.countryInfo.flag),
                                        height: 100,
                                        width: 200,
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Text('Tests Performed',
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('${_formatter.format(snapshot.data.tests)}',
                                              style: TextStyle(
                                                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                                        ],
                                      )
                                    ],
                                  );
                                }
                                return CircularProgressIndicator();
                              }),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.crop_square, color: Colors.blue),
                                    Text('Active Cases'),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.crop_square, color: Colors.green),
                                    Text('Recovered'),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.crop_square, color: Colors.red),
                                    Text('Mortality'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text('Cummulative Cases',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: TextDecoration.underline)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Last",
                                        style:
                                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    StreamBuilder<KeyValuePair>(
                                        stream: _bloc.days,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return DropdownButton(
                                              onChanged: (selected) {
                                                _bloc.daysController.sink.add(selected);
                                                _bloc.fetchHistory(_country, selected.value);
                                              },
                                              value: snapshot.data,
                                              hint: Text(
                                                'Select Days',
                                                style: TextStyle(color: Colors.black),
                                              ),
                                              style: TextStyle(color: Colors.black),
                                              items: _lastDays.map((KeyValuePair pair) {
                                                return DropdownMenuItem<KeyValuePair>(
                                                  value: pair,
                                                  child: Center(child: Text(pair.name)),
                                                );
                                              }).toList(),
                                            );
                                          }
                                          return Container();
                                        }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            height: 200,
                            child: StreamBuilder<CovidHistoricalData>(
                                stream: _bloc.history,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return charts.TimeSeriesChart(
                                      _createHistoricalData(snapshot.data.timeline),
                                      defaultRenderer: new charts.LineRendererConfig(includeArea: true),
                                      animate: true,
                                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                                    );
                                  }
                                  return Center(child: CircularProgressIndicator());
                                }),
                          ),
                          divider,
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text('Daily Cases',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: TextDecoration.underline)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            height: 200,
                            child: StreamBuilder<CovidHistoricalData>(
                                stream: _bloc.history,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return charts.TimeSeriesChart(
                                      _createHistoricalData(Timeline(
                                        cases: _createDailyCasesHistory(snapshot.data.timeline.cases),
                                        deaths: _createDailyCasesHistory(snapshot.data.timeline.deaths),
                                        recovered: _createDailyCasesHistory(snapshot.data.timeline.recovered),
                                      )),
                                      defaultRenderer: new charts.LineRendererConfig(includeArea: true),
                                      animate: true,
                                      dateTimeFactory: const charts.LocalDateTimeFactory(),
                                    );
                                  }
                                  return Center(child: CircularProgressIndicator());
                                }),
                          ),
                          SizedBox(height: 100,child: Center(child: Text("-- End --")))
                        ],
                      ),
                    ),
                  );
                },
                headerBuilder: (context, state) {
                  return Container(
                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.maximize),
                          Text(
                            'Country Statistics',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ));
  }
}
