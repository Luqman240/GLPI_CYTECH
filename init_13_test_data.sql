-- init_13_test_data.sql
-- Génération d'un jeu de test conséquent

-- Grant access to the view
-- Connect as a privileged user (like SYS or SYSTEM)
CONNECT system/Luqman123 AS SYSDBA

-- Grant SELECT and INSERT privileges on the required tables
GRANT SELECT, INSERT ON c##glpi_cergy.glpi_computers_items TO c##glpi_central;
GRANT SELECT, INSERT ON c##glpi_cergy.glpi_printers_items TO c##glpi_central;
GRANT SELECT, INSERT ON c##glpi_cergy.glpi_tickets TO c##glpi_central;
GRANT SELECT, INSERT ON c##glpi_cergy.glpi_tickets_items TO c##glpi_central;
GRANT SELECT, INSERT ON c##glpi_cergy.glpi_tickets_issues TO c##glpi_central;

GRANT SELECT, INSERT ON c##glpi_pau.glpi_computers_items TO c##glpi_central;
GRANT SELECT, INSERT ON c##glpi_pau.glpi_printers_items TO c##glpi_central;
GRANT SELECT, INSERT ON c##glpi_pau.glpi_tickets TO c##glpi_central;
GRANT SELECT, INSERT ON c##glpi_pau.glpi_tickets_items TO c##glpi_central;
GRANT SELECT, INSERT ON c##glpi_pau.glpi_tickets_issues TO c##glpi_central;

-- Also grant sequence privileges if needed
GRANT SELECT ON c##glpi_cergy.seq_ticket_id TO c##glpi_central;
GRANT SELECT ON c##glpi_cergy.seq_ticket_item_id TO c##glpi_central;
GRANT SELECT ON c##glpi_cergy.seq_ticket_issue_id TO c##glpi_central;

GRANT SELECT ON c##glpi_pau.seq_ticket_id TO c##glpi_central;
GRANT SELECT ON c##glpi_pau.seq_ticket_item_id TO c##glpi_central;
GRANT SELECT ON c##glpi_pau.seq_ticket_issue_id TO c##glpi_central;
-- Supprimez les données existantes dans l'ordre inverse des dépendances
-- D'abord les tables enfants
DELETE FROM c##glpi_cergy.glpi_tickets_issues;
DELETE FROM c##glpi_pau.glpi_tickets_issues;
DELETE FROM c##glpi_cergy.glpi_tickets_items;
DELETE FROM c##glpi_pau.glpi_tickets_items;
DELETE FROM c##glpi_cergy.glpi_tickets;
DELETE FROM c##glpi_pau.glpi_tickets;
DELETE FROM c##glpi_cergy.glpi_computers_items;
DELETE FROM c##glpi_pau.glpi_computers_items;
DELETE FROM c##glpi_cergy.glpi_printers_items;
DELETE FROM c##glpi_pau.glpi_printers_items;
DELETE FROM c##glpi_cergy.glpi_users;
DELETE FROM c##glpi_pau.glpi_users;

-- Puis les tables de référence si nécessaire
-- DELETE FROM c##glpi_central.glpi_printers;
-- DELETE FROM c##glpi_central.glpi_computers;
-- DELETE FROM c##glpi_central.glpi_sites;
-- DELETE FROM c##glpi_central.glpi_clients;

COMMIT;


-- Se connecter au schéma central
CONNECT c##glpi_central/glpi_central

-- Désactiver les triggers sur les tables du schéma central
ALTER TABLE glpi_clients DISABLE ALL TRIGGERS;
ALTER TABLE glpi_sites DISABLE ALL TRIGGERS;
ALTER TABLE glpi_computers DISABLE ALL TRIGGERS;
ALTER TABLE glpi_printers DISABLE ALL TRIGGERS;

-- Se connecter au schéma Cergy
CONNECT c##glpi_cergy/glpi_cergy

-- Désactiver les triggers sur les tables du site de Cergy
ALTER TABLE glpi_users DISABLE ALL TRIGGERS;
ALTER TABLE glpi_computers_items DISABLE ALL TRIGGERS;
ALTER TABLE glpi_printers_items DISABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets DISABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets_items DISABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets_issues DISABLE ALL TRIGGERS;

