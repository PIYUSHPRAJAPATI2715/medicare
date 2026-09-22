const Doctor = require('./Doctor.model');
const Specialty = require('./Specialty.model');
const User = require('./User.model');
const DataStore = require('./data_store');

const seedInitialData = async () => {
  try {
    const dataStore = new DataStore();

    const specCount = await Specialty.countDocuments();
    if (specCount === 0) {
      console.log('🌱 Seeding default Specialties to MongoDB...');
      await Specialty.insertMany(dataStore.specialties);
    }

    const docCount = await Doctor.countDocuments();
    if (docCount === 0) {
      console.log('🌱 Seeding default Doctors to MongoDB...');
      await Doctor.insertMany(dataStore.doctors);
    }

    const userCount = await User.countDocuments();
    if (userCount === 0) {
      console.log('🌱 Seeding default Users to MongoDB...');
      await User.insertMany(dataStore.users);
    }

    console.log('✅ MongoDB database check & seed completed.');
  } catch (err) {
    console.error('⚠️ MongoDB Seeding Error:', err.message);
  }
};

module.exports = seedInitialData;
