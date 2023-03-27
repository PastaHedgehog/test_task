import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, double> _exchangeRates = {};

//* Метод для получения котировок на сегодняшний день ___________________________________________________________________________________
  Future<void> _fetchExchangeRates() async {
    var response = await http.get(Uri.parse(
        'http://www.cbr.ru/scripts/XML_daily.asp')); //* Запрос к файлу ЦБ

    var document =
        XmlDocument.parse(response.body); //*  парсинг полученного XML  файла
    var root = document.rootElement;

    Map<String, double> exchangeRates = {}; //*создаем словарь

    //*  записываем в наш словарь только необходимые элементы
    for (var element in root.children) {
      var currencyCode = element.findElements('CharCode').single.text;
      if (currencyCode == 'USD' ||
          currencyCode == 'EUR' ||
          currencyCode == 'BYN' ||
          currencyCode == 'KZT') {
        var exchangeRate = double.parse(
            element.findElements('Value').single.text.replaceAll(',', '.'));

        exchangeRates[currencyCode] = exchangeRate;
      }
    }

    //*  выводим наши значения на экран
    setState(() {
      _exchangeRates = exchangeRates;
    });
  }

//* Метод для получения котировок на заданую дату___________________________________________________________________________________
  Future<void> _fetchExchangeRatesByDate(DateTime date) async {
    var formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'; //*  форматируем нашу дату для запроса
    var response = await http.get(Uri.parse(
        'http://www.cbr.ru/scripts/XML_daily.asp?date_req=$formattedDate')); //* получаем данные за указанный период

    var document = XmlDocument.parse(response.body);
    var root = document.rootElement;

    Map<String, double> exchangeRates = {}; //*создаем словарь

    //*  записываем в наш словарь только необходимые элементы
    for (var element in root.children) {
      var currencyCode = element.findElements('CharCode').single.text;
      if (currencyCode == 'USD' ||
          currencyCode == 'EUR' ||
          currencyCode == 'BYN' ||
          currencyCode == 'KZT') {
        var exchangeRate = double.parse(
            element.findElements('Value').single.text.replaceAll(',', '.'));

        exchangeRates[currencyCode] = exchangeRate;
      }
    }

    //*  выводим наши значения на экран
    setState(() {
      _exchangeRates = exchangeRates;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        title: Align(
          alignment: Alignment.center,
          child: Text(widget.title,
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Roboto",
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Сегодня:  ${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}',
              style: TextStyle(
                  fontSize: 30,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ListView.builder(
              //* создаем наш список
              itemCount: _exchangeRates
                  .length, //* задаём длинну, равную длинне словаря
              itemBuilder: (BuildContext context, int index) {
                var currencyCode = _exchangeRates.keys.toList()[
                    index]; //* обращаемся к нашим данным  для дальнейшей работы  с ними
                var exchangeRate = _exchangeRates[currencyCode]!;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Container(
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 2, color: Color.fromARGB(255, 22, 21, 82)),
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 10,
                      child: Align(
                        alignment: Alignment.center,
                        child: ListTile(
                          title: Text(
                            currencyCode,
                            style: TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                              exchangeRate.toStringAsFixed(2) + " руб.",
                              style: TextStyle(
                                  fontFamily: "Roboto", fontSize: 25)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      //* элемент для выбора действия
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromARGB(255, 109, 109, 109),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.today,
            ),
            label: 'Сегодня',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Выбрать дату',
          ),
        ],
        onTap: (index) async {
          if (index == 0) {
            await _fetchExchangeRates();
          } else {
            //* выбор действия при нажатии на кнопки
            var selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1992),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Color.fromARGB(
                              255, 22, 21, 82), // header background color
                          onPrimary: Color.fromARGB(
                              255, 255, 255, 255), // header text color
                          onSurface: Color.fromARGB(
                              255, 22, 21, 82), // body text color
                        ),
                      ),
                      child: child!);
                });

            if (selectedDate != null) {
              await _fetchExchangeRatesByDate(selectedDate);
            }
          }
        },
      ),
    );
  }
}
