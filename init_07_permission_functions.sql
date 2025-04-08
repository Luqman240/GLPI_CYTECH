-- init_07_permission_functions.sql
-- Création des fonctions pour vérification des permissions

CONNECT c##glpi_central/glpi_central

-- Fonction pour vérifier les permissions de tickets
CREATE OR REPLACE FUNCTION check_ticket_permissions(
    p_client_id NUMBER
) RETURN BOOLEAN AS
    v_user_client_id NUMBER;
BEGIN
    current_user_client_id(v_user_client_id);
    
    IF p_client_id = v_user_client_id THEN
        RETURN TRUE;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Permission refusée : Vous ne pouvez pas créer un ticket pour un autre client.');
        RETURN FALSE;
    END IF;
END check_ticket_permissions;
/

-- Fonction pour vérifier les permissions de mise à jour de tickets
CREATE OR REPLACE FUNCTION check_ticket_update_permissions(
    p_utilisateur_id NUMBER,
    p_client_id NUMBER
) RETURN BOOLEAN AS
    v_user_id NUMBER;
    v_user_role VARCHAR2(40);
    v_user_client_id NUMBER;
BEGIN
    current_user_id(v_user_id);
    current_user_role(v_user_role);
    current_user_client_id(v_user_client_id);
    
    IF (p_utilisateur_id = v_user_id OR v_user_role = 'Technicien') AND
       (p_client_id = v_user_client_id) THEN
        RETURN TRUE;
    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Permission refusée : Vous ne pouvez pas modifier ce ticket.');
        RETURN FALSE;
    END IF;
END check_ticket_update_permissions;
/

-- Fonction pour vérifier les permissions pour équipements informatiques
CREATE OR REPLACE FUNCTION check_computer_permission(
    p_utilisateur_id NUMBER,
    p_client_id NUMBER
) RETURN BOOLEAN AS
    v_user_id NUMBER;
    v_user_client_id NUMBER;
BEGIN
    current_user_id(v_user_id);
    current_user_client_id(v_user_client_id);
    
    IF (p_utilisateur_id = v_user_id AND p_client_id = v_user_client_id) THEN
        RETURN TRUE;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Permission refusée : Vous ne pouvez pas gérer cet équipement.');
        RETURN FALSE;
    END IF;
END check_computer_permission;
/

-- Fonction pour vérifier les permissions pour imprimantes
CREATE OR REPLACE FUNCTION check_printer_permission(
    p_utilisateur_id NUMBER,
    p_client_id NUMBER
) RETURN BOOLEAN AS
    v_user_id NUMBER;
    v_user_client_id NUMBER;
BEGIN
    current_user_id(v_user_id);
    current_user_client_id(v_user_client_id);
    
    IF (p_utilisateur_id = v_user_id AND p_client_id = v_user_client_id) THEN
        RETURN TRUE;
    ELSE
        RAISE_APPLICATION_ERROR(-20004, 'Permission refusée : Vous ne pouvez pas gérer cette imprimante.');
        RETURN FALSE;
    END IF;
END check_printer_permission;
/

-- Fonction pour vérifier les permissions par site
CREATE OR REPLACE FUNCTION check_ticket_site_permission(
    p_site_id NUMBER
) RETURN BOOLEAN AS
    v_user_site_id NUMBER;
BEGIN
    current_user_site_id(v_user_site_id);
    
    IF p_site_id = v_user_site_id THEN
        RETURN TRUE;
    ELSE
        RAISE_APPLICATION_ERROR(-20006, 'Permission refusée : vous ne pouvez créer un ticket que pour votre propre site.');
        RETURN FALSE;
    END IF;
END check_ticket_site_permission;
/