# frozen_string_literal: true

describe Google::PlacesApiClient do
  include Mocks::Google::PlacesApi

  subject { described_class.find_nearest_subway_name(longitude: 10, lattitude: 10) }
  let(:metro_station_name) { SecureRandom.hex }
  let!(:request) { mock_google_api_places_request(name: metro_station_name, status: status) }

  context 'success' do
    let(:status) { 'OK' }
    let!(:request) { mock_google_api_places_request(name: metro_station_name) }

    it 'returns nearest subway' do
      expect(subject).to eq(metro_station_name)
      expect(request).to have_been_made
    end
  end

  context 'failure' do
    context 'when not found' do
      let(:status) { 'ZERO_RESULTS' }

      it 'raises error' do
        expect { subject }.to raise_error(::Google::NotFoundError)
        expect(request).to have_been_made
      end
    end

    context 'when connection error' do
      let(:status) { 'REQUEST_DENIED' }

      it 'raises error' do
        expect { subject }.to raise_error(::Google::ClientConnectionError)
        expect(request).to have_been_made
      end
    end
  end
end
