import 'package:flutter/material.dart'; //* стандартный пакет
import './model/fetch_currencies.dart'; //* наша функция
import 'model/Currency.dart'; //* наш класс для работы с валютой

void main() {
  runApp(MyApp()); //* запуск приложения
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Exchange Rates',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Currency Exchange Rates'),
        ),
        body: FutureBuilder<List<Currency>>(
          //* создаем в нашем body виджет  FutureBuilder
          future:
              fetchCurrencies(), //* передаем в него нашу функцию для получения данных
          builder: //* приступаем к формированию нашего элемента
              (BuildContext context, AsyncSnapshot<List<Currency>> snapshot) {
            if (snapshot.hasData) {
              //* проверка на наличие данных
              return ListView.builder(
                //* создаем бесконечный ListView
                itemCount: snapshot.data!
                    .length, //* задаём количество элементов на основании нашего запроса к XML файлу
                itemBuilder: (BuildContext context, int index) {
                  final currency = snapshot.data![
                      index]; //* получаем данные из предоставленного списка по индексу
                  return Card(
                    //* возвращаем элемент с нашими данными
                    child: ListTile(
                      title: Text(currency.name),
                      subtitle: Text(currency.value.toStringAsFixed(2)),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Error: ${snapshot.error}')); //* если произошел сбой, то выведем ошибку
            } else {
              return Center(
                  child:
                      CircularProgressIndicator()); //* иначе выведем индикатор о прогрессе загрузки данных
            }
          },
        ),
      ),
    );
  }
}
