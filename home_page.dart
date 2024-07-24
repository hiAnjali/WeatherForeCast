import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:weather/api_key.dart';
import 'package:weather/model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiResponse? response;
  bool inProgress = false;
  String message = "";

  int currentPageIndex = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: currentPageIndex,
                  children: [
                    /// Home page
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Your current weather',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),

                    /// Search page
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildSearchWidget(),
                          const SizedBox(height: 20),
                          if (inProgress)
                            CircularProgressIndicator()
                          else
                            Expanded(
                                child: SingleChildScrollView(
                                    child: _buildWeatherWidget())),
                        ],
                      ),
                    ),

                    /// Calendar page
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        margin: const EdgeInsets.all(0.0),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month'
                          },
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Card()
                  ],
                ),
              ),
              NavigationBar(
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                indicatorColor: Color.fromARGB(221, 244, 172, 78),
                selectedIndex: currentPageIndex,
                destinations: const <Widget>[
                  NavigationDestination(
                    selectedIcon: Icon(Icons.location_on_outlined),
                    icon: Icon(Icons.location_on_outlined),
                    label: 'Your Location',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_outlined),
                    label: 'Search',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    label: 'Calendar',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchWidget() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search any Location",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.location_on_outlined,
            color: Color.fromARGB(221, 244, 172, 78)),
      ),
      onSubmitted: (value) {
        _getWeatherData(value);
      },
    );
  }

  Widget _buildWeatherWidget() {
    if(response == null){
      return Column(
        children: [
          Image.asset(
            'assets/images/not_found.png',
            height: 300,
            width: 300,
          ),
         
          Text(
            "Get Weather ForeCasts",
            style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.w100),
          )
        ],
      );
    
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                response?.location?.name ?? "",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(221, 244, 172, 78),
                ),
              ),
              Text(
                response?.location?.country ?? "",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w100,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              height: 250,
              child: Image.network(
                "https:${response?.current?.condition?.icon}"
                    .replaceAll("64x64", "128x128"),
                scale: 0.7,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  (response?.current?.tempC.toString() ?? "") + " °c",
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                response?.current?.condition?.text.toString() ?? "",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              )
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _dataAndTitleWidget("Humidity",
                      response?.current?.humidity?.toString() ?? ""),
                  _dataAndTitleWidget("Wind Speed",
                      "${response?.current?.windKph?.toString() ?? ""} km/h"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _dataAndTitleWidget(
                      "UV", response?.current?.uv?.toString() ?? ""),
                  _dataAndTitleWidget("Precipitation",
                      "${response?.current?.precipMm?.toString() ?? ""} mm"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _dataAndTitleWidget("Local Time",
                      response?.location?.localtime?.split(" ").last ?? ""),
                  _dataAndTitleWidget("Local Date",
                      response?.location?.localtime?.split(" ").first ?? ""),
                ],
              ),
            ],
          )
        ],
      );
    }
  }

  Widget _dataAndTitleWidget(String title, String data) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          Text(
            data,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(221, 244, 172, 78),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _getWeatherData(String location) async {
    setState(() {
      inProgress = true;
    });

    try {
      response = await weatherApi().getCurrentWeather(location);
    } catch (e) {
      setState(() {
        message = "Failed to get the location";
        response = null;
      });
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
