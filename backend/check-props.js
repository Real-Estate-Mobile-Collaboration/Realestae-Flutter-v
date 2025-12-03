const mongoose = require('mongoose');
const dotenv = require('dotenv');
dotenv.config();

const Property = require('./models/Property');

mongoose.connect(process.env.MONGODB_URI)
  .then(async () => {
    console.log('✅ MongoDB connected');
    
    const props = await Property.find({}).select('title location.city location.country location.coordinates');
    console.log(`\nTotal properties: ${props.length}\n`);
    
    props.forEach(p => {
      console.log(`- ${p.title}`);
      console.log(`  City: ${p.location.city}, Country: ${p.location.country}`);
      console.log(`  Coords: ${p.location.coordinates.latitude}, ${p.location.coordinates.longitude}\n`);
    });
    
    const tunisiaProps = props.filter(p => p.location.country === 'Tunisia');
    console.log(`\n🇹🇳 Tunisia properties: ${tunisiaProps.length}`);
    
    const moroccoProps = props.filter(p => p.location.country === 'Morocco');
    console.log(`🇲🇦 Morocco properties: ${moroccoProps.length}`);
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Error:', err);
    process.exit(1);
  });
