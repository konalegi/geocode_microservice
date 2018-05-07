# frozen_string_literal: true

describe Google::MapsApiClient do
  include Mocks::Google::MapsApi
  let(:lattitude) { 10 }
  let(:longitude) { 12 }

  describe '.geocode' do
    subject { described_class.geocode(address: address) }
    let(:address) { SecureRandom.hex }
    let(:city) { SecureRandom.hex }

    let!(:request) do
      mock_google_api_maps_geocode_request(address: address,
                                           city: city,
                                           lattitude: lattitude,
                                           longitude: longitude,
                                           status: status)
    end

    context 'success' do
      let(:status) { 'OK' }

      it 'proper location' do
        expect(subject).to eq(longitude: longitude, lattitude: lattitude, city: city)
        expect(request).to have_been_made
      end
    end

    context 'failure' do
      context 'when not found' do
        let(:status) { 'ZERO_RESULTS' }

        it 'raises error' do
          expect { subject }.to raise_error(Google::NotFoundError)
          expect(request).to have_been_made
        end
      end

      context 'when city not found' do
        let(:status) { 'OK' }
        let(:city) { nil }

        it 'not raises error' do
          expect { subject }.not_to raise_error
          expect(request).to have_been_made
        end
      end

      context 'when connection error' do
        let(:status) { 'REQUEST_DENIED' }

        it 'raises error' do
          expect { subject }.to raise_error(Google::ClientConnectionError)
          expect(request).to have_been_made
        end
      end

      context 'when empty response error' do
        let(:status) { nil }

        it 'raises error' do
          expect { subject }.to raise_error(Google::EmptyResponseError)
          expect(request).to have_been_made
        end
      end
    end
  end

  describe '.city_disctict' do
    let(:district_names) { [SecureRandom.hex, SecureRandom.hex] }
    let!(:request) do
      mock_google_api_maps_city_district_request(names: district_names,
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
  end
end
