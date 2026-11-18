# frozen_string_literal: true

# You should add your own steps and support functions here.

# These steps here are scaffolds, which might be useful.

Given /^I am logged in via (github|google|developer) as (".*")/i do |provider, _data|
  # This is just a start. You may want to setup Omniauth differently.
  # Look up Omniauth.test_mode
  page.find_link(text: "#{provider.capitalize} Login")
end

# Suggest Steps that Interact with the Map.
# The Map is rendered as a bunch of SVG elements, which clock can
# 'click' on and the user will be taken to the hopefully right page.
# You should inspect the HTML generated in the browser.
# As a hint you should be able to write some JavaScript
# Example JS: let ca = $('path[data-state-symbol="CA"]')
# This will find all elements based on those data attributes.

# <path class="actionmap-view-region" d="" tabindex="0" data-state-name="California"
#    data-state-fips-code="06" data-state-symbol="CA"></path>

# Clicking SVG paths with Capybara's .click errors in Chrome, so we fire a
# real click event instead. That still runs the map's JS click handler.
def click_map_region(selector)
  expect(page).to have_css(selector)
  page.execute_script(
    "document.querySelector(\"#{selector}\").dispatchEvent(new MouseEvent('click', { bubbles: true }))"
  )
end

# The county maps are drawn from county subdivisions, so one county can have
# several paths. Count the distinct values of a data attribute instead.
def distinct_map_regions(attribute)
  expect(page).to have_css("path[#{attribute}]")
  page.evaluate_script(
    "new Set(Array.from(document.querySelectorAll('path[#{attribute}]'), (p) => p.getAttribute('#{attribute}'))).size"
  )
end

Then /I click the state "(\w\w)"/i do |state|
  click_map_region("path[data-state-symbol='#{state}']")
end

Then /I click the county "(.*)"/i do |county_name|
  click_map_region("path[data-county-name='#{county_name}']")
end

Then /I click the county with FIPS Code "(.*)"/i do |fips_code|
  click_map_region("path[data-county-fips-code='#{fips_code}']")
end

Then /I should see (\d+) (states|counties)/i do |count, kind|
  attribute = kind == 'states' ? 'data-state-symbol' : 'data-county-fips-code'
  expect(distinct_map_regions(attribute)).to eq(count.to_i)
end
