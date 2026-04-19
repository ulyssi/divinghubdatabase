-- Initialisation de la base de données DivingHub (Schéma Relationnel)

-- 1. Table des sites de plongée
CREATE TABLE site (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    type TEXT,
    nationality TEXT,
    size TEXT,
    sunk_on TEXT,
    depth TEXT,
    access TEXT,
    sector TEXT,
    port TEXT,
    theoretical_current TEXT,
    coef_max INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Table des points GPS (Coordonnées Marines)
CREATE TABLE site_coordinate (
    id SERIAL PRIMARY KEY,
    site_id INTEGER REFERENCES site(id) ON DELETE CASCADE,
    lat_deg INTEGER,
    lat_min NUMERIC(7, 4),
    lat_dir CHAR(1), -- 'N' or 'S'
    lon_deg INTEGER,
    lon_min NUMERIC(7, 4),
    lon_dir CHAR(1), -- 'E' or 'W'
    description TEXT,
    is_confirmed BOOLEAN DEFAULT FALSE
);

-- 2. Table de référence des moments de marée (BM, -5, -4, -3, -2, -1, PM, +1, +2, +3, +4, +5)
CREATE TABLE tide_moment (
    id SERIAL PRIMARY KEY,
    label TEXT UNIQUE NOT NULL
);

-- 3. Séquence de marée théorique (Données de référence par site)
CREATE TABLE site_theoretical_tide (
    site_id INTEGER REFERENCES site(id) ON DELETE CASCADE,
    moment_id INTEGER REFERENCES tide_moment(id),
    vitesse TEXT, -- Plongeable, Limite, Non Plongeable, N/A
    PRIMARY KEY (site_id, moment_id)
);

-- 4. Expériences réelles des plongeurs (ressentis_reels)
CREATE TABLE site_diving_experimentation (
    id SERIAL PRIMARY KEY,
    site_id INTEGER REFERENCES site(id) ON DELETE CASCADE,
    dive_date DATE,
    coefficient INTEGER,
    observed_depth NUMERIC(5, 2),
    current_score INTEGER, -- Score de 1 à 7
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Jointure pour les moments réels d'une plongée
CREATE TABLE site_diving_experience_moment (
    experimentation_id INTEGER REFERENCES site_diving_experimentation(id) ON DELETE CASCADE,
    moment_id INTEGER REFERENCES tide_moment(id),
    PRIMARY KEY (experimentation_id, moment_id)
);

-- Insertion des moments de référence
INSERT INTO tide_moment (label) VALUES 
('BM'), ('-5'), ('-4'), ('-3'), ('-2'), ('-1'), 
('PM'), ('+1'), ('+2'), ('+3'), ('+4'), ('+5');

-- Indexation
CREATE INDEX idx_site_name ON site(name);
CREATE INDEX idx_experimentation_site_id ON site_diving_experimentation(site_id);
