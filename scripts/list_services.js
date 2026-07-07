const { initializeApp } = require("firebase/app");
const { getFirestore, collection, getDocs } = require("firebase/firestore");

const firebaseConfig = {
    apiKey: 'AIzaSyD2Q_i8Zp0zpQnC6tCR4KKDe0NOI1njeYI',
    appId: '1:453613002299:web:77ee318a42c82e917e061e',
    projectId: 'washify-7638b',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function listServices() {
  console.log("=== LISTING SERVICES ===");
  try {
    const querySnapshot = await getDocs(collection(db, "services"));
    querySnapshot.forEach((doc) => {
      const data = doc.data();
      console.log(`ID: ${doc.id} | Name: "${data.name}" | StationId: ${data.stationId} | Prices: ${JSON.stringify(data.pricesByCategory || data.price)}`);
    });
    process.exit(0);
  } catch (error) {
    console.error("Error fetching services:", error);
    process.exit(1);
  }
}

listServices();
