import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("About"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("YouTube Downloader App",
                      style: Theme.of(context).textTheme.headline5),
                  const SizedBox(height: 16.0),
                  Text("Brief Description:",
                      style: Theme.of(context).textTheme.subtitle1),
                  const SizedBox(height: 4.0),
                  Text(
                      "This app allows users to download videos from YouTube for offline viewing. It provides a convenient way to save videos for later or for use without an internet connection.",
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 16.0),
                  Text("Team Information:",
                      style: Theme.of(context).textTheme.subtitle1),
                  const SizedBox(height: 4.0),
                  Text("Developed by Omid.N",
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 16.0),
                  Text("Features:",
                      style: Theme.of(context).textTheme.subtitle1),
                  const SizedBox(height: 4.0),
                  Text("- Easy and fast downloads",
                      style: Theme.of(context).textTheme.bodyText2),
                  Text("- Supports multiple resolutions and formats",
                      style: Theme.of(context).textTheme.bodyText2),
                  Text("- Background download capability",
                      style: Theme.of(context).textTheme.bodyText2),
                  Text(
                      "- Multi-threaded downloading behind the scenes (using fetchme lib.)",
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 16.0),
                  Text("Contact Information:",
                      style: Theme.of(context).textTheme.subtitle1),
                  const SizedBox(height: 4.0),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.subtitle1,
                      children: <TextSpan>[
                        const TextSpan(text: 'Email: '),
                        TextSpan(
                            text: 'omidntech@gmail.com',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                const mailUrl = 'mailto:omidntech@gmail.com';
                                try {
                                  await launchUrl(Uri.parse(mailUrl));
                                } catch (e) {
                                  await Clipboard.setData(const ClipboardData(
                                      text: 'omidntech@gmail.com'));
                                }
                              }),
                        const TextSpan(text: '\nLinkedIn: '),
                        TextSpan(
                            text: 'Omid Nejadabbasi profile',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                const linkedInUrl = 'https://www.linkedin.com/in/omid-nejadabbasi-838135189/';
                                try {
                                  await launchUrl(Uri.parse(linkedInUrl));
                                } catch (e) {
                                  await Clipboard.setData(const ClipboardData(
                                      text: 'nejadabbasio@gmail.com'));
                                }
                              }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text("Version Information:",
                      style: Theme.of(context).textTheme.subtitle1),
                  const SizedBox(height: 4.0),
                  Text("Version 1.0.0",
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 16.0),
                  Text("Copyright © 2023 Omid Nejadabbasi.",
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 16.0),
                ])));
  }
}
