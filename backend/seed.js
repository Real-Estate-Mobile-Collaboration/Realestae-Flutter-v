const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import models
const User = require('./models/User');
const Property = require('./models/Property');
const Message = require('./models/Message');
const Favorite = require('./models/Favorite');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

// Sample users
const users = [
  {
    name: 'Ahmed Bennani',
    email: 'ahmed@example.com',
    password: 'password123',
    originalPassword: 'password123',
    phone: '+212 6 12 34 56 78',
    role: 'user',
    notifications: {
      enabled: true,
      email: true,
      push: true
    },
    language: 'English'
  },
  {
    name: 'Fatima Alaoui',
    email: 'fatima@example.com',
    password: 'password123',
    originalPassword: 'password123',
    phone: '+212 6 23 45 67 89',
    role: 'user',
    notifications: {
      enabled: true,
      email: true,
      push: true
    },
    language: 'Français'
  },
  {
    name: 'Youssef El Amrani',
    email: 'youssef@example.com',
    password: 'password123',
    originalPassword: 'password123',
    phone: '+212 6 34 56 78 90',
    role: 'user',
    notifications: {
      enabled: true,
      email: false,
      push: true
    },
    language: 'English'
  },
  {
    name: 'Sanaa Idrissi',
    email: 'sanaa@example.com',
    password: 'password123',
    originalPassword: 'password123',
    phone: '+212 6 45 67 89 01',
    role: 'user',
    notifications: {
      enabled: true,
      email: true,
      push: true
    },
    language: 'العربية'
  }
];

