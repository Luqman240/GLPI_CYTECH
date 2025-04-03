-- Peupler la table des écoles
INSERT INTO glpi_clients (nom) VALUES 
('CY TECH'),

-- Peupler la table des sites
INSERT INTO glpi_sites (nom, client_id) VALUES 
('Cergy', 1),
('Pau', 2);

-- Peupler la table des utilisateurs
-- Admins
INSERT INTO glpi_users (nom, email, mot_de_passe, role, client_id, site_id) VALUES
('Admin Cergy', 'admin.cergy@ecole.com', 'password123', 'Admin', 1, 1),
('Admin Pau', 'admin.pau@ecole.com', 'password123', 'Admin', 1, 2);

-- Techniciens
INSERT INTO glpi_users (nom, email, mot_de_passe, role, client_id, site_id) VALUES
('Technicien Cergy', 'tech.cergy@ecole.com', 'password123', 'Technicien', 1, 1),
('Technicien Pau', 'tech.pau@ecole.com', 'password123', 'Technicien', 1, 2);

-- Enseignants
INSERT INTO glpi_users (nom, email, mot_de_passe, role, client_id, site_id) VALUES
('Professeur Mathématiques Cergy', 'prof.math.cergy@ecole.com', 'password123', 'Enseignant', 1, 1),
('Professeur Histoire Pau', 'prof.histoire.pau@ecole.com', 'password123', 'Enseignant', 1, 2);

-- Étudiants
INSERT INTO glpi_users (nom, email, mot_de_passe, role, client_id, site_id, classe) VALUES
('Étudiant 1 Cergy', 'etudiant1.cergy@ecole.com', 'password123', 'Étudiant', 1, 1, 'Classe A'),
('Étudiant 2 Cergy', 'etudiant2.cergy@ecole.com', 'password123', 'Étudiant', 1, 1, 'Classe B'),
('Étudiant 1 Pau', 'etudiant1.pau@ecole.com', 'password123', 'Étudiant', 1, 2, 'Classe A'),
('Étudiant 2 Pau', 'etudiant2.pau@ecole.com', 'password123', 'Étudiant', 1, 2, 'Classe B');

-- Peupler la table des ordinateurs
INSERT INTO glpi_computers (marque, modele, type) VALUES
('Dell', 'XPS 13', 'Portable'),
('HP', 'EliteBook', 'Portable'),
('Lenovo', 'ThinkPad', 'Portable'),
('Acer', 'Aspire', 'Fixe');

-- Peupler la table des imprimantes
INSERT INTO glpi_printers (marque, modele, type) VALUES
('HP', 'LaserJet', 'Laser'),
('Canon', 'PIXMA', 'Jet d’encre');

-- Peupler la table des ordinateurs utilisés
INSERT INTO glpi_computers_items (reference_computer_id, client_id, site_id, utilisateur_id, date_d_acquisition) VALUES
(1, 1, 1, 1, '2024-01-01'),
(2, 1, 1, 2, '2024-01-01'),
(3, 1, 2, 3, '2024-02-01'),
(4, 1, 2, 4, '2024-02-01');

-- Peupler la table des imprimantes utilisées
INSERT INTO glpi_printers_items (reference_printer_id, client_id, site_id, utilisateur_id, date_d_acquisition) VALUES
(1, 1, 1, 1, '2024-01-01'),
(2, 1, 2, 3, '2024-02-01');

-- Peupler la table des tickets d'incidents
INSERT INTO glpi_tickets (utilisateur_id, client_id, site_id, description, statut, date_creation) VALUES
(1, 1, 1, 'Problème de connexion au réseau', 'Ouvert', '2024-01-01'),
(2, 1, 1, 'L’ordinateur est trop lent', 'En cours', '2024-02-01'),
(3, 1, 2, 'L’imprimante ne fonctionne pas', 'Résolu', '2024-02-01'),
(4, 1, 2, 'Problème d’affichage sur l’écran', 'Fermé', '2024-03-01');

-- Peupler la table des éléments des tickets (références aux équipements)
INSERT INTO glpi_tickets_items (ticket_id, computer_item_id, printer_item_id, site_id) VALUES
(1, 1, NULL, 1),
(2, 2, NULL, 1),
(3, NULL, 1, 2),
(4, 3, NULL, 2);

-- Peupler la table des résolutions de tickets
INSERT INTO glpi_tickets_issues (ticket_id, description_resolution, date_cloture, site_id) VALUES
(1, 'Redémarrage du routeur effectué', '2024-01-02', 1),
(2, 'Réinstallation de l’OS', '2024-02-10', 1),
(3, 'Cartouche d’encre remplacée', '2024-02-10', 2),
(4, 'Écran remplacé', '2024-03-02', 2);
