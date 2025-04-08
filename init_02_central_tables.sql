-- init_02_central_tables.sql
-- Création des tables dans le schéma central

CONNECT c##glpi_central/glpi_central

-- Tables communes centralisées
CREATE TABLE glpi_clients (
    id NUMBER PRIMARY KEY,
    nom VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE glpi_sites (
    id NUMBER PRIMARY KEY,
    nom VARCHAR(255) NOT NULL UNIQUE,
    client_id NUMBER NOT NULL,
    FOREIGN KEY (client_id) REFERENCES glpi_clients(id)
);

CREATE TABLE glpi_computers (
    id NUMBER PRIMARY KEY,
    marque VARCHAR(255) NOT NULL,
    modele VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL
);

CREATE TABLE glpi_printers (
    id NUMBER PRIMARY KEY,
    marque VARCHAR(255) NOT NULL,
    modele VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL
);

-- Séquences pour le schéma central
CREATE SEQUENCE seq_client_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_site_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_computer_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_printer_id START WITH 1 INCREMENT BY 1;