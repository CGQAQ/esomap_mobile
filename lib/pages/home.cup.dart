import 'package:esomap_mobile/api/summaries.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final controller = ScrollController();
  final searchController = TextEditingController();

  var summaries = <SummariesData>[];

  var currentPage = 0;

  var pageSize = 0;

  var stillHaveData = true;

  var keyword = "";

  var isSearching = false;

  @override
  void initState() {
    super.initState();
    summaries = [];

    refresh(reset: true);
    controller.addListener(scrollListener);
  }

  Future<void> refresh({bool reset = false}) async {
    final value = await getSummaries(
      pageCurrent: currentPage,
      keyword: keyword,
    );

    setState(() {
      if (reset) {
        summaries = value.data;
      } else {
        summaries.addAll(value.data);
      }
      pageSize = value.meta.pagination.pageSize;
      stillHaveData = value.meta.pagination.pageCount - 1 > currentPage;
    });
  }

  void scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if (stillHaveData) {
        refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 40,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CupertinoSearchTextField(
                          controller: searchController,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isSearching = true;
                            keyword = searchController.text;
                            refresh(reset: true).then((_) {
                              setState(() {
                                isSearching = false;
                              });
                            });
                          });
                        },
                        icon: isSearching
                            ? const CupertinoActivityIndicator()
                            : const Icon(
                                CupertinoIcons.search,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  controller: controller,
                  itemBuilder: (context, index) {
                    if (index >= summaries.length) {
                      if (stillHaveData) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      } else {
                        return Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text('No more data'),
                              ),
                            ),
                          ],
                        );
                      }
                    }

                    final summary = summaries[index];

                    return ListTile(
                      title: Text(summary.attributes.name),
                      subtitle: Text(summary.attributes.nameEn),
                      leading: summary.attributes.icon != null
                          ? Image.network(
                              summary.attributes.icon!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.fill,
                            )
                          : const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(CupertinoIcons.question_circle),
                            ),
                      trailing: Text(summary.attributes.type),
                      onTap: () {
                        showBottomSheet(
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: 400,
                              width: double.infinity,
                              child: Container(
                                color: const CupertinoThemeData()
                                    .scaffoldBackgroundColor,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Icon(
                                        CupertinoIcons.chevron_compact_down,
                                        size: 30,
                                        color: const CupertinoThemeData()
                                            .primaryColor,
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        child: ItemDetails(
                                          summary: summary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  itemCount: summaries.length + 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemDetails extends StatelessWidget {
  const ItemDetails({
    Key? key,
    required this.summary,
  }) : super(key: key);

  final SummariesData summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        InfoRow(
          name: "??????",
          value: summary.attributes.name,
        ),
        InfoRow(
          name: "????????????",
          value: summary.attributes.nameEn,
        ),
        InfoRow(
          name: "SLUG",
          value: summary.attributes.slug,
        ),
        InfoRow(
          name: "??????",
          value: summary.attributes.type,
        ),
        InfoRow(
          name: "??????",
          value: "${summary.attributes.itemCount}",
        ),
        InfoRow(
          name: "??????",
          value: summary.attributes.itemSlots,
        ),
        InfoRow(
          name: "????????????",
          value: summary.attributes.setBonusCount.toString(),
        ),
        InfoRow(
          name: "??????????????????",
          value: summary.attributes.setMaxEquipCount.toString(),
        ),
        InfoRow(
          name: "?????????ID",
          value: summary.attributes.gameId.toString(),
        ),
        InfoRow(
          name: '????????????(1)',
          value: summary.attributes.setBonusDesc1,
        ),
        InfoRow(
          name: '????????????(2)',
          value: summary.attributes.setBonusDesc2,
        ),
        InfoRow(
          name: '????????????(3)',
          value: summary.attributes.setBonusDesc3,
        ),
        InfoRow(
          name: '????????????(4)',
          value: summary.attributes.setBonusDesc4,
        ),
        InfoRow(
          name: '????????????(5)',
          value: summary.attributes.setBonusDesc5,
        ),
        InfoRow(
          name: '????????????(6)',
          value: summary.attributes.setBonusDesc6,
        ),
        InfoRow(
          name: '????????????(7)',
          value: summary.attributes.setBonusDesc7,
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    Key? key,
    required this.name,
    required this.value,
  }) : super(key: key);

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                "$name???",
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
