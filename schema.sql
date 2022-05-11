-- Name: inventories; Type: TABLE; Schema: public; Owner: ethanweiner
--

CREATE TABLE inventories (
    id integer NOT NULL,
    name text NOT NULL,
    user_id text NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: ethanweiner
--

CREATE SEQUENCE inventories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE inventories_id_seq;

--
-- Name: inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ethanweiner
--

ALTER SEQUENCE inventories_id_seq OWNED BY inventories.id;


--
-- Name: inventories_plants; Type: TABLE; Schema: public; Owner: ethanweiner
--

CREATE TABLE inventories_plants (
    id integer NOT NULL,
    inventory_id integer,
    plant_id integer,
    quantity integer DEFAULT 0 NOT NULL
);


--
-- Name: inventories_plants_id_seq; Type: SEQUENCE; Schema: public; Owner: ethanweiner
--

CREATE SEQUENCE inventories_plants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE inventories_plants_id_seq;

--
-- Name: inventories_plants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ethanweiner
--

ALTER SEQUENCE inventories_plants_id_seq OWNED BY inventories_plants.id;


--
-- Name: plants; Type: TABLE; Schema: public; Owner: ethanweiner
--

CREATE TABLE plants (
    species_id text,
    genus text,
    species text,
    scientific_name text NOT NULL,
    common_name text NOT NULL,
    notes text,
    created_at text,
    updated_at text,
    accepted_symbol text,
    synonym_symbol text,
    symbol text,
    plant_floristic_area text,
    state text,
    category text,
    family text,
    family_symbol text,
    family_common_name text,
    "order" text,
    sub_class text,
    class text,
    sub_division text,
    division text,
    super_division text,
    sub_kingdom text,
    kingdom text,
    itis_tsn text,
    duration text,
    growth_habit text,
    native_status text,
    federal_noxious_status text,
    federal_noxious_common_name text,
    state_noxious_status text,
    state_noxious_common_name text,
    invasive text,
    federal_te_status text,
    state_te_status text,
    state_te_common_name text,
    national_wetland_indicator_status text,
    regional_wetland_indicator_status text,
    active_growth_period text,
    after_harvest_regrowth_rate text,
    bloat text,
    c2n_ratio text,
    coppice_potential text,
    fall_conspicuous text,
    fire_resistance text,
    flower_color text,
    flower_conspicuous text,
    foliage_color text,
    foliage_porosity_summer text,
    foliage_porosity_winter text,
    foliage_texture text,
    fruit_color text,
    fruit_conspicuous text,
    growth_form text,
    growth_rate text,
    max_height_20yrs text,
    mature_height text,
    known_allelopath text,
    leaf_retention text,
    lifespane text,
    low_growing_grass text,
    nitrogen_fixation text,
    resprout_ability text,
    shape_and_orientation text,
    toxicity text,
    adapted_coarse_soils text,
    adapted_medium_soils text,
    adapted_fine_soils text,
    anaeroboic_tolerance text,
    caco3_tolerance text,
    cold_stratification text,
    drought_tolerance text,
    fertility_requirement text,
    fire_tolerance text,
    min_frost_free_days text,
    hedge_tolerance text,
    moisture_user text,
    ph_minimum text,
    ph_maximum text,
    min_planting_density text,
    max_planting_density text,
    precipitation_minimum integer,
    precipitation_maximum integer,
    root_depth_minimum text,
    salinity_tolerance text,
    shade_tolerance text,
    temperature_minimum integer,
    bloom_period text,
    commercial_availability text,
    fruit_seed_abundance text,
    fruit_seed_period_begin text,
    fruit_seed_period_end text,
    fruit_seed_persistence text,
    propogated_by_bare_root text,
    propogated_by_bulbs text,
    propogated_by_container text,
    propogated_by_corms text,
    propogated_by_cuttings text,
    propogated_by_seed text,
    propogated_by_sod text,
    propogated_by_sprigs text,
    propogated_by_tubers text,
    seeds_per_pound text,
    seed_spread_rate text,
    seedling_vigor text,
    small_grain text,
    vegetative_spread_rate text,
    berry_nut_seed_product text,
    christmas_tree_product text,
    fodder_product text,
    fuelwood_product text,
    lumber_product text,
    naval_store_product text,
    nursery_stock_product text,
    palatable_browse_animal text,
    palatable_graze_animal text,
    palatable_human text,
    post_product text,
    protein_potential text,
    pulpwood_product text,
    veneer_product text,
    id integer NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    created_by text
);


--
-- Name: plants_temporary_id_seq; Type: SEQUENCE; Schema: public; Owner: ethanweiner
--

CREATE SEQUENCE plants_temporary_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plants_temporary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ethanweiner
--

ALTER SEQUENCE plants_temporary_id_seq OWNED BY plants.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: ethanweiner
--

CREATE TABLE users (
    id text NOT NULL,
    username text NOT NULL,
    password_hash text NOT NULL,
    num_plants_added integer DEFAULT 0 NOT NULL,
    CONSTRAINT users_num_plants_added_check CHECK ((num_plants_added < 20))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: ethanweiner
--

CREATE SEQUENCE users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ethanweiner
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: inventories id; Type: DEFAULT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY inventories ALTER COLUMN id SET DEFAULT nextval('inventories_id_seq'::regclass);


--
-- Name: inventories_plants id; Type: DEFAULT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY inventories_plants ALTER COLUMN id SET DEFAULT nextval('inventories_plants_id_seq'::regclass);


--
-- Name: plants id; Type: DEFAULT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY plants ALTER COLUMN id SET DEFAULT nextval('plants_temporary_id_seq'::regclass);


--
-- Name: inventories inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY inventories
    ADD CONSTRAINT inventories_pkey PRIMARY KEY (id);


--
-- Name: inventories_plants inventories_plants_inventory_id_plant_id_key; Type: CONSTRAINT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY inventories_plants
    ADD CONSTRAINT inventories_plants_inventory_id_plant_id_key UNIQUE (inventory_id, plant_id);


--
-- Name: inventories_plants inventories_plants_pkey; Type: CONSTRAINT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY inventories_plants
    ADD CONSTRAINT inventories_plants_pkey PRIMARY KEY (id);


--
-- Name: plants plants_temporary_pkey; Type: CONSTRAINT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY plants
    ADD CONSTRAINT plants_temporary_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: inventories_plants inventories_plants_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY inventories_plants
    ADD CONSTRAINT inventories_plants_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES inventories(id) ON DELETE CASCADE;


--
-- Name: inventories_plants inventories_plants_plant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY inventories_plants
    ADD CONSTRAINT inventories_plants_plant_id_fkey FOREIGN KEY (plant_id) REFERENCES plants(id) ON DELETE CASCADE;


--
-- Name: inventories inventories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY inventories
    ADD CONSTRAINT inventories_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: plants plants_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ethanweiner
--

ALTER TABLE ONLY plants
    ADD CONSTRAINT plants_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

-- Copy data into plants database
COPY plants (id, species_id, genus, species, scientific_name, common_name, notes, created_at, updated_at, accepted_symbol, synonym_symbol, symbol, plant_floristic_area, state, category, family, family_symbol, family_common_name, "order", sub_class, class, sub_division, division, super_division, sub_kingdom, kingdom, ITIS_TSN, duration, growth_habit, native_status, federal_noxious_status, federal_noxious_common_name, state_noxious_status, state_noxious_common_name, invasive, federal_te_status, state_te_status, state_te_common_name, national_wetland_indicator_status, regional_wetland_indicator_status, active_growth_period, after_harvest_regrowth_rate, bloat, c2n_ratio, coppice_potential, fall_conspicuous, fire_resistance, flower_color, flower_conspicuous, foliage_color, foliage_porosity_summer, foliage_porosity_winter, foliage_texture, fruit_color, fruit_conspicuous, growth_form, growth_rate, max_height_20yrs, mature_height, known_allelopath, leaf_retention, lifespane, low_growing_grass, nitrogen_fixation, resprout_ability, shape_and_orientation, toxicity, adapted_coarse_soils, adapted_medium_soils, adapted_fine_soils, anaeroboic_tolerance, caco3_tolerance, cold_stratification, drought_tolerance, fertility_requirement, fire_tolerance, min_frost_free_days, hedge_tolerance, moisture_user, ph_minimum, ph_maximum, min_planting_density, max_planting_density, precipitation_minimum, precipitation_maximum, root_depth_minimum, salinity_tolerance, shade_tolerance, temperature_minimum, bloom_period, commercial_availability, fruit_seed_abundance, fruit_seed_period_begin, fruit_seed_period_end, fruit_seed_persistence, propogated_by_bare_root, propogated_by_bulbs, propogated_by_container, propogated_by_corms, propogated_by_cuttings, propogated_by_seed, propogated_by_sod, propogated_by_sprigs, propogated_by_tubers, seeds_per_pound, seed_spread_rate, seedling_vigor, small_grain, vegetative_spread_rate, berry_nut_seed_product, christmas_tree_product, fodder_product, fuelwood_product, lumber_product, naval_store_product, nursery_stock_product, palatable_browse_animal, palatable_graze_animal, palatable_human, post_product, protein_potential, pulpwood_product, veneer_product)
FROM '/Users/ethanweiner/Documents/Launch_School/RB185/plant_connect/data/plants_dbimport.csv'
csv header
WHERE state LIKE '%MA%';
-- 