# BloomShare

Please read this README. It contains important information about how to test BloomShare during its beta phase.

## Beta Experimentation

If you want to test out the beta version of BloomShare:

- Visit https://bloom-share.herokuapp.com
- To login:
  - If you wish, sign up with your own credentials at `/signup`. Your password is encrypted with `BCrypt`.
  - If you do not prefer to use your own credentials, you can sign in to a publically shared account for experimentation purposes only
    - Username: `admin`; Password: `Password1234`
    - _Note_: This is a **shared acount**. Add and remove plants from your inventory as you wish.

### Some Things to Try

- Search for `Fir` in the `Common Name` filter
- Search for all plants with a `Yellow` flower color
- Search for all plants located in one of the U.S. `States`
- Click on a plant result to view more information on that plant
- Try visiting "My Plants" without being logged in
- Authentication
- Add a plant to your inventory and update its quantity
- Try updating the plant with an invalid quantity
- Delete the plant from your inventory
- Search for plants within your inventory
- Try out the inline form at the top
- Log out

## Possible Future Features

- Ability to add custom plants (not already in database) to specific inventories
- Lazy loading for image searches to improve performance

## Notable Developments

- Setup a relational database including plants adapted from the USDA plants database (via a CSV import)
- Various APIs (`Plants`, `Users`, `Inventories`) for querying database
- Robust input validation for authentication inputs, query inputs, and route parameters
- Route guards for authorized routes
- Usage of AJAX to minimize page reload where desired
- Security measures: Password hashing and escaping
- Nested `erb` template rendering
- High-coverage testing suite (SimpleCov)
- Bootstrap-backed layout
