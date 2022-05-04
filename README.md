# BloomShare

Please read this README. It contains important information about how to test BloomShare during its beta phase.

## Beta Experimentation

If you want to test out the beta version of BloomShare:

- Visit https://plant-connect.herokuapp.com
- To login: Press `Log In` button or visit `/login`
  - Username: `admin`; Password: `Secret1!`
  - _Note_: Any data you add for this user is merely stored in a cookie
- Routes not requiring authentication

  - `/plants`: Search for different filters

### Some Things to Try

- Search for `Fir` in the `Common Name` filter
- Search for all plants with a `Yellow` flower color
- Search for all plants located in one of the U.S. `States`
- Click on a plant result to view more information on that plant
- Try visiting "My Plants" without being logged in
- Log in with the username `admin` and password `Secret1!`
- Add a plant to your inventory and update its quantity
- Try updating the plant with an invalid quantity
- Delete the plant from your inventory
- Search for plants within your inventory
- Try out the inline form at the top
- Log out

## Beta Limitations

- Performance issues
  - Plant data is stored and queried using a CSV (slow)
  - To minimize performance issues, only the first 500 entries in the plant database are accessible via search
  - Furthermore, searches are limited to a maximum of 10 results
  - Image searches are not lazy-loaded
- Users may not sign up; to access authenticated routes, users should login with a username of `admin` and password of `Secret1!`
- No user data (e.g. inventory) is persistent, as no database is setup

## Anticipated Features

- Use a relational database to store and query plant data (as opposed to a CSV)
- Proper user authentication and storage
- A `/community` route for interacting with the inventories of other users
- Ability to add custom plants (not already in database) to specific inventories
- Pagination for search results
- Lazy loading for image searches to improve performance

## Notable Developments

- `USDAPlants` API for querying from USDA plants database CSV, using a variety of filters
- Session-backed storage of users and associated inventories
- Robust input validation for authentication inputs, query inputs, and route parameters
- Route guards for authorized routes
- Usage of AJAX to minimize page reload where desired
- Security measures: Password hashing and escaping
- Nested `erb` template rendering
- High-coverage testing suite
- Bootstrap-backed layout
