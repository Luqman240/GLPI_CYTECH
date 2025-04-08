-- init_05_global_views.sql
-- Création des vues globales dans le schéma central

CONNECT c##glpi_central/glpi_central

-- Synonymes pour accéder aux tables des sites
CREATE SYNONYM cergy_users FOR c##glpi_cergy.glpi_users;
CREATE SYNONYM cergy_computers_items FOR c##glpi_cergy.glpi_computers_items;
CREATE SYNONYM cergy_printers_items FOR c##glpi_cergy.glpi_printers_items;
CREATE SYNONYM cergy_tickets FOR c##glpi_cergy.glpi_tickets;
CREATE SYNONYM cergy_tickets_items FOR c##glpi_cergy.glpi_tickets_items;
CREATE SYNONYM cergy_tickets_issues FOR c##glpi_cergy.glpi_tickets_issues;

CREATE SYNONYM pau_users FOR c##glpi_pau.glpi_users;
CREATE SYNONYM pau_computers_items FOR c##glpi_pau.glpi_computers_items;
CREATE SYNONYM pau_printers_items FOR c##glpi_pau.glpi_printers_items;
CREATE SYNONYM pau_tickets FOR c##glpi_pau.glpi_tickets;
CREATE SYNONYM pau_tickets_items FOR c##glpi_pau.glpi_tickets_items;
CREATE SYNONYM pau_tickets_issues FOR c##glpi_pau.glpi_tickets_issues;

-- Vues globales pour l'accès transparent à toutes les données
CREATE OR REPLACE VIEW global_users AS
SELECT * FROM cergy_users
UNION ALL
SELECT * FROM pau_users;

CREATE OR REPLACE VIEW global_computers_items AS
SELECT * FROM cergy_computers_items
UNION ALL
SELECT * FROM pau_computers_items;

CREATE OR REPLACE VIEW global_printers_items AS
SELECT * FROM cergy_printers_items
UNION ALL
SELECT * FROM pau_printers_items;

CREATE OR REPLACE VIEW global_tickets AS
SELECT * FROM cergy_tickets
UNION ALL
SELECT * FROM pau_tickets;

CREATE OR REPLACE VIEW global_tickets_items AS
SELECT * FROM cergy_tickets_items
UNION ALL
SELECT * FROM pau_tickets_items;

CREATE OR REPLACE VIEW global_tickets_issues AS
SELECT * FROM cergy_tickets_issues
UNION ALL
SELECT * FROM pau_tickets_issues;