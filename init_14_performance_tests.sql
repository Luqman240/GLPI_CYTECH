-- init_14_performance_tests.sql
-- Requêtes complexes pour vérifier les temps de réponse

CONNECT c##glpi_central/glpi_central

-- Procédure pour mesurer le temps d'exécution d'une requête
CREATE OR REPLACE PROCEDURE measure_query_execution_time(
    p_query_name IN VARCHAR2,
    p_query IN VARCHAR2
) IS
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_duration NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Exécution de la requête: ' || p_query_name);
    
    -- Mesurer le temps d'exécution
    v_start := SYSTIMESTAMP;
    EXECUTE IMMEDIATE p_query;
    v_end := SYSTIMESTAMP;
    
    -- Calculer la durée en millisecondes
    v_duration := EXTRACT(SECOND FROM (v_end - v_start)) * 1000;
    
    -- Afficher le résultat
    DBMS_OUTPUT.PUT_LINE('Temps d''exécution: ' || TO_CHAR(v_duration, '999999.999') || ' ms');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
END;
/

-- Fonction pour analyser la distribution des données entre les sites
CREATE OR REPLACE PROCEDURE analyze_data_distribution AS
    v_count_cergy_users NUMBER;
    v_count_pau_users NUMBER;
    v_count_cergy_computers NUMBER;
    v_count_pau_computers NUMBER;
    v_count_cergy_printers NUMBER;
    v_count_pau_printers NUMBER;
    v_count_cergy_tickets NUMBER;
    v_count_pau_tickets NUMBER;
    v_count_cergy_tickets_resolved NUMBER;
    v_count_pau_tickets_resolved NUMBER;
BEGIN
    -- Compter les utilisateurs par site
    SELECT COUNT(*) INTO v_count_cergy_users FROM cergy_users;
    SELECT COUNT(*) INTO v_count_pau_users FROM pau_users;
    
    -- Compter les ordinateurs par site
    SELECT COUNT(*) INTO v_count_cergy_computers FROM cergy_computers_items;
    SELECT COUNT(*) INTO v_count_pau_computers FROM pau_computers_items;
    
    -- Compter les imprimantes par site
    SELECT COUNT(*) INTO v_count_cergy_printers FROM cergy_printers_items;
    SELECT COUNT(*) INTO v_count_pau_printers FROM pau_printers_items;
    
    -- Compter les tickets par site
    SELECT COUNT(*) INTO v_count_cergy_tickets FROM cergy_tickets;
    SELECT COUNT(*) INTO v_count_pau_tickets FROM pau_tickets;
    
    -- Compter les tickets résolus par site
    SELECT COUNT(*) INTO v_count_cergy_tickets_resolved 
    FROM cergy_tickets 
    WHERE statut IN ('Resolu', 'Ferme');
    
    SELECT COUNT(*) INTO v_count_pau_tickets_resolved 
    FROM pau_tickets 
    WHERE statut IN ('Resolu', 'Ferme');
    
    -- Afficher les résultats
    DBMS_OUTPUT.PUT_LINE('===== DISTRIBUTION DES DONNÉES ENTRE SITES =====');
    DBMS_OUTPUT.PUT_LINE('--- Utilisateurs ---');
    DBMS_OUTPUT.PUT_LINE('Cergy: ' || v_count_cergy_users || ' (' || 
                         ROUND(v_count_cergy_users/(v_count_cergy_users+v_count_pau_users)*100, 2) || '%)');
    DBMS_OUTPUT.PUT_LINE('Pau: ' || v_count_pau_users || ' (' || 
                         ROUND(v_count_pau_users/(v_count_cergy_users+v_count_pau_users)*100, 2) || '%)');
    
    DBMS_OUTPUT.PUT_LINE('--- Ordinateurs ---');
    DBMS_OUTPUT.PUT_LINE('Cergy: ' || v_count_cergy_computers || ' (' || 
                         ROUND(v_count_cergy_computers/(v_count_cergy_computers+v_count_pau_computers)*100, 2) || '%)');
    DBMS_OUTPUT.PUT_LINE('Pau: ' || v_count_pau_computers || ' (' || 
                         ROUND(v_count_pau_computers/(v_count_cergy_computers+v_count_pau_computers)*100, 2) || '%)');
    
    DBMS_OUTPUT.PUT_LINE('--- Imprimantes ---');
    DBMS_OUTPUT.PUT_LINE('Cergy: ' || v_count_cergy_printers || ' (' || 
                         ROUND(v_count_cergy_printers/(v_count_cergy_printers+v_count_pau_printers)*100, 2) || '%)');
    DBMS_OUTPUT.PUT_LINE('Pau: ' || v_count_pau_printers || ' (' || 
                         ROUND(v_count_pau_printers/(v_count_cergy_printers+v_count_pau_printers)*100, 2) || '%)');
    
    DBMS_OUTPUT.PUT_LINE('--- Tickets ---');
    DBMS_OUTPUT.PUT_LINE('Cergy: ' || v_count_cergy_tickets || ' (' || 
                         ROUND(v_count_cergy_tickets/(v_count_cergy_tickets+v_count_pau_tickets)*100, 2) || '%)');
    DBMS_OUTPUT.PUT_LINE('Pau: ' || v_count_pau_tickets || ' (' || 
                         ROUND(v_count_pau_tickets/(v_count_cergy_tickets+v_count_pau_tickets)*100, 2) || '%)');
    
    DBMS_OUTPUT.PUT_LINE('--- Tickets résolus ---');
    DBMS_OUTPUT.PUT_LINE('Cergy: ' || v_count_cergy_tickets_resolved || ' (' || 
                         ROUND(v_count_cergy_tickets_resolved/v_count_cergy_tickets*100, 2) || '% des tickets de Cergy)');
    DBMS_OUTPUT.PUT_LINE('Pau: ' || v_count_pau_tickets_resolved || ' (' || 
                         ROUND(v_count_pau_tickets_resolved/v_count_pau_tickets*100, 2) || '% des tickets de Pau)');
    DBMS_OUTPUT.PUT_LINE('=========================================');
