const { initializeApp } = require("firebase/app");
const { getFirestore, doc, updateDoc } = require("firebase/firestore");

const firebaseConfig = {
    apiKey: 'AIzaSyD2Q_i8Zp0zpQnC6tCR4KKDe0NOI1njeYI',
    appId: '1:453613002299:web:77ee318a42c82e917e061e',
    projectId: 'washify-7638b',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function fixOtherProducts() {
  console.log("=== FIXING OTHER PRODUCTS ===");
  try {
    const airFreshRef = doc(db, "products", "JGrUIG7vkgepMntEBNfK");
    await updateDoc(airFreshRef, {
      unit: "Unité",
      updatedAt: new Date()
    });
    console.log("Successfully updated air frech unit to 'Unité' in Firestore!");
    process.exit(0);
  } catch (error) {
    console.error("Error updating product:", error);
    process.exit(1);
  }
}

fixOtherProducts();
