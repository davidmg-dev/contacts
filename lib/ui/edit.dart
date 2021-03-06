import 'dart:convert';

import 'package:contacts/ui/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../util/constants.dart' as constants;
import 'common/application_bar.dart';
import 'common/editor/toolbar.dart';
import 'common/input_field.dart';
import '../model/contact.dart';
import 'contact_list.dart';
import 'package:contacts/db/contact_table.dart';
import 'package:flutter/src/widgets/text.dart' as flutter;

class Edit extends ConsumerWidget {
  final Contact contact;

  Edit(this.contact, {Key? key}) : super(key: key);
  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController birthday = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController homeAddress = TextEditingController();
  final FocusNode _focus = FocusNode();
  QuillController _quillController = QuillController.basic();

  var phoneNumberMask = MaskTextInputFormatter(
      mask: '(###) ###-####x#####', filter: {"#": RegExp(r'[0-9]')});
  var birthdayMask = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});

  final editFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    fullName.text = contact.name;
    phoneNumber.text = contact.phoneNumber;
    birthday.text = contact.birthday!;
    email.text = contact.email!;
    homeAddress.text = contact.address!;

    var jsonContent = jsonDecode(contact.notes ?? "");
    _quillController = QuillController(
        document: Document.fromJson(jsonContent),
        selection: const TextSelection.collapsed(offset: 0));

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: ApplicationBar(
          "Edit Contact",
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (editFormKey.currentState!.validate()) {
                  await ContactTable().update(Contact(
                      id: contact.id,
                      name: fullName.text,
                      phoneNumber: phoneNumber.text,
                      birthday: birthday.text,
                      email: email.text,
                      address: homeAddress.text,
                      notes: jsonEncode(
                          _quillController.document.toDelta().toJson())));
                  ref.refresh(contactProvider(contact.id));
                  ref.refresh(contactListsProvider);
                  Navigator.pop(context);
                }
              },
              child: const flutter.Text(
                "Save",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: editFormKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Wrap(runSpacing: 20, children: [
                InputField(
                  fullName,
                  "Full Name",
                  TextInputType.text,
                  validation: (value) {
                    if (value == null || value.isEmpty) {
                      return constants.FULL_NAME_REQUIRED;
                    }
                    return null;
                  },
                ),
                InputField(phoneNumber, "Phone Number", TextInputType.phone,
                    inputFormatters: [phoneNumberMask]),
                InputField(
                  birthday,
                  "Birthday",
                  TextInputType.number,
                  inputFormatters: [birthdayMask],
                ),
                InputField(email, "Email Address", TextInputType.emailAddress),
                InputField(homeAddress, "Home Address", TextInputType.text),
                Row(children: const [
                  flutter.Text(
                    "Notes",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ]),
                Toolbar(quillController: _quillController),
                Flex(direction: Axis.horizontal, children: [
                  Expanded(
                    child: QuillEditor(
                        focusNode: _focus,
                        autoFocus: false,
                        controller: _quillController,
                        readOnly: false,
                        scrollController: ScrollController(),
                        scrollable: true,
                        padding: EdgeInsets.zero,
                        expands: false),
                  ),
                ])
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
