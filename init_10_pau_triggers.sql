-- init_10_pau_triggers.sql
-- Création des triggers sur le site de Pau
CONNECT system/Luqman123 AS SYSDBA

-- Grant execute permissions on the existing functions and procedures
GRANT EXECUTE ON c##glpi_central.current_user_client_id TO c##glpi_pau;
GRANT EXECUTE ON c##glpi_central.current_user_id TO c##glpi_pau;
GRANT EXECUTE ON c##glpi_central.current_user_site_id TO c##glpi_pau;
GRANT EXECUTE ON c##glpi_central.current_user_role TO c##glpi_pau;
GRANT EXECUTE ON c##glpi_central.current_user_email TO c##glpi_pau;
GRANT EXECUTE ON c##glpi_central.check_ticket_permissions TO c##glpi_pau;
GRANT EXECUTE ON c##glpi_central.check_ticket_update_permissions TO c##glpi_pau;
GRANT EXECUTE ON c##glpi_central.check_computer_permission TO c##glpi_pau;
GRANT EXECUTE ON c##glpi_central.check_printer_permission TO c##glpi_pau;
GRANT EXECUTE ON c##glpi_central.check_ticket_site_permission TO c##glpi_pau;

-- Grant access to the views
GRANT SELECT ON c##glpi_central.cergy_users TO c##glpi_pau;
GRANT SELECT ON c##glpi_central.pau_users TO c##glpi_pau;
GRANT SELECT ON c##glpi_central.global_users TO c##glpi_pau;

CONNECT c##glpi_pau/glpi_pau


-- Trigger pour vérifier les permissions lors de la création d'un ticket
CREATE OR REPLACE TRIGGER ticket_permission_trigger
BEFORE INSERT ON glpi_tickets
FOR EACH ROW
DECLARE
    v_allowed BOOLEAN;
BEGIN
    v_allowed := c##glpi_central.check_ticket_permissions(:NEW.client_id);
END;
/

-- Trigger pour vérifier les permissions lors de la mise à jour d'un ticket
CREATE OR REPLACE TRIGGER ticket_update_permission_trigger
BEFORE UPDATE ON glpi_tickets
FOR EACH ROW
DECLARE
    v_allowed BOOLEAN;
BEGIN
    v_allowed := c##glpi_central.check_ticket_update_permissions(:NEW.utilisateur_id, :NEW.client_id);
END;
/

-- Trigger pour vérifier les permissions lors de la gestion d'un ordinateur
CREATE OR REPLACE TRIGGER computer_permission_trigger
BEFORE INSERT OR UPDATE ON glpi_computers_items
FOR EACH ROW
DECLARE
    v_allowed BOOLEAN;
BEGIN
    v_allowed := c##glpi_central.check_computer_permission(:NEW.utilisateur_id, :NEW.client_id);
END;
/

-- Trigger pour vérifier les permissions lors de la gestion d'une imprimante
CREATE OR REPLACE TRIGGER printer_permission_trigger
BEFORE INSERT OR UPDATE ON glpi_printers_items
FOR EACH ROW
DECLARE
    v_allowed BOOLEAN;
BEGIN
    v_allowed := c##glpi_central.check_printer_permission(:NEW.utilisateur_id, :NEW.client_id);
END;
/

-- Trigger pour empêcher la suppression non autorisée d'un ticket
CREATE OR REPLACE TRIGGER prevent_unauthorized_ticket_delete
BEFORE DELETE ON glpi_tickets
FOR EACH ROW
DECLARE
    v_user_id NUMBER;
    v_user_role VARCHAR2(40);
BEGIN
    c##glpi_central.current_user_id(v_user_id);
    c##glpi_central.current_user_role(v_user_role);

    IF v_user_role = 'Étudiant' AND :OLD.utilisateur_id != v_user_id THEN
        RAISE_APPLICATION_ERROR(-20003, 'Permission refusée : vous ne pouvez supprimer que vos propres tickets.');
    END IF;
END;
/

-- Trigger pour définir automatiquement la date de résolution d'un ticket
CREATE OR REPLACE TRIGGER auto_set_ticket_resolution_date
BEFORE UPDATE OF statut ON glpi_tickets
FOR EACH ROW
BEGIN
    IF :NEW.statut IN ('Resolu', 'Ferme') AND :OLD.date_resolution IS NULL THEN
        :NEW.date_resolution := CURRENT_TIMESTAMP;
    END IF;
END;
/

-- Trigger pour vérifier les permissions de site lors de la création d'un ticket
CREATE OR REPLACE TRIGGER ticket_site_permission_trigger
BEFORE INSERT ON glpi_tickets
FOR EACH ROW
BEGIN
    IF NOT c##glpi_central.check_ticket_site_permission(:NEW.site_id) THEN
        RAISE_APPLICATION_ERROR(-20007, 'Site non autorisé.');
    END IF;
END;
/


SHOW ERRORS PROCEDURE ticket_permission_trigger;
SHOW ERRORS PROCEDURE ticket_update_permission_trigger;
SHOW ERRORS PROCEDURE computer_permission_trigger;
SHOW ERRORS PROCEDURE printer_permission_trigger;
SHOW ERRORS PROCEDURE prevent_unauthorized_ticket_delete;
SHOW ERRORS PROCEDURE auto_set_ticket_resolution_date;
SHOW ERRORS PROCEDURE ticket_site_permission_trigger;