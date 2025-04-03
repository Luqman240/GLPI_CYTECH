-- 📌 GESTION DES ROLES ET PERMISSIONS --
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_sites';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_clients';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_users';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_computers';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_printers';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_computers_items';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_printers_items';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_tickets';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_tickets_items';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE glpi_tickets_issues';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Création des rôles
CREATE ROLE c##admin_role;
CREATE ROLE c##technicien_role;
CREATE ROLE c##enseignant_role;
CREATE ROLE c##etudiant_role;

-- 📌 Table des écoles
CREATE TABLE glpi_clients (
    id NUMBER PRIMARY KEY,
    nom VARCHAR(255) NOT NULL UNIQUE
);

-- 📌 Table des sites (Cergy, Pau)
CREATE TABLE glpi_sites (
    id NUMBER PRIMARY KEY,
    nom VARCHAR(255) NOT NULL UNIQUE,
    client_id INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES glpi_clients(id)
);

-- 📌 Table des utilisateurs (enseignants, techniciens, étudiants, admin)
CREATE TABLE glpi_users (
    id NUMBER PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('Admin', 'Technicien', 'Enseignant', 'Étudiant')) NOT NULL,
    client_id INT NOT NULL,  -- École à laquelle appartient l'utilisateur
    site_id INT NOT NULL,  -- Site (Cergy, Pau)
    classe VARCHAR(100) NULL, -- Uniquement pour les étudiants
    FOREIGN KEY (client_id) REFERENCES glpi_clients(id),
    FOREIGN KEY (site_id) REFERENCES glpi_sites(id)
);

-- 📌 Table des ordinateurs
CREATE TABLE glpi_computers (
    id NUMBER PRIMARY KEY,
    marque VARCHAR(255) NOT NULL,
    modele VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL
);

-- 📌 Table des imprimantes
CREATE TABLE glpi_printers (
    id NUMBER PRIMARY KEY,
    marque VARCHAR(255) NOT NULL,
    modele VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL
);

-- 📌 Table des ordinateurs utilisés (répartition par site)
CREATE TABLE glpi_computers_items (
    id NUMBER PRIMARY KEY,
    reference_computer_id INT NOT NULL,
    client_id INT NOT NULL,  -- À quelle école appartient l'ordinateur
    site_id INT NOT NULL,  -- Site (Cergy, Pau)
    utilisateur_id INT NOT NULL,  -- Qui utilise cet ordinateur ?
    date_d_acquisition DATE NOT NULL,
    FOREIGN KEY (reference_computer_id) REFERENCES glpi_computers(id),
    FOREIGN KEY (client_id) REFERENCES glpi_clients(id),
    FOREIGN KEY (site_id) REFERENCES glpi_sites(id),
    FOREIGN KEY (utilisateur_id) REFERENCES glpi_users(id)
);

-- 📌 Table des imprimantes utilisées (répartition par site)
CREATE TABLE glpi_printers_items (
    id NUMBER PRIMARY KEY,
    reference_printer_id INT NOT NULL,
    client_id INT NOT NULL,
    site_id INT NOT NULL,
    utilisateur_id INT NOT NULL,
    date_d_acquisition DATE NOT NULL,
    FOREIGN KEY (reference_printer_id) REFERENCES glpi_printers(id),
    FOREIGN KEY (client_id) REFERENCES glpi_clients(id),
    FOREIGN KEY (site_id) REFERENCES glpi_sites(id),
    FOREIGN KEY (utilisateur_id) REFERENCES glpi_users(id)
);

-- 📌 Table des tickets d'incidents (répartition par site)
CREATE TABLE glpi_tickets (
    id NUMBER PRIMARY KEY,
    utilisateur_id INT NOT NULL,  -- Qui a signalé le problème ?
    client_id INT NOT NULL,  -- École concernée
    site_id INT NOT NULL,  -- Site (Cergy, Pau)
    description VARCHAR(255) NOT NULL,
    statut VARCHAR(20) DEFAULT 'Ouvert' NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_resolution TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES glpi_users(id),
    FOREIGN KEY (client_id) REFERENCES glpi_clients(id),
    FOREIGN KEY (site_id) REFERENCES glpi_sites(id),
    CONSTRAINT statut_check CHECK (statut IN ('Ouvert', 'En cours', 'Resolu', 'Ferme'))
);


-- 📌 Table des éléments des tickets (répartition par site)
CREATE TABLE glpi_tickets_items (
    id NUMBER PRIMARY KEY,
    ticket_id INT NOT NULL,
    computer_item_id INT NULL,
    printer_item_id INT NULL,
    site_id INT NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES glpi_tickets(id),
    FOREIGN KEY (computer_item_id) REFERENCES glpi_computers_items(id),
    FOREIGN KEY (printer_item_id) REFERENCES glpi_printers_items(id),
    FOREIGN KEY (site_id) REFERENCES glpi_sites(id),
    CHECK (
        (computer_item_id IS NOT NULL AND printer_item_id IS NULL) OR 
        (computer_item_id IS NULL AND printer_item_id IS NOT NULL)
    )
);

-- 📌 Table des résolutions de tickets (répartition par site)
CREATE TABLE glpi_tickets_issues (
    id NUMBER PRIMARY KEY,
    ticket_id INT NOT NULL,
    description_resolution VARCHAR(255) NOT NULL,
    date_cloture TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    site_id INT NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES glpi_tickets(id),
    FOREIGN KEY (site_id) REFERENCES glpi_sites(id)
);


-- Attribution des permissions aux rôles

-- Admin : Accès complet
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_sites TO c##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_users TO c##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_computers TO c##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_printers TO c##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_computers_items TO c##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_printers_items TO c##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_tickets TO c##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_tickets_items TO c##admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_tickets_issues TO c##admin_role;

-- Technicien : Accès aux tickets et équipements du site
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_tickets TO c##technicien_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_computers_items TO c##technicien_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_printers_items TO c##technicien_role;
GRANT SELECT ON glpi_sites TO c##technicien_role;

-- Enseignant : Peut gérer ses tickets et ceux de ses étudiants sur son site
GRANT SELECT, INSERT, UPDATE ON glpi_tickets TO c##enseignant_role;
GRANT SELECT ON glpi_computers_items TO c##enseignant_role;
GRANT SELECT ON glpi_printers_items TO c##enseignant_role;
GRANT SELECT ON glpi_sites TO c##enseignant_role;

-- Étudiant : Peut gérer ses propres tickets et équipements sur son site
GRANT SELECT, INSERT ON glpi_tickets TO c##etudiant_role;
GRANT SELECT ON glpi_computers_items TO c##etudiant_role;
GRANT SELECT ON glpi_printers_items TO c##etudiant_role;
GRANT SELECT ON glpi_sites TO c##etudiant_role;
