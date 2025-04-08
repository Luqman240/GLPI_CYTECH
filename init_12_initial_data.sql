-- init_12_initial_data.sql
-- Insertion des données initiales et configuration des rôles

CONNECT c##glpi_central/glpi_central

-- Insérer le client
INSERT INTO glpi_clients VALUES (seq_client_id.NEXTVAL, 'École XYZ');

-- Insérer les sites
INSERT INTO glpi_sites VALUES (1, 'Cergy', 1);
INSERT INTO glpi_sites VALUES (2, 'Pau', 1);

-- Insérer quelques modèles d'ordinateurs
INSERT INTO glpi_computers VALUES (seq_computer_id.NEXTVAL, 'Dell', 'Latitude 5420', 'Laptop');
INSERT INTO glpi_computers VALUES (seq_computer_id.NEXTVAL, 'HP', 'EliteDesk 800 G5', 'Desktop');
INSERT INTO glpi_computers VALUES (seq_computer_id.NEXTVAL, 'Lenovo', 'ThinkPad X1 Carbon', 'Laptop');
INSERT INTO glpi_computers VALUES (seq_computer_id.NEXTVAL, 'Apple', 'MacBook Pro 14', 'Laptop');

-- Insérer quelques modèles d'imprimantes
INSERT INTO glpi_printers VALUES (seq_printer_id.NEXTVAL, 'HP', 'LaserJet Pro M404', 'Laser');
INSERT INTO glpi_printers VALUES (seq_printer_id.NEXTVAL, 'Epson', 'EcoTank ET-4760', 'Inkjet');
INSERT INTO glpi_printers VALUES (seq_printer_id.NEXTVAL, 'Brother', 'MFC-L8900CDW', 'Laser');
INSERT INTO glpi_printers VALUES (seq_printer_id.NEXTVAL, 'Canon', 'PIXMA TR8620', 'Inkjet');

-- Créer un utilisateur administrateur système
CONNECT system/Luqman123

-- Créer un utilisateur commun (c##) pour l'administrateur
BEGIN
   EXECUTE IMMEDIATE 'CREATE USER c##admin_glpi IDENTIFIED BY admin123';
   EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO c##admin_glpi';
   EXECUTE IMMEDIATE 'GRANT c##glpi_admin_role TO c##admin_glpi';
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erreur lors de la création de l''utilisateur admin: ' || SQLERRM);
END;
/

-- Retourner au schéma central
CONNECT c##glpi_central/glpi_central

-- Insérer l'utilisateur admin dans le site de Cergy
INSERT INTO c##glpi_cergy.glpi_users (
    id, nom, email, mot_de_passe, role, client_id, site_id, classe
) VALUES (
    c##glpi_cergy.seq_user_id.NEXTVAL, 'Administrateur', 'c##admin_glpi', 
    'admin123', 'Admin', 1, 1, NULL
);

-- Procédure de test de répartition
CREATE OR REPLACE PROCEDURE test_distribution AS
    v_count_cergy_users NUMBER := 0;
    v_count_pau_users NUMBER := 0;
    v_count_cergy_tickets NUMBER := 0;
    v_count_pau_tickets NUMBER := 0;
BEGIN
    -- Compter le nombre d'utilisateurs par site
    SELECT COUNT(*) INTO v_count_cergy_users FROM cergy_users;
    SELECT COUNT(*) INTO v_count_pau_users FROM pau_users;
    
    -- Compter le nombre de tickets par site
    SELECT COUNT(*) INTO v_count_cergy_tickets FROM cergy_tickets;
    SELECT COUNT(*) INTO v_count_pau_tickets FROM pau_tickets;
    
    -- Afficher les résultats
    DBMS_OUTPUT.PUT_LINE('===== DISTRIBUTION DES DONNÉES =====');
    DBMS_OUTPUT.PUT_LINE('Utilisateurs à Cergy: ' || v_count_cergy_users);
    DBMS_OUTPUT.PUT_LINE('Utilisateurs à Pau: ' || v_count_pau_users);
    DBMS_OUTPUT.PUT_LINE('Tickets à Cergy: ' || v_count_cergy_tickets);
    DBMS_OUTPUT.PUT_LINE('Tickets à Pau: ' || v_count_pau_tickets);
    DBMS_OUTPUT.PUT_LINE('===================================');
