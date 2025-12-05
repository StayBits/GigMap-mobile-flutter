import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigmap_mobile_flutter/bloc/users/UsersBloc.dart';
import 'package:gigmap_mobile_flutter/models/UserDataModel.dart';

class EditProfileView extends StatefulWidget {
  final UserDataModel user;

  const EditProfileView({super.key, required this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController usernameController;
  late TextEditingController nameController;
  late TextEditingController imageController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user.username);
    nameController = TextEditingController(text: widget.user.name);
    imageController = TextEditingController(text: widget.user.image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar perfil"),
        backgroundColor: const Color(0xFF5C0F1A),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UserUpdatedSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Perfil actualizado")),
            );
            Navigator.pop(context, true);
          }

          if (state is UsersErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final loading = state is UsersLoadingState;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar preview
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: imageController.text.trim().isNotEmpty
                      ? NetworkImage(imageController.text.trim())
                      : null,
                  child: imageController.text.trim().isEmpty
                      ? const Icon(Icons.person, size: 55, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),

                // USERNAME
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // NAME
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // IMAGE
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(
                    labelText: "URL de imagen",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 25),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                            context.read<UsersBloc>().add(
                                  UpdateUserEvent(
                                    userId: widget.user.id,
                                    email: widget.user.email,
                                    username: usernameController.text.trim(),
                                    isArtist: widget.user.isArtist,
                                    role: widget.user.role,
                                    name: nameController.text.trim(),
                                    image: imageController.text.trim()
                                  ),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C0F1A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Guardar cambios",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
