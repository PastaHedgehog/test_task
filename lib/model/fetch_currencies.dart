import 'Currency.dart'; //* наш класс для работы с валютой
import 'package:http/http.dart' as http; //* пакет для hhtp запросов
import 'package:xml/xml.dart' as xml; //* пакет для работы с XML

//*   Асинхронная функция, отвечающая за получения данных из сайта ЦБ посредством обращения к удалённому XML Файлу

Future<List<Currency>> fetchCurrencies() async {
  final response = await http.get(Uri.parse(
      'http://www.cbr.ru/scripts/XML_daily.asp')); //* запрос к удалённому XML файлу

  final document = xml.XmlDocument.parse(response
      .body); //* парсинг XML и запись его в переменную для дальнейшей работы с ним
  final elements = document.findAllElements(
      'Valute'); //* Запись элементов с тегом  "Valute" переменную для удобства дальнейшей работы

  final currencies = elements.where((element) {
    //* начинаем поиск необходимых нам валют
    final charCode = element
        .findElements('CharCode')
        .first
        .text; //*  получаем первый элемент в виде текста
    return charCode ==
            'USD' || //* возвращаем только те валюты, которые требуется получить
        charCode == 'EUR' ||
        charCode == 'BYN' ||
        charCode == 'KZT';
  }).map((element) {
    //* формируем представление с нашими данными
    final name = element.findElements('CharCode').first.text;
    final value = element.findElements('Value').first.text;

    return Currency(
        name,
        double.parse(value.replaceFirst(',',
            '.'))); //* возвращаем экземпляр объекста  Currency с полученными данными
  });

  return currencies.toList(); //* конвертируем все в список
}
