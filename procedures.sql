CREATE OR REPLACE PROCEDURE current_user_client_id(
    p_user_client_id OUT NUMBER  -- Type VARCHAR2 pour les sorties de type chaîne
) IS
BEGIN
    -- Récupère le rôle de l'utilisateur connecté en fonction de son email
    SELECT client_id INTO p_user_client_id
    FROM glpi_users
    WHERE email = USER;  -- Utilise USER pour obtenir l'utilisateur connecté dans Oracle
    
    -- Vérifie si le rôle existe
    IF p_user_client_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Utilisateur non trouvé');
    END IF;
END current_user_client_id;
/

CREATE OR REPLACE PROCEDURE current_user_id(
    p_user_id OUT NUMBER  -- Type VARCHAR2 pour les sorties de type chaîne
) IS
BEGIN
    -- Récupère le rôle de l'utilisateur connecté en fonction de son email
    SELECT id INTO p_user_id
    FROM glpi_users
    WHERE email = USER;  -- Utilise USER pour obtenir l'utilisateur connecté dans Oracle
    
    -- Vérifie si le rôle existe
    IF p_user_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Utilisateur non trouvé');
    END IF;
END current_user_id;
/

CREATE OR REPLACE PROCEDURE current_user_role(
    p_user_role OUT VARCHAR2  -- Type VARCHAR2 pour les sorties de type chaîne
) IS
BEGIN
    -- Récupère le rôle de l'utilisateur connecté en fonction de son email
    SELECT role INTO p_user_role
    FROM glpi_users
    WHERE email = USER;  -- Utilise USER pour obtenir l'utilisateur connecté dans Oracle
    
    -- Vérifie si le rôle existe
    IF p_user_role IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Utilisateur non trouvé');
    END IF;
END current_user_role;
/

CREATE OR REPLACE PROCEDURE current_user_email(
    p_email OUT VARCHAR2
) IS
BEGIN
    -- Récupère l'email de l'utilisateur connecté à partir de la table glpi_users
    SELECT email INTO p_email
    FROM glpi_users
    WHERE email = USER;  -- Utilise CURRENT_USER pour récupérer l'utilisateur de la base de données
    
    -- Si aucun utilisateur n'est trouvé, on génère une exception
    IF p_email IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Utilisateur non trouvé dans la table glpi_users');
    END IF;
END current_user_email;

/

CREATE OR REPLACE PROCEDURE create_utilisateur(
    p_nom IN VARCHAR2,
    p_email IN VARCHAR2,
    p_mot_de_passe IN VARCHAR2,
    p_role IN VARCHAR2,  -- Utilise un type simple de texte pour le rôle
    p_client_id IN NUMBER,  -- En Oracle, on utilise le type NUMBER pour les entiers
    p_classe IN VARCHAR2 DEFAULT NULL
) IS
BEGIN
    -- Vérifier si l'utilisateur connecté a la permission de créer un utilisateur pour ce client
    -- Remplacer current_user_client_id() et current_user_role() par des fonctions Oracle existantes ou des variables de gestion
    -- Exemple (à adapter selon ta logique) :
    -- IF p_client_id <> get_current_user_client_id() AND get_current_user_role() <> 'Admin' THEN
    -- Pour l'instant, utilisation de USER pour l'utilisateur connecté
    IF p_client_id <> 1 AND USER <> 'ADMIN' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Permission refusée : Vous ne pouvez pas créer un utilisateur pour ce client.');
    END IF;

    -- Créer un utilisateur dans la table glpi_users
    INSERT INTO glpi_users (nom, email, mot_de_passe, role, client_id, classe)
    VALUES (p_nom, p_email, p_mot_de_passe, p_role, p_client_id, p_classe);
    
    -- Créer l'utilisateur dans la base de données Oracle avec les privilèges associés
    BEGIN
        IF p_role = 'Admin' THEN
            EXECUTE IMMEDIATE 'CREATE USER "' || p_email || '" IDENTIFIED BY "' || p_mot_de_passe || '"';
            EXECUTE IMMEDIATE 'GRANT DBA TO "' || p_email || '"';  -- Attribuer le rôle Admin (DBA) à l'utilisateur
        ELSIF p_role = 'Technicien' THEN
            EXECUTE IMMEDIATE 'CREATE USER "' || p_email || '" IDENTIFIED BY "' || p_mot_de_passe || '"';
            EXECUTE IMMEDIATE 'GRANT technicien_role TO "' || p_email || '"'; -- Associer un rôle spécifique pour technicien
        ELSIF p_role = 'Enseignant' THEN
            EXECUTE IMMEDIATE 'CREATE USER "' || p_email || '" IDENTIFIED BY "' || p_mot_de_passe || '"';
            EXECUTE IMMEDIATE 'GRANT enseignant_role TO "' || p_email || '"'; -- Associer un rôle spécifique pour enseignant
        ELSIF p_role = 'Étudiant' THEN
            EXECUTE IMMEDIATE 'CREATE USER "' || p_email || '" IDENTIFIED BY "' || p_mot_de_passe || '"';
            EXECUTE IMMEDIATE 'GRANT etudiant_role TO "' || p_email || '"'; -- Associer un rôle spécifique pour étudiant
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            -- Capture l'erreur et l'affiche
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
            RAISE;
    END;
