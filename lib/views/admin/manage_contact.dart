import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/models/contact_model.dart';
import 'package:driving_school/views/admin/add_contact.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class ManageContact extends StatelessWidget {
  const ManageContact({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // final adminCourseController = Provider.of<UserController>(context);
    return Scaffold(
      body: Stack(
        children: [
          ////////////////////////////////////////////////////////
          Positioned(
              top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Image.asset('assets/Ellipse 36.png')]),
          ///////////////////////////////////////////////////
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: width,
                  height: height / 6,
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(EvaIcons.arrow_ios_back_outline),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Manage Contact',
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<AdminController>(
                      builder: (context, contactController, _) {
                    return FutureBuilder(
                        future: contactController.fetchContacts(),
                        builder: (context, snapshot) {
                          return snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : contactController.contactsList.isEmpty
                                  ? const Center(
                                      child: Text('No Contacts Found'),
                                    )
                                  : snapshot.hasError
                                      ? Center(
                                          child:
                                              Text(snapshot.error.toString()),
                                        )
                                      : ListView.separated(
                                          itemBuilder: (context, index) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                                border: Border.all(color: Colors.grey.shade100),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                     padding: const EdgeInsets.all(12),
                                                     decoration: BoxDecoration(
                                                       color: index % 2 == 0 ? Colors.blue.shade50 : Colors.amber.shade50,
                                                       shape: BoxShape.circle,
                                                     ),
                                                     child: Icon(
                                                       Icons.person_outline, 
                                                       color: index % 2 == 0 ? Colors.blue : Colors.amber.shade800,
                                                       size: 24,
                                                     ),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          contactController.contactsList[index].contactName,
                                                          style: GoogleFonts.epilogue(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                              color: Colors.black87
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          contactController.contactsList[index].contactNumber.toString(),
                                                          style: GoogleFonts.epilogue(
                                                              fontSize: 14,
                                                              color: Colors.grey.shade600
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            _showEditDialog(
                                                              context,
                                                              contactController
                                                                  .contactsList[index],
                                                              contactController);
                                                          },
                                                          icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600)),
                                                      IconButton(
                                                        onPressed: () {
                                                          contactController.deleteContact(
                                                              contactController
                                                                  .contactsList[index]
                                                                  .contactID,
                                                              context);
                                                        },
                                                        icon: Container(
                                                          padding: const EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                            color: Colors.red.shade50,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.red.shade400,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(
                                                height: 15,
                                              ),
                                          itemCount: contactController
                                              .contactsList.length);
                        });
                  }),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddContact(),
            ),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, ContactModel contact, AdminController controller) {
    final nameController = TextEditingController(text: contact.contactName);
    final numberController =
        TextEditingController(text: contact.contactNumber.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Contact',
              style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: GoogleFonts.epilogue(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: numberController,
                  decoration: InputDecoration(
                    labelText: 'Number',
                    labelStyle: GoogleFonts.epilogue(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Number is required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.epilogue(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: defaultBlue),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ContactModel updatedContact = ContactModel(
                    contactID: contact.contactID,
                    contactName: nameController.text,
                    contactNumber: int.parse(numberController.text),
                  );
                  controller.updateContact(updatedContact, context);
                }
              },
              child: Text('Update',
                  style: GoogleFonts.epilogue(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
