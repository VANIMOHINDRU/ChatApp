import 'package:flutter/material.dart';
import 'package:chat/avatar.dart';
import 'package:chat/main.dart';
import 'package:chat/pages/chat.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _imageUrl;
  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getInitialProfile();
  }

  Future<void> _getInitialProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle(); //at most one row

    if (data != null) {
      setState(() {
        _usernameController.text = data[
            'username']; //data object, which contains the user's profile information fetched from the Supabase database.
        _websiteController.text = data['website'];
        _imageUrl = data['avatar_url'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Avatar(
                imageUrl: _imageUrl,
                onUpload: (imageUrl) async {
                  setState(() {
                    _imageUrl = imageUrl;
                  });
                  final userId = supabase.auth.currentUser!.id;
                  await supabase
                      .from('profiles')
                      .update({'avatar_url': imageUrl}).eq('id', userId);
                }),
            const SizedBox(
              height: 12,
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(label: Text('Username')),
            ),
            const SizedBox(
              height: 12,
            ),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(label: Text('Website')),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
                onPressed: () async {
                  final username = _usernameController.text.trim();
                  final website = _websiteController.text.trim();
                  final userId = supabase.auth.currentUser!.id;
                  await supabase
                      .from('profiles')
                      .update({'username': username, 'website': website}).eq(
                          'id', userId);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Your data has been saved')));
                  }
                },
                child: const Text('Save')),
            const SizedBox(
              height: 24,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return const Chat();
                        },
                      ));
                    },
                    child: const Text('Next')),
              ],
            )
          ],
        ));
  }
}
