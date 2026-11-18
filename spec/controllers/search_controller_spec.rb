# frozen_string_literal: true

require 'rails_helper'

describe SearchController do
  render_views

  let(:geocodio_data) do
    legislator = { 'type' => 'senator',
                   'bio' => { 'first_name' => 'Alex', 'last_name' => 'Padilla' },
                   'references' => { 'govtrack_id' => '456789' } }
    { 'results' => [{ 'response' => { 'results' => [{ 'fields' => {
      'congressional_districts' => [{ 'current_legislators' => [legislator] }]
    } }] } }] }
  end

  before do
    allow(Representative).to receive(:geocodio_search).and_return(geocodio_data)
    get :search, params: { address: 'Berkeley, CA' }
  end

  it 'renders the search results' do
    expect(response).to render_template('representatives/search')
  end

  it 'links each rep name to their profile page' do
    rep = Representative.find_by(ocdid: '456789')
    expect(response.body).to include(%(href="#{representative_path(rep)}"))
  end

  it 'only shows each rep name once' do
    expect(response.body.scan('Alex Padilla').size).to eq(1)
  end
end