END;
/

-- Exécution des tests de performance
SET SERVEROUTPUT ON;
SET TIMING ON;

-- Analyser la distribution des données
BEGIN
    analyze_data_distribution;
END;
/

-- Tests de performance avec différentes requêtes
BEGIN
    -- Test 1: Afficher tous les tickets d'un site spécifique
    measure_query_execution_time(
        'Tickets du site de Cergy',
        'SELECT COUNT(*) FROM global_tickets WHERE site_id = 1'
    );
    
    -- Test 2: Afficher les tickets par statut
    measure_query_execution_time(
        'Tickets par statut',
        'SELECT statut, COUNT(*) FROM global_tickets GROUP BY statut'
    );
    
    -- Test 3: Afficher les utilisateurs avec le plus de tickets
    measure_query_execution_time(
        'Top utilisateurs avec tickets',
        'SELECT u.nom, COUNT(t.id) as nb_tickets
         FROM global_users u
         JOIN global_tickets t ON u.id = t.utilisateur_id
         GROUP BY u.nom
         ORDER BY nb_tickets DESC
         FETCH FIRST 10 ROWS ONLY'
    );
    
    -- Test 4: Recherche multi-critères sur les tickets
    measure_query_execution_time(
        'Recherche multi-critères',
        'SELECT t.id, t.description, t.statut, u.nom, s.nom as site
         FROM global_tickets t
         JOIN global_users u ON t.utilisateur_id = u.id
         JOIN glpi_sites s ON t.site_id = s.id
         WHERE t.statut = ''En cours''
         AND t.site_id = 1
         AND t.date_creation > SYSDATE - 90'
    );
    
    -- Test 5: Jointure complexe tickets-équipements
    measure_query_execution_time(
        'Jointure complexe tickets-équipements',
        'SELECT t.id, t.description, u.nom as utilisateur,
                CASE 
                    WHEN ti.computer_item_id IS NOT NULL THEN ''Ordinateur''
                    WHEN ti.printer_item_id IS NOT NULL THEN ''Imprimante''
                    ELSE ''Aucun''
                END as type_equipement,
                c.marque || '' '' || c.modele as modele_ordinateur,
                p.marque || '' '' || p.modele as modele_imprimante
         FROM global_tickets t
         JOIN global_users u ON t.utilisateur_id = u.id
         LEFT JOIN global_tickets_items ti ON t.id = ti.ticket_id
         LEFT JOIN global_computers_items ci ON ti.computer_item_id = ci.id
         LEFT JOIN global_printers_items pi ON ti.printer_item_id = pi.id
         LEFT JOIN glpi_computers c ON ci.reference_computer_id = c.id
         LEFT JOIN glpi_printers p ON pi.reference_printer_id = p.id
         WHERE t.statut = ''Ouvert'''
    );
    
    -- Test 6: Vue d'ensemble statistique
    measure_query_execution_time(
    'Vue d''ensemble statistique',
    'SELECT s.nom as site, 
            COUNT(DISTINCT u.id) as nb_utilisateurs,
            COUNT(DISTINCT ci.id) as nb_ordinateurs,
            COUNT(DISTINCT pi.id) as nb_imprimantes,
            COUNT(DISTINCT t.id) as nb_tickets,
            COUNT(DISTINCT CASE WHEN t.statut = ''Resolu'' OR t.statut = ''Ferme'' THEN t.id END) as tickets_resolus,
            ROUND(COUNT(DISTINCT CASE WHEN t.statut = ''Resolu'' OR t.statut = ''Ferme'' THEN t.id END) / 
                  NULLIF(COUNT(DISTINCT t.id), 0) * 100, 2) as pourcentage_resolution
     FROM glpi_sites s
     LEFT JOIN global_users u ON s.id = u.site_id
     LEFT JOIN global_computers_items ci ON s.id = ci.site_id
     LEFT JOIN global_printers_items pi ON s.id = pi.site_id
     LEFT JOIN global_tickets t ON s.id = t.site_id
     GROUP BY s.nom'
);
    
    -- Test 7: Temps moyen de résolution par site
    measure_query_execution_time(
        'Temps moyen de résolution',
        'SELECT s.nom as site,
                AVG(EXTRACT(DAY FROM (t.date_resolution - t.date_creation)) * 24 +
                    EXTRACT(HOUR FROM (t.date_resolution - t.date_creation))) as heures_moyenne
         FROM global_tickets t
         JOIN glpi_sites s ON t.site_id = s.id
         WHERE t.statut IN (''Resolu'', ''Ferme'')
         AND t.date_resolution IS NOT NULL
         GROUP BY s.nom'
    );
    
    -- Test 8: Distribution des tickets par type d'équipement
    measure_query_execution_time(
        'Distribution par type d''équipement',
        'SELECT 
            s.nom as site,
            SUM(CASE WHEN ti.computer_item_id IS NOT NULL THEN 1 ELSE 0 END) as tickets_ordinateurs,
            SUM(CASE WHEN ti.printer_item_id IS NOT NULL THEN 1 ELSE 0 END) as tickets_imprimantes,
            SUM(CASE WHEN ti.computer_item_id IS NULL AND ti.printer_item_id IS NULL THEN 1 ELSE 0 END) as tickets_autres
         FROM global_tickets t
         JOIN glpi_sites s ON t.site_id = s.id
         LEFT JOIN global_tickets_items ti ON t.id = ti.ticket_id
         GROUP BY s.nom'
    );
    
    -- Test 9: Répartition des tickets par rôle d'utilisateur
    measure_query_execution_time(
        'Répartition par rôle',
        'SELECT 
            u.role,
            COUNT(t.id) as nombre_tickets,
            ROUND(COUNT(t.id) * 100.0 / (SELECT COUNT(*) FROM global_tickets), 2) as pourcentage
         FROM global_tickets t
         JOIN global_users u ON t.utilisateur_id = u.id
         GROUP BY u.role
         ORDER BY nombre_tickets DESC'
    );
    
    -- Test 10: Requête avec tri et pagination
    measure_query_execution_time(
        'Tri et pagination des tickets',
        'SELECT *
         FROM (
            SELECT t.id, t.description, t.statut, t.date_creation, u.nom as utilisateur, s.nom as site,
                   ROW_NUMBER() OVER (ORDER BY t.date_creation DESC) as rn
            FROM global_tickets t
            JOIN global_users u ON t.utilisateur_id = u.id
            JOIN glpi_sites s ON t.site_id = s.id
         )
         WHERE rn BETWEEN 1 AND 50'
    );
    
    -- Affichage des résultats
    DBMS_OUTPUT.PUT_LINE('Tests de performance terminés !');
END;
/