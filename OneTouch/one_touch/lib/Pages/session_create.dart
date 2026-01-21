import 'package:flutter/material.dart';
import '../Objects/template.dart';
import 'note_session.dart';

/* This page will be used for creating note sessions */

class SessionCreate extends StatefulWidget{ 
  final Template template;
  final void Function(Template, String) saveTemplatesCallback;

  const SessionCreate({
    super.key,
    required this.template,
    required this.saveTemplatesCallback
  });

  @override
  State<StatefulWidget> createState() => _SessionCreate();
}

class _SessionCreate extends State<SessionCreate> {
  final textController = TextEditingController();

  @override
  // clean up controller when widget is disposed
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override 
  Widget build(BuildContext BuildContext) {
    return Scaffold(
      appBar: AppBar(title: RichText(
        text: TextSpan(
            text: 'Create session from template: ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20
            ),
            children: <TextSpan>[
              TextSpan(
                text: widget.template.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              )
            ]
          )
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: "Session Title",
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              child: const Text('Create new session'),
              onPressed: (){
                Navigator.pop(context);
                // create a cloned version of the template with new id
                Template newSession = widget.template.clone();
                newSession.name = textController.text;
                newSession.id = newSession.idGenerator();
                widget.saveTemplatesCallback(newSession, "addSession");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return NoteSession(template: newSession, saveTemplatesCallback: widget.saveTemplatesCallback);
                    }
                  ),
                );
              },
            ),
          ]
        )

      )
    );
  }
}
