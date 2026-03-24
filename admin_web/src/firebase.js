import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';

// Configuration Firebase SafeRide (Remplacer par les vraies clés si nécessaire)
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "saferide-qc.firebaseapp.com",
  projectId: "saferide-qc",
  storageBucket: "saferide-qc.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
export default app;
