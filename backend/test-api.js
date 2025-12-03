const axios = require('axios');

async function testAPI() {
  try {
    const response = await axios.get('http://10.57.251.123:5000/api/properties?limit=1000');
    
    console.log(`\n✅ Total properties: ${response.data.total}`);
    console.log(`📦 Returned: ${response.data.count}\n`);
    
    const tunisiaProps = response.data.data.filter(p => p.location.country === 'Tunisia');
    console.log(`🇹🇳 Tunisia properties: ${tunisiaProps.length}`);
    tunisiaProps.forEach(p => {
      console.log(`  - ${p.title}`);
      console.log(`    City: ${p.location.city}`);
      console.log(`    Coords: ${p.location.coordinates.latitude}, ${p.location.coordinates.longitude}\n`);
    });
    
    const moroccoProps = response.data.data.filter(p => p.location.country === 'Morocco');
    console.log(`🇲🇦 Morocco properties: ${moroccoProps.length}`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

testAPI();
