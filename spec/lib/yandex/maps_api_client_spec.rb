# frozen_string_literal: true

describe Yandex::MapsApiClient do
  include Mocks::Yandex::MapsApi
  include Mocks::Google::MapsApi

  let(:lattitude) { 10.02 }
  let(:longitude) { 12.01 }

  describe '.geocode' do
    subject { described_class.geocode(address: address) }
    let(:address) { SecureRandom.hex }
    let(:city) { SecureRandom.hex }
    let!(:request) do
      mock_yandex_api_maps_geocode_request(address: address,
                                           city: city,
                                           lattitude: lattitude,
                                           longitude: longitude,
                                           found: found)
    end

    context 'success' do
      let(:found) { true }
      specify do
        expect(subject).to eq(longitude: longitude, lattitude: lattitude, city: city)
        expect(request).to have_been_made
      end
    end

    context 'failure' do
      context 'when not found' do
        let(:found) { false }
        it 'raises error' do
          expect { subject }.to raise_error(::Yandex::NotFoundError)
          expect(request).to have_been_made
        end
      end
    end

    context 'when city not found' do
      let(:found) { true }
      let(:city) { nil }

      it 'not raises error' do
        expect { subject }.not_to raise_error
        expect(request).to have_been_made
      end
    end
  end

  describe '.city_disctict' do
    let(:district_names) { [SecureRandom.hex, SecureRandom.hex] }
    let!(:request) do
      mock_yandex_api_maps_city_district_request(names: district_names,
                                                 longitude: longitude,
                                                 lattitude: lattitude)
    end

    subject do
      described_class.city_disctict(longitude: longitude, lattitude: lattitude)
    end

    it 'returns proper district_name' do
      expect(subject).to match_array(district_names)
      expect(request).to have_been_made
    end

    context 'failure' do
      let(:district_names) { [] }

      it 'returns proper district_name' do
        expect { subject }.to raise_error(::Yandex::NotFoundError)
        expect(request).to have_been_made
      end
    end
  end
end
