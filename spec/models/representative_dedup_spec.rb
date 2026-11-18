# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Representative do
  def legislator(first, last, govtrack_id)
    { 'type' => 'senator',
      'bio' => { 'first_name' => first, 'last_name' => last },
      'references' => { 'govtrack_id' => govtrack_id } }
  end

  def api_response(*legislators)
    { 'results' => [{ 'response' => { 'results' => [{ 'fields' => {
      'congressional_districts' => [{ 'current_legislators' => legislators }]
    } }] } }] }
  end

  let(:padilla) { api_response(legislator('Alex', 'Padilla', '456789')) }
  let(:two_reps) { api_response(legislator('Alex', 'Padilla', '456789'), legislator('Adam', 'Schiff', '400361')) }

  describe '.civic_api_to_representative_params' do
    it 'does not create a duplicate when the same rep is returned twice' do
      described_class.civic_api_to_representative_params(padilla)
      expect { described_class.civic_api_to_representative_params(padilla) }.not_to change(described_class, :count)
    end

    it 'keeps different reps as separate records' do
      expect { described_class.civic_api_to_representative_params(two_reps) }.to change(described_class, :count).by(2)
    end

    it 'stores the unique govtrack id from the API' do
      reps = described_class.civic_api_to_representative_params(padilla)
      expect(reps.first.ocdid).to eq('456789')
    end
  end
end
