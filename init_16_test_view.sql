-- ====================================================================
-- EXEMPLES DE REQUÊTES SUR LES VUES GLOBALES
-- ====================================================================

CONNECT c##glpi_central/glpi_central

-- Au début du script
WHENEVER SQLERROR CONTINUE
SPOOL output.txt

-- 1. Afficher les utilisateurs (limité à 5)
SELECT id, nom, email, role, site_id
FROM global_users
WHERE ROWNUM <= 5;

-- 2. Afficher les ordinateurs (limité à 5)
SELECT id, reference_computer_id, site_id, utilisateur_id, date_d_acquisition
FROM global_computers_items
WHERE ROWNUM <= 5;

-- 3. Afficher les imprimantes (limité à 5)
SELECT id, reference_printer_id, site_id, utilisateur_id, date_d_acquisition
FROM global_printers_items
WHERE ROWNUM <= 5;

-- 4. Afficher les tickets (limité à 5)
SELECT id, utilisateur_id, site_id, description, statut, date_creation, date_resolution
FROM global_tickets
WHERE ROWNUM <= 5;

-- 5. Statistiques par site
SELECT 
    s.nom AS site,
    COUNT(DISTINCT u.id) AS nombre_utilisateurs,
    COUNT(DISTINCT c.id) AS nombre_ordinateurs,
    COUNT(DISTINCT p.id) AS nombre_imprimantes,
    COUNT(DISTINCT t.id) AS nombre_tickets
FROM c##glpi_central.glpi_sites s
LEFT JOIN global_users u ON s.id = u.site_id
LEFT JOIN global_computers_items c ON s.id = c.site_id
LEFT JOIN global_printers_items p ON s.id = p.site_id
LEFT JOIN global_tickets t ON s.id = t.site_id
GROUP BY s.id, s.nom
ORDER BY s.id;

-- 6. Répartition des tickets par statut
SELECT statut, COUNT(*) AS nombre, 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM global_tickets), 2) AS pourcentage
FROM global_tickets
GROUP BY statut
ORDER BY nombre DESC;
-- À la fin du script
SPOOL OFF