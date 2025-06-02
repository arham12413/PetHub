import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(String)? onFilterChanged;

  const Search({super.key, this.onSearch, this.onFilterChanged});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search pets...',
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.red),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.red),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearch?.call('');
                },
              ),
            ),
            onChanged: (value) {
              widget.onSearch?.call(value);
            },
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.filter_list, color: Colors.red),
          onSelected: (String value) {
            setState(() {
              _selectedFilter = value;
            });
            widget.onFilterChanged?.call(value);
          },
          itemBuilder: (BuildContext context) {
            return {'All', 'Dog', 'Cat', 'Bird', 'Other'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}