END create_utilisateur;
/


CREATE OR REPLACE PROCEDURE update_ticket(
    p_ticket_id IN NUMBER,
    p_description IN VARCHAR2,  -- Remplacer TEXT par VARCHAR2
    p_statut IN VARCHAR2,
    p_date_resolution IN TIMESTAMP DEFAULT NULL
) IS
    v_ticket_count NUMBER;
    v_user_id NUMBER;
    v_is_technicien NUMBER; -- Utilisation d'un type numérique pour la vérification du rôle
BEGIN
    -- Vérifier si le ticket est déjà résolu
    SELECT COUNT(1)
    INTO v_ticket_count
    FROM glpi_tickets
    WHERE id = p_ticket_id AND statut = 'Resolu';

    IF v_ticket_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Le ticket est déjà résolu');
    END IF;
    
    -- Vérifier que l'utilisateur connecté a les droits pour modifier ce ticket
    SELECT utilisateur_id
    INTO v_user_id
    FROM glpi_tickets
    WHERE id = p_ticket_id;

    IF v_user_id != USER THEN
        -- Vérifier si l'utilisateur est un Technicien
        SELECT COUNT(1)
        INTO v_is_technicien
        FROM USER_ROLE_PRIVS
        WHERE GRANTED_ROLE = 'Technicien';

        IF v_is_technicien = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Permission refusée : Vous ne pouvez pas modifier ce ticket.');
        END IF;
    END IF;

    -- Mise à jour du ticket
    UPDATE glpi_tickets
    SET description = p_description,
        statut = p_statut,
        date_resolution = p_date_resolution
    WHERE id = p_ticket_id;

    COMMIT;  -- Commiter les changements
EXCEPTION
    WHEN OTHERS THEN
        -- Capturer l'erreur et afficher un message
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
        ROLLBACK;  -- Rollback en cas d'erreur
END update_ticket;
/

CREATE OR REPLACE PROCEDURE create_ticket_with_equipements(
    p_utilisateur_id IN INT,
    p_client_id IN INT,
    p_description IN VARCHAR2,
    p_statut IN VARCHAR2,
    p_computer_item_id IN INT DEFAULT NULL,
    p_printer_item_id IN INT DEFAULT NULL
) IS
    v_ticket_id INT;
    v_user_client_id VARCHAR2(255);  -- Variable pour stocker l'ID client de l'utilisateur connecté
BEGIN
    -- Récupérer l'ID client de l'utilisateur connecté
    current_user_client_id(v_user_client_id);  -- Appel de la procédure avec un paramètre de sortie
    
    -- Vérifier que l'utilisateur connecté peut créer un ticket pour ce client
    IF p_client_id <> v_user_client_id THEN
        RAISE_APPLICATION_ERROR(-20005, 'Permission refusée : Vous ne pouvez pas créer un ticket pour ce client.');
    END IF;
    
    -- Créer le ticket
    INSERT INTO glpi_tickets (utilisateur_id, client_id, description, statut)
    VALUES (p_utilisateur_id, p_client_id, p_description, p_statut)
    RETURNING id INTO v_ticket_id;
    
    -- Associer les équipements si fournis
    IF p_computer_item_id IS NOT NULL THEN
        INSERT INTO glpi_tickets_items (ticket_id, computer_item_id)
        VALUES (v_ticket_id, p_computer_item_id);
    END IF;
    
    IF p_printer_item_id IS NOT NULL THEN
        INSERT INTO glpi_tickets_items (ticket_id, printer_item_id)
        VALUES (v_ticket_id, p_printer_item_id);
    END IF;
END create_ticket_with_equipements;
/
