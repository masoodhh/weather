import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:weather/features/feature_bookmark/domain/entities/city_entity.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:weather/features/feature_weather/presentation/bloc/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../locator.dart';
import '../../../feature_weather/data/models/suggest_city_model.dart';
import '../../../feature_weather/domain/use_cases/get_suggestion_city_usecase.dart';

class BookMarkScreen extends StatefulWidget {
  final PageController pageController;

  const BookMarkScreen({super.key, required this.pageController});

  @override
  State<BookMarkScreen> createState() => _BookMarkScreenState();
}

class _BookMarkScreenState extends State<BookMarkScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    BlocProvider.of<BookmarkBloc>(context).add(GetAllCityEvent());
     TextEditingController _textEditingController = TextEditingController();

    final GetSuggestionCityUseCase _getSuggestionCityUseCase = GetSuggestionCityUseCase(locator());
    final FocusNode _focusNode = FocusNode();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TypeAheadField(
              hideOnUnfocus: true,
              controller: _textEditingController,
              onSelected: (Data model) {
                _textEditingController.clear();
                BlocProvider.of<BookmarkBloc>(context).add(SaveCwEvent(model.name!));
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    hintText: "search a City...",
                    hintStyle: TextStyle(color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _textEditingController.clear(); // پاک کردن متن فیلد
                      },
                    )
                  ),
                );
              },
              suggestionsCallback: (String prefix) {
                if (prefix.length > 2) return _getSuggestionCityUseCase(prefix);
              },
              itemBuilder: (context, Data model) {
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(model.name!),
                  subtitle: Text("${model.region!}, ${model.country}"),
                );
              },
            )
            ,
          ),
          Expanded(
            child: BlocBuilder<BookmarkBloc, BookmarkState>(
              buildWhen: (previous, current) {
                /// rebuild UI just when allCityStatus Changed
                if (current.status == previous.status) {
                  return false;
                } else {
                  return true;
                }
              },
              builder: (context, state) {
                /// show Loading for AllCityStatus
                if (state.status == Status.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                /// show Error for AllCityStatus
                if (state.status == Status.error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error!),
                        duration: Duration(seconds: 3), // مدت زمان نمایش پیام
                        behavior: SnackBarBehavior.floating, // نمایش پیام در بالای صفحه
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height - 140, right: 20, left: 20),
                      ),
                    );
                  });
                }

                /// show Completed for AllCityStatus
                if (state.status == Status.completed || state.status == Status.error) {
                  final List<City> cities = state.cities;

                  return Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        /// show text in center if there is no city bookmarked
                        child: (cities.isEmpty)
                            ? const Center(
                                child: Text(
                                  'there is no bookmark city',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.builder(
                                itemCount: cities.length,
                                itemBuilder: (context, index) {
                                  final City city = cities[index];
                                  return GestureDetector(
                                    onTap: () {
                                      /// call for getting bookmarked city Data
                                      BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(city.name));

                                      /// animate to HomeScreen for showing Data
                                      widget.pageController.animateToPage(
                                        0,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 5.0,
                                            sigmaY: 5.0,
                                          ),
                                          child: Container(
                                            width: width,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                              color: Colors.grey.withOpacity(0.1),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 20.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    city.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      BlocProvider.of<BookmarkBloc>(context)
                                                          .add(DeleteCityEvent(city.name));
                                                      BlocProvider.of<BookmarkBloc>(context)
                                                          .add(GetAllCityEvent());
                                                    },
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                ],
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
                  );
                }

                /// show Default value
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
