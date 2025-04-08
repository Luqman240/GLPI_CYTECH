# Mini Projet : Amélioration de la Gestion du Parc Informatique de CY Tech

## Description

Ce mini-projet a pour objectif de repenser et améliorer une partie de la base de données de GLPI (Gestionnaire Libre de Parc Informatique) pour optimiser la gestion du parc informatique de CY Tech et prendre en compte l'aspect multi-sites (Cergy, Pau). Le projet se base sur un reverse engineering du schéma de GLPI et l'application des connaissances acquises dans le cadre du cours de bases de données et de programmation PL/SQL.

Le périmètre du projet inclut la gestion des utilisateurs, des équipements informatiques et des informations relatives à la structure des réseaux.

## Objectifs

Le projet consiste à :
1. **Concevoir une nouvelle base de données** en utilisant les concepts étudiés en cours :
   - Gestion des utilisateurs et des rôles
   - Tablespaces, clusters, index, vues
   - PL/SQL (triggers, curseurs, procédures, fonctions)
   - Bases de données réparties (BDDR)
   - Plan de requêtes pour l'optimisation
2. **Valider la structure** en effectuant des tests de performance sur la base de données à l'aide d'un jeu de tests conséquent généré en PL/SQL.

## Technologies Utilisées

- **PL/SQL** pour la création de procédures, fonctions, triggers, et la gestion des performances
- **Oracle Database** pour la gestion des données et l'exécution des requêtes
- **GLPI** comme référence pour la structure du parc informatique
- **Git** pour la gestion du code source et la collaboration en équipe

## Fonctionnalités

- Gestion des utilisateurs (création, modification, rôles)
- Gestion des tickets et des équipements associés (création, modification, suppression)
- Optimisation des requêtes grâce aux index et à la gestion de la base de données
- Validation des performances via un jeu de tests généré en PL/SQL
- Gestion multi-sites (Cergy, Pau)

## Instructions pour l'Installation

1. **Récuperer les fichiers du repo**
2. **Ouvrir SQLPLUS en tant que SYS**
3. **Remplacer dans tous les fichiers "system/Luqman123" par les identifiants de votre utilisateur SYSTEM**
4. **Exécuter l'ensemble des fichiers dans l'ordre avec @"chemin/vers/le/fichier.sql**

