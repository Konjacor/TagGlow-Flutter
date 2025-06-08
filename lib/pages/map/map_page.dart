import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  final List<_Location> _locations = [
    _Location(
      name: '位置 A',
      description: '这是第一个位置',
      tags: ['标签1', '标签2'],
      position: LatLng(39.9042, 116.4074), // 北京坐标
    ),
    _Location(
      name: '位置 B',
      description: '这是第二个位置',
      tags: ['标签3'],
      position: LatLng(31.2304, 121.4737), // 上海坐标
    ),
  ];

  Widget _buildLocationSheet(_Location loc) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(loc.description),
          const SizedBox(height: 8),
          Text('标签: ${loc.tags.join(', ')}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('高德地图 - 标记示例')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _locations.first.position,
          zoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://t{s}.tianditu.gov.cn/vec_w/wmts?'
                'service=WMTS&request=GetTile&version=1.0.0&'
                'layer=vec&style=default&tilematrixset=w&format=tiles&'
                'tilecol={x}&tilerow={y}&tilematrix={z}&tk=681864dd26975e37cd94b2c699448a4d',
            subdomains: const ['0', '1', '2', '3', '4', '5', '6', '7'],
            userAgentPackageName: 'com.example.flutter_map_demo',
          ),
          MarkerLayer(
            markers: _locations.map((loc) {
              return Marker(
                point: loc.position,
                width: 80,
                height: 80,
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => _buildLocationSheet(loc),
                    );
                  },
                  child: const Icon(Icons.location_on, size: 36, color: Colors.red),
                ),
              );
            }).toList(),
          ),
        ],
      )

    );
  }
}

class _Location {
  final String name;
  final String description;
  final List<String> tags;
  final LatLng position;

  _Location({
    required this.name,
    required this.description,
    required this.tags,
    required this.position,
  });
}
