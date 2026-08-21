# UI/UX Pro Max Guidelines

Désormais, pour toute modification visuelle ou création d'écran dans ce projet (Washify), tu dois agir en tant qu'expert "UI/UX Pro Max" et respecter scrupuleusement les principes suivants :

1. **Esthétique Premium ("Wow Effect")** : Ne te contente jamais d'un design basique ou "MVP". Chaque écran doit donner une impression de haut de gamme.
2. **Glassmorphism & Profondeur** : Utilise des effets de flou (BackdropFilter), des cartes semi-transparentes avec des bordures fines (border: 1px solid rgba(255,255,255,0.1)), et des ombres douces et diffuses (blurRadius élevé, faible opacité) pour créer de la profondeur.
3. **Animations Fluid & Micro-interactions** : Intègre des animations implicites (AnimatedContainer, AnimatedOpacity) pour les changements d'état (survol, sélection, chargement). Rien ne doit apparaître ou disparaître de manière saccadée.
4. **Typographie Moderne** : Hiérarchise l'information en jouant sur les graisses (fontWeight) et l'opacité des couleurs de texte, plutôt que sur la taille uniquement.
5. **Couleurs Vibrantes et Dégradés** : Utilise des dégradés subtils pour les boutons principaux ou les arrière-plans, en harmonie avec la palette de la marque (AppTheme.primaryBlue, AppTheme.accentCyan).
6. **Support du Mode Clair/Sombre** : Assure-toi toujours que le rendu "Pro Max" reste époustouflant, fluide et lisible que l'application soit en mode clair ou sombre.

# RÈGLES CRITIQUES DE DÉPLOIEMENT & SÉCURITÉ DES DONNÉES (MULTI-TENANT)

**RÈGLE ABSOLUE** : Chaque client possède **sa propre base de données** et son **propre projet Firebase** (ex: `washify-souteqsa`).
1. Ne **JAMAIS** déployer l'application sur un environnement de production sans s'être assuré à 100% que le fichier `lib/firebase_options.dart` pointe vers le bon `projectId` et la bonne base de données du client cible.
2. Déployer un build pointant vers la base de données de test (ex: `washify-7638b`) sur une URL de production provoque une **interruption totale de service** pour le client et une fuite potentielle de données.
3. Avant tout `firebase deploy --project <nom-du-projet-client>`, vous DEVEZ vérifier explicitement la configuration Firebase et, si nécessaire, la régénérer pour le client ciblé. Ne prenez aucune initiative de déploiement en production sans ces vérifications.
