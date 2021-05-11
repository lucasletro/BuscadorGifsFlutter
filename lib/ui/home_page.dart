import 'dart:async';
import 'dart:convert';
//import 'dart:ffi';


import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;

  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if(_search == null)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=fmM4O5gqMIMkbwFbanlzW3mEV2NZZXKf&limit=20&rating=g");
    else
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=fmM4O5gqMIMkbwFbanlzW3mEV2NZZXKf&q=$_search&limit=19&offset=$_offset&rating=g&lang=en");

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGifs().then((map){
      print(map);
    });
  }

//LAYOUT DO APP.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _search = text;
                  _offset = 0;  //resetar o offset
                });
              },
            ),
          ),
          // ESPAÇO DOS GIFS.
          Expanded(                                  //expanded é para o future builder saber qual espaço vai ocupar. senao ocuparia o espaço todo.
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){           //caso esteja esperando ou carregando nada, vai ser mostrado um indicador de carregando alguma coisa.
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),     //especificando a cor do indicador de carregando.
                        strokeWidth: 5.0,                                            //largura do indicador carregando.
                      ),
                    );
                  default:
                    //depois que ele carregou os dados tenho que retornar aqui o container contendo os dados qe quero mostrar.
                    if(snapshot.hasError) return Container();                   //se snapshot contem error vai retornar um container vazio.
                    else return _createGifTable(context,snapshot);              //caso contrario vai retornar a tabela de gifs.
                }
              }
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data){
    if(_search == null || _search.isEmpty){
      return data.length;
    }else{
      return data.length + 1;
    }

  }

//TABELA DE GIFS.
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(                                                    //GRIDVIEW É A VIEW ONDE PODEMOS MOSTRAR O WIDGET EM FORMATO DE GRADE.
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,                                                      //QUANTOS ITENS ELE VAI PODER TER NA HORIZONTAL
        crossAxisSpacing: 10.0,                                                 //O ESPAÇAMENTO ENTRE OS ITENS NA HORIZONTAL
        mainAxisSpacing: 10.0,                                                  //ESPAÇAMENTO NA VERTICAL
      ),
      itemCount: _getCount(snapshot.data["data"]),                                  //QUANTIDADE DE GIFS QUE VOU COLOCAR NA MINHA TELA
      itemBuilder: (context, index){
        if(_search == null || index < snapshot.data["data"].length)
          //SE EU NAO ESTIVER PESQUISANDO VAI RETORNAR OS GIFS. SE ESTIVER PESQUISANDO E NAO FOR O ULTIMO ITEM TBM VAI RETORNAR O GIF.
          return GestureDetector(                                                 //GESTURE DETECTOR PARA CONSEGUIR CLICAR NA IMAGEM
           child: FadeInImage.memoryNetwork(
             placeholder: kTransparentImage,
             image: snapshot.data["data"] [index] ["images"] ["fixed_height"] ["url"],
             height: 300.0,
             fit: BoxFit.cover,
           ),
            onTap: (){
             Navigator.push(context,                                            //PARA IR PARA PROXIMA TELA AO CLICAR NOS GIFS
              MaterialPageRoute(builder:(context) => GifPage(snapshot.data["data"] [index]))
             );
            },
            onLongPress: (){
              Share.share(snapshot.data["data"] [index] ["images"] ["fixed_height"] ["url"]);
            },
          );
        else
          //SE FOR O MEU ITEM VAI RETORNAR O ICONE PRA CARREGR MAIS.
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 70.0,),
                  Text("Carregar mais...",
                  style: TextStyle(color: Colors.white, fontSize: 22.0),)
                ],
              ),
              onTap: (){
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
      }
    );
  }

}
