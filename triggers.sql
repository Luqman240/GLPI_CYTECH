-- Function to check ticket creation permissions
CREATE OR REPLACE FUNCTION check_ticket_permissions(
    p_client_id NUMBER
) RETURN BOOLEAN AS
    v_user_client_id NUMBER;  -- Variable pour stocker l'ID client de l'utilisateur
BEGIN
    -- Appel de la procédure pour obtenir l'ID client de l'utilisateur connecté
    current_user_client_id(v_user_client_id);
    
    -- Vérification si l'utilisateur appartient au même client
    IF p_client_id = v_user_client_id THEN
        RETURN TRUE;  -- L'utilisateur peut créer un ticket pour son propre client
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Permission refusée : Vous ne pouvez pas créer un ticket pour un autre client.');
        RETURN FALSE;  -- Cette ligne ne sera jamais exécutée en raison de l'exception
    END IF;
END check_ticket_permissions;
/



-- Trigger for ticket permission check on insert
CREATE OR REPLACE TRIGGER ticket_permission_trigger
BEFORE INSERT ON glpi_tickets
FOR EACH ROW
DECLARE
    v_allowed BOOLEAN;
BEGIN
    v_allowed := check_ticket_permissions(:NEW.client_id);
    -- No need to assign :NEW as the function will either allow the operation or raise an exception
END;
/

CREATE OR REPLACE FUNCTION check_ticket_update_permissions(
    p_utilisateur_id NUMBER,
    p_client_id NUMBER
) RETURN BOOLEAN AS
    v_user_id NUMBER;  -- Variable pour stocker l'ID utilisateur
    v_user_role VARCHAR2(40);  -- Variable pour stocker le rôle utilisateur
    v_user_client_id NUMBER;
BEGIN
    -- Appel de la procédure pour obtenir l'ID de l'utilisateur connecté
    current_user_id(v_user_id);
    
    -- Appel de la procédure pour obtenir le rôle de l'utilisateur connecté
    current_user_role(v_user_role);
    current_user_client_id(v_user_client_id);
    -- Vérifier si l'utilisateur est soit l'auteur du ticket, soit un technicien du même site
    IF (p_utilisateur_id = v_user_id OR v_user_role = 'Technicien') AND
       (p_client_id = v_user_client_id) THEN
        -- Modification autorisée
        RETURN TRUE;
    ELSE
        -- Sinon, l'utilisateur n'a pas la permission
        RAISE_APPLICATION_ERROR(-20002, 'Permission refusée : Vous ne pouvez pas modifier ce ticket.');
        RETURN FALSE; -- Cette ligne ne sera jamais exécutée en raison de l'exception
    END IF;
END check_ticket_update_permissions;
/



-- Trigger for ticket update permission check
CREATE OR REPLACE TRIGGER ticket_update_permission_trigger
BEFORE UPDATE ON glpi_tickets
FOR EACH ROW
DECLARE
    v_allowed BOOLEAN;
BEGIN
    v_allowed := check_ticket_update_permissions(:NEW.utilisateur_id, :NEW.client_id);
    -- No need to assign :NEW as the function will either allow the operation or raise an exception
END;
/

-- Function to check computer equipment permissions
CREATE OR REPLACE FUNCTION check_computer_permission(
    p_utilisateur_id NUMBER,
    p_client_id NUMBER
) RETURN BOOLEAN AS
    v_user_id NUMBER;  -- Variable pour stocker l'ID utilisateur
    v_user_client_id NUMBER;
BEGIN
	current_user_id(v_user_id);
    current_user_client_id(v_user_client_id);
    -- Check if the user is associated with this equipment and the equipment belongs to the same site
    IF (p_utilisateur_id = v_user_id AND p_client_id = v_user_client_id) THEN
        -- User can add or modify the equipment
        RETURN TRUE;
    ELSE
        -- Otherwise, the user doesn't have permission
        RAISE_APPLICATION_ERROR(-20003, 'Permission refusée : Vous ne pouvez pas gérer cet équipement.');
        RETURN FALSE; -- Will never execute due to exception
    END IF;
END;
/

-- Trigger for computer equipment permission check
CREATE OR REPLACE TRIGGER computer_permission_trigger
BEFORE INSERT OR UPDATE ON glpi_computers_items
FOR EACH ROW
DECLARE
    v_allowed BOOLEAN;
BEGIN
    v_allowed := check_computer_permission(:NEW.utilisateur_id, :NEW.client_id);
    -- No need to assign :NEW as the function will either allow the operation or raise an exception
END;
/

-- Function to check printer permissions
CREATE OR REPLACE FUNCTION check_printer_permission(
    p_utilisateur_id NUMBER,
    p_client_id NUMBER
) RETURN BOOLEAN AS
    v_user_id NUMBER;  -- Variable pour stocker l'ID utilisateur
    v_user_client_id NUMBER;
BEGIN
	current_user_id(v_user_id);
	current_user_client_id(v_user_client_id);
    -- Check if the user is associated with this equipment and the equipment belongs to the same site
    IF (p_utilisateur_id = v_user_id AND p_client_id = v_user_client_id) THEN        -- User can add or modify the printer
        RETURN TRUE;
    ELSE
        -- Otherwise, the user doesn't have permission
        RAISE_APPLICATION_ERROR(-20004, 'Permission refusée : Vous ne pouvez pas gérer cette imprimante.');
        RETURN FALSE; -- Will never execute due to exception
    END IF;
END;
/

-- Trigger for printer permission check
CREATE OR REPLACE TRIGGER printer_permission_trigger
BEFORE INSERT OR UPDATE ON glpi_printers_items
FOR EACH ROW
DECLARE
    v_allowed BOOLEAN;
BEGIN
    v_allowed := check_printer_permission(:NEW.utilisateur_id, :NEW.client_id);
    -- No need to assign :NEW as the function will either allow the operation or raise an exception
END;
/