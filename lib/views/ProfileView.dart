import 'package:flutter/material.dart';
import 'package:gigmap_mobile_flutter/components/GigmapAppBar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = true; // Placeholder for current user vs viewed user
    final bool isArtist = false; // Placeholder for user role
    final String? currentUserImage = ""; // Placeholder
    final String currentUserName = "Nombre de usuario"; // Placeholder
    final String currentUsername = "@username"; // Placeholder

    final List<String> tabOptions = isArtist
        ? ["Conciertos", "Comunidades", "Likes"]
        : ["GigList", "Comunidades", "Likes"];

    return DefaultTabController(
      length: tabOptions.length,
      initialIndex: _selectedTab,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GigMapAppBar(context: context),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Row below the custom AppBar that shows the title and logout action
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isOwner)
                        IconButton(
                          icon: const Icon(Icons.logout, color: Color(0xFF5C0F1A)),
                          onPressed: () {},
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),

                // HEADER
                Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFFEDEDED),
                      backgroundImage:
                          currentUserImage != null &&
                              currentUserImage.isNotEmpty
                          ? NetworkImage(currentUserImage)
                          : null,
                      child:
                          currentUserImage == null || currentUserImage.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 55,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      currentUserName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      currentUsername,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    if (isOwner)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C0F1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          "Editar perfil",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          "Seguir",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // TABS
                TabBar(
                  indicatorColor: const Color(0xFF5C0F1A),
                  labelColor: const Color(0xFF5C0F1A),
                  unselectedLabelColor: Colors.grey,
                  onTap: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                  tabs: tabOptions.map((title) => Tab(text: title)).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