-- Se connecter au schéma Pau
CONNECT c##glpi_pau/glpi_pau

-- Désactiver les triggers sur les tables du site de Pau
ALTER TABLE glpi_users DISABLE ALL TRIGGERS;
ALTER TABLE glpi_computers_items DISABLE ALL TRIGGERS;
ALTER TABLE glpi_printers_items DISABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets DISABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets_items DISABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets_issues DISABLE ALL TRIGGERS;

CONNECT c##glpi_central/glpi_central

-- Procédure pour générer des utilisateurs de test
CREATE OR REPLACE PROCEDURE generate_test_users(
    p_site_id IN NUMBER,
    p_count IN NUMBER
) IS
    v_role VARCHAR2(20);
    v_site VARCHAR2(10);
    v_nom VARCHAR2(50);
    v_prenom VARCHAR2(50);
    v_email VARCHAR2(100);
    v_password VARCHAR2(20);
    v_classe VARCHAR2(20);
BEGIN
    -- Déterminer le site
    IF p_site_id = 1 THEN
        v_site := 'Cergy';
    ELSE
        v_site := 'Pau';
    END IF;
    
    -- Génération d'utilisateurs
    FOR i IN 1..p_count LOOP
        -- Déterminer le rôle (distribution réaliste)
        CASE
            WHEN MOD(i, 20) = 0 THEN v_role := 'Admin';
            WHEN MOD(i, 5) = 0 THEN v_role := 'Technicien';
            WHEN MOD(i, 3) = 0 THEN v_role := 'Enseignant';
            ELSE v_role := 'Étudiant';
        END CASE;
        
        -- Générer un nom aléatoire
        v_prenom := CASE MOD(i, 10)
            WHEN 0 THEN 'Jean'
            WHEN 1 THEN 'Marie'
            WHEN 2 THEN 'Pierre'
            WHEN 3 THEN 'Sophie'
            WHEN 4 THEN 'Thomas'
            WHEN 5 THEN 'Camille'
            WHEN 6 THEN 'Julien'
            WHEN 7 THEN 'Emma'
            WHEN 8 THEN 'Lucas'
            WHEN 9 THEN 'Léa'
        END;
        
        v_nom := CASE MOD(i, 10)
            WHEN 0 THEN 'Dupont'
            WHEN 1 THEN 'Martin'
            WHEN 2 THEN 'Durand'
            WHEN 3 THEN 'Leroy'
            WHEN 4 THEN 'Moreau'
            WHEN 5 THEN 'Petit'
            WHEN 6 THEN 'Simon'
            WHEN 7 THEN 'Laurent'
            WHEN 8 THEN 'Lefebvre'
            WHEN 9 THEN 'Garcia'
        END || '_' || i;
        
        -- Générer email et mot de passe
        v_email := LOWER(v_prenom || '.' || v_nom || '@' || v_site || '.edu');
        v_password := 'Pass' || TO_CHAR(i);
        
        -- Générer classe uniquement pour les étudiants
        IF v_role = 'Étudiant' THEN
            v_classe := 'Classe' || TO_CHAR(CEIL(i/30));
        ELSE
            v_classe := NULL;
        END IF;
        
        -- Insérer l'utilisateur dans le site approprié
        IF p_site_id = 1 THEN
            -- Cergy
            INSERT INTO c##glpi_cergy.glpi_users (
                id, nom, email, mot_de_passe, role, client_id, site_id, classe
            ) VALUES (
                c##glpi_cergy.seq_user_id.NEXTVAL, 
                v_prenom || ' ' || v_nom, 
                v_email, 
                v_password, 
                v_role, 
                1, -- client_id
                p_site_id,
                v_classe
            );
        ELSE
            -- Pau
            INSERT INTO c##glpi_pau.glpi_users (
                id, nom, email, mot_de_passe, role, client_id, site_id, classe
            ) VALUES (
                c##glpi_pau.seq_user_id.NEXTVAL, 
                v_prenom || ' ' || v_nom, 
                v_email, 
                v_password, 
                v_role, 
                1, -- client_id
                p_site_id,
                v_classe
            );
        END IF;
        
        -- Tous les 20 utilisateurs, faire un commit pour éviter les problèmes de transaction trop longue
        IF MOD(i, 20) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
END;
/

