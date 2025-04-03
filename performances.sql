-- Crée une séquence pour générer des identifiants uniques
CREATE SEQUENCE glpi_users_seq5 START WITH 1 INCREMENT BY 1;

SET TIMING ON;

DECLARE
   i INT;
   v_id INT;
BEGIN
   FOR i IN 1..10000 LOOP
      -- Utilisation de la séquence pour générer un ID unique
      SELECT glpi_users_seq.NEXTVAL INTO v_id FROM dual;

      INSERT INTO glpi_users (id, nom, email, mot_de_passe, role, client_id, site_id)
      VALUES (v_id, 'User' || i, 'user' || i || '@example.com', 'password123', 'Étudiant', MOD(i, 2) + 1, MOD(i, 2) + 1);
   END LOOP;
   COMMIT;
END;
/

SET TIMING ON;

SELECT u.nom, u.email, t.id AS ticket_id, t.description
FROM glpi_users u
JOIN glpi_tickets t ON u.id = t.utilisateur_id
WHERE u.site_id = 1
ORDER BY t.date_creation DESC
FETCH FIRST 10000 ROWS ONLY;

SET TIMING ON;

DECLARE
   i INT;
BEGIN
   FOR i IN 1..10000 LOOP
      UPDATE glpi_computers
      SET marque = 'Marque_' || MOD(i, 10)
      WHERE id = i;
   END LOOP;
   COMMIT;
END;
/
