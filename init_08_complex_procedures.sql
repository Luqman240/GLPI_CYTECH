-- init_08_complex_procedures.sql
-- Création des procédures plus complexes
-- Connexion
-- Connect as SYSDBA
CONNECT system/Luqman123 AS SYSDBA;

-- Grant system privileges
GRANT CREATE USER TO c##glpi_central;
GRANT CREATE SESSION TO c##glpi_central;
GRANT GRANT ANY ROLE TO c##glpi_central;
GRANT ALTER USER TO c##glpi_central;
GRANT DROP USER TO c##glpi_central;

-- Grant privileges on Cergy schema objects
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_cergy.glpi_users TO c##glpi_central;
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_cergy.glpi_tickets TO c##glpi_central;
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_cergy.glpi_tickets_items TO c##glpi_central;
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_cergy.glpi_computers_items TO c##glpi_central;
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_cergy.glpi_printers_items TO c##glpi_central;

-- Grant privileges on Pau schema objects
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_pau.glpi_users TO c##glpi_central;
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_pau.glpi_tickets TO c##glpi_central;
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_pau.glpi_tickets_items TO c##glpi_central;
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_pau.glpi_computers_items TO c##glpi_central;
GRANT INSERT, SELECT, UPDATE, DELETE ON c##glpi_pau.glpi_printers_items TO c##glpi_central;

-- Grant privileges on sequences
GRANT SELECT, ALTER ON c##glpi_cergy.seq_user_id TO c##glpi_central;
GRANT SELECT, ALTER ON c##glpi_cergy.seq_ticket_id TO c##glpi_central;
GRANT SELECT, ALTER ON c##glpi_cergy.seq_ticket_item_id TO c##glpi_central;
GRANT SELECT, ALTER ON c##glpi_cergy.seq_computer_item_id TO c##glpi_central;
GRANT SELECT, ALTER ON c##glpi_cergy.seq_printer_item_id TO c##glpi_central;

GRANT SELECT, ALTER ON c##glpi_pau.seq_user_id TO c##glpi_central;
GRANT SELECT, ALTER ON c##glpi_pau.seq_ticket_id TO c##glpi_central;
GRANT SELECT, ALTER ON c##glpi_pau.seq_ticket_item_id TO c##glpi_central;
GRANT SELECT, ALTER ON c##glpi_pau.seq_computer_item_id TO c##glpi_central;
GRANT SELECT, ALTER ON c##glpi_pau.seq_printer_item_id TO c##glpi_central;


-- Then reconnect as c##glpi_central
CONNECT c##glpi_central/glpi_central

-- Grant execute privileges on utility functions

GRANT EXECUTE ON current_user_role TO c##glpi_central;
GRANT EXECUTE ON current_user_site_id TO c##glpi_central;
GRANT EXECUTE ON current_user_id TO c##glpi_central;

-- Procédure pour créer un utilisateur dans le site approprié
CREATE OR REPLACE PROCEDURE create_utilisateur(
    p_nom IN VARCHAR2,
    p_email IN VARCHAR2,
    p_mot_de_passe IN VARCHAR2,
    p_role IN VARCHAR2,
    p_client_id IN NUMBER,
    p_site_id IN NUMBER,
    p_classe IN VARCHAR2 DEFAULT NULL
) IS
    v_user_role VARCHAR2(20);
