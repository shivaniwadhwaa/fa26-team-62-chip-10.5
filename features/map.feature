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
