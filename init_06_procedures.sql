-- init_06_procedures.sql
-- Création des procédures stockées principales

CONNECT c##glpi_central/glpi_central

-- Procédure pour obtenir l'ID du client de l'utilisateur actuel
CREATE OR REPLACE PROCEDURE current_user_client_id(
    p_user_client_id OUT NUMBER
) IS
    v_email VARCHAR2(255);
BEGIN
    -- Récupérer l'email de l'utilisateur connecté
    v_email := USER;
    
    -- Chercher d'abord dans le site de Cergy
    BEGIN
        SELECT client_id INTO p_user_client_id
        FROM cergy_users
        WHERE email = v_email;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Continue to check Pau site
    END;
    
    -- Chercher ensuite dans le site de Pau
    BEGIN
        SELECT client_id INTO p_user_client_id
        FROM pau_users
        WHERE email = v_email;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Utilisateur non trouvé');
    END;
END current_user_client_id;
/

-- Procédure pour obtenir l'ID de l'utilisateur actuel
CREATE OR REPLACE PROCEDURE current_user_id(
    p_user_id OUT NUMBER
) IS
    v_email VARCHAR2(255);
BEGIN
    -- Récupérer l'email de l'utilisateur connecté
    v_email := USER;
    
    -- Chercher d'abord dans le site de Cergy
    BEGIN
        SELECT id INTO p_user_id
        FROM cergy_users
        WHERE email = v_email;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Continue to check Pau site
    END;
    
    -- Chercher ensuite dans le site de Pau
    BEGIN
        SELECT id INTO p_user_id
        FROM pau_users
        WHERE email = v_email;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Utilisateur non trouvé');
    END;
END current_user_id;
/

-- Procédure pour obtenir le site de l'utilisateur actuel
CREATE OR REPLACE PROCEDURE current_user_site_id(
    p_user_site_id OUT NUMBER
) IS
    v_email VARCHAR2(255);
BEGIN
    -- Récupérer l'email de l'utilisateur connecté
    v_email := USER;
    
    -- Chercher d'abord dans le site de Cergy
    BEGIN
        SELECT site_id INTO p_user_site_id
        FROM cergy_users
        WHERE email = v_email;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Continue to check Pau site
    END;
    
    -- Chercher ensuite dans le site de Pau
    BEGIN
        SELECT site_id INTO p_user_site_id
        FROM pau_users
        WHERE email = v_email;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Utilisateur non trouvé');
    END;
END current_user_site_id;
/

-- Procédure pour obtenir le rôle de l'utilisateur actuel
CREATE OR REPLACE PROCEDURE current_user_role(
    p_user_role OUT VARCHAR2
) IS
    v_email VARCHAR2(255);
BEGIN
    -- Récupérer l'email de l'utilisateur connecté
    v_email := USER;
    
    -- Chercher d'abord dans le site de Cergy
    BEGIN
        SELECT role INTO p_user_role
        FROM cergy_users
        WHERE email = v_email;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Continue to check Pau site
    END;
    
    -- Chercher ensuite dans le site de Pau
    BEGIN
        SELECT role INTO p_user_role
        FROM pau_users
        WHERE email = v_email;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Utilisateur non trouvé');
    END;
END current_user_role;
/

-- Procédure pour obtenir l'email de l'utilisateur actuel
CREATE OR REPLACE PROCEDURE current_user_email(
    p_email OUT VARCHAR2
) IS
BEGIN
    -- Dans ce cas, l'email est simplement le nom d'utilisateur
    p_email := USER;
    
    -- Vérifier que l'utilisateur existe bien dans l'un des sites
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM global_users
        WHERE email = p_email;
        
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Utilisateur non trouvé dans la table glpi_users');
        END IF;
    END;
END current_user_email;
/