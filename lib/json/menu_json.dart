const List menu = ["Livraison", "Click and Collect"];
const List peopleFeedback = [
  "Lieu agréable (12)",
  "Bon service (11)",
  "Facile d'accès (14)"
];
const List test = ["test 1", "test 2", "test 3"];
const List categories = [
  {"img": "assets/icons/pickup.svg", "name": "Achat"},
  {"img": "assets/icons/essentials.svg", "name": "Essentiels"},
  {"img": "assets/icons/books.svg", "name": "Livres"},
  {"img": "assets/icons/tools.svg", "name": "Outils"},
  {"img": "assets/icons/deals.svg", "name": "Deals"},
  {"img": "assets/icons/discount.svg", "name": "Promos"},
];
const List firstMenu = [
  {
    "img":
        "https://img.check.fm/venue/11467/images/tvfuglrv5ba3f8cdbd1e7.jpg?w=300&h=300",
    "is_liked": true,
    "name": "Bar Joe",
    "description": "Le meilleur ami de votre féria",
    "location": "44 Boulevard Victor Hugo",
    "clickAndCollect": true,
    "rate": "4.5",
    "comments": {
      "Très bel endroit, je recommande",
      "J'ai été très bien accueillie",
      "Rien à reprocher"
    }
  }
];
const List exploreMenu = [
  {
    "img":
        "https://images.unsplash.com/photo-1530016555861-3d1f3f5ca94b?ixid=MXwxMjA3fDB8MHxzZWFyY2h8Mnx8Zm9vZCUyMGRvbnV0fGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    "is_liked": true,
    "name": "Dunkin'",
    "description": "Breakfast and Brunch - Donuts",
    "location": "122 Fulton St",
    "clickAndCollect": false,
    "rate": "4.0",
    "comments": {
      "Très bel endroit, je recommande",
      "J'ai été très bien accueillie",
      "Rien à reprocher"
    }
  },
  {
    "img":
        "https://images.unsplash.com/photo-1552895638-f7fe08d2f7d5?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8Zm9vZCUyMG1jZG9uYWxkfGVufDB8fDB8&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    "is_liked": false,
    "name": "McDonald's",
    "description": "American - Fast Food - Burgers",
    "location": "Delancey St",
    "clickAndCollect": true,
    "rate": "3.6",
    "comments": {
      "Très bel endroit, je recommande",
      "J'ai été très bien accueillie",
      "Rien à reprocher"
    }
  },
  {
    "img":
        "https://images.unsplash.com/photo-1506354666786-959d6d497f1a?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MTR8fGZvb2R8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    "is_liked": true,
    "name": "Subway",
    "description": "Fast Food - Sandwich - American",
    "location": "30 Broad St",
    "clickAndCollect": false,
    "rate": "3.8",
    "comments": {
      "Très bel endroit, je recommande",
      "J'ai été très bien accueillie",
      "Rien à reprocher"
    }
  },
];

const List popluarNearYou = [
  {
    "img":
        "https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NHx8Zm9vZHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    "is_liked": false,
    "name": "Village Breakfast Snob",
    "description": "Breakfast and Brunch - American - Sandwich",
    "location": "New-York",
    "clickAndCollect": false,
    "rate": "3.0",
    "comments": {
      "Très bel endroit, je recommande",
      "J'ai été très bien accueillie",
      "Rien à reprocher"
    }
  },
  {
    "img":
        "https://images.unsplash.com/photo-1467453678174-768ec283a940?ixid=MXwxMjA3fDB8MHxzZWFyY2h8Mjd8fGZvb2R8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    "is_liked": false,
    "name": "Soho Finest Market",
    "description": "Breakfast and Brunch - Juice and Smoothies",
    "location": "Los Angeles",
    "clickAndCollect": true,
    "rate": "2.1",
    "comments": {
      "Très bel endroit, je recommande",
      "J'ai été très bien accueillie",
      "Rien à reprocher"
    }
  },
];

const List packForYou = [
  {
    "img":
        "https://images.unsplash.com/photo-1559847844-5315695dadae?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1940&q=80",
    "name": "The Bacon, Egg, and Cheese Bagel",
    "description":
        'Fresh eggs, bacon, and creamy cheese stuffed and between a begel...',
    "price": "\$ 11.99"
  },
  {
    "img":
        "https://images.unsplash.com/photo-1527324688151-0e627063f2b1?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1yZWxhdGVkfDJ8fHxlbnwwfHx8&auto=format&fit=crop&w=800&q=60",
    "name": "Original French Toast",
    "description":
        'Sliced challah bread soaked in eggs and milk, then fried serve with a good...',
    "price": "\$ 9.99"
  },
  {
    "img":
        "https://images.unsplash.com/photo-1557079604-d28080618be0?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1yZWxhdGVkfDV8fHxlbnwwfHx8&auto=format&fit=crop&w=800&q=60",
    "name": "Spanish Omelette",
    "description":
        'French eggs, tomatoes, onions, and peppers, creamy cheese, and salads...',
    "price": "\$ 13.99"
  },
  {
    "img":
        "https://images.unsplash.com/photo-1557499305-87bd9049ec2d?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1yZWxhdGVkfDh8fHxlbnwwfHx8&auto=format&fit=crop&w=800&q=60",
    "name": "2 Eggs Served with Home Fries and Toast",
    "description":
        '2 eggs served your way with home fries and hot toast. Choicee of add...',
    "price": "\$ 10.99"
  },
  {
    "img":
        "https://images.unsplash.com/photo-1580476262798-bddd9f4b7369?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1yZWxhdGVkfDE4fHx8ZW58MHx8fA%3D%3D&auto=format&fit=crop&w=800&q=60",
    "name": "The Bacon Egg, and Cheese Sandwich",
    "description":
        'Fresh eggs, bacon, and creamy cheese stuffed in between sandwich...',
    "price": "\$ 11.99"
  }
];
