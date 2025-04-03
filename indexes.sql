-- Index sur le champ email pour accélérer les recherches par email
CREATE INDEX idx_users_email ON glpi_users (email);

-- Index sur le champ role pour accélérer les recherches par rôle
CREATE INDEX idx_users_role ON glpi_users (role);

-- Index sur le client_id pour accélérer les recherches liées à un client spécifique
CREATE INDEX idx_users_client_id ON glpi_users (client_id);

-- Index composite sur client_id et role pour accélérer les recherches combinées
CREATE INDEX idx_users_client_role ON glpi_users (client_id, role);

-- Index sur le champ utilisateur_id pour accélérer les recherches par utilisateur
CREATE INDEX idx_tickets_utilisateur_id ON glpi_tickets (utilisateur_id);

-- Index sur le client_id pour accélérer les recherches par client
CREATE INDEX idx_tickets_client_id ON glpi_tickets (client_id);

-- Index composite sur utilisateur_id et client_id pour accélérer les recherches combinées
CREATE INDEX idx_tickets_utilisateur_client ON glpi_tickets (utilisateur_id, client_id);

-- Index sur ticket_id pour accélérer la récupération des éléments de ticket
CREATE INDEX idx_tickets_items_ticket_id ON glpi_tickets_items (ticket_id);

-- Index sur computer_item_id pour accélérer la recherche par équipement informatique
CREATE INDEX idx_tickets_items_computer_item_id ON glpi_tickets_items (computer_item_id);

-- Index sur printer_item_id pour accélérer la recherche par imprimante
CREATE INDEX idx_tickets_items_printer_item_id ON glpi_tickets_items (printer_item_id);

-- Index sur utilisateur_id pour accélérer les recherches sur les équipements par utilisateur
CREATE INDEX idx_computers_items_utilisateur_id ON glpi_computers_items (utilisateur_id);

-- Index sur client_id pour accélérer les recherches sur les équipements par client
CREATE INDEX idx_computers_items_client_id ON glpi_computers_items (client_id);

-- Index similaire pour la table des imprimantes
CREATE INDEX idx_printers_items_utilisateur_id ON glpi_printers_items (utilisateur_id);
CREATE INDEX idx_printers_items_client_id ON glpi_printers_items (client_id);
CREATE INDEX idx_tickets_status ON glpi_tickets (utilisateur_id, statut);