-- Procédure pour générer des équipements de test
CREATE OR REPLACE PROCEDURE generate_test_equipment(
    p_site_id IN NUMBER,
    p_computers_count IN NUMBER,
    p_printers_count IN NUMBER
) IS
    v_computer_id NUMBER;
    v_printer_id NUMBER;
    v_user_id NUMBER;
    v_acquisition_date DATE;
    
    -- Curseur pour obtenir des utilisateurs du site
    CURSOR c_users IS
        SELECT id FROM global_users 
        WHERE site_id = p_site_id;
BEGIN
    -- Génération d'ordinateurs attribués
    FOR i IN 1..p_computers_count LOOP
        -- Sélectionner un modèle d'ordinateur aléatoire
        SELECT id INTO v_computer_id
        FROM glpi_computers
        WHERE ROWNUM = 1
        ORDER BY DBMS_RANDOM.VALUE;
        
        -- Sélectionner un utilisateur aléatoire du site
        OPEN c_users;
        FETCH c_users INTO v_user_id;
        IF c_users%NOTFOUND THEN
            -- Si pas d'utilisateur, prendre l'admin
            SELECT id INTO v_user_id FROM global_users WHERE role = 'Admin' AND ROWNUM = 1;
        END IF;
        CLOSE c_users;
        
        -- Date d'acquisition aléatoire des 3 dernières années
        v_acquisition_date := TRUNC(SYSDATE) - DBMS_RANDOM.VALUE(0, 3*365);
        
        -- Insérer l'ordinateur dans le site approprié
        IF p_site_id = 1 THEN
            -- Cergy
            INSERT INTO c##glpi_cergy.glpi_computers_items (
                id, reference_computer_id, client_id, site_id, utilisateur_id, date_d_acquisition
            ) VALUES (
                c##glpi_cergy.seq_computer_item_id.NEXTVAL,
                v_computer_id,
                1, -- client_id
                p_site_id,
                v_user_id,
                v_acquisition_date
            );
        ELSE
            -- Pau
            INSERT INTO c##glpi_pau.glpi_computers_items (
                id, reference_computer_id, client_id, site_id, utilisateur_id, date_d_acquisition
            ) VALUES (
                c##glpi_pau.seq_computer_item_id.NEXTVAL,
                v_computer_id,
                1, -- client_id
                p_site_id,
                v_user_id,
                v_acquisition_date
            );
        END IF;
        
        -- Tous les 20 ordinateurs, faire un commit
        IF MOD(i, 20) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    -- Génération d'imprimantes attribuées
    FOR i IN 1..p_printers_count LOOP
        -- Sélectionner un modèle d'imprimante aléatoire
        SELECT id INTO v_printer_id
        FROM glpi_printers
        WHERE ROWNUM = 1
        ORDER BY DBMS_RANDOM.VALUE;
        
        -- Sélectionner un utilisateur aléatoire du site
        OPEN c_users;
        FETCH c_users INTO v_user_id;
        IF c_users%NOTFOUND THEN
            -- Si pas d'utilisateur, prendre l'admin
            SELECT id INTO v_user_id FROM global_users WHERE role = 'Admin' AND ROWNUM = 1;
        END IF;
        CLOSE c_users;
        
        -- Date d'acquisition aléatoire des 3 dernières années
        v_acquisition_date := TRUNC(SYSDATE) - DBMS_RANDOM.VALUE(0, 3*365);
        
        -- Insérer l'imprimante dans le site approprié
        IF p_site_id = 1 THEN
            -- Cergy
            INSERT INTO c##glpi_cergy.glpi_printers_items (
                id, reference_printer_id, client_id, site_id, utilisateur_id, date_d_acquisition
            ) VALUES (
                c##glpi_cergy.seq_printer_item_id.NEXTVAL,
                v_printer_id,
                1, -- client_id
                p_site_id,
                v_user_id,
                v_acquisition_date
            );
        ELSE
            -- Pau
            INSERT INTO c##glpi_pau.glpi_printers_items (
                id, reference_printer_id, client_id, site_id, utilisateur_id, date_d_acquisition
            ) VALUES (
                c##glpi_pau.seq_printer_item_id.NEXTVAL,
                v_printer_id,
                1, -- client_id
                p_site_id,
                v_user_id,
                v_acquisition_date
            );
        END IF;
        
        -- Tous les 20 imprimantes, faire un commit
        IF MOD(i, 20) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE generate_test_tickets(
    p_site_id IN NUMBER,
    p_count IN NUMBER
) IS
    v_utilisateur_id NUMBER;
    v_computer_item_id NUMBER := NULL;
    v_printer_item_id NUMBER := NULL;
    v_description VARCHAR2(255);
    v_statut VARCHAR2(20);
    v_ticket_id NUMBER;
    v_resolution VARCHAR2(255);
    v_date_creation TIMESTAMP;
    v_date_resolution TIMESTAMP;
    v_has_equipment BOOLEAN;
    
    -- Tableau de descriptions de problèmes
    TYPE tab_desc IS TABLE OF VARCHAR2(255);
    v_desc_arr tab_desc := tab_desc(
        'Problème de connexion réseau',
        'Écran bleu au démarrage',
        'Imprimante qui ne répond plus',
        'Application qui plante',
        'Problème de mise à jour Windows',
        'Virus détecté',
        'Problème de son',
        'Écran noir',
        'Batterie qui ne charge plus',
        'Clavier qui ne fonctionne pas correctement',
        'Souris défectueuse',
        'Problème d''accès à l''intranet',
        'Problème de messagerie',
        'Connexion WiFi instable',
        'Problème de carte graphique'
    );
    
    -- Tableau de résolutions
    TYPE tab_res IS TABLE OF VARCHAR2(255);
    v_res_arr tab_res := tab_res(
        'Redémarrage de l''équipement',
        'Réinstallation du pilote',
        'Nettoyage du disque dur',
        'Mise à jour du logiciel',
        'Remplacement de la pièce défectueuse',
        'Installation d''un logiciel antivirus',
        'Réinitialisation des paramètres réseau',
        'Mise à jour du BIOS',
        'Changement de mot de passe',
        'Restauration système'
    );
