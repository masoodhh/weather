import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:weather/core/params/ForecastParams.dart';
import 'package:weather/core/utils/date_converter.dart';
import 'package:weather/core/widgets/app_background.dart';
import 'package:weather/core/widgets/dot_loading_widget.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:weather/features/feature_weather/data/models/ForcastDaysModel.dart';
import 'package:weather/features/feature_weather/domain/entities/current_city_entity.dart';
import 'package:weather/features/feature_weather/domain/entities/forecase_days_entity.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_suggestion_city_usecase.dart';
import 'package:weather/features/feature_weather/presentation/bloc/cw_status.dart';
import 'package:weather/features/feature_weather/presentation/bloc/fw_status.dart';
import 'package:weather/features/feature_weather/presentation/bloc/home_bloc.dart';
import 'package:weather/features/feature_weather/presentation/widgets/bookmark_icon.dart';
import 'package:weather/features/feature_weather/presentation/widgets/day_weather_view.dart';
import 'package:weather/locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../data/models/suggest_city_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  TextEditingController textEditingController = TextEditingController();

  GetSuggestionCityUseCase getSuggestionCityUseCase = GetSuggestionCityUseCase(locator());

  String cityName = "mashhad";
  final PageController _pageController = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(cityName));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final height = MediaQuery
        .of(context)
        .size
        .height;
    final width = MediaQuery
        .of(context)
        .size
        .width;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: height * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
            child: Row(
              children: [
                Expanded(
                  child: TypeAheadField(
                    controller: textEditingController,
                    onSelected: (Data model) {
                      textEditingController.text = model.name!;
                      BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(model.name!));
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onSubmitted: (String prefix) {
                          controller.text = prefix;
                          BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(prefix));
                        },
                        // controller: textEditingController,
                        style: DefaultTextStyle
                            .of(context)
                            .style
                            .copyWith(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          hintText: "Enter a City...",
                          hintStyle: TextStyle(color: Colors.white),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      );
                    },

                    suggestionsCallback: (String prefix) {
                      Logger logger=Logger();
                      logger.i(prefix);
                      return getSuggestionCityUseCase(prefix);
                    },
                    itemBuilder: (context, Data model) {
                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(model.name!),
                        subtitle: Text("${model.region!}, ${model.country}"),
                      );
                    },
                    /*onSuggestionSelected: (Data model) {
                      textEditingController.text = model.name!;
                      BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(model.name!));
                    },*/
                  ),
                ),
                const SizedBox(width: 10),
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (previous, current) {
                    if (previous.cwStatus == current.cwStatus) {
                      return false;
                    } else {
                      return true;
                    }
                  },
                  builder: (context, state) {
                    //show loading state for cw
                    if (state.cwStatus is CwLoading) {
                      return const CircularProgressIndicator();
                    }

                    //show error state for cw
                    if (state.cwStatus is CwError) {
                      return IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 35,
                        ),
                      );
                    }
                    //show loaded state for cw
                    if (state.cwStatus is CwCompleted) {
                      final CwCompleted cwComplete = state.cwStatus as CwCompleted;
                      BlocProvider.of<BookmarkBloc>(context).add(
                        GetCityByNameEvent(
                          cwComplete.currentCityEntity.name!,
                        ),
                      );
                      return BookMarkIcon(
                        name: cwComplete.currentCityEntity.name!,
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),

          //main ui
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) {
              /// rebuild just when CwStatus Changed
              if (previous.cwStatus == current.cwStatus) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state.cwStatus is CwLoading) {
                return const Expanded(child: DotLoadingWidget());
              }

              if (state.cwStatus is CwCompleted) {
                /// cast
                final CwCompleted cwCompleted = state.cwStatus as CwCompleted;
                final CurrentCityEntity currentCityEntity = cwCompleted.currentCityEntity;

                /// create params for api call
                final ForecastParams forecastParams = ForecastParams(
                  currentCityEntity.coord!.lat!,
                  currentCityEntity.coord!.lon!,
                );

                /// start load Fw event
                BlocProvider.of<HomeBloc>(context).add(LoadFwEvent(forecastParams));

                /// change Times to Hour --5:55 AM/PM----
                final sunrise = DateConverter.changeDtToDateTimeHour(
                  currentCityEntity.sys!.sunrise,
                  currentCityEntity.timezone,
                );
                final sunset = DateConverter.changeDtToDateTimeHour(
                  currentCityEntity.sys!.sunset,
                  currentCityEntity.timezone,
                );

                return Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: width,
                          height: 400,
                          child: PageView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            allowImplicitScrolling: true,
                            controller: _pageController,
                            itemCount: 2,
                            itemBuilder: (context, position) {
                              if (position == 0) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Text(
                                        currentCityEntity.name!,
                                        style: const TextStyle(
                                          fontSize: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Text(
                                        currentCityEntity.weather![0].description!,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: AppBackground.setIconForMain(
                                        currentCityEntity.weather![0].description!,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Text(
                                        "${currentCityEntity.main!.temp!.round()}\u00B0",
                                        style: const TextStyle(
                                          fontSize: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        /// max temp
                                        Column(
                                          children: [
                                            const Text(
                                              "max",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "${currentCityEntity.main!.tempMax!.round()}\u00B0",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),

                                        /// divider
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                            right: 10,
                                          ),
                                          child: Container(
                                            color: Colors.grey,
                                            width: 2,
                                            height: 40,
                                          ),
                                        ),

                                        /// min temp
                                        Column(
                                          children: [
                                            const Text(
                                              "min",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "${currentCityEntity.main!.tempMin!.round()}\u00B0",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                return Container(
                                  color: Colors.amber,
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      /// pageView Indicator
                      Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          // PageController
                          count: 2,
                          effect: const ExpandingDotsEffect(
                            dotWidth: 10,
                            dotHeight: 10,
                            spacing: 5,
                            activeDotColor: Colors.white,
                          ),
                          // your preferred effect
                          onDotClicked: (index) =>
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(microseconds: 500),
                                curve: Curves.bounceOut,
                              ),
                        ),
                      ),

                      /// divider
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Container(
                          color: Colors.white24,
                          height: 2,
                          width: double.infinity,
                        ),
                      ),

                      /// forecast weather 7 days
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                          width: double.infinity,
                          height: 130,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Center(
                              child: BlocBuilder<HomeBloc, HomeState>(
                                builder: (BuildContext context, state) {
                                  /// show Loading State for Fw
                                  if (state.fwStatus is FwLoading) {
                                    return const DotLoadingWidget();
                                  }

                                  /// show Completed State for Fw
                                  if (state.fwStatus is FwCompleted) {
                                    /// casting
                                    final FwCompleted fwCompleted = state.fwStatus as FwCompleted;
                                    final ForecastDaysEntity forecastDaysEntity =
                                        fwCompleted.forecastDaysEntity;
                                    final List<Daily> mainDaily = forecastDaysEntity.daily!;

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 8,
                                      itemBuilder: (BuildContext context,
                                          int index,) {
                                        return DaysWeatherView(
                                          daily: mainDaily[index],
                                        );
                                      },
                                    );
                                  }

                                  /// show Error State for Fw
                                  if (state.fwStatus is FwError) {
                                    final FwError fwError = state.fwStatus as FwError;
                                    return Center(
                                      child: Text(fwError.message!),
                                    );
                                  }

                                  /// show Default State for Fw
                                  return Container();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// divider
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Container(
                          color: Colors.white24,
                          height: 2,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "wind speed",
                                style: TextStyle(
                                  fontSize: height * 0.017,
                                  color: Colors.amber,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  "${currentCityEntity.wind!.speed!} m/s",
                                  style: TextStyle(
                                    fontSize: height * 0.016,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              color: Colors.white24,
                              height: 30,
                              width: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              children: [
                                Text(
                                  "sunrise",
                                  style: TextStyle(
                                    fontSize: height * 0.017,
                                    color: Colors.amber,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    sunrise,
                                    style: TextStyle(
                                      fontSize: height * 0.016,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              color: Colors.white24,
                              height: 30,
                              width: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              children: [
                                Text(
                                  "sunset",
                                  style: TextStyle(
                                    fontSize: height * 0.017,
                                    color: Colors.amber,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    sunset,
                                    style: TextStyle(
                                      fontSize: height * 0.016,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              color: Colors.white24,
                              height: 30,
                              width: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              children: [
                                Text(
                                  "humidity",
                                  style: TextStyle(
                                    fontSize: height * 0.017,
                                    color: Colors.amber,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    "${currentCityEntity.main!.humidity!}%",
                                    style: TextStyle(
                                      fontSize: height * 0.016,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                );
              }

              if (state.cwStatus is CwError) {
                return const Center(
                  child: Text('error'),
                );
              }

              return Container();
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
