part of views;

class InfoView extends StatefulWidget {
  const InfoView({Key key}) : super(key: key);

  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            InfoTab(),
            ScreenTab(),
            KeypadTab(),
          ]),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        builder: (BuildContext context, bool value, Widget child) {
          return Offstage(
            offstage: toolbarHidden.value,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: kFloatingActionButtonMargin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.9,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: 210,
                        child: TabBar(
                            controller: _tabController,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.info),
                              ),
                              Tab(
                                icon: Icon(Icons.cast),
                              ),
                              Tab(
                                icon: Icon(Icons.dialpad),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        valueListenable: toolbarHidden,
      ),
    );
  }
}
