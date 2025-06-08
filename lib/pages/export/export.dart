import 'package:flutter/material.dart';

class ExportPage extends StatefulWidget {
  final dynamic params;

  const ExportPage({super.key, this.params});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导出笔记')),
      body: Row(
        children: [
          // 左侧：笔记内容导出
          Expanded(
  flex: 2,
  child: Padding(
    padding: const EdgeInsets.all(24.0),
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '我的导出笔记',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '拙政园：一步一景，邂逅江南园林的温婉,初到苏州，拙政园便是我行程中的第一站。这座江南古典园林的代表之作，以水为中心，亭台楼阁、假山池塘、花木繁茂，犹如一幅徐徐展开的山水画卷。踏入拙政园的那一刻，仿佛时间都慢了下来。园中的小飞虹，朱红色的栏杆倒映在水中，宛如一条绚丽的彩虹落入碧波，美得令人心醉。漫步在曲折的回廊上，透过花窗望去，每一处景致都似精心雕琢的水墨画，框起了四季的流转。远处的香洲，宛如一艘即将启航的画舫，静静停泊在绿水之上，船头的匾额上 “香洲” 二字，仿佛在诉说着昔日的繁华与诗意。在这里，我感受到了江南园林 “虽由人作，宛自天开” 的独特魅力，一步一景，景随步移，每一次转角都能邂逅不一样的惊喜。平江路：枕河而居，感受苏州的人间烟火从拙政园出来，沿着临顿路步行片刻，便来到了平江路。这条苏州古城保存最完好的历史街区，以 “水陆并行，河街相邻” 的格局，展现着苏州独特的水乡风貌。走在平江路上，脚下是青石板路，身旁是潺潺流水，耳边不时传来摇橹船划过水面的声音，以及船娘哼唱的吴侬软语，让人仿佛穿越回了旧时光。街边的店铺琳琅满目，有古色古香的书店、精美的手工艺品店，还有散发着诱人香气的小吃摊。我走进一家名为 “猫的天空之城” 的书店，店内弥漫着淡淡的咖啡香和书香，一面面明信片墙上挂满了游客们对未来的期许。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('导出功能还在开发中～')),
                );
              },
              child: const Text('导出为 PDF'),
            ),
          ],
        ),
      ),
    ),
  ),
),


          // 右侧：旅游图片
          Expanded(
  flex: 3,
  child: Padding(
    padding: const EdgeInsets.all(24.0),
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias, // 让圆角对图片生效
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Image.asset(
          'asset/images/updateVersion/header/suzhou.jpg',
          fit: BoxFit.cover,
        ),
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