BEGIN
    -- Vérifier les permissions
    BEGIN
        current_user_role(v_user_role);
        IF v_user_role != 'Admin' AND v_user_role != 'Technicien' THEN
            RAISE_APPLICATION_ERROR(-20002, 'Permission refusée: seuls les administrateurs et techniciens peuvent créer des utilisateurs');
        END IF;
    EXCEPTION 
        WHEN OTHERS THEN
            IF SQLCODE = -20001 THEN -- Utilisateur non trouvé
                NULL; -- Permettre la création du premier utilisateur
            ELSE
                RAISE;
            END IF;
    END;

    -- Insérer dans le site approprié
    IF p_site_id = 1 THEN
        -- Insérer dans Cergy
        INSERT INTO c##glpi_cergy.glpi_users (
            id, nom, email, mot_de_passe, role, client_id, site_id, classe
        ) VALUES (
            c##glpi_cergy.seq_user_id.NEXTVAL, p_nom, p_email, p_mot_de_passe, 
            p_role, p_client_id, p_site_id, p_classe
        );
    ELSIF p_site_id = 2 THEN
        -- Insérer dans Pau
        INSERT INTO c##glpi_pau.glpi_users (
            id, nom, email, mot_de_passe, role, client_id, site_id, classe
        ) VALUES (
            c##glpi_pau.seq_user_id.NEXTVAL, p_nom, p_email, p_mot_de_passe, 
            p_role, p_client_id, p_site_id, p_classe
        );
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Site invalide. Utilisez 1 pour Cergy ou 2 pour Pau.');
    END IF;
    
    -- Créer l'utilisateur de base de données (utiliser c## pour les utilisateurs communs)
    DECLARE
        v_username VARCHAR2(255) := 'c##' || REPLACE(p_email, '@', '_');
    BEGIN
        EXECUTE IMMEDIATE 'CREATE USER ' || v_username || ' IDENTIFIED BY "' || p_mot_de_passe || '"';
        
        -- Attribuer le rôle approprié
        IF p_role = 'Admin' THEN
            EXECUTE IMMEDIATE 'GRANT c##glpi_admin_role TO ' || v_username;
        ELSIF p_role = 'Technicien' THEN
            EXECUTE IMMEDIATE 'GRANT c##glpi_technicien_role TO ' || v_username;
        ELSIF p_role = 'Enseignant' THEN
            EXECUTE IMMEDIATE 'GRANT c##glpi_enseignant_role TO ' || v_username;
        ELSIF p_role = 'Étudiant' THEN
            EXECUTE IMMEDIATE 'GRANT c##glpi_etudiant_role TO ' || v_username;
        END IF;
        
        -- Accorder les privilèges nécessaires
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_username;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur lors de la création de l''utilisateur en base de données: ' || SQLERRM);
            RAISE;
    END;
END create_utilisateur;
/

-- Procédure pour créer un ticket avec équipements
CREATE OR REPLACE PROCEDURE create_ticket_with_equipements(
    p_utilisateur_id IN NUMBER,
    p_client_id IN NUMBER,
    p_site_id IN NUMBER,
    p_description IN VARCHAR2,
    p_statut IN VARCHAR2 DEFAULT 'Ouvert',
    p_computer_item_id IN NUMBER DEFAULT NULL,
    p_printer_item_id IN NUMBER DEFAULT NULL
) IS
    v_ticket_id NUMBER;
    v_user_site_id NUMBER;
