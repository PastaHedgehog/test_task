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
      home: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30)),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'Currency  Rates App',
              style: TextStyle(
                  color: Color.fromARGB(255, 128, 128, 128),
                  fontSize: 25,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        body: FutureBuilder<List<Currency>>(
          //* создаем в нашем body виджет  FutureBuilder
          future:
              fetchCurrencies(), //* передаем в него нашу функцию для получения данных
          builder: //* приступаем к формированию нашего элемента
              (BuildContext context, AsyncSnapshot<List<Currency>> snapshot) {
            if (snapshot.hasData) {
              //* Если у нас есть данные, то загрузим наш экран
              return ListView.builder(
                //* создаем бесконечный ListView
                itemCount: snapshot.data!
                    .length, //* задаём количество элементов на основании нашего запроса к XML файлу
                itemBuilder: (BuildContext context, int index) {
                  final currency = snapshot.data![
                      index]; //* получаем данные из предоставленного списка по индексу
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 30),
                    child: SizedBox(
                      height: 120,
                      child: Card(
                        //* возвращаем элемент с нашими данными
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: BorderSide(
                                color: Color.fromRGBO(107, 107, 107, 1),
                                width: 2)),
                        elevation: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: ListTile(
                            title: Text(
                              currency.name,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Roboto",
                              ),
                            ),
                            trailing: Text(
                              currency.value.toStringAsFixed(2) + " руб",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Roboto",
                              ),
                            ),
                          ),
                        ),
                      ),
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
