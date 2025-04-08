-- init_11_privileges.sql
-- Attribution des privilèges entre schémas
-- Connect as SYSDBA
CONNECT system/Luqman123 AS SYSDBA

-- Grant privileges with GRANT OPTION for Cergy tables
GRANT SELECT ON c##glpi_cergy.glpi_users TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_cergy.glpi_computers_items TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_cergy.glpi_printers_items TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_cergy.glpi_tickets TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_cergy.glpi_tickets_items TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_cergy.glpi_tickets_issues TO c##glpi_central WITH GRANT OPTION;

-- Grant privileges with GRANT OPTION for Pau tables
GRANT SELECT ON c##glpi_pau.glpi_users TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_pau.glpi_computers_items TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_pau.glpi_printers_items TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_pau.glpi_tickets TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_pau.glpi_tickets_items TO c##glpi_central WITH GRANT OPTION;
GRANT SELECT ON c##glpi_pau.glpi_tickets_issues TO c##glpi_central WITH GRANT OPTION;

CONNECT c##glpi_central/glpi_central

-- Accorder des privilèges d'exécution sur les procédures du schéma central
GRANT EXECUTE ON current_user_client_id TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON current_user_id TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON current_user_site_id TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON current_user_role TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON current_user_email TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON create_utilisateur TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON create_ticket_with_equipements TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON update_ticket TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON assign_equipment_to_user TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON check_ticket_permissions TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON check_ticket_update_permissions TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON check_computer_permission TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON check_printer_permission TO c##glpi_cergy, c##glpi_pau;
GRANT EXECUTE ON check_ticket_site_permission TO c##glpi_cergy, c##glpi_pau;

-- Accorder des privilèges sur les vues globales
GRANT SELECT ON global_users TO c##glpi_cergy, c##glpi_pau;
GRANT SELECT ON global_computers_items TO c##glpi_cergy, c##glpi_pau;
GRANT SELECT ON global_printers_items TO c##glpi_cergy, c##glpi_pau;
GRANT SELECT ON global_tickets TO c##glpi_cergy, c##glpi_pau;
GRANT SELECT ON global_tickets_items TO c##glpi_cergy, c##glpi_pau;
GRANT SELECT ON global_tickets_issues TO c##glpi_cergy, c##glpi_pau;

-- Accorder des privilèges sur les tables partagées
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_clients TO c##glpi_cergy, c##glpi_pau;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_sites TO c##glpi_cergy, c##glpi_pau;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_computers TO c##glpi_cergy, c##glpi_pau;
GRANT SELECT, INSERT, UPDATE, DELETE ON glpi_printers TO c##glpi_cergy, c##glpi_pau;