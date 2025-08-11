import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@uetrachna.edu.pk',
      queryParameters: {
        'subject': 'Complaint Management App Support',
      },
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch email app';
    }
  }

  void _launchLocation() async {
    final Uri mapUri = Uri.parse(
      'https://www.google.com/maps?q=7+km+Off+Main+G.T+Road,+Link+Rachna,+College+Road,+Gujranwala',
    );
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    } else {
      throw 'Could not open map location';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text("How do I submit a complaint?",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                      "Go to the Dashboard > New Complaint. Fill out the form and submit. A unique Complaint ID will be generated."),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("How can I track my complaint?",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                      "Use the ‘Track by Complaint ID’ page and enter your Registration Number to view your complains."),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("I forgot my password. What should I do?",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                      "Go to the Login screen and click on ‘Forgot Password’ to reset your password via email."),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Still need help?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _launchEmail,
              icon: const Icon(Icons.email_outlined),
              label: const Text("Contact Support via Email"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('https://rcet.uet.edu.pk/'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('UET Rachna Campus'),
              subtitle: const Text(
                  '7 km Off Main G.T Road, Link Rachna, College Road, Gujranwala'),
              onTap: _launchLocation,
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('(055)6770168'),
            ),
          ],
        ),
      ),
    );
  }
}
