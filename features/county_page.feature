Feature: County page
  As a voter
  So that I can find and get around my county's info
  I want the county page to show my reps and link back to the state map

Scenario: The county page links back to the state map
  Given Geocodio returns "Alex Padilla" as a senator for any address
  And I am on the county page for "001" in "CA"
  When I follow "Back to California"
  Then I should see "Counties in California"
  And I should be on the state page for "CA"