// Sample properties
const getProperties = (userIds) => [
  {
    title: 'Appartement Moderne à Casablanca Centre',
    description: 'Magnifique appartement de 120m² situé au cœur de Casablanca. Proche de toutes commodités, transport, écoles et commerces. Idéal pour une famille.',
    price: 1500000,
    propertyType: 'Apartment',
    status: 'For Sale',
    bedrooms: 3,
    bathrooms: 2,
    area: 120,
    location: {
      address: '15 Boulevard Mohammed V',
      city: 'Casablanca',
      state: 'Grand Casablanca',
      country: 'Morocco',
      zipCode: '20000',
      coordinates: {
        latitude: 33.5731,
        longitude: -7.5898
      }
    },
    images: [
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
      'https://images.unsplash.com/photo-1567496898669-ee935f5f647a?w=800',
      'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800'
    ],
    amenities: ['Parking', 'Elevator', 'Security', 'Balcony', 'Air Conditioning'],
    owner: userIds[0],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Villa Luxueuse avec Piscine - Marrakech',
    description: 'Superbe villa de standing avec piscine privée, jardin paysager et vue sur l\'Atlas. 5 chambres spacieuses, salon marocain traditionnel, cuisine équipée.',
    price: 8500000,
    propertyType: 'House',
    status: 'For Sale',
    bedrooms: 5,
    bathrooms: 4,
    area: 350,
    location: {
      address: 'Route de Fès, Palmeraie',
      city: 'Marrakech',
      state: 'Marrakech-Safi',
      country: 'Morocco',
      zipCode: '40000',
      coordinates: {
        latitude: 31.6295,
        longitude: -7.9811
      }
    },
    images: [
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800'
    ],
    amenities: ['Swimming Pool', 'Garden', 'Parking', 'Security', 'Gym', 'Air Conditioning', 'Furnished'],
    owner: userIds[1],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Studio Étudiant - Rabat Agdal',
    description: 'Studio meublé de 35m² idéal pour étudiant. Proche des universités et transports en commun. Cuisine équipée, salle de bain moderne.',
    price: 2500,
    propertyType: 'Studio',
    status: 'For Rent',
    bedrooms: 1,
    bathrooms: 1,
    area: 35,
    location: {
      address: 'Avenue Mehdi Ben Barka, Agdal',
      city: 'Rabat',
      state: 'Rabat-Salé-Kénitra',
      country: 'Morocco',
      zipCode: '10090',
      coordinates: {
        latitude: 33.9716,
        longitude: -6.8498
      }
    },
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800'
    ],
    amenities: ['Furnished', 'Elevator', 'Internet'],
    owner: userIds[2],
    isAvailable: true
  },
  {
    title: 'Maison Traditionnelle - Fès Médina',
    description: 'Riad traditionnel rénové dans la médina de Fès. Architecture authentique marocaine avec patio central. 4 chambres, terrasse panoramique.',
    price: 3200000,
    propertyType: 'House',
    status: 'For Sale',
    bedrooms: 4,
    bathrooms: 3,
    area: 200,
    location: {
      address: 'Derb Sidi Ahmed, Médina',
      city: 'Fès',
      state: 'Fès-Meknès',
      country: 'Morocco',
      zipCode: '30000',
      coordinates: {
        latitude: 34.0331,
        longitude: -5.0003
      }
    },
    images: [
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800',
      'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800'
    ],
    amenities: ['Garden', 'Traditional Design', 'Terrace'],
    owner: userIds[3],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Appartement Vue Mer - Tanger',
    description: 'Superbe appartement avec vue panoramique sur le détroit de Gibraltar. 3 chambres, grande terrasse, proche de la plage et du centre-ville.',
    price: 2800000,
    propertyType: 'Apartment',
    status: 'For Sale',
    bedrooms: 3,
    bathrooms: 2,
    area: 110,
    location: {
      address: 'Boulevard Mohamed VI',
      city: 'Tanger',
      state: 'Tanger-Tétouan-Al Hoceïma',
      country: 'Morocco',
      zipCode: '90000',
      coordinates: {
        latitude: 35.7595,
        longitude: -5.8340
      }
    },
    images: [
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800'
    ],
    amenities: ['Balcony', 'Sea View', 'Parking', 'Security', 'Elevator'],
    owner: userIds[0],
    isAvailable: true
  },
  {
    title: 'Bureau Moderne - Casablanca Twin Center',
    description: 'Espace de bureau de 80m² dans un immeuble moderne près du Twin Center. Climatisé, sécurisé, parking disponible. Parfait pour start-up ou PME.',
    price: 8000,
    propertyType: 'Office',
    status: 'For Rent',
    bedrooms: 0,
    bathrooms: 1,
    area: 80,
    location: {
      address: 'Boulevard Zerktouni',
      city: 'Casablanca',
      state: 'Grand Casablanca',
      country: 'Morocco',
      zipCode: '20100',
      coordinates: {
        latitude: 33.5883,
        longitude: -7.6114
      }
    },
    images: [
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
      'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800'
    ],
    amenities: ['Air Conditioning', 'Parking', 'Security', 'Elevator', 'Internet'],
    owner: userIds[1],
    isAvailable: true
  },
  {
    title: 'Villa de Vacances - Agadir Bord de Mer',
    description: 'Villa de vacances à 100m de la plage. 4 chambres, jardin avec barbecue, terrasse avec vue mer. Location courte et longue durée.',
    price: 15000,
    propertyType: 'House',
    status: 'For Rent',
    bedrooms: 4,
    bathrooms: 3,
    area: 180,
    location: {
      address: 'Secteur Balnéaire',
      city: 'Agadir',
      state: 'Souss-Massa',
      country: 'Morocco',
      zipCode: '80000',
      coordinates: {
        latitude: 30.4278,
        longitude: -9.5981
      }
    },
    images: [
      'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=800',
      'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=800',
      'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800'
    ],
    amenities: ['Swimming Pool', 'Garden', 'Beach Access', 'Parking', 'Furnished', 'Terrace'],
    owner: userIds[2],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Terrain Constructible - Marrakech Route Ourika',
    description: 'Terrain de 500m² avec vue sur l\'Atlas. Viabilisé (eau, électricité). Idéal pour construction de villa ou projet immobilier.',
    price: 1200000,
    propertyType: 'Land',
    status: 'For Sale',
    bedrooms: 0,
    bathrooms: 0,
    area: 500,
    location: {
      address: 'Route de l\'Ourika, Km 12',
      city: 'Marrakech',
      state: 'Marrakech-Safi',
      country: 'Morocco',
      zipCode: '40000',
      coordinates: {
        latitude: 31.5731,
        longitude: -7.9351
      }
    },
    images: [
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
      'https://images.unsplash.com/photo-1464146072230-91cabc968266?w=800'
    ],
    amenities: [],
    owner: userIds[3],
    isAvailable: true
  },
  {
    title: 'Duplex de Luxe - Casablanca Marina',
    description: 'Duplex haut standing de 200m² avec vue sur la marina. Finitions luxueuses, cuisine équipée haut de gamme, 2 terrasses.',
    price: 5500000,
    propertyType: 'Apartment',
    status: 'For Sale',
    bedrooms: 4,
    bathrooms: 3,
    area: 200,
    location: {
      address: 'Marina de Casablanca',
      city: 'Casablanca',
      state: 'Grand Casablanca',
      country: 'Morocco',
      zipCode: '20250',
      coordinates: {
        latitude: 33.6065,
        longitude: -7.6310
      }
    },
    images: [
      'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800',
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
      'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?w=800'
    ],
    amenities: ['Marina View', 'Terrace', 'Parking', 'Security', 'Gym', 'Swimming Pool', 'Elevator'],
    owner: userIds[0],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Appartement Familial - Rabat Hassan',
    description: 'Grand appartement familial de 150m² dans un quartier calme. 4 chambres, double salon, cuisine spacieuse. Proche écoles et commerces.',
    price: 2200000,
    propertyType: 'Apartment',
    status: 'For Sale',
    bedrooms: 4,
    bathrooms: 2,
    area: 150,
    location: {
      address: 'Avenue Hassan II',
      city: 'Rabat',
      state: 'Rabat-Salé-Kénitra',
      country: 'Morocco',
      zipCode: '10000',
      coordinates: {
        latitude: 34.0209,
        longitude: -6.8416
      }
    },
    images: [
      'https://images.unsplash.com/photo-1600585154363-67eb9e2e2099?w=800',
      'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800'
    ],
    amenities: ['Parking', 'Elevator', 'Balcony', 'Storage'],
    owner: userIds[1],
    isAvailable: true
  },
  // Propriétés en Tunisie
  {
    title: 'Appartement Standing - Tunis Centre Ville',
    description: 'Bel appartement de 130m² au cœur de Tunis. 3 chambres spacieuses, double salon, cuisine moderne équipée. Vue dégagée, quartier résidentiel calme.',
    price: 450000,
    propertyType: 'Apartment',
    status: 'For Sale',
    bedrooms: 3,
    bathrooms: 2,
    area: 130,
    location: {
      address: 'Avenue Habib Bourguiba',
      city: 'Tunis',
      state: 'Tunis',
      country: 'Tunisia',
      zipCode: '1000',
      coordinates: {
        latitude: 36.8065,
        longitude: 10.1815
      }
    },
    images: [
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
      'https://images.unsplash.com/photo-1567496898669-ee935f5f647a?w=800',
      'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800'
    ],
    amenities: ['Parking', 'Elevator', 'Security', 'Balcony', 'Air Conditioning'],
    owner: userIds[0],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Villa avec Piscine - La Marsa',
    description: 'Magnifique villa moderne de 400m² à La Marsa. Piscine privée, jardin arboré, 5 chambres, salon principal avec cheminée. Zone résidentielle prisée.',
    price: 1200000,
    propertyType: 'Villa',
    status: 'For Sale',
    bedrooms: 5,
    bathrooms: 4,
    area: 400,
    location: {
      address: 'Zone Résidentielle, La Marsa',
      city: 'La Marsa',
      state: 'Tunis',
      country: 'Tunisia',
      zipCode: '2078',
      coordinates: {
        latitude: 36.8780,
        longitude: 10.3247
      }
    },
    images: [
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800',
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
      'https://images.unsplash.com/photo-1571055107559-3e67626fa8be?w=800'
    ],
    amenities: ['Swimming Pool', 'Garden', 'Parking', 'Security', 'Air Conditioning', 'Fireplace', 'Terrace'],
    owner: userIds[2],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Appartement Neuf - Sousse Khezama',
    description: 'Appartement neuf de 95m² dans une résidence sécurisée. 2 chambres, salon lumineux, cuisine équipée. Proche de la plage et des commodités.',
    price: 280000,
    propertyType: 'Apartment',
    status: 'For Sale',
    bedrooms: 2,
    bathrooms: 1,
    area: 95,
    location: {
      address: 'Résidence Les Jasmins, Khezama',
      city: 'Sousse',
      state: 'Sousse',
      country: 'Tunisia',
      zipCode: '4000',
      coordinates: {
        latitude: 35.8256,
        longitude: 10.6369
      }
    },
    images: [
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
      'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
      'https://images.unsplash.com/photo-1494526585095-c41746248156?w=800'
    ],
    amenities: ['Elevator', 'Security', 'Balcony', 'Parking', 'Beach Access'],
    owner: userIds[3],
    isAvailable: true
  },
  {
    title: 'Maison Traditionnelle - Hammamet Médina',
    description: 'Charmante maison traditionnelle rénovée dans la médina de Hammamet. Architecture authentique, patio central, 3 chambres, terrasse avec vue mer.',
    price: 520000,
    propertyType: 'House',
    status: 'For Sale',
    bedrooms: 3,
    bathrooms: 2,
    area: 180,
    location: {
      address: 'Médina de Hammamet',
      city: 'Hammamet',
      state: 'Nabeul',
      country: 'Tunisia',
      zipCode: '8050',
      coordinates: {
        latitude: 36.4000,
        longitude: 10.6167
      }
    },
    images: [
      'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
      'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
      'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=800'
    ],
    amenities: ['Terrace', 'Sea View', 'Traditional Design', 'Garden'],
    owner: userIds[1],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Studio à Louer - Sfax Centre',
    description: 'Studio meublé de 40m² en plein centre de Sfax. Idéal pour étudiant ou jeune professionnel. Tout équipé, internet inclus.',
    price: 600,
    propertyType: 'Studio',
    status: 'For Rent',
    bedrooms: 1,
    bathrooms: 1,
    area: 40,
    location: {
      address: 'Avenue Hedi Chaker',
      city: 'Sfax',
      state: 'Sfax',
      country: 'Tunisia',
      zipCode: '3000',
      coordinates: {
        latitude: 34.7406,
        longitude: 10.7603
      }
    },
    images: [
      'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800',
      'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800'
    ],
    amenities: ['Furnished', 'Internet', 'Air Conditioning'],
    owner: userIds[0],
    isAvailable: true
  },
  {
    title: 'Duplex Vue Mer - Monastir',
    description: 'Superbe duplex de 160m² avec vue panoramique sur la mer. 3 chambres, grand salon avec cheminée, 2 terrasses. Résidence avec piscine.',
    price: 680000,
    propertyType: 'Apartment',
    status: 'For Sale',
    bedrooms: 3,
    bathrooms: 2,
    area: 160,
    location: {
      address: 'Zone Touristique, Skanes',
      city: 'Monastir',
      state: 'Monastir',
      country: 'Tunisia',
      zipCode: '5000',
      coordinates: {
        latitude: 35.7775,
        longitude: 10.8261
      }
    },
    images: [
      'https://images.unsplash.com/photo-1560184897-ae75f418493e?w=800',
      'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800',
      'https://images.unsplash.com/photo-1600573472591-ee6b68d14c68?w=800'
    ],
    amenities: ['Sea View', 'Terrace', 'Swimming Pool', 'Security', 'Parking', 'Fireplace'],
    owner: userIds[2],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Terrain Constructible - Nabeul',
    description: 'Terrain de 600m² à Nabeul, zone résidentielle calme. Viabilisé, proche de toutes commodités. Idéal pour construction villa.',
    price: 180000,
    propertyType: 'Land',
    status: 'For Sale',
    bedrooms: 0,
    bathrooms: 0,
    area: 600,
    location: {
      address: 'Zone Résidentielle Bir Challouf',
      city: 'Nabeul',
      state: 'Nabeul',
      country: 'Tunisia',
      zipCode: '8000',
      coordinates: {
        latitude: 36.4513,
        longitude: 10.7356
      }
    },
    images: [
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
      'https://images.unsplash.com/photo-1464146072230-91cabc968266?w=800'
    ],
    amenities: [],
    owner: userIds[3],
    isAvailable: true
  },
  {
    title: 'Bureau Moderne - Tunis Lac 2',
    description: 'Espace de bureau de 120m² dans un immeuble moderne au Lac 2. Climatisé, parking, sécurité 24/7. Parfait pour entreprise ou cabinet.',
    price: 1500,
    propertyType: 'Office',
    status: 'For Rent',
    bedrooms: 0,
    bathrooms: 2,
    area: 120,
    location: {
      address: 'Les Berges du Lac 2',
      city: 'Tunis',
      state: 'Tunis',
      country: 'Tunisia',
      zipCode: '1053',
      coordinates: {
        latitude: 36.8389,
        longitude: 10.2378
      }
    },
    images: [
      'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800',
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800'
    ],
    amenities: ['Air Conditioning', 'Parking', 'Security', 'Elevator', 'Internet'],
    owner: userIds[1],
    isAvailable: true
  },
  {
    title: 'Maison Oasis - Tozeur',
    description: 'Charmante maison traditionnelle au cœur de l\'oasis de Tozeur. 3 chambres, jardin avec palmiers dattiers, architecture saharienne authentique. Idéal investissement touristique.',
    price: 320000,
    propertyType: 'House',
    status: 'For Sale',
    bedrooms: 3,
    bathrooms: 2,
    area: 150,
    location: {
      address: 'Quartier Bled el Hadher',
      city: 'Tozeur',
      state: 'Tozeur',
      country: 'Tunisia',
      zipCode: '2200',
      coordinates: {
        latitude: 33.9197,
        longitude: 8.1335
      }
    },
    images: [
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800',
      'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800'
    ],
    amenities: ['Garden', 'Traditional Design', 'Terrace', 'Palm Trees'],
    owner: userIds[2],
    featured: true,
    isAvailable: true
  },
  {
    title: 'Villa Moderne - Gafsa',
    description: 'Belle villa moderne de 220m² dans un quartier résidentiel de Gafsa. 4 chambres, grand salon, cuisine équipée, garage. Proche de toutes commodités.',
    price: 380000,
    propertyType: 'Villa',
    status: 'For Sale',
    bedrooms: 4,
    bathrooms: 3,
    area: 220,
    location: {
      address: 'Cité El Ksar',
      city: 'Gafsa',
      state: 'Gafsa',
      country: 'Tunisia',
      zipCode: '2100',
      coordinates: {
        latitude: 34.4250,
        longitude: 8.7842
      }
    },
    images: [
      'https://images.unsplash.com/photo-1600047509358-9dc75507daeb?w=800',
      'https://images.unsplash.com/photo-1600585152220-90363fe7e115?w=800',
      'https://images.unsplash.com/photo-1588880331179-bc9b93a8cb5e?w=800'
    ],
    amenities: ['Parking', 'Garden', 'Air Conditioning', 'Security'],
    owner: userIds[3],
    isAvailable: true
  },
  {
    title: 'Appartement à Louer - Tozeur Centre',
    description: 'Appartement meublé de 70m² au centre-ville de Tozeur. 2 chambres, balcon, proche des sites touristiques. Idéal pour location saisonnière.',
    price: 800,
    propertyType: 'Apartment',
    status: 'For Rent',
    bedrooms: 2,
    bathrooms: 1,
    area: 70,
    location: {
      address: 'Avenue Habib Bourguiba',
      city: 'Tozeur',
      state: 'Tozeur',
      country: 'Tunisia',
      zipCode: '2200',
      coordinates: {
        latitude: 33.9236,
        longitude: 8.1303
      }
    },
    images: [
      'https://images.unsplash.com/photo-1556020685-ae41abfc9365?w=800',
      'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800'
    ],
    amenities: ['Furnished', 'Balcony', 'Air Conditioning'],
    owner: userIds[0],
    isAvailable: true
  }
];

