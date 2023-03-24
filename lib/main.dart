import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Котировки валют',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExchangeRatesScreen(),
    );
  }
}

class ExchangeRatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Котировки валют'),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchExchangeRates(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(snapshot.data![index]),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка при загрузке котировок: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

Future<List<String>> fetchExchangeRates() async {
  final response =
      await http.get(Uri.parse('https://www.cbr.ru/scripts/XML_daily.asp'));
  final document = XmlDocument.parse(response.body);
  final rates = document.findAllElements('Valute').map((element) {
    final name = element.findElements('CharCode').single.text;
    final value = element.findElements('Value').single.text;
    return '$name: $value';
  }).toList();
  return rates;
}
