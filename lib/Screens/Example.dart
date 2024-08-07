import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  static const String id = "ddd";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Abandon'),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(),
                SizedBox(height: 10),
                WordDetails(),
                SizedBox(height: 10),
                TranslationDetails(),
                SizedBox(height: 10),
                FooterOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search...',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WordDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'abandon',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Icon(Icons.volume_up, color: Colors.blue),
            SizedBox(width: 5),
            Text('UK', style: TextStyle(color: Colors.blue)),
            SizedBox(width: 10),
            Icon(Icons.volume_up, color: Colors.red),
            SizedBox(width: 5),
            Text('US', style: TextStyle(color: Colors.red)),
          ],
        ),
        SizedBox(height: 5),
        Text(
          '/əˈbændən/ verb [transitive]',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class TranslationDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'ترک کردن، ترک گفتن، واگذاکردن، تسلیم شدن، رهاکردن، تبعیدکردن، واگذاری، رهاسازی، بی خیالی، رها کردن، علوم نظامی: رها کردن',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

class FooterOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'توضیحات فارسی\nشرح و مثالهای انگلیسی\nفلش کارت و فهرست لغات\nتلفظ آفلاین و آنلاین عبارات\nفونتیک با قابلیت تست تلفظ',
        style: TextStyle(fontSize: 16, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
