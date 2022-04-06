# Brainstorm

## Intentions

- Make the app a simple, MVP for now
- Avoid fancy details:
  - Search autocomplete
  - Advanced style
  - AJAX
- Mess around w/ JQuery to work on DOM manipulation

## All Features

1. User authentication

- Singular user, multiple use cases
  - Personal inventory management
  - Searching other inventories
  - Advertising for nurseries

2. Plant database search tool

- Search for plants
- Optionally add plant to personal inventory

3. Inventory manager

- Search within inventory
- Add plants by:
  - Adding plant directly from database
  - Submitting own plant (for personal use only)
- Public-facing option: Others can view your account + inventory
  - Separate page to handle this

4. Nearby inventory search tool

- View 1: View all public-facing inventories -> browse
  - Provides information about the inventory (location, contact, etc.)
- View 2: Search inventories for plants
  - Search is limited to public-facing inventories
  - Search tool is separate for now
- [For now] Don't filter by location
- Options:
  - Filter for particular plants

## Database Architecture

1. Database of all USDA plants
2. Database of users
3. User-specific tables of their own plants

- Unique id
- Contains quantity

- **NOTE**: User plants = **Detached Duplicates** of USDA plants (not just simple links)
  - _Pros_:
    - Custom editing of user plants
    - Custom plants and USDA plants can both be treated as user plants (common interface)
    - USDA database is static -> no need to retain link
  - _Cons_:
    - Database Storage: Requires duplication

## Views

- AUTHENTICATION
  - `sign_up.erb`
  - `sign_in.erb`
- [INDEX] SEARCH: `plant_search.erb`: Plant search form (AJAX or new page?)
  - Usage: Database search, inventory search
  - Conditional elements depending on search type
- MY INVENTORY
  - `plant_list.erb`
  - List of all plants added to inventory
  - Edit ability
  - Add plant button
- ADD PLANT
  - Search for plant
  - Custom plant form
- FIND
  - `plant_list.erb`: List of plants from public inventories
  - `inventory_list.erb`: List of inventories themselves
- PLANT?: View full plant data
  - Option to add plant to personal inventory

## Components

- `plant_list.erb`: List of supplied `@plants` (table or ul?)
- Plant entry:
  - Most relevant plant data
- Usage: Database search, inventory search,
- `inventory_list.erb`: List of public-facing inventories

## RB175 Features

- Authentication
- Ability to search
- Settings (logout)
- My inventory (stored in session)?

## RB185 Features

- Reconfigure to use a SQL database
  - Add database capabilities to API

## Future Features

- Link plant database search tool & nearby search tool
  - "Filter to nearby" option
  - Plant page -> "Find nearby" option
- Pagination

## Implementation Ideas

Backend

- Create an API for interacting w/ plant database?
  - Look into example api: https://github.com/sckott/usdaplantsapi/
  - [RB185] Update API implementation to use own SQL database? (Heroku + Postgres)
  - `PlantDatabase` class w/ methods for querying
- Interacting with `database`
  - Create SQL database

Frontend

- Styling Bootstrap
- Use nested layouts to allow for more complex component nesting