BEGIN
    -- Génération de tickets
    FOR i IN 1..p_count LOOP
        -- Sélectionner un utilisateur aléatoire du site
        BEGIN
            SELECT id INTO v_utilisateur_id
            FROM global_users
            WHERE site_id = p_site_id
            AND ROWNUM = 1
            ORDER BY DBMS_RANDOM.VALUE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Si pas d'utilisateur trouvé, utiliser l'ID 1
                v_utilisateur_id := 1;
        END;
        
        -- Description aléatoire
        v_description := v_desc_arr(TRUNC(DBMS_RANDOM.VALUE(1, v_desc_arr.COUNT + 1)));
        
        -- Statut aléatoire (avec une distribution réaliste)
        IF i <= p_count * 0.2 THEN
			v_statut := 'Ouvert';
		ELSIF i <= p_count * 0.5 THEN
			v_statut := 'En cours';
		ELSIF i <= p_count * 0.9 THEN
			v_statut := 'Resolu';
		ELSE
			v_statut := 'Ferme';
		END IF;

        
        -- Date de création aléatoire (6 derniers mois)
        v_date_creation := SYSTIMESTAMP - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 180), 'DAY');
        
        -- Date de résolution aléatoire (après création) pour les tickets résolus ou fermés
        IF v_statut IN ('Resolu', 'Ferme') THEN
            v_date_resolution := v_date_creation + NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 30), 'DAY');
        ELSE
            v_date_resolution := NULL;
        END IF;
        
        -- Décider si ce ticket aura un équipement associé (80% des tickets)
        v_has_equipment := DBMS_RANDOM.VALUE(0, 1) < 0.8;
        
        -- Si équipement, déterminer s'il s'agit d'un ordinateur ou d'une imprimante (70/30)
        IF v_has_equipment THEN
            IF DBMS_RANDOM.VALUE(0, 1) < 0.7 THEN
                -- Pour un ordinateur, générer un ID fictif pour l'instant
                v_computer_item_id := i; -- Using ticket iteration as a simple way to create various IDs
                v_printer_item_id := NULL;
            ELSE
                -- Pour une imprimante, générer un ID fictif 
                v_printer_item_id := i;
                v_computer_item_id := NULL;
            END IF;
        ELSE
            v_computer_item_id := NULL;
            v_printer_item_id := NULL;
        END IF;
        
        -- Insérer le ticket dans le site approprié
        IF p_site_id = 1 THEN
            -- Cergy
            INSERT INTO c##glpi_cergy.glpi_tickets (
                id, utilisateur_id, client_id, site_id, description, statut, 
                date_creation, date_resolution
            ) VALUES (
                c##glpi_cergy.seq_ticket_id.NEXTVAL,
                v_utilisateur_id,
                1, -- client_id
                p_site_id,
                v_description,
                v_statut,
                v_date_creation,
                v_date_resolution
            ) RETURNING id INTO v_ticket_id;
            
            -- Création de l'élément de ticket si équipement associé
            IF v_has_equipment THEN
                -- D'abord, créer l'équipement s'il n'existe pas déjà
                IF v_computer_item_id IS NOT NULL THEN
                    -- Créer un enregistrement d'ordinateur 
                    DECLARE
                        v_computer_exists NUMBER;
                        v_computer_ref_id NUMBER := TRUNC(DBMS_RANDOM.VALUE(1, 5)); -- Référence à un modèle existant
                    BEGIN
                        -- Vérifier si un ordinateur avec cet ID existe déjà
                        SELECT COUNT(*) INTO v_computer_exists 
                        FROM c##glpi_cergy.glpi_computers_items 
                        WHERE id = v_computer_item_id;
                        
                        -- S'il n'existe pas, le créer
                        IF v_computer_exists = 0 THEN
                            INSERT INTO c##glpi_cergy.glpi_computers_items (
                                id, reference_computer_id, client_id, site_id, utilisateur_id, date_d_acquisition
                            ) VALUES (
                                v_computer_item_id,
                                v_computer_ref_id,
                                1, -- client_id
                                p_site_id,
                                v_utilisateur_id,
                                SYSDATE - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 1095), 'DAY') -- 0-3 ans
                            );
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_computer_item_id := NULL; -- Ignorer l'erreur et continuer sans équipement
                    END;
                ELSIF v_printer_item_id IS NOT NULL THEN
                    -- Créer un enregistrement d'imprimante
                    DECLARE
                        v_printer_exists NUMBER;
                        v_printer_ref_id NUMBER := TRUNC(DBMS_RANDOM.VALUE(1, 5)); -- Référence à un modèle existant
                    BEGIN
                        -- Vérifier si une imprimante avec cet ID existe déjà
                        SELECT COUNT(*) INTO v_printer_exists 
                        FROM c##glpi_cergy.glpi_printers_items 
                        WHERE id = v_printer_item_id;
                        
                        -- Si elle n'existe pas, la créer
                        IF v_printer_exists = 0 THEN
                            INSERT INTO c##glpi_cergy.glpi_printers_items (
                                id, reference_printer_id, client_id, site_id, utilisateur_id, date_d_acquisition
                            ) VALUES (
                                v_printer_item_id,
                                v_printer_ref_id,
                                1, -- client_id
                                p_site_id,
                                v_utilisateur_id,
                                SYSDATE - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 1095), 'DAY') -- 0-3 ans
                            );
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_printer_item_id := NULL; -- Ignorer l'erreur et continuer sans équipement
                    END;
                END IF;
                
                -- Maintenant associer le ticket avec l'équipement
                IF v_computer_item_id IS NOT NULL OR v_printer_item_id IS NOT NULL THEN
                    INSERT INTO c##glpi_cergy.glpi_tickets_items (
                        id, ticket_id, computer_item_id, printer_item_id, site_id
                    ) VALUES (
                        c##glpi_cergy.seq_ticket_item_id.NEXTVAL,
                        v_ticket_id,
                        v_computer_item_id,
                        v_printer_item_id,
                        p_site_id
                    );
                END IF;
            END IF;
            
            -- Pour les tickets résolus ou fermés, ajouter une résolution
            IF v_statut IN ('Resolu', 'Ferme') THEN
                v_resolution := v_res_arr(TRUNC(DBMS_RANDOM.VALUE(1, v_res_arr.COUNT + 1)));
                
                INSERT INTO c##glpi_cergy.glpi_tickets_issues (
                    id, ticket_id, description_resolution, date_cloture, site_id
                ) VALUES (
                    c##glpi_cergy.seq_ticket_issue_id.NEXTVAL,
                    v_ticket_id,
                    v_resolution,
                    v_date_resolution,
                    p_site_id
                );
            END IF;
        ELSE
            -- Pau - même logique que pour Cergy mais avec les tables de Pau
            INSERT INTO c##glpi_pau.glpi_tickets (
                id, utilisateur_id, client_id, site_id, description, statut, 
                date_creation, date_resolution
            ) VALUES (
                c##glpi_pau.seq_ticket_id.NEXTVAL,
                v_utilisateur_id,
                1, -- client_id
                p_site_id,
                v_description,
                v_statut,
                v_date_creation,
                v_date_resolution
            ) RETURNING id INTO v_ticket_id;
            
            -- Création de l'élément de ticket si équipement associé
            IF v_has_equipment THEN
                -- D'abord, créer l'équipement s'il n'existe pas déjà
                IF v_computer_item_id IS NOT NULL THEN
                    -- Créer un enregistrement d'ordinateur 
                    DECLARE
                        v_computer_exists NUMBER;
                        v_computer_ref_id NUMBER := TRUNC(DBMS_RANDOM.VALUE(1, 5)); -- Référence à un modèle existant
                    BEGIN
                        -- Vérifier si un ordinateur avec cet ID existe déjà
                        SELECT COUNT(*) INTO v_computer_exists 
                        FROM c##glpi_pau.glpi_computers_items 
                        WHERE id = v_computer_item_id;
                        
                        -- S'il n'existe pas, le créer
                        IF v_computer_exists = 0 THEN
                            INSERT INTO c##glpi_pau.glpi_computers_items (
                                id, reference_computer_id, client_id, site_id, utilisateur_id, date_d_acquisition
                            ) VALUES (
                                v_computer_item_id,
                                v_computer_ref_id,
                                1, -- client_id
                                p_site_id,
                                v_utilisateur_id,
                                SYSDATE - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 1095), 'DAY') -- 0-3 ans
                            );
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_computer_item_id := NULL; -- Ignorer l'erreur et continuer sans équipement
                    END;
                ELSIF v_printer_item_id IS NOT NULL THEN
                    -- Créer un enregistrement d'imprimante
                    DECLARE
                        v_printer_exists NUMBER;
                        v_printer_ref_id NUMBER := TRUNC(DBMS_RANDOM.VALUE(1, 5)); -- Référence à un modèle existant
                    BEGIN
                        -- Vérifier si une imprimante avec cet ID existe déjà
                        SELECT COUNT(*) INTO v_printer_exists 
                        FROM c##glpi_pau.glpi_printers_items 
                        WHERE id = v_printer_item_id;
                        
                        -- Si elle n'existe pas, la créer
                        IF v_printer_exists = 0 THEN
                            INSERT INTO c##glpi_pau.glpi_printers_items (
                                id, reference_printer_id, client_id, site_id, utilisateur_id, date_d_acquisition
                            ) VALUES (
                                v_printer_item_id,
                                v_printer_ref_id,
                                1, -- client_id
                                p_site_id,
                                v_utilisateur_id,
                                SYSDATE - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 1095), 'DAY') -- 0-3 ans
                            );
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_printer_item_id := NULL; -- Ignorer l'erreur et continuer sans équipement
                    END;
                END IF;
                
                -- Maintenant associer le ticket avec l'équipement
                IF v_computer_item_id IS NOT NULL OR v_printer_item_id IS NOT NULL THEN
                    INSERT INTO c##glpi_pau.glpi_tickets_items (
                        id, ticket_id, computer_item_id, printer_item_id, site_id
                    ) VALUES (
                        c##glpi_pau.seq_ticket_item_id.NEXTVAL,
                        v_ticket_id,
                        v_computer_item_id,
                        v_printer_item_id,
                        p_site_id
                    );
                END IF;
            END IF;
            
            -- Pour les tickets résolus ou fermés, ajouter une résolution
            IF v_statut IN ('Resolu', 'Ferme') THEN
                v_resolution := v_res_arr(TRUNC(DBMS_RANDOM.VALUE(1, v_res_arr.COUNT + 1)));
                
                INSERT INTO c##glpi_pau.glpi_tickets_issues (
                    id, ticket_id, description_resolution, date_cloture, site_id
                ) VALUES (
                    c##glpi_pau.seq_ticket_issue_id.NEXTVAL,
                    v_ticket_id,
                    v_resolution,
                    v_date_resolution,
                    p_site_id
                );
            END IF;
        END IF;
        
        -- Tous les 10 tickets, faire un commit
        IF MOD(i, 10) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    COMMIT;
