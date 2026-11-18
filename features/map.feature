Feature: ActionMap Shows State and County Maps

Scenario: Navigating States and counties
  Given I am on the homepage
  Then I should see "National Map"
  When I click the state "CA"
  Then I should see "California"
  And I should be on the state page for "CA"

Scenario: Clicking a county on the state map goes to the county page
  Given Geocodio returns "Alex Padilla" as a senator for any address
  And I am on the state page for "CA"
  When I click the county with FIPS Code "001"
  Then I should see "Alameda County, CA"
  And I should be on the county page for "001" in "CA"

Scenario: The county page lists the county's representatives below the map
  Given Geocodio returns "Alex Padilla" as a senator for any address
  When I go to the county page for "001" in "CA"
  Then I should see "Alameda County, CA"
  And I should see "Representatives for Alameda County"
  And I should see "Alex Padilla"

Scenario: The national map draws every state
  Given I am on the homepage
  Then I should see 56 states

Scenario: The state map draws every county
  Given I am on the state page for "CA"
  Then I should see 58 counties

Scenario: Clicking a county by name on the state map
  Given Geocodio returns "Alex Padilla" as a senator for any address
  And I am on the state page for "CA"
  When I click the county "Alpine County"
  Then I should see "Alpine County, CA"
  And I should be on the county page for "003" in "CA"

Scenario: Clicking a different county on the county map
  Given Geocodio returns "Alex Padilla" as a senator for any address
  And I am on the county page for "001" in "CA"
  When I click the county with FIPS Code "003"
  Then I should see "Alpine County, CA"
  And I should be on the county page for "003" in "CA"

Scenario: Going to a state that doesn't exist
  When I go to the state page for "XX"
  Then I should see "State 'XX' not found."
  And I should be on the homepage

Scenario: Going to a county that doesn't exist
  When I go to the county page for "999" in "CA"
  Then I should see "County with code '999' not found for CA"
  And I should be on the homepage
