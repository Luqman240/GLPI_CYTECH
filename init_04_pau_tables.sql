-- init_04_pau_tables.sql
-- Création des tables dans le schéma Pau

CONNECT c##glpi_pau/glpi_pau

-- Tables spécifiques au site Pau (identiques à Cergy)
CREATE TABLE glpi_users (
    id NUMBER PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('Admin', 'Technicien', 'Enseignant', 'Étudiant')) NOT NULL,
    client_id NUMBER NOT NULL,
    site_id NUMBER NOT NULL,
    classe VARCHAR(100) NULL
);

CREATE TABLE glpi_computers_items (
    id NUMBER PRIMARY KEY,
    reference_computer_id NUMBER NOT NULL,
    client_id NUMBER NOT NULL,
    site_id NUMBER NOT NULL,
    utilisateur_id NUMBER NOT NULL,
    date_d_acquisition DATE NOT NULL
);

CREATE TABLE glpi_printers_items (
    id NUMBER PRIMARY KEY,
    reference_printer_id NUMBER NOT NULL,
    client_id NUMBER NOT NULL,
    site_id NUMBER NOT NULL,
    utilisateur_id NUMBER NOT NULL,
    date_d_acquisition DATE NOT NULL
);

CREATE TABLE glpi_tickets (
    id NUMBER PRIMARY KEY,
    utilisateur_id NUMBER NOT NULL,
    client_id NUMBER NOT NULL,
    site_id NUMBER NOT NULL,
    description VARCHAR(255) NOT NULL,
    statut VARCHAR(20) DEFAULT 'Ouvert' NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_resolution TIMESTAMP,
    CONSTRAINT statut_check CHECK (statut IN ('Ouvert', 'En cours', 'Resolu', 'Ferme'))
);

CREATE TABLE glpi_tickets_items (
    id NUMBER PRIMARY KEY,
    ticket_id NUMBER NOT NULL,
    computer_item_id NUMBER NULL,
    printer_item_id NUMBER NULL,
    site_id NUMBER NOT NULL,
    CHECK (
        (computer_item_id IS NOT NULL AND printer_item_id IS NULL) OR 
        (computer_item_id IS NULL AND printer_item_id IS NOT NULL)
    )
);

CREATE TABLE glpi_tickets_issues (
    id NUMBER PRIMARY KEY,
    ticket_id NUMBER NOT NULL,
    description_resolution VARCHAR(255) NOT NULL,
    date_cloture TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    site_id NUMBER NOT NULL
);

-- Accorder les privilèges au schéma central pour accéder aux tables
GRANT SELECT ON glpi_users TO c##glpi_central;
GRANT SELECT ON glpi_computers_items TO c##glpi_central;
GRANT SELECT ON glpi_printers_items TO c##glpi_central;
GRANT SELECT ON glpi_tickets TO c##glpi_central;
GRANT SELECT ON glpi_tickets_items TO c##glpi_central;
GRANT SELECT ON glpi_tickets_issues TO c##glpi_central;

-- Créer des synonymes pour accéder aux tables centrales depuis Pau
CREATE SYNONYM glpi_clients FOR c##glpi_central.glpi_clients;
CREATE SYNONYM glpi_sites FOR c##glpi_central.glpi_sites;
CREATE SYNONYM glpi_computers FOR c##glpi_central.glpi_computers;
CREATE SYNONYM glpi_printers FOR c##glpi_central.glpi_printers;

-- Séquences pour Pau (IDs pairs)
CREATE SEQUENCE seq_user_id START WITH 2 INCREMENT BY 2;
CREATE SEQUENCE seq_computer_item_id START WITH 2 INCREMENT BY 2;
CREATE SEQUENCE seq_printer_item_id START WITH 2 INCREMENT BY 2;
CREATE SEQUENCE seq_ticket_id START WITH 2 INCREMENT BY 2;
CREATE SEQUENCE seq_ticket_item_id START WITH 2 INCREMENT BY 2;
CREATE SEQUENCE seq_ticket_issue_id START WITH 2 INCREMENT BY 2;

-- Accorder les privilèges au schéma central pour accéder aux tables
GRANT SELECT ON seq_user_id TO c##glpi_central;
GRANT SELECT ON seq_printer_item_id TO c##glpi_central;
GRANT SELECT ON seq_computer_item_id TO c##glpi_central;
GRANT SELECT ON seq_ticket_id TO c##glpi_central;
GRANT SELECT ON seq_ticket_item_id TO c##glpi_central;
GRANT SELECT ON seq_ticket_issue_id TO c##glpi_central;

-- Création des index pour le site de Pau
CREATE INDEX idx_users_role ON glpi_users (role);
CREATE INDEX idx_users_client_id ON glpi_users (client_id);
CREATE INDEX idx_users_client_role ON glpi_users (client_id, role);
CREATE INDEX idx_tickets_utilisateur_id ON glpi_tickets (utilisateur_id);
CREATE INDEX idx_tickets_client_id ON glpi_tickets (client_id);
CREATE INDEX idx_tickets_utilisateur_client ON glpi_tickets (utilisateur_id, client_id);
CREATE INDEX idx_tickets_items_ticket_id ON glpi_tickets_items (ticket_id);
CREATE INDEX idx_tickets_items_computer_item_id ON glpi_tickets_items (computer_item_id);
CREATE INDEX idx_tickets_items_printer_item_id ON glpi_tickets_items (printer_item_id);
CREATE INDEX idx_computers_items_utilisateur_id ON glpi_computers_items (utilisateur_id);
CREATE INDEX idx_computers_items_client_id ON glpi_computers_items (client_id);
CREATE INDEX idx_printers_items_utilisateur_id ON glpi_printers_items (utilisateur_id);
CREATE INDEX idx_printers_items_client_id ON glpi_printers_items (client_id);
CREATE INDEX idx_tickets_status ON glpi_tickets (utilisateur_id, statut);


CONNECT system/Luqman123

-- Grant necessary permissions to c##glpi_central
GRANT CREATE USER TO c##glpi_central;
GRANT ALTER USER TO c##glpi_central;
GRANT DROP USER TO c##glpi_central;
GRANT CREATE SESSION TO c##glpi_central;

-- Grant permissions for roles
GRANT CREATE ROLE TO c##glpi_central;
GRANT DROP ANY ROLE TO c##glpi_central;
GRANT GRANT ANY ROLE TO c##glpi_central;

-- Grant permissions for sequences
GRANT CREATE ANY SEQUENCE TO c##glpi_central;
GRANT SELECT ANY SEQUENCE TO c##glpi_central;
GRANT ALTER ANY SEQUENCE TO c##glpi_central;

-- Grant permissions for session management
GRANT ALTER SESSION TO c##glpi_central;
