import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat/main.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.imageUrl, required this.onUpload});

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey,
                  child: const Center(child: Text('No image!')),
                ),
        ),
        const SizedBox(
          height: 12,
        ),
        ElevatedButton(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();

              XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image == null) {
                return;
              }
              final imageExtension = image.path
                  .split('.')
                  .last
                  .toLowerCase(); /*path/to/image.jpg->jpg*/
              final userId = supabase.auth.currentUser!.id;
              final imagePath = '/$userId/profile';
              final imageBytes = await image.readAsBytes();
              await supabase.storage.from('profiles').uploadBinary(
                  imagePath, imageBytes,
                  fileOptions: FileOptions(
                      upsert: true,
                      contentType: 'image/$imageExtension')); //bucket name
              String imageUrl =
                  supabase.storage.from('profiles').getPublicUrl(imagePath);

              imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
                't': DateTime.now().millisecondsSinceEpoch.toString()
              }).toString();

              //https://example.supabase.co/storage/v1/object/public/profiles/image.jpg?t=1678901234567.
              //The timestamp helps ensure that the image is fetched from the server instead of being loaded from a cache, which can be useful for ensuring that the latest version of the image is displayed.
              onUpload(imageUrl);
            },
            child: const Text('Upload')),
      ],
    );
  }
}
