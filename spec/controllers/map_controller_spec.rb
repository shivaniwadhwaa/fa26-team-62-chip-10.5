# frozen_string_literal: true

require 'rails_helper'

describe MapController do
  before do
    # TODO: It would be good to move these to factories.
    @california = State.create({ name: 'California', symbol: 'CA', fips_code: 6,
                            is_territory: 0, lat_min: 32.30, lat_max: 40.00,
                            long_min: 114.8, long_max: 124.24 })
    @washington = State.create({ name: 'Washington', symbol: 'WA', fips_code: 53,
                            is_territory: 0, lat_min: 32.30, lat_max: 40.00,
                            long_min: 114.8, long_max: 124.24 })

    @alameda = @california.counties.create({ name: 'Alameda', fips_code: 1, fips_class: 'CA' })
    @alpine = @california.counties.create({ name: 'Alpine', fips_code: 3, fips_class: 'CA' })
  end

  describe 'GET index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @states' do
      get :index
      expect(assigns(:states)).to eq(State.all)
    end

    it 'assigns @states_by_fips_code' do
      get :index
      expect(assigns(:states_by_fips_code)).to eq(State.all.index_by(&:std_fips_code))
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET state' do
    it 'returns a successful response' do
      get :state, params: { use_route: '/state/', state_symbol: 'CA' }
      expect(response).to be_successful
    end

    it 'assigns @state' do
      get :state, params: { use_route: '/state/', state_symbol: 'CA' }
      expect(assigns(:state)).to eq(@california)
    end

    it 'assigns @county_details' do
      get :state, params: { use_route: '/state/', state_symbol: 'CA' }
      expect(assigns(:county_details)).to eq(@california.counties.index_by(&:std_fips_code))
    end

    it 'redirects to home page if invalid state' do
      get :state, params: { use_route: '/state/', state_symbol: 'XX' }
      expect(response).to redirect_to root_path
    end
  end

  describe 'GET county' do
    let(:county_params) do
      { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA', std_fips_code: '001' }
    end
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
    end

    it 'searches geocodio for the county' do
      get :county, params: county_params
      expect(Representative).to have_received(:geocodio_search).with('Alameda, CA')
    end

    it 'assigns @representatives for the county' do
      get :county, params: county_params
      expect(assigns(:representatives).map(&:name)).to eq(['Alex Padilla'])
    end

    context 'when rendering the county page' do
      render_views

      it 'links each rep name to their profile page' do
        get :county, params: county_params
        rep = Representative.find_by(ocdid: '456789')
        expect(response.body).to include(%(href="#{representative_path(rep)}"))
      end

      it 'says so when no reps are found' do
        allow(Representative).to receive(:geocodio_search).and_raise(ArgumentError, 'Missing GEOCODIO_API_KEY')
        get :county, params: county_params
        expect(response.body).to include('No representatives found for Alameda.')
      end
    end

    it 'assigns no representatives if the geocodio search fails' do
      allow(Representative).to receive(:geocodio_search).and_raise(ArgumentError, 'Missing GEOCODIO_API_KEY')
      get :county, params: county_params
      expect(assigns(:representatives)).to eq([])
    end

    it 'returns a successful response' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(response).to be_successful
    end

    it 'assigns @state' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(assigns(:state)).to eq(@california)
    end

    it 'assigns @county' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(assigns(:county)).to eq(@alameda)
    end

    it 'assigns @county_details' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(assigns(:county_details)).to eq(@california.counties.index_by(&:std_fips_code))
    end

    it 'redirects to home page if invalid state' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'XX',
std_fips_code: '001' }
      expect(response).to redirect_to root_path
    end
  end
end
