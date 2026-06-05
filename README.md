# Restaurant Management SaaS 🍽️

Une application SaaS full-stack complète permettant de gérer efficacement les opérations d'un restaurant, de la réservation client à la configuration des salles et des services par les gérants. 

L'architecture repose sur une séparation stricte entre une base de données relationnelle intelligente et une interface utilisateur multiplateforme réactive.

## 🛠️ Stack Technique

**Frontend (Client & Manager)**
* **Framework:** Flutter
* **Langage:** Dart
* **State Management:** Riverpod
* **Architecture:** Consommation d'API REST dynamique

**Backend & Base de données**
* **Database:** PostgreSQL
* **API:** PostgREST (Génération automatique d'API RESTful)
* **Logique métier:** Fonctions PL/pgSQL, Triggers et gestion rigoureuse des contraintes (chevauchements, règles temporelles)
* **Sécurité:** Row Level Security (RLS) et authentification par rôles (Client / Manager)

## ✨ Fonctionnalités Principales

### 👨‍💼 Côté Manager
* **Gestion des Services (CRUD) :** Définition des horaires d'ouverture avec prévention des chevauchements.
* **Plan de Salle :** Configuration des tables et des capacités.
* **Réservations :** Validation, annulation et suivi en temps réel des réservations.
* **Règles Métiers Intégrées :** Blocage automatique des actions incohérentes (ex: suppression d'un service contenant des réservations actives).

### 📱 Côté Client
* **Recherche :** Consultation des restaurants et de leurs horaires d'ouverture dynamiques.
* **Réservation Intelligente :** Proposition des créneaux disponibles selon la capacité des tables et les règles du restaurant.
* **Suivi :** Historique et statut des réservations en direct.