END;
/

-- Génération des données de test
BEGIN
	-- Insérer des données de référence avant de générer les équipements
	INSERT INTO c##glpi_central.glpi_clients VALUES (1, 'CY TECH');
	INSERT INTO c##glpi_central.glpi_sites VALUES (1, 'Cergy', 1);
	INSERT INTO c##glpi_central.glpi_sites VALUES (2, 'Pau', 1);

	-- Insérer des modèles d'ordinateurs
	INSERT INTO c##glpi_central.glpi_computers VALUES (1, 'Dell', 'Latitude 5420', 'Laptop');
	INSERT INTO c##glpi_central.glpi_computers VALUES (2, 'HP', 'EliteDesk 800 G5', 'Desktop');
	INSERT INTO c##glpi_central.glpi_computers VALUES (3, 'Lenovo', 'ThinkPad X1 Carbon', 'Laptop');
	INSERT INTO c##glpi_central.glpi_computers VALUES (4, 'Apple', 'MacBook Pro 14', 'Laptop');

	-- Insérer des modèles d'imprimantes
	INSERT INTO c##glpi_central.glpi_printers VALUES (1, 'HP', 'LaserJet Pro M404', 'Laser');
	INSERT INTO c##glpi_central.glpi_printers VALUES (2, 'Epson', 'EcoTank ET-4760', 'Inkjet');
	INSERT INTO c##glpi_central.glpi_printers VALUES (3, 'Brother', 'MFC-L8900CDW', 'Laser');
	INSERT INTO c##glpi_central.glpi_printers VALUES (4, 'Canon', 'PIXMA TR8620', 'Inkjet');
    -- Générer des utilisateurs (100 pour Cergy, 80 pour Pau)
    DBMS_OUTPUT.PUT_LINE('Génération des utilisateurs...');
    generate_test_users(1, 100); -- Cergy
    generate_test_users(2, 80);  -- Pau
    
    -- Générer des équipements (200 ordinateurs, 50 imprimantes pour Cergy, 150/40 pour Pau)
    DBMS_OUTPUT.PUT_LINE('Génération des équipements...');
    generate_test_equipment(1, 200, 50); -- Cergy
    generate_test_equipment(2, 150, 40); -- Pau
    
    -- Générer des tickets (300 pour Cergy, 250 pour Pau)
    DBMS_OUTPUT.PUT_LINE('Génération des tickets...');
    generate_test_tickets(1, 300); -- Cergy
    generate_test_tickets(2, 250); -- Pau
    
    DBMS_OUTPUT.PUT_LINE('Génération de données terminée !');
