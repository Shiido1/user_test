// ignore_for_file: unused_result

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// this future function fetches data from the api
Future<List<dynamic>> fetchData() async {
  final url = Uri.parse('https://jsonplaceholder.typicode.com/users');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load data');
  }
}

// FutureProvider for fetching and manage user data
final dataProvider = FutureProvider<List<dynamic>>((ref) async {
  return fetchData();
});

// ignore: must_be_immutable
class HomePage extends ConsumerWidget {
  final TextEditingController searchController = TextEditingController();
  final RefreshController refreshController = RefreshController();
  String query = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider for data state
    final dataAsync = ref.watch(dataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                // Update the query as user types
                query = value;
                // Rebuild UI when query changes
                ref.refresh(dataProvider);
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: dataAsync.when(
              data: (data) {
                // Filter the list based on the query
                final filteredData = data.where((user) {
                  return user['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase());
                }).toList();

                return SmartRefresher(
                    controller: refreshController,
                    enablePullDown: true,
                    onRefresh: () async {
                      // Trigger data reload and refresh UI
                      ref.refresh(dataProvider);
                      refreshController.refreshCompleted();
                    },
                    child: filteredData.isEmpty
                        ? const Center(child: Text('No results found'))
                        : SizedBox(
                            height: 550,
                            child: ListView(children: [
                              ...filteredData.map((e) => Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 14),
                                      decoration: BoxDecoration(
                                          color:
                                              Colors.blueGrey.withOpacity(.1)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 160,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e["name"],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                      fontSize: 15.6,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  e["email"]
                                                      .toString()
                                                      .toLowerCase(),
                                                  style: const TextStyle(
                                                      fontSize: 13.6,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                const SizedBox(height: 4),
                                                SizedBox(
                                                  width: 150,
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .person_pin_circle_outlined,
                                                        size: 22,
                                                        color: Color.fromARGB(
                                                            255, 87, 83, 83),
                                                      ),
                                                      const SizedBox(
                                                          width: 2.4),
                                                      Text(
                                                        '@${e["username"].toString().toLowerCase()}',
                                                        style: const TextStyle(
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 114.0,
                                            child: Wrap(
                                              children: [
                                                const Text(
                                                  'Address: ',
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  '${e["address"]["street"]}, ${e["address"]["suite"]},${e["address"]["city"]}',
                                                  style: const TextStyle(
                                                      fontSize: 12.2,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ))))
                            ]),
                          ));
              },
              loading: () => SingleChildScrollView(
                child: Column(
                  children: [
                    ...[1, 2, 3, 4, 5, 6, 7].map((o) => getShimmers())
                  ],
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  getShimmers() => Padding(
        padding: const EdgeInsets.all(14.0),
        child: Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: const Color.fromARGB(255, 201, 197, 197),
          child: Container(
            width: double.infinity,
            height: 80.0,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(6)),
          ),
        ),
      );
}