END test_distribution;
/

-- Exécuter la procédure de test
SET SERVEROUTPUT ON;
EXEC test_distribution;

-- ADMIN : Accès complet
GRANT SELECT, INSERT, UPDATE, DELETE ON global_users TO c##glpi_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON global_computers_items TO c##glpi_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON global_printers_items TO c##glpi_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON global_tickets TO c##glpi_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON global_tickets_items TO c##glpi_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON global_tickets_issues TO c##glpi_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_clients TO c##glpi_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_sites TO c##glpi_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_computers TO c##glpi_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_printers TO c##glpi_admin_role;
GRANT EXECUTE ON create_utilisateur TO c##glpi_admin_role;
GRANT EXECUTE ON create_ticket_with_equipements TO c##glpi_admin_role;
GRANT EXECUTE ON update_ticket TO c##glpi_admin_role;
GRANT EXECUTE ON assign_equipment_to_user TO c##glpi_admin_role;

-- TECHNICIEN : Accès aux tickets et équipements
GRANT SELECT, INSERT, UPDATE, DELETE ON global_tickets TO c##glpi_technicien_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON global_tickets_items TO c##glpi_technicien_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON global_tickets_issues TO c##glpi_technicien_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON global_computers_items TO c##glpi_technicien_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON global_printers_items TO c##glpi_technicien_role;
GRANT SELECT ON global_users TO c##glpi_technicien_role;
GRANT SELECT ON glpi_sites TO c##glpi_technicien_role;
GRANT SELECT ON glpi_clients TO c##glpi_technicien_role;
GRANT SELECT ON glpi_computers TO c##glpi_technicien_role;
GRANT SELECT ON glpi_printers TO c##glpi_technicien_role;
GRANT EXECUTE ON create_ticket_with_equipements TO c##glpi_technicien_role;
GRANT EXECUTE ON update_ticket TO c##glpi_technicien_role;
GRANT EXECUTE ON assign_equipment_to_user TO c##glpi_technicien_role;

-- ENSEIGNANT : Peut créer et suivre des tickets
GRANT SELECT, INSERT, UPDATE ON global_tickets TO c##glpi_enseignant_role;
GRANT SELECT ON global_computers_items TO c##glpi_enseignant_role;
GRANT SELECT ON global_printers_items TO c##glpi_enseignant_role;
GRANT SELECT ON glpi_sites TO c##glpi_enseignant_role;
GRANT SELECT ON glpi_clients TO c##glpi_enseignant_role;
GRANT SELECT ON glpi_computers TO c##glpi_enseignant_role;
GRANT SELECT ON glpi_printers TO c##glpi_enseignant_role;
GRANT EXECUTE ON create_ticket_with_equipements TO c##glpi_enseignant_role;
GRANT EXECUTE ON update_ticket TO c##glpi_enseignant_role;

-- ÉTUDIANT : Peut créer des tickets
GRANT SELECT, INSERT ON global_tickets TO c##glpi_etudiant_role;
GRANT SELECT ON global_computers_items TO c##glpi_etudiant_role;
GRANT SELECT ON global_printers_items TO c##glpi_etudiant_role;
GRANT SELECT ON glpi_sites TO c##glpi_etudiant_role;
GRANT SELECT ON glpi_clients TO c##glpi_etudiant_role;
GRANT SELECT ON glpi_computers TO c##glpi_etudiant_role;
GRANT SELECT ON glpi_printers TO c##glpi_etudiant_role;
GRANT EXECUTE ON create_ticket_with_equipements TO c##glpi_etudiant_role;

COMMIT;