END;
/


-- Se connecter au schéma central
CONNECT c##glpi_central/glpi_central

-- Désactiver les triggers sur les tables du schéma central
ALTER TABLE glpi_clients ENABLE ALL TRIGGERS;
ALTER TABLE glpi_sites ENABLE ALL TRIGGERS;
ALTER TABLE glpi_computers ENABLE ALL TRIGGERS;
ALTER TABLE glpi_printers ENABLE ALL TRIGGERS;

-- Se connecter au schéma Cergy
CONNECT c##glpi_cergy/glpi_cergy

-- Désactiver les triggers sur les tables du site de Cergy
ALTER TABLE glpi_users ENABLE ALL TRIGGERS;
ALTER TABLE glpi_computers_items ENABLE ALL TRIGGERS;
ALTER TABLE glpi_printers_items ENABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets ENABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets_items ENABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets_issues ENABLE ALL TRIGGERS;

-- Se connecter au schéma Pau
CONNECT c##glpi_pau/glpi_pau

-- Désactiver les triggers sur les tables du site de Pau
ALTER TABLE glpi_users ENABLE ALL TRIGGERS;
ALTER TABLE glpi_computers_items ENABLE ALL TRIGGERS;
ALTER TABLE glpi_printers_items ENABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets ENABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets_items ENABLE ALL TRIGGERS;
ALTER TABLE glpi_tickets_issues ENABLE ALL TRIGGERS;