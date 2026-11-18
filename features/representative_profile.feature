Feature: View a representative's profile
  As a voter
  So that I can learn about and contact my representatives
  I want to see a profile page for each representative from my search

  Scenario: Search results link to a representative's profile
    Given Geocodio returns "Alex Padilla" as a senator for any address
    And I am on the representatives page
    When I fill in "Enter a location:" with "2556 Telegraph Ave, Berkeley, CA"
    And I press "Search"
    Then I should see "Alex Padilla"
    When I follow "Alex Padilla"
    Then I should see "Democrat"
    And I should be on the profile page for "Alex Padilla"
    And I should see "202-224-3553"
    And I should see "https://www.padilla.senate.gov"

  Scenario: Searching the same address twice does not duplicate reps
    Given Geocodio returns "Alex Padilla" as a senator for any address
    When I search for "2556 Telegraph Ave, Berkeley, CA" 2 times
    Then there should be 1 representative named "Alex Padilla"

  Scenario: Profile page links to the representative's news articles
    Given a representative named "Jane Doe" exists
    When I go to the profile page for "Jane Doe"
    Then I should see "Jane Doe"
    And I should see "News Articles"

  Scenario: Reps on the county page link to their profiles
    Given Geocodio returns "Alex Padilla" as a senator for any address
    And I am on the county page for "001" in "CA"
    When I follow "Alex Padilla"
    Then I should see "Democrat"
    And I should be on the profile page for "Alex Padilla"