BEGIN
    -- Vérifier que l'utilisateur appartient au site spécifié
    current_user_site_id(v_user_site_id);
    IF p_site_id != v_user_site_id THEN
        RAISE_APPLICATION_ERROR(-20005, 'Permission refusée : Vous ne pouvez pas créer un ticket pour un autre site.');
    END IF;
    
    -- Insérer le ticket dans le site approprié
    IF p_site_id = 1 THEN
        -- Cergy
        INSERT INTO c##glpi_cergy.glpi_tickets (
            id, utilisateur_id, client_id, site_id, description, statut
        ) VALUES (
            c##glpi_cergy.seq_ticket_id.NEXTVAL, p_utilisateur_id, p_client_id, 
            p_site_id, p_description, p_statut
        ) RETURNING id INTO v_ticket_id;
        
        -- Associer les équipements si fournis
        IF p_computer_item_id IS NOT NULL THEN
            INSERT INTO c##glpi_cergy.glpi_tickets_items (
                id, ticket_id, computer_item_id, printer_item_id, site_id
            ) VALUES (
                c##glpi_cergy.seq_ticket_item_id.NEXTVAL, v_ticket_id, 
                p_computer_item_id, NULL, p_site_id
            );
        END IF;
        
        IF p_printer_item_id IS NOT NULL THEN
            INSERT INTO c##glpi_cergy.glpi_tickets_items (
                id, ticket_id, computer_item_id, printer_item_id, site_id
            ) VALUES (
                c##glpi_cergy.seq_ticket_item_id.NEXTVAL, v_ticket_id, 
                NULL, p_printer_item_id, p_site_id
            );
        END IF;
        
    ELSIF p_site_id = 2 THEN
        -- Pau
        INSERT INTO c##glpi_pau.glpi_tickets (
            id, utilisateur_id, client_id, site_id, description, statut
        ) VALUES (
            c##glpi_pau.seq_ticket_id.NEXTVAL, p_utilisateur_id, p_client_id, 
            p_site_id, p_description, p_statut
        ) RETURNING id INTO v_ticket_id;
        
        -- Associer les équipements si fournis
        IF p_computer_item_id IS NOT NULL THEN
            INSERT INTO c##glpi_pau.glpi_tickets_items (
                id, ticket_id, computer_item_id, printer_item_id, site_id
            ) VALUES (
                c##glpi_pau.seq_ticket_item_id.NEXTVAL, v_ticket_id, 
                p_computer_item_id, NULL, p_site_id
            );
        END IF;
        
        IF p_printer_item_id IS NOT NULL THEN
            INSERT INTO c##glpi_pau.glpi_tickets_items (
                id, ticket_id, computer_item_id, printer_item_id, site_id
            ) VALUES (
                c##glpi_pau.seq_ticket_item_id.NEXTVAL, v_ticket_id, 
                NULL, p_printer_item_id, p_site_id
            );
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20006, 'Site invalide. Utilisez 1 pour Cergy ou 2 pour Pau.');
    END IF;
END create_ticket_with_equipements;
/

CREATE OR REPLACE PROCEDURE update_ticket(
    p_ticket_id IN NUMBER,
    p_description IN VARCHAR2,
    p_statut IN VARCHAR2,
    p_date_resolution IN TIMESTAMP DEFAULT NULL
) IS
    v_ticket_site_id NUMBER;
    v_ticket_utilisateur_id NUMBER;
    v_user_site_id NUMBER;
    v_user_id NUMBER;
    v_user_role VARCHAR2(20);
    v_ticket_exists NUMBER;
BEGIN
    -- Check in Cergy first
    SELECT COUNT(*), MAX(site_id), MAX(utilisateur_id) 
    INTO v_ticket_exists, v_ticket_site_id, v_ticket_utilisateur_id
    FROM c##glpi_cergy.glpi_tickets
    WHERE id = p_ticket_id;
    
    -- If not found in Cergy, check Pau
    IF v_ticket_exists = 0 THEN
        SELECT COUNT(*), MAX(site_id), MAX(utilisateur_id)
        INTO v_ticket_exists, v_ticket_site_id, v_ticket_utilisateur_id
        FROM c##glpi_pau.glpi_tickets
        WHERE id = p_ticket_id;
    END IF;
    
    IF v_ticket_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Le ticket spécifié n''existe pas.');
    END IF;
    
    -- Get current user info
    current_user_site_id(v_user_site_id);
    current_user_id(v_user_id);
    current_user_role(v_user_role);
    
    -- Check permissions
    IF v_user_role != 'Admin' AND v_user_role != 'Technicien' AND v_ticket_utilisateur_id != v_user_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Permission refusée: vous ne pouvez modifier que vos propres tickets.');
    END IF;
    
    -- Update the ticket in the appropriate schema
    IF v_ticket_site_id = 1 THEN
        UPDATE c##glpi_cergy.glpi_tickets
        SET description = p_description,
            statut = p_statut,
            date_resolution = CASE 
                                WHEN p_statut IN ('Resolu', 'Ferme') 
                                    AND date_resolution IS NULL 
                                THEN CURRENT_TIMESTAMP 
                                ELSE p_date_resolution 
                              END
        WHERE id = p_ticket_id;
    ELSIF v_ticket_site_id = 2 THEN
        UPDATE c##glpi_pau.glpi_tickets
        SET description = p_description,
            statut = p_statut,
            date_resolution = CASE 
                                WHEN p_statut IN ('Resolu', 'Ferme') 
                                    AND date_resolution IS NULL 
                                THEN CURRENT_TIMESTAMP 
                                ELSE p_date_resolution 
                              END
        WHERE id = p_ticket_id;
    END IF;
