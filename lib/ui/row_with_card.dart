import 'package:flutter/material.dart';

class RowWithCardWidget extends StatelessWidget {
  const RowWithCardWidget({
    Key key,
    @required this.index,
    @required this.label,
    @required this.name,
  }) : super(key: key);

  final int index;
  final String label;
  final String name;

  IconData _getCategoryBasedIcon(String myLabel) {
    IconData myIconData;
    switch (myLabel) {
      case 'office':
        myIconData = Icons.work;
        break;
      case 'library':
        myIconData = Icons.local_library;
        break;
      case 'exam':
        myIconData = Icons.assignment;
        break;
      default:
        myIconData = Icons.work;
        break;
    }
    return myIconData;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          _getCategoryBasedIcon(label),
          size: 48.0,
          color: Colors.teal,
        ),
        title: Text(name),
        subtitle: Text(label),
        trailing: Text(
          '${index * 7 + 5}',
          style: TextStyle(color: Colors.teal),
        ),
        //selected: true,
        onTap: () {
          print('Tapped on Row $index');
        },
      ),
    );
  }
}