async function seedDatabase() {
  try {
    console.log('🗑️  Cleaning database...');
    await User.deleteMany({});
    await Property.deleteMany({});
    await Message.deleteMany({});
    await Favorite.deleteMany({});

    console.log('👥 Creating users...');
    const createdUsers = [];
    for (const userData of users) {
      // Create user - the password will be hashed automatically by the User model's pre-save hook
      const user = await User.create(userData);
      createdUsers.push(user);
      console.log(`   ✓ ${user.name} (${user.email})`);
    }

    const userIds = createdUsers.map(u => u._id);

    console.log('\n🏠 Creating properties...');
    const properties = getProperties(userIds);
    const createdProperties = [];
    for (const propertyData of properties) {
      const property = await Property.create(propertyData);
      createdProperties.push(property);
      console.log(`   ✓ ${property.title} - ${property.price.toLocaleString()} MAD`);
    }

    console.log('\n💬 Creating sample messages...');
    const messages = [
      {
        conversationId: Message.createConversationId(userIds[0], userIds[1]),
        sender: userIds[0],
        receiver: userIds[1],
        content: 'Bonjour, je suis intéressé par votre villa à Marrakech. Est-elle toujours disponible?',
        propertyRef: createdProperties[1]._id
      },
      {
        conversationId: Message.createConversationId(userIds[0], userIds[1]),
        sender: userIds[1],
        receiver: userIds[0],
        content: 'Bonjour! Oui, la villa est toujours disponible. Souhaitez-vous organiser une visite?',
        propertyRef: createdProperties[1]._id
      },
      {
        conversationId: Message.createConversationId(userIds[0], userIds[1]),
        sender: userIds[0],
        receiver: userIds[1],
        content: 'Avec plaisir! Je serais disponible ce weekend. Quel serait le meilleur moment?',
        propertyRef: createdProperties[1]._id
      },
      {
        conversationId: Message.createConversationId(userIds[2], userIds[3]),
        sender: userIds[2],
        receiver: userIds[3],
        content: 'Salut! Votre maison à Fès est magnifique. Quel est le prix final?',
        propertyRef: createdProperties[3]._id
      },
      {
        conversationId: Message.createConversationId(userIds[2], userIds[3]),
        sender: userIds[3],
        receiver: userIds[2],
        content: 'Merci! Le prix est de 3,200,000 MAD mais négociable. Voulez-vous plus d\'informations?',
        propertyRef: createdProperties[3]._id
      },
      // Messages entre Ahmed (userIds[0]) et Youssef (userIds[2])
      {
        conversationId: Message.createConversationId(userIds[0], userIds[2]),
        sender: userIds[2],
        receiver: userIds[0],
        content: 'Bonjour Ahmed, j\'ai vu votre appartement à Casablanca. Est-il toujours disponible?',
        propertyRef: createdProperties[0]._id
      },
      {
        conversationId: Message.createConversationId(userIds[0], userIds[2]),
        sender: userIds[0],
        receiver: userIds[2],
        content: 'Oui, il est disponible. Voulez-vous le visiter?',
        propertyRef: createdProperties[0]._id
      },
      // Messages entre Ahmed (userIds[0]) et Sanaa (userIds[3])
      {
        conversationId: Message.createConversationId(userIds[0], userIds[3]),
        sender: userIds[3],
        receiver: userIds[0],
        content: 'Salam, je cherche un appartement à Casablanca. Le vôtre m\'intéresse beaucoup!',
        propertyRef: createdProperties[0]._id
      },
      {
        conversationId: Message.createConversationId(userIds[0], userIds[3]),
        sender: userIds[0],
        receiver: userIds[3],
        content: 'Salam! Avec plaisir, je peux vous organiser une visite cette semaine.',
        propertyRef: createdProperties[0]._id
      },
      {
        conversationId: Message.createConversationId(userIds[0], userIds[3]),
        sender: userIds[3],
        receiver: userIds[0],
        content: 'Parfait! Je suis disponible jeudi ou vendredi.',
        propertyRef: createdProperties[0]._id,
        isRead: false
      }
    ];

    for (const messageData of messages) {
      const message = await Message.create(messageData);
      console.log(`   ✓ Message: ${message.sender} → ${message.receiver}`);
    }

    console.log('\n❤️  Creating sample favorites...');
    const favorites = [
      {
        user: userIds[0],
        property: createdProperties[1]._id
      },
      {
        user: userIds[0],
        property: createdProperties[4]._id
      },
      {
        user: userIds[1],
        property: createdProperties[0]._id
      },
      {
        user: userIds[2],
        property: createdProperties[3]._id
      },
      {
        user: userIds[2],
        property: createdProperties[6]._id
      }
    ];

    for (const favoriteData of favorites) {
      await Favorite.create(favoriteData);
    }
    console.log(`   ✓ ${favorites.length} favorites created`);

    console.log('\n✅ Database seeded successfully!');
    console.log('\n📊 Summary:');
    console.log(`   • Users: ${createdUsers.length}`);
    console.log(`   • Properties: ${createdProperties.length}`);
    console.log(`   • Messages: ${messages.length}`);
    console.log(`   • Favorites: ${favorites.length}`);
    console.log('\n🔐 Test Credentials:');
    console.log('   Email: ahmed@example.com');
    console.log('   Password: password123');
    console.log('\n   Email: fatima@example.com');
    console.log('   Password: password123');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

seedDatabase();
