# frozen_string_literal: true

# Stubs the Geocodio API so scenarios never hit the real internet.
Given(/^Geocodio returns "([^"]*)" as a senator for any address$/) do |full_name|
  first, last = full_name.split(' ', 2)
  legislator = {
    'type' => 'senator',
    'bio' => { 'first_name' => first, 'last_name' => last, 'party' => 'Democrat',
               'photo_url' => 'https://example.com/photo.jpg' },
    'contact' => { 'address' => '331 Hart Senate Office Building Washington DC 20510',
                   'phone' => '202-224-3553', 'url' => 'https://www.padilla.senate.gov' },
    'references' => { 'govtrack_id' => '456789' }
  }
  data = { 'results' => [{ 'response' => { 'results' => [{ 'fields' => {
    'congressional_districts' => [{ 'current_legislators' => [legislator] }]
  } }] } }] }
  allow(Representative).to receive(:geocodio_search).and_return(data)
end

Given(/^a representative named "([^"]*)" exists$/) do |name|
  Representative.create!(name: name, ocdid: "test-#{name.parameterize}", title: 'senator')
end

When(/^I search for "([^"]*)" (\d+) times$/) do |address, count|
  count.to_i.times do
    visit representatives_path
    fill_in 'Enter a location:', with: address
    click_button 'Search'
    expect(page).to have_content('Search Results')
  end
end

Then(/^there should be (\d+) representatives? named "([^"]*)"$/) do |count, name|
  expect(Representative.where(name: name).count).to eq(count.to_i)
end
