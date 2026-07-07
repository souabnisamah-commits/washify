const { initializeApp } = require("firebase/app");
const { getFirestore, collection, addDoc, doc, setDoc, getDoc, updateDoc, query, where, getDocs, orderBy } = require("firebase/firestore");

const firebaseConfig = {
    apiKey: 'AIzaSyD2Q_i8Zp0zpQnC6tCR4KKDe0NOI1njeYI',
    appId: '1:453613002299:web:77ee318a42c82e917e061e',
    projectId: 'washify-7638b',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function runTests() {
  console.log("=== DEBUT DES TESTS REELS ===");
  try {
    // 1. Create a station
    const stationRef = await addDoc(collection(db, "stations"), {
      name: "Station Alpha",
      address: "123 Rue de Paris",
      phone: "0102030405",
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    console.log("Station Créée ID:", stationRef.id);

    // 2. Create Patron
    const patronRef = doc(db, "users", "patron123");
    await setDoc(patronRef, {
      id: "patron123",
      phone: "11111111",
      firstName: "Jean",
      lastName: "Patron",
      tenantId: stationRef.id,
      roles: ["patron"],
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    console.log("\n--- PREUVE 1: Patron ---");
    const pSnap = await getDoc(patronRef);
    console.log(JSON.stringify(pSnap.data(), null, 2));

    // 3. Create Ouvrier
    const ouvrierRef = doc(db, "users", "ouvrier456");
    await setDoc(ouvrierRef, {
      id: "ouvrier456",
      phone: "22222222",
      firstName: "Luc",
      lastName: "Laveur",
      tenantId: stationRef.id,
      stationId: stationRef.id, // For fallback
      roles: ["ouvrier"],
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // 4. Ouvrier Dashboard query (requires composite index)
    console.log("\n--- PREUVE 2: Index Ouvrier ---");
    const q = query(collection(db, "tickets"), where("workerId", "==", "ouvrier456"), orderBy("createdAt", "desc"));
    await getDocs(q); // Should not throw failed-precondition!
    console.log("Requête Firestore (where workerId + orderBy createdAt) exécutée avec succès sans erreur d'index.");

    // 5. Create Service
    const serviceRef = await addDoc(collection(db, "services"), {
      stationId: stationRef.id,
      name: "Lavage Express",
      price: 15.0,
      durationMinutes: 30,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    
    // 6. Update Wash Service (BUG 3 proof)
    console.log("\n--- PREUVE 3: Modification Lavage ---");
    const serviceSnap1 = await getDoc(serviceRef);
    console.log("AVANT:", JSON.stringify(serviceSnap1.data(), null, 2));
    
    await updateDoc(serviceRef, {
      price: 20.0,
      name: "Lavage Express Premium",
      updatedAt: new Date()
    });
    
    const serviceSnap2 = await getDoc(serviceRef);
    console.log("APRES:", JSON.stringify(serviceSnap2.data(), null, 2));

    // 7. Ticket & Payment
    console.log("\n--- SCENARIO COMPLET: Ticket -> Paiement ---");
    const ticketRef = await addDoc(collection(db, "tickets"), {
      stationId: stationRef.id,
      workerId: "ouvrier456",
      workerName: "Luc Laveur",
      serviceId: serviceRef.id,
      serviceName: "Lavage Express Premium",
      totalAmount: 20.0,
      status: "en_attente",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    console.log("Ticket Créé ID:", ticketRef.id, "Statut: en_attente");

    await updateDoc(ticketRef, {
      status: "paye",
      updatedAt: new Date()
    });
    const tSnap = await getDoc(ticketRef);
    console.log("Ticket Payé:", JSON.stringify(tSnap.data(), null, 2));

    process.exit(0);
  } catch (error) {
    console.error("ERREUR FATALE:", error);
    process.exit(1);
  }
}

runTests();