END update_ticket;
/

-- Procédure pour attribuer un équipement à un utilisateur
CREATE OR REPLACE PROCEDURE assign_equipment_to_user(
    p_user_id IN NUMBER,
    p_computer_id IN NUMBER DEFAULT NULL,
    p_printer_id IN NUMBER DEFAULT NULL,
    p_client_id IN NUMBER,
    p_site_id IN NUMBER
) IS
    v_user_site_id NUMBER;
    v_user_role VARCHAR2(20);
BEGIN
    -- Vérifier les permissions
    current_user_site_id(v_user_site_id);
    current_user_role(v_user_role);
    
    IF v_user_role != 'Admin' AND v_user_role != 'Technicien' AND v_user_site_id != p_site_id THEN
        RAISE_APPLICATION_ERROR(-20009, 'Permission refusée: vous ne pouvez pas attribuer d''équipements sur un autre site.');
    END IF;
    
    -- Attribuer équipement dans le site approprié
    IF p_site_id = 1 THEN
        -- Cergy
        IF p_computer_id IS NOT NULL THEN
            INSERT INTO c##glpi_cergy.glpi_computers_items (
                id, reference_computer_id, client_id, site_id, utilisateur_id, date_d_acquisition
            ) VALUES (
                c##glpi_cergy.seq_computer_item_id.NEXTVAL, p_computer_id, p_client_id,
                p_site_id, p_user_id, CURRENT_DATE
            );
        END IF;
        
        IF p_printer_id IS NOT NULL THEN
            INSERT INTO c##glpi_cergy.glpi_printers_items (
                id, reference_printer_id, client_id, site_id, utilisateur_id, date_d_acquisition
            ) VALUES (
                c##glpi_cergy.seq_printer_item_id.NEXTVAL, p_printer_id, p_client_id,
                p_site_id, p_user_id, CURRENT_DATE
            );
        END IF;
    ELSIF p_site_id = 2 THEN
        -- Pau
        IF p_computer_id IS NOT NULL THEN
            INSERT INTO c##glpi_pau.glpi_computers_items (
                id, reference_computer_id, client_id, site_id, utilisateur_id, date_d_acquisition
            ) VALUES (
                c##glpi_pau.seq_computer_item_id.NEXTVAL, p_computer_id, p_client_id,
                p_site_id, p_user_id, CURRENT_DATE
            );
        END IF;
        
        IF p_printer_id IS NOT NULL THEN
            INSERT INTO c##glpi_pau.glpi_printers_items (
                id, reference_printer_id, client_id, site_id, utilisateur_id, date_d_acquisition
            ) VALUES (
                c##glpi_pau.seq_printer_item_id.NEXTVAL, p_printer_id, p_client_id,
                p_site_id, p_user_id, CURRENT_DATE
            );
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20010, 'Site invalide. Utilisez 1 pour Cergy ou 2 pour Pau.');
    END IF;
END assign_equipment_to_user;
/

SHOW ERRORS PROCEDURE create_utilisateur;
SHOW ERRORS PROCEDURE create_ticket_with_equipements;
SHOW ERRORS PROCEDURE update_ticket;
SHOW ERRORS PROCEDURE assign_equipment_to_user;

