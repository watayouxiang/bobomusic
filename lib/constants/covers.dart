import 'dart:math';
import "package:path/path.dart" as path;

class Covers {
  static String getRandomCover() {
    final random = Random();
    final covers = [...Covers.cultural, ...Covers.natural, ...Covers.film];

    return covers[random.nextInt(covers.length)];
  }

  static String getLocalCover() {
    return Covers.local[0];
  }

  static List<String> natural = [
    "https://images.unsplash.com/photo-1738762389606-7cd5ccc09753?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDYyfDZzTVZqVExTa2VRfHxlbnwwfHx8fHw%3D",
    "https://plus.unsplash.com/premium_photo-1739123306475-2b43e0d3829f?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDYzfDZzTVZqVExTa2VRfHxlbnwwfHx8fHw%3D",
    "https://images.unsplash.com/photo-1585951301678-8fd6f3b32c7e?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDEyMnw2c01WalRMU2tlUXx8ZW58MHx8fHx8",
    "https://images.unsplash.com/photo-1737496538329-a59d10148a08?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDEyNnw2c01WalRMU2tlUXx8ZW58MHx8fHx8",
    "https://images.unsplash.com/photo-1735767976699-6096acda642d?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDE0OHw2c01WalRMU2tlUXx8ZW58MHx8fHx8",
    "https://images.unsplash.com/photo-1736841131662-ab6fc065124a?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDE2MHw2c01WalRMU2tlUXx8ZW58MHx8fHx8",
    "https://images.unsplash.com/photo-1740525009604-cf420e1399e6?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHw2OHx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1738096294977-3bf7225f9a6a?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxNzN8fHxlbnwwfHx8fHw%3D"
  ];

  static List<String> cultural = [
    "https://images.unsplash.com/photo-1740367217559-de1dcaafafe3?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHw1Mnx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1732813963186-f03b882873e6?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxMDV8fHxlbnwwfHx8fHw%3D",
    "https://images.unsplash.com/photo-1739414487275-c5258a576bd9?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxMjV8fHxlbnwwfHx8fHw%3D",
    "https://images.unsplash.com/photo-1724271362937-391a150db603?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxMzd8fHxlbnwwfHx8fHw%3D",
    "https://images.unsplash.com/photo-1740165886249-ec4b5785acf4?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwyNDF8fHxlbnwwfHx8fHw%3D",
    "https://images.unsplash.com/photo-1739800105257-aba885199b43?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwzMDd8fHxlbnwwfHx8fHw%3D",
    "https://images.unsplash.com/photo-1739924144825-4544ec14ee29?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwzMTd8fHxlbnwwfHx8fHw%3D",
    "https://images.unsplash.com/photo-1736618626242-542735175261?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHw0NTd8fHxlbnwwfHx8fHw%3D",
  ];

  static List<String> film = [
    "https://images.unsplash.com/photo-1740299201166-a6251c4092c9?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDIxfGhtZW52UWhVbXhNfHxlbnwwfHx8fHw%3D"
    "https://images.unsplash.com/photo-1740299200525-79bee914fd20?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDI1fGhtZW52UWhVbXhNfHxlbnwwfHx8fHw%3D",
    "https://images.unsplash.com/photo-1739131188330-042fcb7b95e4?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDM3fGhtZW52UWhVbXhNfHxlbnwwfHx8fHw%3D",
    "https://images.unsplash.com/photo-1737985827822-071a00a82fec?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDE1MHxobWVudlFoVW14TXx8ZW58MHx8fHx8",
    "https://images.unsplash.com/photo-1627953385320-1ccf8610c70a?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDE2MnxobWVudlFoVW14TXx8ZW58MHx8fHx8",
    "https://images.unsplash.com/photo-1736627829937-1f19b66adc00?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDIxOHxobWVudlFoVW14TXx8ZW58MHx8fHx8",
    "https://images.unsplash.com/photo-1736167852508-105cb125e645?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDIzMnxobWVudlFoVW14TXx8ZW58MHx8fHx8",
    "https://images.unsplash.com/photo-1733966007271-107ded9bd0fd?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDMxMXxobWVudlFoVW14TXx8ZW58MHx8fHx8",
  ];

  static List<String> local = [
    path.join("assets", "images", "cover-1.jpg"),
  ];
}